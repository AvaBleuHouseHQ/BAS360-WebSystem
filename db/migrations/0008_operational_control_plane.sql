-- Archemedica operational control-plane hardening
-- Corrective basis: ARC-PERSIST-OQ-002 initial execution / ARC-DEV-006
-- Status: CONTROLLED IMPLEMENTATION / NOT PRODUCTION QUALIFIED

BEGIN;

-- ============================================================================
-- A. Transaction-local request context (corrects OQ2-14 supported runtime path)
-- ============================================================================
CREATE OR REPLACE FUNCTION archemedica_security.establish_request_context(
    p_tenant_id uuid,
    p_actor_principal text,
    p_correlation_id text
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, archemedica_security, pg_temp
AS $$
BEGIN
    IF p_tenant_id IS NULL OR p_actor_principal IS NULL OR btrim(p_actor_principal) = ''
       OR p_correlation_id IS NULL OR btrim(p_correlation_id) = '' THEN
        RAISE EXCEPTION 'ARC_AUTH_CONTEXT_INVALID: tenant, actor and correlation are required'
            USING ERRCODE='42501';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM public.tenant WHERE tenant_id = p_tenant_id AND status = 'ACTIVE') THEN
        RAISE EXCEPTION 'ARC_AUTH_TENANT_NOT_ACTIVE_OR_UNKNOWN' USING ERRCODE='42501';
    END IF;

    -- true => transaction-local. Context disappears automatically at COMMIT/ROLLBACK.
    PERFORM set_config('archemedica.tenant_id', p_tenant_id::text, true);
    PERFORM set_config('archemedica.actor_principal', p_actor_principal, true);
    PERFORM set_config('archemedica.correlation_id', p_correlation_id, true);
END;
$$;
REVOKE ALL ON FUNCTION archemedica_security.establish_request_context(uuid,text,text) FROM PUBLIC;

-- ============================================================================
-- B. Atomic idempotent command intake / business-effect binding (OQ2-02)
-- ============================================================================
ALTER TABLE idempotency_record
    ADD COLUMN IF NOT EXISTS request_hash text,
    ADD COLUMN IF NOT EXISTS completed_at timestamptz;

CREATE OR REPLACE FUNCTION begin_idempotent_command(
    p_idempotency_key text,
    p_command_type text,
    p_request_hash text
)
RETURNS idempotency_record
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, archemedica_security, pg_temp
AS $$
DECLARE
    t uuid := archemedica_security.current_tenant_id();
    rec idempotency_record;
BEGIN
    INSERT INTO idempotency_record(tenant_id,idempotency_key,command_type,request_hash,status)
    VALUES(t,p_idempotency_key,p_command_type,p_request_hash,'IN_PROGRESS')
    ON CONFLICT (tenant_id,idempotency_key) DO NOTHING;

    SELECT * INTO rec
      FROM idempotency_record
     WHERE tenant_id=t AND idempotency_key=p_idempotency_key
     FOR UPDATE;

    IF rec.command_type <> p_command_type OR rec.request_hash IS DISTINCT FROM p_request_hash THEN
        RAISE EXCEPTION 'ARC_IDEMPOTENCY_KEY_REUSE_MISMATCH' USING ERRCODE='23505';
    END IF;

    RETURN rec;
END;
$$;

CREATE OR REPLACE FUNCTION complete_idempotent_command(
    p_idempotency_key text,
    p_business_effect_ref text
)
RETURNS idempotency_record
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, archemedica_security, pg_temp
AS $$
DECLARE
    t uuid := archemedica_security.current_tenant_id();
    rec idempotency_record;
BEGIN
    SELECT * INTO rec FROM idempotency_record
     WHERE tenant_id=t AND idempotency_key=p_idempotency_key
     FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION 'ARC_IDEMPOTENCY_RECORD_NOT_FOUND'; END IF;

    IF rec.status='COMPLETED' THEN
        IF rec.business_effect_ref IS DISTINCT FROM p_business_effect_ref THEN
            RAISE EXCEPTION 'ARC_IDEMPOTENCY_EFFECT_MISMATCH' USING ERRCODE='23505';
        END IF;
        RETURN rec;
    END IF;

    UPDATE idempotency_record
       SET business_effect_ref=p_business_effect_ref,
           status='COMPLETED', completed_at=now(), updated_at=now()
     WHERE tenant_id=t AND idempotency_key=p_idempotency_key
     RETURNING * INTO rec;
    RETURN rec;
END;
$$;
REVOKE ALL ON FUNCTION begin_idempotent_command(text,text,text) FROM PUBLIC;
REVOKE ALL ON FUNCTION complete_idempotent_command(text,text) FROM PUBLIC;

-- ============================================================================
-- C. Consumer-side delivery deduplication (OQ2-03)
-- ============================================================================
CREATE TABLE consumer_delivery_record (
    tenant_id uuid NOT NULL REFERENCES tenant(tenant_id),
    consumer_name text NOT NULL,
    outbox_event_id uuid NOT NULL REFERENCES outbox_event(outbox_event_id),
    effect_ref text,
    first_seen_at timestamptz NOT NULL DEFAULT now(),
    completed_at timestamptz,
    status text NOT NULL CHECK(status IN ('RECEIVED','COMPLETED','RECONCILIATION_REQUIRED','FAILED')),
    PRIMARY KEY(tenant_id,consumer_name,outbox_event_id)
);
ALTER TABLE consumer_delivery_record ENABLE ROW LEVEL SECURITY;
ALTER TABLE consumer_delivery_record FORCE ROW LEVEL SECURITY;
CREATE POLICY consumer_delivery_tenant_isolation ON consumer_delivery_record
FOR ALL USING (tenant_id=archemedica_security.current_tenant_id())
WITH CHECK (tenant_id=archemedica_security.current_tenant_id());
CREATE TRIGGER trg_consumer_delivery_reject_tenant_reassignment
BEFORE UPDATE OF tenant_id ON consumer_delivery_record
FOR EACH ROW EXECUTE FUNCTION archemedica_security.reject_tenant_reassignment();

CREATE OR REPLACE FUNCTION register_consumer_delivery(
    p_consumer_name text,
    p_outbox_event_id uuid,
    p_effect_ref text DEFAULT NULL
)
RETURNS consumer_delivery_record
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path=public,archemedica_security,pg_temp
AS $$
DECLARE
    t uuid := archemedica_security.current_tenant_id();
    rec consumer_delivery_record;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM outbox_event WHERE outbox_event_id=p_outbox_event_id AND tenant_id=t) THEN
        RAISE EXCEPTION 'ARC_OUTBOX_EVENT_NOT_FOUND_OR_NOT_AUTHORIZED' USING ERRCODE='42501';
    END IF;

    INSERT INTO consumer_delivery_record(tenant_id,consumer_name,outbox_event_id,effect_ref,status)
    VALUES(t,p_consumer_name,p_outbox_event_id,p_effect_ref,'RECEIVED')
    ON CONFLICT (tenant_id,consumer_name,outbox_event_id) DO NOTHING;

    SELECT * INTO rec FROM consumer_delivery_record
     WHERE tenant_id=t AND consumer_name=p_consumer_name AND outbox_event_id=p_outbox_event_id;
    RETURN rec;
END;
$$;
REVOKE ALL ON FUNCTION register_consumer_delivery(text,uuid,text) FROM PUBLIC;

-- ============================================================================
-- D. Controlled outbox claim / reconciliation (OQ2-05)
-- ============================================================================
ALTER TABLE outbox_event
    ADD COLUMN IF NOT EXISTS claimed_at timestamptz,
    ADD COLUMN IF NOT EXISTS claimed_by text,
    ADD COLUMN IF NOT EXISTS delivery_attempts integer NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS last_error text;

CREATE OR REPLACE FUNCTION claim_outbox_event(p_outbox_event_id uuid)
RETURNS outbox_event
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path=public,archemedica_security,pg_temp
AS $$
DECLARE
    t uuid := archemedica_security.current_tenant_id();
    actor text := archemedica_security.current_actor_principal();
    rec outbox_event;
BEGIN
    SELECT * INTO rec FROM outbox_event
     WHERE outbox_event_id=p_outbox_event_id AND tenant_id=t
     FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION 'ARC_OUTBOX_NOT_FOUND_OR_NOT_AUTHORIZED' USING ERRCODE='42501'; END IF;
    IF rec.status NOT IN ('PENDING','RECONCILIATION_REQUIRED','FAILED') THEN
        RETURN rec;
    END IF;
    UPDATE outbox_event
       SET status='PROCESSING', claimed_at=now(), claimed_by=actor,
           delivery_attempts=delivery_attempts+1
     WHERE outbox_event_id=p_outbox_event_id
     RETURNING * INTO rec;
    RETURN rec;
END;
$$;

CREATE OR REPLACE FUNCTION mark_outbox_reconciliation(p_outbox_event_id uuid,p_error text)
RETURNS outbox_event
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path=public,archemedica_security,pg_temp
AS $$
DECLARE t uuid := archemedica_security.current_tenant_id(); rec outbox_event;
BEGIN
    UPDATE outbox_event
       SET status='RECONCILIATION_REQUIRED', last_error=p_error
     WHERE outbox_event_id=p_outbox_event_id AND tenant_id=t
     RETURNING * INTO rec;
    IF NOT FOUND THEN RAISE EXCEPTION 'ARC_OUTBOX_NOT_FOUND_OR_NOT_AUTHORIZED' USING ERRCODE='42501'; END IF;
    RETURN rec;
END;
$$;
REVOKE ALL ON FUNCTION claim_outbox_event(uuid) FROM PUBLIC;
REVOKE ALL ON FUNCTION mark_outbox_reconciliation(uuid,text) FROM PUBLIC;

-- ============================================================================
-- E. Safety/quality hold precedence (OQ2-06)
-- ============================================================================
CREATE TABLE decision_hold (
    hold_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id uuid NOT NULL REFERENCES tenant(tenant_id),
    der_id uuid NOT NULL REFERENCES decision_evidence_record(der_id),
    hold_type text NOT NULL CHECK(hold_type IN ('SAFETY','QUALITY','REGULATORY','DATA_INTEGRITY','OTHER')),
    hold_state text NOT NULL CHECK(hold_state IN ('OPEN','RELEASED','SUPERSEDED')) DEFAULT 'OPEN',
    reason text NOT NULL,
    opened_by text NOT NULL,
    opened_at timestamptz NOT NULL DEFAULT now(),
    released_by text,
    released_at timestamptz
);
CREATE INDEX idx_decision_hold_open ON decision_hold(tenant_id,der_id,hold_state);
ALTER TABLE decision_hold ENABLE ROW LEVEL SECURITY;
ALTER TABLE decision_hold FORCE ROW LEVEL SECURITY;
CREATE POLICY decision_hold_tenant_isolation ON decision_hold
FOR ALL USING (tenant_id=archemedica_security.current_tenant_id())
WITH CHECK (tenant_id=archemedica_security.current_tenant_id());
CREATE TRIGGER trg_decision_hold_reject_tenant_reassignment
BEFORE UPDATE OF tenant_id ON decision_hold
FOR EACH ROW EXECUTE FUNCTION archemedica_security.reject_tenant_reassignment();

CREATE OR REPLACE FUNCTION archemedica_security.assert_transition_precedence(p_der_id uuid,p_new_state text)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path=public,archemedica_security,pg_temp
AS $$
DECLARE t uuid := archemedica_security.current_tenant_id();
BEGIN
    IF upper(p_new_state) IN ('APPROVED','COMPLETE','CLOSED','READY')
       AND EXISTS (SELECT 1 FROM decision_hold WHERE tenant_id=t AND der_id=p_der_id AND hold_state='OPEN') THEN
        RAISE EXCEPTION 'ARC_ACTIVE_HOLD_BLOCKS_CLOSURE' USING ERRCODE='23514';
    END IF;
END;
$$;
REVOKE ALL ON FUNCTION archemedica_security.assert_transition_precedence(uuid,text) FROM PUBLIC;

-- Replace controlled DER transition to include hold precedence.
CREATE OR REPLACE FUNCTION transition_der_state(
    p_der_id uuid,
    p_expected_revision bigint,
    p_new_state text,
    p_reason text,
    p_causal_episode_id uuid DEFAULT NULL
)
RETURNS decision_evidence_record
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, archemedica_security, pg_temp
AS $$
DECLARE
    rec decision_evidence_record;
    prior_state text;
    prior_revision bigint;
    active_tenant uuid;
    actor text;
    corr text;
BEGIN
    active_tenant := archemedica_security.current_tenant_id();
    actor := archemedica_security.current_actor_principal();
    corr := archemedica_security.current_correlation_id();

    SELECT * INTO rec FROM decision_evidence_record
     WHERE der_id=p_der_id AND tenant_id=active_tenant FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION 'ARC_DER_NOT_FOUND_OR_NOT_AUTHORIZED' USING ERRCODE='42501'; END IF;

    prior_state := rec.decision_state;
    prior_revision := rec.revision;
    PERFORM archemedica_security.assert_expected_revision(prior_revision,p_expected_revision,'DER '||p_der_id::text);
    PERFORM archemedica_security.assert_transition_precedence(p_der_id,p_new_state);

    IF upper(p_new_state) IN ('APPROVED','COMPLETE','CLOSED','READY')
       AND upper(coalesce(rec.unresolved_state,'UNKNOWN')) NOT IN ('RESOLVED','NONE','NOT_APPLICABLE') THEN
        RAISE EXCEPTION 'ARC_NO_FALSE_CLOSURE: DER unresolved_state=%',rec.unresolved_state USING ERRCODE='23514';
    END IF;

    UPDATE decision_evidence_record SET decision_state=p_new_state,revision=revision+1,updated_at=now()
     WHERE der_id=p_der_id RETURNING * INTO rec;

    INSERT INTO state_transition_event(tenant_id,object_type,object_id,from_revision,to_revision,from_state,to_state,actor_principal,reason,correlation_id,causal_episode_id)
    VALUES(active_tenant,'DER',p_der_id,prior_revision,rec.revision,prior_state,p_new_state,actor,p_reason,corr,p_causal_episode_id);
    INSERT INTO audit_event(tenant_id,actor_principal,action,object_type,object_id,object_revision,reason,causal_episode_id,correlation_key,authorization_context,outcome)
    VALUES(active_tenant,actor,'STATE_TRANSITION','DER',p_der_id,rec.revision,p_reason,p_causal_episode_id,corr,jsonb_build_object('tenant_id',active_tenant,'actor_principal',actor),'SUCCESS');
    INSERT INTO outbox_event(tenant_id,event_type,aggregate_type,aggregate_id,causal_episode_id,payload)
    VALUES(active_tenant,'DER_STATE_CHANGED','DER',p_der_id,p_causal_episode_id,jsonb_build_object('from_state',prior_state,'to_state',p_new_state,'from_revision',prior_revision,'to_revision',rec.revision,'correlation_id',corr));
    RETURN rec;
END;
$$;
REVOKE ALL ON FUNCTION transition_der_state(uuid,bigint,text,text,uuid) FROM PUBLIC;

-- ============================================================================
-- F. Causal episode open-or-reuse / dedup (OQ2-07, OQ2-08)
-- ============================================================================
CREATE UNIQUE INDEX IF NOT EXISTS uq_open_reassessment_root
ON reassessment_episode(tenant_id,root_trigger_type,root_trigger_id)
WHERE status='OPEN';

CREATE OR REPLACE FUNCTION open_or_reuse_reassessment_episode(
    p_root_trigger_type text,
    p_root_trigger_id uuid,
    p_parent_event_id uuid DEFAULT NULL
)
RETURNS reassessment_episode
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path=public,archemedica_security,pg_temp
AS $$
DECLARE t uuid := archemedica_security.current_tenant_id(); rec reassessment_episode;
BEGIN
    SELECT * INTO rec FROM reassessment_episode
     WHERE tenant_id=t AND root_trigger_type=p_root_trigger_type AND root_trigger_id=p_root_trigger_id AND status='OPEN'
     ORDER BY opened_at LIMIT 1;
    IF FOUND THEN RETURN rec; END IF;

    BEGIN
        INSERT INTO reassessment_episode(tenant_id,root_trigger_type,root_trigger_id,parent_event_id,status)
        VALUES(t,p_root_trigger_type,p_root_trigger_id,p_parent_event_id,'OPEN')
        RETURNING * INTO rec;
        RETURN rec;
    EXCEPTION WHEN unique_violation THEN
        SELECT * INTO rec FROM reassessment_episode
         WHERE tenant_id=t AND root_trigger_type=p_root_trigger_type AND root_trigger_id=p_root_trigger_id AND status='OPEN'
         ORDER BY opened_at LIMIT 1;
        RETURN rec;
    END;
END;
$$;
REVOKE ALL ON FUNCTION open_or_reuse_reassessment_episode(text,uuid,uuid) FROM PUBLIC;

-- ============================================================================
-- G. Contextual dependency impact / anti-false-cascade (OQ2-09)
-- ============================================================================
CREATE TABLE dependency_impact_assessment (
    impact_assessment_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id uuid NOT NULL REFERENCES tenant(tenant_id),
    dep_id uuid NOT NULL REFERENCES dependency_edge(dep_id),
    trigger_object_type text NOT NULL,
    trigger_object_id uuid NOT NULL,
    impact_state text NOT NULL CHECK(impact_state IN (
      'NOT_MATERIALLY_AFFECTED','POTENTIALLY_AFFECTED','REASSESSMENT_REQUIRED','UNKNOWN','STALE'
    )),
    basis text NOT NULL,
    assessed_at timestamptz NOT NULL DEFAULT now(),
    assessed_by text NOT NULL,
    UNIQUE(tenant_id,dep_id,trigger_object_type,trigger_object_id)
);
ALTER TABLE dependency_impact_assessment ENABLE ROW LEVEL SECURITY;
ALTER TABLE dependency_impact_assessment FORCE ROW LEVEL SECURITY;
CREATE POLICY dependency_impact_tenant_isolation ON dependency_impact_assessment
FOR ALL USING(tenant_id=archemedica_security.current_tenant_id())
WITH CHECK(tenant_id=archemedica_security.current_tenant_id());

CREATE OR REPLACE FUNCTION evaluate_dependency_impact(p_dep_id uuid,p_trigger_object_id uuid)
RETURNS dependency_impact_assessment
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path=public,archemedica_security,pg_temp
AS $$
DECLARE
 t uuid := archemedica_security.current_tenant_id();
 actor text := archemedica_security.current_actor_principal();
 d dependency_edge;
 s text;
 rationale text;
 rec dependency_impact_assessment;
BEGIN
 SELECT * INTO d FROM dependency_edge WHERE dep_id=p_dep_id AND tenant_id=t;
 IF NOT FOUND THEN RAISE EXCEPTION 'ARC_DEPENDENCY_NOT_FOUND_OR_NOT_AUTHORIZED' USING ERRCODE='42501'; END IF;

 IF d.status='REJECTED' THEN s:='NOT_MATERIALLY_AFFECTED'; rationale:='dependency rejected';
 ELSIF d.status IN ('UNKNOWN','ASSERTED') OR upper(coalesce(d.materiality,'UNKNOWN'))='UNKNOWN' OR upper(coalesce(d.confidence_state,'UNKNOWN'))='UNKNOWN' THEN
   s:='UNKNOWN'; rationale:='dependency support/materiality insufficient';
 ELSIF d.status='CONFIRMED' AND upper(d.materiality) IN ('HIGH','MATERIAL','CRITICAL') THEN
   s:='REASSESSMENT_REQUIRED'; rationale:='confirmed material dependency';
 ELSE
   s:='POTENTIALLY_AFFECTED'; rationale:='connected dependency without demonstrated material impact';
 END IF;

 INSERT INTO dependency_impact_assessment(tenant_id,dep_id,trigger_object_type,trigger_object_id,impact_state,basis,assessed_by)
 VALUES(t,p_dep_id,d.source_type,p_trigger_object_id,s,rationale,actor)
 ON CONFLICT(tenant_id,dep_id,trigger_object_type,trigger_object_id)
 DO UPDATE SET impact_state=EXCLUDED.impact_state,basis=EXCLUDED.basis,assessed_at=now(),assessed_by=EXCLUDED.assessed_by
 RETURNING * INTO rec;
 RETURN rec;
END;
$$;
REVOKE ALL ON FUNCTION evaluate_dependency_impact(uuid,uuid) FROM PUBLIC;

-- ============================================================================
-- H. Requirement supersession currency without blanket closure (OQ2-11)
-- ============================================================================
ALTER TABLE regulatory_applicability
  ADD COLUMN IF NOT EXISTS currency_state text NOT NULL DEFAULT 'CURRENT'
    CHECK(currency_state IN ('CURRENT','STALE','UNKNOWN','SUPERSEDED'));

CREATE TABLE requirement_supersession_impact (
    impact_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id uuid NOT NULL REFERENCES tenant(tenant_id),
    prior_req_id uuid NOT NULL REFERENCES controlled_requirement(req_id),
    successor_req_id uuid NOT NULL REFERENCES controlled_requirement(req_id),
    rsa_id uuid NOT NULL REFERENCES regulatory_applicability(rsa_id),
    prior_currency_state text NOT NULL,
    new_currency_state text NOT NULL,
    recorded_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE(tenant_id,successor_req_id,rsa_id)
);
ALTER TABLE requirement_supersession_impact ENABLE ROW LEVEL SECURITY;
ALTER TABLE requirement_supersession_impact FORCE ROW LEVEL SECURITY;
CREATE POLICY req_supersession_impact_tenant_isolation ON requirement_supersession_impact
FOR ALL USING(tenant_id=archemedica_security.current_tenant_id())
WITH CHECK(tenant_id=archemedica_security.current_tenant_id());

CREATE OR REPLACE FUNCTION propagate_requirement_supersession(p_prior_req_id uuid,p_successor_req_id uuid)
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path=public,archemedica_security,pg_temp
AS $$
DECLARE t uuid := archemedica_security.current_tenant_id(); n integer;
BEGIN
 IF NOT EXISTS (SELECT 1 FROM controlled_requirement WHERE req_id=p_successor_req_id AND supersedes_req_id=p_prior_req_id) THEN
   RAISE EXCEPTION 'ARC_INVALID_REQUIREMENT_SUCCESSOR';
 END IF;

 WITH affected AS (
   SELECT rsa_id,currency_state FROM regulatory_applicability
    WHERE tenant_id=t AND req_id=p_prior_req_id
 ), ins AS (
   INSERT INTO requirement_supersession_impact(tenant_id,prior_req_id,successor_req_id,rsa_id,prior_currency_state,new_currency_state)
   SELECT t,p_prior_req_id,p_successor_req_id,rsa_id,currency_state,'STALE' FROM affected
   ON CONFLICT DO NOTHING RETURNING rsa_id
 )
 UPDATE regulatory_applicability r SET currency_state='STALE',revision=revision+1,updated_at=now()
 WHERE r.tenant_id=t AND r.req_id=p_prior_req_id;
 GET DIAGNOSTICS n = ROW_COUNT;
 RETURN n;
END;
$$;
REVOKE ALL ON FUNCTION propagate_requirement_supersession(uuid,uuid) FROM PUBLIC;

-- ============================================================================
-- I. Single-authoritative-successor constraints (OQ2-15)
-- ============================================================================
CREATE UNIQUE INDEX IF NOT EXISTS uq_program_single_successor ON development_program(tenant_id,supersedes_program_id) WHERE supersedes_program_id IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS uq_rps_single_successor ON regulated_product_system(tenant_id,supersedes_rps_id) WHERE supersedes_rps_id IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS uq_cpt_single_successor ON constituent_part(tenant_id,supersedes_cpt_id) WHERE supersedes_cpt_id IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS uq_cfg_single_successor ON product_configuration(tenant_id,supersedes_cfg_id) WHERE supersedes_cfg_id IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS uq_lco_single_successor ON lifecycle_control_object(tenant_id,supersedes_lco_id) WHERE supersedes_lco_id IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS uq_rsa_single_successor ON regulatory_applicability(tenant_id,supersedes_rsa_id) WHERE supersedes_rsa_id IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS uq_der_single_successor ON decision_evidence_record(tenant_id,supersedes_der_id) WHERE supersedes_der_id IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS uq_study_single_successor ON study_investigation(tenant_id,supersedes_study_id) WHERE supersedes_study_id IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS uq_protocol_single_successor ON protocol_plan(tenant_id,supersedes_protocol_id) WHERE supersedes_protocol_id IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS uq_change_single_successor ON controlled_change(tenant_id,supersedes_change_id) WHERE supersedes_change_id IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS uq_risk_single_successor ON integrated_risk(tenant_id,supersedes_risk_id) WHERE supersedes_risk_id IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS uq_eig_single_successor ON evidence_integrity_assessment(tenant_id,supersedes_eig_id) WHERE supersedes_eig_id IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS uq_muse_single_successor ON model_algorithm_use(tenant_id,supersedes_muse_id) WHERE supersedes_muse_id IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS uq_signal_single_successor ON safety_quality_signal(tenant_id,supersedes_signal_id) WHERE supersedes_signal_id IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS uq_supplier_single_successor ON supplier_external_dependency(tenant_id,supersedes_supplier_dependency_id) WHERE supersedes_supplier_dependency_id IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS uq_obligation_single_successor ON obligation(tenant_id,supersedes_obligation_id) WHERE supersedes_obligation_id IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS uq_impl_state_single_successor ON implementation_effective_state(tenant_id,supersedes_implementation_state_id) WHERE supersedes_implementation_state_id IS NOT NULL;

COMMIT;

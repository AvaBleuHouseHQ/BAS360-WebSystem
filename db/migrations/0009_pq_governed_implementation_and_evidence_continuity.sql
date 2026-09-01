-- Archemedica PQ governed implementation and decision-evidence continuity
-- Qualification basis: ARC-PERSIST-PQ-003 v1.0
-- Status: CONTROLLED IMPLEMENTATION / NOT PRODUCTION QUALIFIED

BEGIN;

-- Decision-time evidence links must be unique so one canonical snapshot is reused.
CREATE UNIQUE INDEX IF NOT EXISTS uq_controlled_evidence_link_once
ON controlled_evidence_link(tenant_id, evs_id, target_type, target_id, relationship_type);

-- Decision evidence is explicitly linked to the causal episode and integrated risk.
ALTER TABLE decision_evidence_record
    ADD COLUMN IF NOT EXISTS causal_episode_id uuid NULL REFERENCES reassessment_episode(episode_id),
    ADD COLUMN IF NOT EXISTS risk_id uuid NULL REFERENCES integrated_risk(risk_id);

CREATE INDEX IF NOT EXISTS idx_der_episode ON decision_evidence_record(tenant_id, causal_episode_id);
CREATE INDEX IF NOT EXISTS idx_der_risk ON decision_evidence_record(tenant_id, risk_id);

-- Tenant-integrity checks for the newly introduced DER relationships.
CREATE OR REPLACE FUNCTION archemedica_security.assert_der_extended_refs_same_tenant()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path=pg_catalog,public,archemedica_security,pg_temp
AS $$
BEGIN
    IF NEW.causal_episode_id IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM public.reassessment_episode x
        WHERE x.episode_id=NEW.causal_episode_id AND x.tenant_id=NEW.tenant_id
    ) THEN
        RAISE EXCEPTION 'ARC_CROSS_TENANT_DER_EPISODE_REFERENCE' USING ERRCODE='42501';
    END IF;
    IF NEW.risk_id IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM public.integrated_risk x
        WHERE x.risk_id=NEW.risk_id AND x.tenant_id=NEW.tenant_id
    ) THEN
        RAISE EXCEPTION 'ARC_CROSS_TENANT_DER_RISK_REFERENCE' USING ERRCODE='42501';
    END IF;
    RETURN NEW;
END;
$$;
REVOKE ALL ON FUNCTION archemedica_security.assert_der_extended_refs_same_tenant() FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_der_extended_refs_same_tenant ON decision_evidence_record;
CREATE TRIGGER trg_der_extended_refs_same_tenant
BEFORE INSERT OR UPDATE OF tenant_id,causal_episode_id,risk_id ON decision_evidence_record
FOR EACH ROW EXECUTE FUNCTION archemedica_security.assert_der_extended_refs_same_tenant();

-- Governed implementation-state transition. READY/EFFECTIVE require objective evidence
-- and are blocked by an open hold on the controlling DER.
CREATE OR REPLACE FUNCTION transition_implementation_state(
    p_implementation_state_id uuid,
    p_expected_revision bigint,
    p_new_state text,
    p_objective_evidence_id uuid,
    p_controlling_der_id uuid,
    p_reason text
)
RETURNS implementation_effective_state
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path=public,archemedica_security,pg_temp
AS $$
DECLARE
    t uuid := archemedica_security.current_tenant_id();
    actor text := archemedica_security.current_actor_principal();
    corr text := archemedica_security.current_correlation_id();
    rec implementation_effective_state;
    prior_state text;
    prior_revision bigint;
BEGIN
    SELECT * INTO rec FROM implementation_effective_state
    WHERE implementation_state_id=p_implementation_state_id AND tenant_id=t
    FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION 'ARC_IMPLEMENTATION_STATE_NOT_FOUND_OR_NOT_AUTHORIZED' USING ERRCODE='42501'; END IF;

    prior_state := rec.state;
    prior_revision := rec.revision;
    PERFORM archemedica_security.assert_expected_revision(prior_revision,p_expected_revision,'IMPLEMENTATION_STATE '||p_implementation_state_id::text);

    IF upper(p_new_state) IN ('READY','EFFECTIVE') THEN
        IF p_objective_evidence_id IS NULL OR NOT EXISTS (
            SELECT 1 FROM evidence_snapshot e
            WHERE e.evs_id=p_objective_evidence_id AND e.tenant_id=t
              AND e.reconstruction_state IN ('RECONSTRUCTABLE','BOUNDED_LIMITATION')
        ) THEN
            RAISE EXCEPTION 'ARC_IMPLEMENTATION_EVIDENCE_REQUIRED' USING ERRCODE='23514';
        END IF;
        IF p_controlling_der_id IS NULL OR NOT EXISTS (
            SELECT 1 FROM decision_evidence_record d
            WHERE d.der_id=p_controlling_der_id AND d.tenant_id=t
              AND upper(d.decision_state) IN ('APPROVED','READY','COMPLETE','CLOSED')
              AND upper(coalesce(d.unresolved_state,'UNKNOWN')) IN ('RESOLVED','NONE','NOT_APPLICABLE')
        ) THEN
            RAISE EXCEPTION 'ARC_IMPLEMENTATION_CONTROLLING_DECISION_NOT_READY' USING ERRCODE='23514';
        END IF;
        IF EXISTS (
            SELECT 1 FROM decision_hold h
            WHERE h.tenant_id=t AND h.der_id=p_controlling_der_id AND h.hold_state='OPEN'
        ) THEN
            RAISE EXCEPTION 'ARC_ACTIVE_HOLD_BLOCKS_IMPLEMENTATION' USING ERRCODE='23514';
        END IF;
    END IF;

    UPDATE implementation_effective_state
       SET state=upper(p_new_state), objective_evidence_id=p_objective_evidence_id,
           effective_at=CASE WHEN upper(p_new_state)='EFFECTIVE' THEN now() ELSE effective_at END,
           revision=revision+1, updated_at=now()
     WHERE implementation_state_id=p_implementation_state_id
     RETURNING * INTO rec;

    INSERT INTO state_transition_event(
      tenant_id,object_type,object_id,from_revision,to_revision,from_state,to_state,
      actor_principal,reason,correlation_id,causal_episode_id
    ) VALUES(
      t,'IMPLEMENTATION_STATE',p_implementation_state_id,prior_revision,rec.revision,prior_state,rec.state,
      actor,p_reason,corr,NULL
    );
    INSERT INTO audit_event(
      tenant_id,actor_principal,action,object_type,object_id,object_revision,reason,
      correlation_key,authorization_context,outcome
    ) VALUES(
      t,actor,'STATE_TRANSITION','IMPLEMENTATION_STATE',p_implementation_state_id,rec.revision,p_reason,
      corr,jsonb_build_object('tenant_id',t,'actor_principal',actor),'SUCCESS'
    );
    INSERT INTO outbox_event(tenant_id,event_type,aggregate_type,aggregate_id,payload)
    VALUES(t,'IMPLEMENTATION_STATE_CHANGED','IMPLEMENTATION_STATE',p_implementation_state_id,
      jsonb_build_object('from_state',prior_state,'to_state',rec.state,'from_revision',prior_revision,'to_revision',rec.revision,'correlation_id',corr));
    RETURN rec;
END;
$$;
REVOKE ALL ON FUNCTION transition_implementation_state(uuid,bigint,text,uuid,uuid,text) FROM PUBLIC;

COMMIT;

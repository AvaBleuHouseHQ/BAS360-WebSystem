-- Archemedica expected-revision and state-transition controls
-- Integrated control basis: ARC-SYS-HARDEN-001 / Single-Reality State & Concurrency
-- Status: CONTROLLED IMPLEMENTATION / NOT PRODUCTION QUALIFIED

BEGIN;

CREATE TABLE state_transition_event (
    transition_event_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id uuid NOT NULL REFERENCES tenant(tenant_id),
    object_type text NOT NULL,
    object_id uuid NOT NULL,
    from_revision bigint NOT NULL,
    to_revision bigint NOT NULL,
    from_state text,
    to_state text,
    actor_principal text NOT NULL,
    reason text,
    correlation_id text NOT NULL,
    causal_episode_id uuid NULL REFERENCES reassessment_episode(rae_id),
    occurred_at timestamptz NOT NULL DEFAULT now(),
    CHECK (to_revision = from_revision + 1)
);

ALTER TABLE state_transition_event ENABLE ROW LEVEL SECURITY;
ALTER TABLE state_transition_event FORCE ROW LEVEL SECURITY;
CREATE POLICY state_transition_event_tenant_isolation ON state_transition_event
FOR ALL USING (tenant_id = archemedica_security.current_tenant_id())
WITH CHECK (tenant_id = archemedica_security.current_tenant_id());
CREATE TRIGGER trg_state_transition_event_reject_tenant_reassignment
BEFORE UPDATE OF tenant_id ON state_transition_event
FOR EACH ROW EXECUTE FUNCTION archemedica_security.reject_tenant_reassignment();

CREATE INDEX idx_state_transition_object ON state_transition_event(tenant_id, object_type, object_id, occurred_at);

CREATE OR REPLACE FUNCTION archemedica_security.assert_expected_revision(actual_revision bigint, expected_revision bigint, object_ref text)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    IF expected_revision IS NULL OR actual_revision <> expected_revision THEN
        RAISE EXCEPTION 'ARC_STALE_WRITE_REJECTED: % expected %, actual %', object_ref, expected_revision, actual_revision
            USING ERRCODE='40001';
    END IF;
END;
$$;

-- Controlled DER transition: establishes the pattern for consequential state changes.
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

    SELECT * INTO rec
    FROM decision_evidence_record
    WHERE der_id = p_der_id AND tenant_id = active_tenant
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'ARC_DER_NOT_FOUND_OR_NOT_AUTHORIZED' USING ERRCODE='42501';
    END IF;

    prior_state := rec.decision_state;
    prior_revision := rec.revision;
    PERFORM archemedica_security.assert_expected_revision(prior_revision, p_expected_revision, 'DER ' || p_der_id::text);

    -- No silent clean closure while unresolved state remains material/unknown.
    IF upper(p_new_state) IN ('APPROVED','COMPLETE','CLOSED','READY')
       AND upper(coalesce(rec.unresolved_state,'UNKNOWN')) NOT IN ('RESOLVED','NONE','NOT_APPLICABLE') THEN
        RAISE EXCEPTION 'ARC_NO_FALSE_CLOSURE: DER unresolved_state=%', rec.unresolved_state USING ERRCODE='23514';
    END IF;

    UPDATE decision_evidence_record
    SET decision_state = p_new_state,
        revision = revision + 1,
        updated_at = now()
    WHERE der_id = p_der_id
    RETURNING * INTO rec;

    INSERT INTO state_transition_event(
        tenant_id, object_type, object_id, from_revision, to_revision, from_state, to_state,
        actor_principal, reason, correlation_id, causal_episode_id
    ) VALUES (
        active_tenant, 'DER', p_der_id, prior_revision, rec.revision, prior_state, p_new_state,
        actor, p_reason, corr, p_causal_episode_id
    );

    INSERT INTO audit_event(
        tenant_id, actor_principal, action, object_type, object_id, object_revision,
        reason, causal_episode_id, correlation_key, authorization_context, outcome
    ) VALUES (
        active_tenant, actor, 'STATE_TRANSITION', 'DER', p_der_id, rec.revision,
        p_reason, p_causal_episode_id, corr,
        jsonb_build_object('tenant_id',active_tenant,'actor_principal',actor), 'SUCCESS'
    );

    INSERT INTO outbox_event(
        tenant_id, event_type, aggregate_type, aggregate_id, causal_episode_id, payload
    ) VALUES (
        active_tenant, 'DER_STATE_CHANGED', 'DER', p_der_id, p_causal_episode_id,
        jsonb_build_object('from_state',prior_state,'to_state',p_new_state,'from_revision',prior_revision,'to_revision',rec.revision,'correlation_id',corr)
    );

    RETURN rec;
END;
$$;

REVOKE ALL ON FUNCTION transition_der_state(uuid,bigint,text,text,uuid) FROM PUBLIC;

-- Prevent direct revision decrement/skip on core controlled tables. Authorized functions may increment by exactly one.
CREATE OR REPLACE FUNCTION archemedica_security.enforce_monotonic_revision()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.revision <> OLD.revision + 1 THEN
        RAISE EXCEPTION 'ARC_INVALID_REVISION_TRANSITION: % -> %', OLD.revision, NEW.revision USING ERRCODE='23514';
    END IF;
    RETURN NEW;
END;
$$;

DO $$
DECLARE tbl text;
BEGIN
    FOREACH tbl IN ARRAY ARRAY[
        'development_program','regulated_product_system','constituent_part','product_configuration',
        'lifecycle_control_object','regulatory_applicability','decision_evidence_record',
        'study_investigation','protocol_plan','controlled_change','integrated_risk','evidence_integrity_assessment',
        'model_algorithm_use','safety_quality_signal','supplier_external_dependency','obligation','implementation_effective_state'
    ]
    LOOP
        EXECUTE format(
            'CREATE TRIGGER %I BEFORE UPDATE OF revision ON %I FOR EACH ROW EXECUTE FUNCTION archemedica_security.enforce_monotonic_revision()',
            'trg_' || tbl || '_monotonic_revision', tbl
        );
    END LOOP;
END $$;

COMMIT;

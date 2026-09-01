-- Archemedica tenant/session authorization and RLS controls
-- Change Control: ARC-CC-003
-- Security Contract: ARC-AUTH-001 v1.0
-- Status: CONTROLLED IMPLEMENTATION / NOT PRODUCTION QUALIFIED

BEGIN;

CREATE SCHEMA IF NOT EXISTS archemedica_security;

CREATE OR REPLACE FUNCTION archemedica_security.current_tenant_id()
RETURNS uuid
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    raw text;
BEGIN
    raw := current_setting('archemedica.tenant_id', true);
    IF raw IS NULL OR btrim(raw) = '' THEN
        RAISE EXCEPTION 'ARC_AUTH_CONTEXT_MISSING: archemedica.tenant_id is required'
            USING ERRCODE = '42501';
    END IF;
    BEGIN
        RETURN raw::uuid;
    EXCEPTION WHEN invalid_text_representation THEN
        RAISE EXCEPTION 'ARC_AUTH_CONTEXT_INVALID: archemedica.tenant_id is not a UUID'
            USING ERRCODE = '42501';
    END;
END;
$$;

CREATE OR REPLACE FUNCTION archemedica_security.current_actor_principal()
RETURNS text
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    raw text;
BEGIN
    raw := current_setting('archemedica.actor_principal', true);
    IF raw IS NULL OR btrim(raw) = '' THEN
        RAISE EXCEPTION 'ARC_AUTH_CONTEXT_MISSING: archemedica.actor_principal is required'
            USING ERRCODE = '42501';
    END IF;
    RETURN raw;
END;
$$;

CREATE OR REPLACE FUNCTION archemedica_security.current_correlation_id()
RETURNS text
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    raw text;
BEGIN
    raw := current_setting('archemedica.correlation_id', true);
    IF raw IS NULL OR btrim(raw) = '' THEN
        RAISE EXCEPTION 'ARC_AUTH_CONTEXT_MISSING: archemedica.correlation_id is required'
            USING ERRCODE = '42501';
    END IF;
    RETURN raw;
END;
$$;

CREATE OR REPLACE FUNCTION archemedica_security.tenant_matches(row_tenant uuid)
RETURNS boolean
LANGUAGE sql
STABLE
AS $$
    SELECT row_tenant = archemedica_security.current_tenant_id();
$$;

-- Tenant table is not a directory. Normal tenant-scoped access sees only active tenant.
ALTER TABLE tenant ENABLE ROW LEVEL SECURITY;
ALTER TABLE tenant FORCE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation_select ON tenant
    FOR SELECT
    USING (tenant_id = archemedica_security.current_tenant_id());

-- Force RLS on all tenant-scoped tables.
ALTER TABLE development_program FORCE ROW LEVEL SECURITY;
ALTER TABLE regulated_product_system FORCE ROW LEVEL SECURITY;
ALTER TABLE constituent_part FORCE ROW LEVEL SECURITY;
ALTER TABLE product_configuration FORCE ROW LEVEL SECURITY;
ALTER TABLE configuration_constituent FORCE ROW LEVEL SECURITY;
ALTER TABLE lifecycle_control_object FORCE ROW LEVEL SECURITY;
ALTER TABLE regulatory_applicability FORCE ROW LEVEL SECURITY;
ALTER TABLE decision_evidence_record FORCE ROW LEVEL SECURITY;
ALTER TABLE dependency_edge FORCE ROW LEVEL SECURITY;
ALTER TABLE dependency_coverage FORCE ROW LEVEL SECURITY;
ALTER TABLE reassessment_episode FORCE ROW LEVEL SECURITY;
ALTER TABLE idempotency_record FORCE ROW LEVEL SECURITY;
ALTER TABLE outbox_event FORCE ROW LEVEL SECURITY;
ALTER TABLE audit_event FORCE ROW LEVEL SECURITY;

-- Standard tenant isolation policies.
DO $$
DECLARE
    tbl text;
BEGIN
    FOREACH tbl IN ARRAY ARRAY[
        'development_program','regulated_product_system','constituent_part','product_configuration',
        'configuration_constituent','lifecycle_control_object','regulatory_applicability',
        'decision_evidence_record','dependency_edge','dependency_coverage','reassessment_episode',
        'idempotency_record','outbox_event'
    ]
    LOOP
        EXECUTE format(
            'CREATE POLICY %I ON %I FOR ALL USING (tenant_id = archemedica_security.current_tenant_id()) WITH CHECK (tenant_id = archemedica_security.current_tenant_id())',
            tbl || '_tenant_isolation', tbl
        );
    END LOOP;
END $$;

-- Audit rows may be tenant-scoped. Global/system audit rows are deliberately not visible to tenant runtime context.
CREATE POLICY audit_event_tenant_select ON audit_event
    FOR SELECT
    USING (tenant_id = archemedica_security.current_tenant_id());
CREATE POLICY audit_event_tenant_insert ON audit_event
    FOR INSERT
    WITH CHECK (tenant_id = archemedica_security.current_tenant_id());

-- Evidence snapshots are mixed shared/tenant scope.
ALTER TABLE evidence_snapshot ENABLE ROW LEVEL SECURITY;
ALTER TABLE evidence_snapshot FORCE ROW LEVEL SECURITY;
CREATE POLICY evidence_snapshot_read ON evidence_snapshot
    FOR SELECT
    USING (tenant_id IS NULL OR tenant_id = archemedica_security.current_tenant_id());
CREATE POLICY evidence_snapshot_write ON evidence_snapshot
    FOR INSERT
    WITH CHECK (tenant_id = archemedica_security.current_tenant_id());
CREATE POLICY evidence_snapshot_update ON evidence_snapshot
    FOR UPDATE
    USING (tenant_id = archemedica_security.current_tenant_id())
    WITH CHECK (tenant_id = archemedica_security.current_tenant_id());
CREATE POLICY evidence_snapshot_delete ON evidence_snapshot
    FOR DELETE
    USING (tenant_id = archemedica_security.current_tenant_id());

-- Prevent tenant-id reassignment on controlled rows.
CREATE OR REPLACE FUNCTION archemedica_security.reject_tenant_reassignment()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.tenant_id IS DISTINCT FROM OLD.tenant_id THEN
        RAISE EXCEPTION 'ARC_TENANT_REASSIGNMENT_PROHIBITED'
            USING ERRCODE = '42501';
    END IF;
    RETURN NEW;
END;
$$;

DO $$
DECLARE
    tbl text;
BEGIN
    FOREACH tbl IN ARRAY ARRAY[
        'development_program','regulated_product_system','constituent_part','product_configuration',
        'configuration_constituent','lifecycle_control_object','regulatory_applicability',
        'evidence_snapshot','decision_evidence_record','dependency_edge','dependency_coverage',
        'reassessment_episode','idempotency_record','outbox_event','audit_event'
    ]
    LOOP
        EXECUTE format(
            'CREATE TRIGGER %I BEFORE UPDATE OF tenant_id ON %I FOR EACH ROW EXECUTE FUNCTION archemedica_security.reject_tenant_reassignment()',
            'trg_' || tbl || '_reject_tenant_reassignment', tbl
        );
    END LOOP;
END $$;

-- Cross-table tenant consistency helpers for concrete foreign-key relationships.
CREATE OR REPLACE FUNCTION archemedica_security.assert_same_tenant(parent_tenant uuid, child_tenant uuid, relation_name text)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    IF parent_tenant IS NULL OR child_tenant IS NULL OR parent_tenant <> child_tenant THEN
        RAISE EXCEPTION 'ARC_CROSS_TENANT_REFERENCE: %', relation_name
            USING ERRCODE = '42501';
    END IF;
END;
$$;

CREATE OR REPLACE FUNCTION archemedica_security.check_program_rps_tenant()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE parent_tenant uuid;
BEGIN
    SELECT tenant_id INTO parent_tenant FROM development_program WHERE program_id = NEW.program_id;
    PERFORM archemedica_security.assert_same_tenant(parent_tenant, NEW.tenant_id, 'development_program -> regulated_product_system');
    RETURN NEW;
END; $$;
CREATE TRIGGER trg_rps_program_tenant BEFORE INSERT OR UPDATE OF tenant_id, program_id ON regulated_product_system
FOR EACH ROW EXECUTE FUNCTION archemedica_security.check_program_rps_tenant();

CREATE OR REPLACE FUNCTION archemedica_security.check_rps_child_tenant()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE parent_tenant uuid;
BEGIN
    SELECT tenant_id INTO parent_tenant FROM regulated_product_system WHERE rps_id = NEW.rps_id;
    PERFORM archemedica_security.assert_same_tenant(parent_tenant, NEW.tenant_id, TG_TABLE_NAME || ' -> regulated_product_system');
    RETURN NEW;
END; $$;
CREATE TRIGGER trg_constituent_rps_tenant BEFORE INSERT OR UPDATE OF tenant_id, rps_id ON constituent_part
FOR EACH ROW EXECUTE FUNCTION archemedica_security.check_rps_child_tenant();
CREATE TRIGGER trg_configuration_rps_tenant BEFORE INSERT OR UPDATE OF tenant_id, rps_id ON product_configuration
FOR EACH ROW EXECUTE FUNCTION archemedica_security.check_rps_child_tenant();

CREATE OR REPLACE FUNCTION archemedica_security.check_configuration_constituent_tenant()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE cfg_tenant uuid; cpt_tenant uuid;
BEGIN
    SELECT tenant_id INTO cfg_tenant FROM product_configuration WHERE cfg_id = NEW.cfg_id;
    SELECT tenant_id INTO cpt_tenant FROM constituent_part WHERE cpt_id = NEW.cpt_id;
    PERFORM archemedica_security.assert_same_tenant(cfg_tenant, NEW.tenant_id, 'configuration_constituent -> product_configuration');
    PERFORM archemedica_security.assert_same_tenant(cpt_tenant, NEW.tenant_id, 'configuration_constituent -> constituent_part');
    RETURN NEW;
END; $$;
CREATE TRIGGER trg_configuration_constituent_tenant BEFORE INSERT OR UPDATE OF tenant_id, cfg_id, cpt_id ON configuration_constituent
FOR EACH ROW EXECUTE FUNCTION archemedica_security.check_configuration_constituent_tenant();

CREATE OR REPLACE FUNCTION archemedica_security.check_lco_tenant()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE parent_tenant uuid;
BEGIN
    IF NEW.rps_id IS NOT NULL THEN
        SELECT tenant_id INTO parent_tenant FROM regulated_product_system WHERE rps_id = NEW.rps_id;
        PERFORM archemedica_security.assert_same_tenant(parent_tenant, NEW.tenant_id, 'lifecycle_control_object -> regulated_product_system');
    END IF;
    IF NEW.cfg_id IS NOT NULL THEN
        SELECT tenant_id INTO parent_tenant FROM product_configuration WHERE cfg_id = NEW.cfg_id;
        PERFORM archemedica_security.assert_same_tenant(parent_tenant, NEW.tenant_id, 'lifecycle_control_object -> product_configuration');
    END IF;
    IF NEW.cpt_id IS NOT NULL THEN
        SELECT tenant_id INTO parent_tenant FROM constituent_part WHERE cpt_id = NEW.cpt_id;
        PERFORM archemedica_security.assert_same_tenant(parent_tenant, NEW.tenant_id, 'lifecycle_control_object -> constituent_part');
    END IF;
    RETURN NEW;
END; $$;
CREATE TRIGGER trg_lco_tenant BEFORE INSERT OR UPDATE OF tenant_id, rps_id, cfg_id, cpt_id ON lifecycle_control_object
FOR EACH ROW EXECUTE FUNCTION archemedica_security.check_lco_tenant();

COMMIT;

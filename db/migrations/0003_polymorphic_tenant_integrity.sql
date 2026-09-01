-- Archemedica polymorphic tenant-integrity controls
-- Change Control: ARC-CC-003
-- Security Contract: ARC-AUTH-001 v1.0
-- Status: CONTROLLED IMPLEMENTATION / NOT PRODUCTION QUALIFIED

BEGIN;

-- Resolve tenant ownership for implemented controlled-object types.
-- Unsupported types fail closed rather than being treated as globally safe.
CREATE OR REPLACE FUNCTION archemedica_security.controlled_object_tenant(object_type text, object_id uuid)
RETURNS uuid
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public, archemedica_security, pg_temp
AS $$
DECLARE
    owner_tenant uuid;
BEGIN
    CASE upper(object_type)
        WHEN 'PROGRAM' THEN
            SELECT tenant_id INTO owner_tenant FROM development_program WHERE program_id = object_id;
        WHEN 'RPS' THEN
            SELECT tenant_id INTO owner_tenant FROM regulated_product_system WHERE rps_id = object_id;
        WHEN 'CFG' THEN
            SELECT tenant_id INTO owner_tenant FROM product_configuration WHERE cfg_id = object_id;
        WHEN 'CPT' THEN
            SELECT tenant_id INTO owner_tenant FROM constituent_part WHERE cpt_id = object_id;
        WHEN 'LCO' THEN
            SELECT tenant_id INTO owner_tenant FROM lifecycle_control_object WHERE lco_id = object_id;
        WHEN 'RSA' THEN
            SELECT tenant_id INTO owner_tenant FROM regulatory_applicability WHERE rsa_id = object_id;
        WHEN 'DER' THEN
            SELECT tenant_id INTO owner_tenant FROM decision_evidence_record WHERE der_id = object_id;
        WHEN 'DEP' THEN
            SELECT tenant_id INTO owner_tenant FROM dependency_edge WHERE dep_id = object_id;
        WHEN 'DCA' THEN
            SELECT tenant_id INTO owner_tenant FROM dependency_coverage WHERE dca_id = object_id;
        WHEN 'RAE' THEN
            SELECT tenant_id INTO owner_tenant FROM reassessment_episode WHERE rae_id = object_id;
        WHEN 'EVS' THEN
            SELECT tenant_id INTO owner_tenant FROM evidence_snapshot WHERE evs_id = object_id;
            IF owner_tenant IS NULL THEN
                RAISE EXCEPTION 'ARC_SHARED_OBJECT_CONTEXT_PROHIBITED: shared EVS requires explicit shared-evidence relationship semantics'
                    USING ERRCODE = '42501';
            END IF;
        ELSE
            RAISE EXCEPTION 'ARC_UNSUPPORTED_CONTROLLED_OBJECT_TYPE: %', object_type
                USING ERRCODE = '22023';
    END CASE;

    IF owner_tenant IS NULL THEN
        RAISE EXCEPTION 'ARC_CONTROLLED_OBJECT_NOT_FOUND_OR_UNRESOLVED: % %', object_type, object_id
            USING ERRCODE = '23503';
    END IF;

    RETURN owner_tenant;
END;
$$;

REVOKE ALL ON FUNCTION archemedica_security.controlled_object_tenant(text, uuid) FROM PUBLIC;

CREATE OR REPLACE FUNCTION archemedica_security.assert_context_tenant()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE owner_tenant uuid;
BEGIN
    owner_tenant := archemedica_security.controlled_object_tenant(NEW.context_type, NEW.context_id);
    PERFORM archemedica_security.assert_same_tenant(owner_tenant, NEW.tenant_id, TG_TABLE_NAME || ' context');
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_rsa_context_tenant
BEFORE INSERT OR UPDATE OF tenant_id, context_type, context_id ON regulatory_applicability
FOR EACH ROW EXECUTE FUNCTION archemedica_security.assert_context_tenant();

CREATE TRIGGER trg_der_context_tenant
BEFORE INSERT OR UPDATE OF tenant_id, context_type, context_id ON decision_evidence_record
FOR EACH ROW EXECUTE FUNCTION archemedica_security.assert_context_tenant();

CREATE TRIGGER trg_dca_context_tenant
BEFORE INSERT OR UPDATE OF tenant_id, context_type, context_id ON dependency_coverage
FOR EACH ROW EXECUTE FUNCTION archemedica_security.assert_context_tenant();

CREATE OR REPLACE FUNCTION archemedica_security.assert_dependency_endpoint_tenants()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE source_tenant uuid; target_tenant uuid;
BEGIN
    source_tenant := archemedica_security.controlled_object_tenant(NEW.source_type, NEW.source_id);
    target_tenant := archemedica_security.controlled_object_tenant(NEW.target_type, NEW.target_id);
    PERFORM archemedica_security.assert_same_tenant(source_tenant, NEW.tenant_id, 'dependency source');
    PERFORM archemedica_security.assert_same_tenant(target_tenant, NEW.tenant_id, 'dependency target');
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_dependency_endpoint_tenants
BEFORE INSERT OR UPDATE OF tenant_id, source_type, source_id, target_type, target_id ON dependency_edge
FOR EACH ROW EXECUTE FUNCTION archemedica_security.assert_dependency_endpoint_tenants();

-- Reassessment root triggers are also controlled object references.
CREATE OR REPLACE FUNCTION archemedica_security.assert_reassessment_root_tenant()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE root_tenant uuid;
BEGIN
    root_tenant := archemedica_security.controlled_object_tenant(NEW.root_trigger_type, NEW.root_trigger_id);
    PERFORM archemedica_security.assert_same_tenant(root_tenant, NEW.tenant_id, 'reassessment root trigger');
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_reassessment_root_tenant
BEFORE INSERT OR UPDATE OF tenant_id, root_trigger_type, root_trigger_id ON reassessment_episode
FOR EACH ROW EXECUTE FUNCTION archemedica_security.assert_reassessment_root_tenant();

COMMIT;

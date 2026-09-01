-- Archemedica tenant-integrity extension for migration 0005 objects
-- Corrective basis: ARC-PERSIST-TRACE-001 and ARC-AUTH-001

BEGIN;

CREATE OR REPLACE FUNCTION archemedica_security.controlled_object_tenant(object_type text, object_id uuid)
RETURNS uuid
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public, archemedica_security, pg_temp
AS $$
DECLARE owner_tenant uuid;
BEGIN
    CASE upper(object_type)
        WHEN 'PROGRAM' THEN SELECT tenant_id INTO owner_tenant FROM development_program WHERE program_id = object_id;
        WHEN 'RPS' THEN SELECT tenant_id INTO owner_tenant FROM regulated_product_system WHERE rps_id = object_id;
        WHEN 'CFG' THEN SELECT tenant_id INTO owner_tenant FROM product_configuration WHERE cfg_id = object_id;
        WHEN 'CPT' THEN SELECT tenant_id INTO owner_tenant FROM constituent_part WHERE cpt_id = object_id;
        WHEN 'LCO' THEN SELECT tenant_id INTO owner_tenant FROM lifecycle_control_object WHERE lco_id = object_id;
        WHEN 'STU' THEN SELECT tenant_id INTO owner_tenant FROM study_investigation WHERE study_id = object_id;
        WHEN 'PRO' THEN SELECT tenant_id INTO owner_tenant FROM protocol_plan WHERE protocol_id = object_id;
        WHEN 'CHG' THEN SELECT tenant_id INTO owner_tenant FROM controlled_change WHERE change_id = object_id;
        WHEN 'RSK' THEN SELECT tenant_id INTO owner_tenant FROM integrated_risk WHERE risk_id = object_id;
        WHEN 'EIG' THEN SELECT tenant_id INTO owner_tenant FROM evidence_integrity_assessment WHERE eig_id = object_id;
        WHEN 'MUSE' THEN SELECT tenant_id INTO owner_tenant FROM model_algorithm_use WHERE muse_id = object_id;
        WHEN 'SIG' THEN SELECT tenant_id INTO owner_tenant FROM safety_quality_signal WHERE signal_id = object_id;
        WHEN 'SUP' THEN SELECT tenant_id INTO owner_tenant FROM supplier_external_dependency WHERE supplier_dependency_id = object_id;
        WHEN 'OBL' THEN SELECT tenant_id INTO owner_tenant FROM obligation WHERE obligation_id = object_id;
        WHEN 'IMPL' THEN SELECT tenant_id INTO owner_tenant FROM implementation_effective_state WHERE implementation_state_id = object_id;
        WHEN 'RSA' THEN SELECT tenant_id INTO owner_tenant FROM regulatory_applicability WHERE rsa_id = object_id;
        WHEN 'DER' THEN SELECT tenant_id INTO owner_tenant FROM decision_evidence_record WHERE der_id = object_id;
        WHEN 'DEP' THEN SELECT tenant_id INTO owner_tenant FROM dependency_edge WHERE dep_id = object_id;
        WHEN 'DCA' THEN SELECT tenant_id INTO owner_tenant FROM dependency_coverage WHERE dca_id = object_id;
        WHEN 'RAE' THEN SELECT tenant_id INTO owner_tenant FROM reassessment_episode WHERE rae_id = object_id;
        WHEN 'EVS' THEN
            SELECT tenant_id INTO owner_tenant FROM evidence_snapshot WHERE evs_id = object_id;
            IF owner_tenant IS NULL THEN
                RAISE EXCEPTION 'ARC_SHARED_OBJECT_CONTEXT_PROHIBITED: shared EVS requires explicit shared-evidence relationship semantics' USING ERRCODE='42501';
            END IF;
        ELSE
            RAISE EXCEPTION 'ARC_UNSUPPORTED_CONTROLLED_OBJECT_TYPE: %', object_type USING ERRCODE='22023';
    END CASE;
    IF owner_tenant IS NULL THEN
        RAISE EXCEPTION 'ARC_CONTROLLED_OBJECT_NOT_FOUND_OR_UNRESOLVED: % %', object_type, object_id USING ERRCODE='23503';
    END IF;
    RETURN owner_tenant;
END;
$$;
REVOKE ALL ON FUNCTION archemedica_security.controlled_object_tenant(text, uuid) FROM PUBLIC;

CREATE OR REPLACE FUNCTION archemedica_security.assert_context_tenant()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, archemedica_security, pg_temp
AS $$
DECLARE owner_tenant uuid;
BEGIN
    owner_tenant := archemedica_security.controlled_object_tenant(NEW.context_type, NEW.context_id);
    PERFORM archemedica_security.assert_same_tenant(owner_tenant, NEW.tenant_id, TG_TABLE_NAME || ' context');
    RETURN NEW;
END;
$$;

DO $$
DECLARE rec record;
BEGIN
    FOR rec IN SELECT * FROM (VALUES
        ('integrated_risk','trg_risk_context_tenant'),
        ('model_algorithm_use','trg_muse_context_tenant'),
        ('safety_quality_signal','trg_signal_context_tenant'),
        ('supplier_external_dependency','trg_supplier_context_tenant'),
        ('obligation','trg_obligation_context_tenant'),
        ('implementation_effective_state','trg_impl_context_tenant')
    ) AS x(tbl,trg)
    LOOP
        EXECUTE format('CREATE TRIGGER %I BEFORE INSERT OR UPDATE OF tenant_id, context_type, context_id ON %I FOR EACH ROW EXECUTE FUNCTION archemedica_security.assert_context_tenant()', rec.trg, rec.tbl);
    END LOOP;
END $$;

CREATE OR REPLACE FUNCTION archemedica_security.check_study_tenant()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path=public,archemedica_security,pg_temp AS $$
DECLARE p_t uuid; r_t uuid;
BEGIN
    SELECT tenant_id INTO p_t FROM development_program WHERE program_id=NEW.program_id;
    SELECT tenant_id INTO r_t FROM regulated_product_system WHERE rps_id=NEW.rps_id;
    PERFORM archemedica_security.assert_same_tenant(p_t, NEW.tenant_id, 'study -> program');
    PERFORM archemedica_security.assert_same_tenant(r_t, NEW.tenant_id, 'study -> RPS');
    RETURN NEW;
END; $$;
CREATE TRIGGER trg_study_tenant BEFORE INSERT OR UPDATE OF tenant_id,program_id,rps_id ON study_investigation FOR EACH ROW EXECUTE FUNCTION archemedica_security.check_study_tenant();

CREATE OR REPLACE FUNCTION archemedica_security.check_protocol_tenant()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path=public,archemedica_security,pg_temp AS $$
DECLARE s_t uuid;
BEGIN
    SELECT tenant_id INTO s_t FROM study_investigation WHERE study_id=NEW.study_id;
    PERFORM archemedica_security.assert_same_tenant(s_t, NEW.tenant_id, 'protocol -> study');
    RETURN NEW;
END; $$;
CREATE TRIGGER trg_protocol_tenant BEFORE INSERT OR UPDATE OF tenant_id,study_id ON protocol_plan FOR EACH ROW EXECUTE FUNCTION archemedica_security.check_protocol_tenant();

CREATE OR REPLACE FUNCTION archemedica_security.check_eig_tenant()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path=public,archemedica_security,pg_temp AS $$
DECLARE e_t uuid;
BEGIN
    SELECT tenant_id INTO e_t FROM evidence_snapshot WHERE evs_id=NEW.evs_id;
    IF e_t IS NULL THEN
        -- Shared evidence is permitted, but the assessment itself remains tenant-specific.
        RETURN NEW;
    END IF;
    PERFORM archemedica_security.assert_same_tenant(e_t, NEW.tenant_id, 'EIG -> EVS');
    RETURN NEW;
END; $$;
CREATE TRIGGER trg_eig_tenant BEFORE INSERT OR UPDATE OF tenant_id,evs_id ON evidence_integrity_assessment FOR EACH ROW EXECUTE FUNCTION archemedica_security.check_eig_tenant();

CREATE OR REPLACE FUNCTION archemedica_security.check_evidence_link_tenant()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path=public,archemedica_security,pg_temp AS $$
DECLARE e_t uuid; t_t uuid; i_t uuid;
BEGIN
    SELECT tenant_id INTO e_t FROM evidence_snapshot WHERE evs_id=NEW.evs_id;
    IF e_t IS NOT NULL THEN PERFORM archemedica_security.assert_same_tenant(e_t, NEW.tenant_id, 'evidence link -> EVS'); END IF;
    IF NEW.eig_id IS NOT NULL THEN
        SELECT tenant_id INTO i_t FROM evidence_integrity_assessment WHERE eig_id=NEW.eig_id;
        PERFORM archemedica_security.assert_same_tenant(i_t, NEW.tenant_id, 'evidence link -> EIG');
    END IF;
    t_t := archemedica_security.controlled_object_tenant(NEW.target_type, NEW.target_id);
    PERFORM archemedica_security.assert_same_tenant(t_t, NEW.tenant_id, 'evidence link target');
    RETURN NEW;
END; $$;
CREATE TRIGGER trg_evidence_link_tenant BEFORE INSERT OR UPDATE OF tenant_id,evs_id,eig_id,target_type,target_id ON controlled_evidence_link FOR EACH ROW EXECUTE FUNCTION archemedica_security.check_evidence_link_tenant();

COMMIT;

-- Corrective migration for ARC-DEV-004
-- Fixes trigger/private-resolver privilege-path defect from migration 0003.

BEGIN;

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

CREATE OR REPLACE FUNCTION archemedica_security.assert_dependency_endpoint_tenants()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, archemedica_security, pg_temp
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

CREATE OR REPLACE FUNCTION archemedica_security.assert_reassessment_root_tenant()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, archemedica_security, pg_temp
AS $$
DECLARE root_tenant uuid;
BEGIN
    root_tenant := archemedica_security.controlled_object_tenant(NEW.root_trigger_type, NEW.root_trigger_id);
    PERFORM archemedica_security.assert_same_tenant(root_tenant, NEW.tenant_id, 'reassessment root trigger');
    RETURN NEW;
END;
$$;

REVOKE ALL ON FUNCTION archemedica_security.assert_context_tenant() FROM PUBLIC;
REVOKE ALL ON FUNCTION archemedica_security.assert_dependency_endpoint_tenants() FROM PUBLIC;
REVOKE ALL ON FUNCTION archemedica_security.assert_reassessment_root_tenant() FROM PUBLIC;

COMMIT;

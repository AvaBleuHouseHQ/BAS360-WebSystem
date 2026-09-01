-- ARC-AUTH-001 RLS negative tests
-- Controlled test specification; execute in isolated test database only.
-- Expected result comments define qualification intent. This file is not itself execution evidence.

BEGIN;

-- Test fixtures assume migrations 0001-0003 have been applied.
-- Test harness should create non-owner/non-superuser runtime role before executing runtime sections.

-- Administrative fixture setup placeholders:
-- T-A = 11111111-1111-1111-1111-111111111111
-- T-B = 22222222-2222-2222-2222-222222222222
-- Program A/B and RPS A/B identifiers must be captured by harness.

-- AUTH-OQ-001: Missing tenant context fails closed.
RESET archemedica.tenant_id;
RESET archemedica.actor_principal;
-- EXPECT: SELECT from tenant-scoped table raises ARC_AUTH_CONTEXT_MISSING / SQLSTATE 42501.
SELECT count(*) FROM regulated_product_system;

-- AUTH-OQ-002: Malformed tenant context fails closed.
SELECT set_config('archemedica.tenant_id', 'not-a-uuid', true);
SELECT set_config('archemedica.actor_principal', 'principal:test', true);
-- EXPECT: raises ARC_AUTH_CONTEXT_INVALID / 42501.
SELECT count(*) FROM regulated_product_system;

-- Remaining tests require harness variables or generated SQL for concrete fixture UUIDs.
-- The harness MUST execute each block in a new transaction or restore transaction-local settings.

-- AUTH-OQ-003: Tenant A cannot SELECT Tenant B RPS.
-- SET LOCAL archemedica.tenant_id = '<TENANT_A_UUID>';
-- SET LOCAL archemedica.actor_principal = 'principal:a';
-- EXPECT: query by <RPS_B_UUID> returns zero rows, not Tenant B data.
-- SELECT * FROM regulated_product_system WHERE rps_id = '<RPS_B_UUID>';

-- AUTH-OQ-004: Tenant A cannot INSERT row with Tenant B tenant_id.
-- EXPECT: RLS WITH CHECK violation.
-- INSERT INTO regulated_product_system(tenant_id, program_id, rps_key, name)
-- VALUES ('<TENANT_B_UUID>', '<PROGRAM_B_UUID>', 'RPS-X', 'cross-tenant write');

-- AUTH-OQ-005: Tenant A cannot mutate Tenant B row.
-- EXPECT: zero rows updated or RLS denial; no state change.
-- UPDATE regulated_product_system SET name='bad' WHERE rps_id='<RPS_B_UUID>';

-- AUTH-OQ-006: Same-tenant row cannot reference Tenant B parent.
-- Under Tenant A context, attempt to create RPS A referencing Program B.
-- EXPECT: ARC_CROSS_TENANT_REFERENCE or unresolved parent; no row written.

-- AUTH-OQ-007: Configuration cannot connect constituents across tenants.
-- EXPECT: trg_configuration_constituent_tenant rejects relation.

-- AUTH-OQ-008: LCO cannot attach to cross-tenant RPS/CFG/CPT.
-- EXPECT: ARC_CROSS_TENANT_REFERENCE.

-- AUTH-OQ-009: DER polymorphic context cannot point to Tenant B object.
-- EXPECT: ARC_CROSS_TENANT_REFERENCE.

-- AUTH-OQ-010: Dependency graph cannot bridge Tenant A source to Tenant B target.
-- EXPECT: trg_dependency_endpoint_tenants rejects insert.

-- AUTH-OQ-011: Unsupported polymorphic object type fails closed.
-- EXPECT: ARC_UNSUPPORTED_CONTROLLED_OBJECT_TYPE.
-- SELECT archemedica_security.controlled_object_tenant('UNKNOWN_TYPE', gen_random_uuid());

-- AUTH-OQ-012: Tenant-scoped evidence is invisible cross-tenant.
-- EXPECT: Tenant A cannot SELECT EVS row with tenant_id Tenant B.

-- AUTH-OQ-013: Shared evidence can be read without disclosing tenant usage.
-- EXPECT: public/shared EVS (tenant_id NULL) visible; no tenant relationship or tenant-specific audit metadata exposed through this row.

-- AUTH-OQ-014: Tenant reassignment is prohibited.
-- EXPECT: ARC_TENANT_REASSIGNMENT_PROHIBITED.
-- UPDATE regulated_product_system SET tenant_id='<TENANT_B_UUID>' WHERE rps_id='<RPS_A_UUID>';

-- AUTH-OQ-015: Pooled-connection context reset safety.
-- Transaction 1: set Tenant A using SET LOCAL and commit.
-- Transaction 2 on same physical connection: do not set tenant context.
-- EXPECT: missing-context exception; Tenant A context must not persist.

-- AUTH-OQ-016: Tenant A cannot inspect Tenant B audit rows.
-- EXPECT: zero Tenant B rows returned.

-- AUTH-OQ-017: Global/system audit rows (tenant_id NULL) are not visible to normal tenant context.
-- EXPECT: zero global rows returned.

-- AUTH-OQ-018: RLS owner bypass protection.
-- Harness must confirm runtime role is not table owner, superuser, or BYPASSRLS and that FORCE ROW LEVEL SECURITY is set.

ROLLBACK;

# ARC-DEV-004 — Polymorphic Tenant Trigger Privilege Defect

**Document ID:** ARC-DEV-004  
**Version:** 1.0  
**Status:** CONTROLLED — DEVIATION / CORRECTIVE ACTION OPEN  
**System:** Archemedica / BAS360-WebSystem  
**Author/Document Owner:** Cassandra Harrison  
**Date Identified:** 2026-09-01  
**Affected Artifact:** `db/migrations/0003_polymorphic_tenant_integrity.sql`

## 1. Description
Static security review identified a privilege-path defect in migration 0003. The private `archemedica_security.controlled_object_tenant(text, uuid)` resolver is `SECURITY DEFINER` and has PUBLIC execution revoked, which is desirable to prevent direct tenant-membership probing. However, trigger helper functions that call the resolver were initially created as invoker-context functions.

Under a properly restricted application runtime role, the trigger path could therefore fail because the invoker does not have direct EXECUTE privilege on the private resolver.

## 2. Impact
**Severity:** Major pre-qualification implementation defect; no production impact because the persistence foundation is not released or qualified.

Potential effect if left uncorrected: legitimate same-tenant writes using DER/RSA/DCA/dependency/reassessment polymorphic references could fail under the intended non-owner runtime role.

## 3. Root Cause
Security hardening correctly removed direct resolver access, but trigger execution-context semantics were not closed at the same design step. This is an example of a control interaction defect: one protection can break another path if the whole authorization chain is not tested.

## 4. Corrective Action
Create migration 0004 that:

1. replaces the affected trigger helper functions as narrowly scoped `SECURITY DEFINER` functions;
2. fixes each helper function `search_path` to controlled schemas plus `pg_temp`;
3. retains the private resolver's revoked PUBLIC execution;
4. revokes direct PUBLIC execution on trigger helper functions where appropriate;
5. adds qualification checks proving a restricted runtime role can perform same-tenant writes but cannot directly invoke the private tenant resolver or create cross-tenant references.

## 5. Preventive Action
Add a security-function review rule: every `SECURITY DEFINER` function and every function that calls one shall be reviewed for invocation privilege, fixed search path, least privilege, direct-call exposure and data-disclosure behavior.

## 6. Verification Required
Retest AUTH-OQ-006 through AUTH-OQ-011 under an actual non-owner/non-superuser/non-BYPASSRLS role.

## 7. Disposition
**OPEN — CORRECT BEFORE RLS QUALIFICATION.**

The original migration is preserved as committed evidence of the defect. It is not rewritten to imply the issue never existed.

## 8. Change History
| Version | Date | Change | Status |
|---|---|---|---|
| 1.0 | 2026-09-01 | Recorded trigger/private-resolver privilege interaction defect and required corrective action | OPEN |

**END OF CONTROLLED DEVIATION**
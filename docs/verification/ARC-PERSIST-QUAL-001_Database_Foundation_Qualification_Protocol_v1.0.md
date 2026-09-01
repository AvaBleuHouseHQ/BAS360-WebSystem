# ARC-PERSIST-QUAL-001 — Database Foundation Qualification Protocol

**Document ID:** ARC-PERSIST-QUAL-001  
**Version:** 1.0  
**Status:** CONTROLLED — EXECUTION PENDING  
**System:** Archemedica / BAS360-WebSystem  
**Author/Document Owner:** Cassandra Harrison  
**Date:** 2026-09-01  
**Change Control:** ARC-CC-003  
**Architecture:** ARC-PERSIST-001 v1.0  
**Security Contract:** ARC-AUTH-001 v1.0

## 1. Purpose
Qualify the current controlled PostgreSQL persistence foundation for the limited architecture scope implemented by migrations 0001 through 0007. This protocol verifies database installation order, tenant isolation, fail-closed session context, cross-tenant graph integrity, no-false-closure behavior, expected-revision stale-write rejection, and atomic production of transition/audit/outbox records.

## 2. Claim Boundary
Successful execution supports only a controlled engineering qualification of the tested database foundation at the identified commit. It does not establish GxP validation, 21 CFR Part 11 compliance, ISO certification, regulator acceptance, clinical correctness, production release, operational security certification, or customer-environment qualification.

## 3. Controlled Configuration
The CI runner shall use a pinned PostgreSQL major version and apply repository migrations in lexical order. Qualification evidence shall be tied to the Git commit SHA and workflow-run identity.

## 4. Runtime Role
Testing shall instantiate `archemedica_runtime` as a non-superuser, non-BYPASSRLS role. The runtime role receives only the table/schema/function privileges needed by the current pilot harness. Qualification shall fail if tests rely on superuser or BYPASSRLS behavior.

## 5. Mandatory Tests
| ID | Control | Expected Result |
|---|---|---|
| Q01 | Tenant directory isolation | Tenant A sees only Tenant A row |
| Q02 | Tenant-scoped table isolation | Tenant A sees only Tenant A program |
| Q03 | Direct cross-tenant object visibility | Tenant B DER invisible to Tenant A |
| Q04 | Cross-tenant direct write | Rejected by RLS |
| Q05 | Hidden cross-tenant polymorphic graph edge | Rejected/fails closed |
| Q06 | Same-tenant graph edge | Accepted |
| Q07 | No False Closure | APPROVED blocked while unresolved state is UNKNOWN |
| Q08 | Expected revision | Stale expected revision rejected |
| Q09 | Valid controlled transition | Exactly one revision increment |
| Q10 | Atomic controlled effects | Exactly one transition, audit, and outbox effect |
| Q11 | Missing tenant context | Access fails closed |
| Q12 | Malformed tenant context | Access fails closed |

## 6. Execution Harness
`tests/db/ARC-PERSIST-QUAL-001_database_qualification.sql`

The harness uses synthetic tenants and synthetic product/decision records only.

## 7. Acceptance
All Q01-Q12 must pass. Any SQL error not explicitly expected by a negative test is a qualification failure. A failing workflow creates a controlled deviation before corrective change. Failed history shall not be rewritten or deleted.

## 8. Open Risks Outside This Execution
This execution does not yet qualify concurrent multi-session races, crash recovery between transaction commit and external delivery, queue worker replay under process death, backup/restore, migration rollback, search/cache/export tenant isolation, external evidence retention, or human-review cognition. Those remain subsequent OQ/PQ targets.

## 9. Disposition Rule
- **PASS:** proceed to expanded concurrency/replay OQ design.
- **FAIL:** implementation gate closes; record deviation; correct; retest; regression.

## 10. Change History
| Version | Date | Change | Status |
|---|---|---|---|
| 1.0 | 2026-09-01 | Established executable PostgreSQL database-foundation qualification protocol | CONTROLLED — EXECUTION PENDING |

**END OF CONTROLLED DOCUMENT**

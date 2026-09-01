# ARC-PERSIST-QUAL-001 — Database Foundation Qualification Execution Report

**Version:** 1.0  
**Status:** CONTROLLED — EXECUTED / PASS  
**System:** Archemedica / BAS360-WebSystem  
**Author / Document Owner:** Cassandra Harrison  
**Execution Date:** 2026-09-01  
**Protocol:** `docs/verification/ARC-PERSIST-QUAL-001_Database_Foundation_Qualification_Protocol_v1.0.md`  
**Harness:** `tests/db/ARC-PERSIST-QUAL-001_database_qualification.sql`  
**Corrective Reference:** ARC-DEV-005  
**GitHub Actions Run:** 33518398903  
**Job:** 99891145316  
**Qualified Commit:** `bb46d2f119c4f57c1eed0370d62ca1e9653ab334`  
**Database:** PostgreSQL 16.15  

## 1. Objective

Execute the full controlled database-foundation qualification from a clean PostgreSQL 16 service after correcting the ARC-DEV-005 harness defect. The purpose was to verify that migrations 0001–0007 install successfully and that all defined Q01–Q12 security, isolation, state-transition, and fail-closed assertions execute to completion.

## 2. Execution Configuration

The GitHub Actions workflow created a fresh PostgreSQL 16 service container and checked out commit `bb46d2f119c4f57c1eed0370d62ca1e9653ab334`.

The workflow then applied, in order:

1. `0001_archemedica_core.sql`
2. `0002_tenant_rls_and_context.sql`
3. `0003_polymorphic_tenant_integrity.sql`
4. `0004_polymorphic_trigger_privilege_fix.sql`
5. `0005_pilot_decision_continuity_objects.sql`
6. `0006_new_object_tenant_integrity.sql`
7. `0007_revision_and_transition_controls.sql`

All seven migrations completed successfully before qualification execution.

## 3. Qualification Results

| Test | Control | Result |
|---|---|---|
| Q01 | Active tenant can see only its tenant row | PASS |
| Q02 | Active tenant can see only its development program | PASS |
| Q03 | Tenant-B DER hidden from Tenant-A | PASS |
| Q04 | Cross-tenant direct insert rejected | PASS |
| Q05 | Hidden cross-tenant polymorphic dependency rejected | PASS |
| Q06 | Same-tenant dependency accepted | PASS |
| Q07 | No False Closure while DER unresolved state is UNKNOWN | PASS |
| Q08 | Stale expected revision rejected | PASS |
| Q09 | Correct expected revision succeeds and increments exactly once | PASS |
| Q10 | Successful transition creates exactly one transition, audit, and outbox effect | PASS |
| Q11 | Missing tenant context fails closed | PASS |
| Q12 | Malformed tenant context fails closed | PASS |

**Total:** 12 PASS / 0 FAIL / 0 NOT EXECUTED.

The terminal harness result was:

`ARC-PERSIST-QUAL-001 PASS`

## 4. Corrective Retest of ARC-DEV-005

ARC-DEV-005 identified a verification-harness error in the first execution attempt, where psql variable substitution was incorrectly used inside a dollar-quoted PL/pgSQL block during Q09.

The corrected harness moved Q09 entirely into a server-side PL/pgSQL assertion. The full fresh-database run then executed Q01–Q12 without error. This provides objective evidence that the ARC-DEV-005 correction was effective.

## 5. Evidence Integrity

The successful run was not a continuation of the failed database instance. A fresh PostgreSQL service was initialized, all migrations were reapplied, and the complete harness was executed from the beginning. Therefore the PASS is not dependent on residual state from the failed run.

## 6. Qualification Disposition

**PASS — DATABASE FOUNDATION QUALIFICATION ACCEPTED FOR CONTROLLED PILOT DEVELOPMENT.**

This disposition authorizes advancement to the separately controlled concurrency, replay, and failure-injection OQ defined in ARC-PERSIST-OQ-002.

It does **not** authorize production release or establish GxP validation, 21 CFR Part 11 compliance, ISO certification/conformity, security certification, clinical/scientific validity, regulator acceptance, or operational qualification of a deployed production environment.

## 7. Open Controls Before Pilot Release

The following remain required:

- ARC-PERSIST-OQ-002 concurrency/replay/failure-injection execution;
- connection-pool tenant-context reuse testing;
- deterministic idempotency and exactly-once business-effect controls;
- outbox crash/recovery and reconciliation testing;
- false cross-modality cascade testing;
- regulatory source/requirement supersession propagation testing;
- six-month historical reconstruction testing;
- persistence traceability re-review after OQ corrections;
- controlled PQ and pilot disposition.

No production or broad compliance claim is permitted from this execution alone.
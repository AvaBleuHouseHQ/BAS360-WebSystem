# ARC-DEV-005 — Qualification Harness psql Substitution Defect

**Version:** 1.0  
**Status:** CONTROLLED — CLOSED AFTER SUCCESSFUL CORRECTIVE RETEST  
**System:** Archemedica / BAS360-WebSystem  
**Author / Document Owner:** Cassandra Harrison  
**Date:** 2026-09-01  
**Affected Protocol:** ARC-PERSIST-QUAL-001 v1.0  
**Affected Harness:** `tests/db/ARC-PERSIST-QUAL-001_database_qualification.sql`  
**Observed Failed Run:** GitHub Actions run 33517872913 / job 99889380878  
**Corrective Run:** GitHub Actions run 33518398903 / job 99891145316  
**Corrected Commit:** `bb46d2f119c4f57c1eed0370d62ca1e9653ab334`  
**Execution Report:** `docs/verification/evidence/ARC-PERSIST-QUAL-001_Database_Foundation_Qualification_Execution_Report_v1.0.md`

## 1. Deviation

The first executable PostgreSQL qualification run failed during Q09 because the harness attempted to reference a psql variable (`:q09_revision`) inside a dollar-quoted PL/pgSQL `DO` body. psql variable substitution does not occur inside that quoted body, so PostgreSQL received the literal colon token and raised a syntax error.

The controlled migrations 0001–0007 all applied successfully before the harness failure. Q01–Q08 executed through the point preceding Q09. The failed run did **not** establish a qualification PASS.

## 2. Classification

**Type:** Verification harness defect  
**Product/database defect established:** No  
**Qualification impact:** Material to first run; corrected by full retest  
**Security impact established:** None from this defect  
**Release impact:** Resolved for ARC-PERSIST-QUAL-001; later OQ/PQ gates remain

## 3. Root Cause

The harness mixed psql client-variable syntax with server-side PL/pgSQL dollar quoting. The design review did not catch that client-side substitution boundary before first execution.

## 4. Corrective Action Implemented

Q09 was rewritten so `transition_der_state(...)` and its returned revision are evaluated entirely inside a server-side PL/pgSQL block. The invalid psql-variable dependency was removed.

## 5. Corrective Retest

A completely new PostgreSQL 16 service was initialized. Migrations 0001–0007 were reapplied from the beginning. The corrected qualification harness then executed Q01–Q12 in full.

Results:

- migrations 0001–0007: PASS;
- Q01–Q12: 12 PASS / 0 FAIL / 0 NOT EXECUTED;
- Q09: revision advanced exactly once as expected;
- Q10: one transition event, one audit event, and one outbox event were produced for the controlled transition;
- Q11/Q12: missing and malformed tenant context failed closed;
- terminal harness result: `ARC-PERSIST-QUAL-001 PASS`.

## 6. Closure Determination

**ARC-DEV-005 is CLOSED.**

The root cause was confined to the qualification harness and the corrective action was effective under full clean-database retest. No database/product correction was required for this deviation.

## 7. Boundary

Closure of ARC-DEV-005 and PASS of ARC-PERSIST-QUAL-001 authorize advancement only to the next controlled persistence OQ. They do not establish GxP validation, 21 CFR Part 11 compliance, ISO certification/conformity, security certification, regulator acceptance, clinical/scientific validity, or production qualification/release.
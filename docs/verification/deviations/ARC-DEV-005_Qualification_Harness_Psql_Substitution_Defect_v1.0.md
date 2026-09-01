# ARC-DEV-005 — Qualification Harness psql Substitution Defect

**Version:** 1.0  
**Status:** CONTROLLED — OPEN PENDING CORRECTIVE RETEST  
**System:** Archemedica / BAS360-WebSystem  
**Author / Document Owner:** Cassandra Harrison  
**Date:** 2026-09-01  
**Affected Protocol:** ARC-PERSIST-QUAL-001 v1.0  
**Affected Harness:** `tests/db/ARC-PERSIST-QUAL-001_database_qualification.sql`  
**Observed Run:** GitHub Actions run 33517872913 / job 99889380878  

## 1. Deviation

The first executable PostgreSQL qualification run failed during Q09 because the harness attempted to reference a psql variable (`:q09_revision`) inside a dollar-quoted PL/pgSQL `DO` body. psql variable substitution does not occur inside that quoted body, so PostgreSQL received the literal colon token and raised a syntax error.

The controlled migrations 0001–0007 all applied successfully before the harness failure. Q01–Q08 executed through the point preceding Q09. The run therefore demonstrates that the qualification environment and migration chain were executable, but it does **not** establish a PASS for ARC-PERSIST-QUAL-001 because Q09–Q12 were not completed.

## 2. Classification

**Type:** Verification harness defect  
**Product/database defect established:** No  
**Qualification impact:** Material — qualification run invalid/incomplete  
**Security impact established:** None from this failure itself  
**Release impact:** Gate remains closed

## 3. Root Cause

The harness mixed psql client-variable syntax with server-side PL/pgSQL dollar quoting. The design review did not catch that client-side substitution boundary before first execution.

## 4. Corrective Action

Replace the Q09 psql-variable/`DO` construct with a server-side assertion that calls `transition_der_state(...)`, stores the returned revision in a PL/pgSQL variable, and validates the value inside one `DO` block. This avoids dependence on psql substitution semantics.

The corrected harness shall be committed as a new revision of the same controlled test file; this deviation record remains preserved.

## 5. Retest Requirements

The corrective run must:

1. execute on PostgreSQL 16 using the same controlled migration sequence;
2. execute Q01–Q12 in full;
3. show Q09 revision increment exactly once;
4. show Q10 exactly-one transition/audit/outbox effects;
5. show Q11/Q12 fail closed;
6. produce an explicit terminal PASS only after all assertions complete.

Any new failure becomes a new deviation or an extension of this deviation only if it has the same root cause.

## 6. Disposition

**ARC-PERSIST-QUAL-001 remains NOT PASSED.**

This record must not be used to imply GxP validation, Part 11 compliance, ISO certification/conformity, security certification, regulator acceptance, or production qualification.
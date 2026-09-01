# ARC-DEV-008 — PQ Migration and Harness Schema-Contract Mismatch

**Version:** 1.0  
**Status:** CONTROLLED — OPEN PENDING COMPLETE CORRECTIVE RETEST  
**System:** Archemedica / BAS360-WebSystem  
**Author / Document Owner:** Cassandra Harrison  
**Date:** 2026-09-01  
**Protocol:** ARC-PERSIST-PQ-003 v1.0  
**Observed Run:** GitHub Actions `33526280658`, job `99917818305`

## Deviation

The first PQ execution stopped while applying migration 0009 before any PQ test executed. Migration 0009 referenced `reassessment_episode(episode_id)`, while the controlled canonical primary key established in migration 0001 is `reassessment_episode(rae_id)`.

A full pre-retest reconciliation also identified generated PQ harness field names that did not match the controlled schema, including constituent/configuration/LCO/regulatory/evidence aliases. These are test-implementation defects and must be corrected together rather than surfaced serially one run at a time.

## Classification

**Type:** PQ migration/test schema-contract defect  
**Product behavior defect established:** No — PQ test body did not execute  
**Qualification impact:** Material — PQ execution invalid/incomplete  
**Release impact:** PQ gate remains closed

## Corrective Action

1. align migration 0009 with canonical `rae_id`;
2. reconcile the PQ harness against the exact migrations 0001–0009 schema contracts;
3. preserve canonical names rather than adding compatibility aliases merely to satisfy the test;
4. rerun all migrations from a fresh PostgreSQL 16 instance;
5. execute all PQ3-01 through PQ3-16 in one complete run;
6. treat any subsequent database/product failure as a new controlled finding.

## Disposition

**OPEN pending complete corrective PQ retest.**

No production, GxP, Part 11, ISO conformity/certification, regulatory acceptance, or clinical-effectiveness claim is authorized.
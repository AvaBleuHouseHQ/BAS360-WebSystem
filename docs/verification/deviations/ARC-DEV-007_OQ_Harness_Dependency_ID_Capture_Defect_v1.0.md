# ARC-DEV-007 — OQ Harness Dependency-ID Capture Defect

**Version:** 1.1  
**Status:** CONTROLLED — CLOSED / CORRECTED AND RETESTED  
**System:** Archemedica / BAS360-WebSystem  
**Author / Document Owner:** Cassandra Harrison  
**Date Opened:** 2026-09-01  
**Date Closed:** 2026-09-01  
**Protocol:** ARC-PERSIST-OQ-002  
**Initial Defective Run:** GitHub Actions `33525120715`, job `99913882209`  
**Corrective Harness:** `tests/db/ARC-PERSIST-OQ-002_gate_v1_1.sh`  
**Corrective Harness Commit:** `481ad715aa924dba5b153e11d6d1a7e9515036d5`  
**Final Workflow Commit:** `ad9f4a5ce704ebf1df354628d0d7c35db533b3ab`  
**Final Retest Run:** `33525332032`, job `99914588124`

## 1. Original Deviation

The first corrective OQ execution passed OQ2-01 through OQ2-08, then the shell harness exited before OQ2-09 because dependency IDs returned as multiple lines were captured using `read` under `set -e`. A latent three-column parsing weakness was also identified in the OQ2-11 regulatory requirement fixture.

No database-control failure was established by that harness termination.

## 2. Correction

The controlled corrective wrapper:

- replaced multi-row dependency-ID capture with `mapfile`;
- validated that exactly three dependency IDs were produced for OQ2-09;
- parsed the requirement fixture using an explicit `|` delimiter;
- retained the original harness and failed execution in history rather than rewriting them away.

## 3. Corrective Retest

A new PostgreSQL 16.15 instance was initialized from scratch. Migrations 0001–0008 were reapplied and the entire ARC-PERSIST-OQ-002 set was executed in one run.

Result:

- OQ2-01 through OQ2-16: PASS
- PASS: 16
- FAIL: 0
- Gate: PASS

Terminal execution evidence:

`ARC-PERSIST-OQ-002 SUMMARY PASS=16 FAIL=0`  
`ARC-PERSIST-OQ-002 GATE=PASS`

## 4. Closure

**ARC-DEV-007 is CLOSED — CORRECTED AND RETESTED.**

The closure applies to the OQ harness defect only and does not enlarge the qualification claims beyond the tested controlled persistence scope.

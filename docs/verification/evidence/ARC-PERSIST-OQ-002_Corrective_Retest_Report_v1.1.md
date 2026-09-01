# ARC-PERSIST-OQ-002 — Corrective Retest and Operational Qualification Report

**Document ID:** ARC-PERSIST-OQ-002-RETEST  
**Version:** 1.1  
**Status:** CONTROLLED — EXECUTED / PASS FOR TESTED PERSISTENCE SCOPE  
**System:** Archemedica / BAS360-WebSystem  
**Author / Document Owner:** Cassandra Harrison  
**Execution Date:** 2026-09-01  
**Final Execution Commit:** `ad9f4a5ce704ebf1df354628d0d7c35db533b3ab`  
**Corrective Migration Commit:** `5b79b8308fbbffdaedeef49a073ac1c0b8d48d87`  
**Final GitHub Actions Run:** `33525332032`  
**Final Job:** `99914588124`  
**Database:** PostgreSQL 16.15  

## 1. Purpose

Document the controlled corrective sequence, complete retest, and final disposition of ARC-PERSIST-OQ-002 following the initial operational-qualification gate failure.

## 2. Preserved Initial Execution

Initial run `33524599328` / job `99912105063` produced:

- PASS: 6
- FAIL: 1
- NOT IMPLEMENTED: 9
- Overall: FAIL

The initial failure and missing controls remain preserved in `ARC-PERSIST-OQ-002_Execution_Report_v1.0.md`.

The direct failure was OQ2-14: PostgreSQL tenant context was session-persistent and therefore unsafe as the primary contract for pooled application connections. The nine NOT IMPLEMENTED scenarios identified absent mandatory operational controls rather than being treated as future optional enhancements.

## 3. Corrective Implementation

Migration `db/migrations/0008_operational_control_plane.sql` added the controlled operational-control plane required by the failed OQ:

1. transaction-local request context via `archemedica_security.establish_request_context(...)`;
2. idempotent command intake and completion binding;
3. consumer delivery deduplication persistence;
4. outbox claim and reconciliation transitions;
5. safety/quality/regulatory/data-integrity hold precedence;
6. causal episode open-or-reuse semantics;
7. duplicate causal basis/path deduplication;
8. contextual dependency-impact assessment separating `POTENTIALLY_AFFECTED`, `REASSESSMENT_REQUIRED`, `UNKNOWN`, and `NOT_MATERIALLY_AFFECTED`;
9. requirement-level supersession currency propagation;
10. single-authoritative-successor uniqueness controls across controlled version chains.

## 4. Verification-Harness Deviation

The first corrective execution passed OQ2-01 through OQ2-08, then stopped because of a shell fixture/capture defect documented as ARC-DEV-007. No database-control failure was established by that event.

The harness was corrected without combining partial runs into an artificial PASS. The final execution began from a fresh PostgreSQL service and reapplied migrations 0001–0008 before executing all 16 OQ scenarios.

## 5. Final Corrective Retest Results

| Scenario | Result | Verified Control |
|---|---|---|
| OQ2-01 | PASS | exactly one same-revision DER transition wins; competing write is stale-rejected |
| OQ2-02 | PASS | duplicate command reuses one completed business-effect binding |
| OQ2-03 | PASS | duplicate consumer delivery is deduplicated to one consumer record |
| OQ2-04 | PASS | injected transaction failure rolls canonical change back |
| OQ2-05 | PASS | outbox crash path enters reconciliation and can be reclaimed while consumer effect remains deduplicated |
| OQ2-06 | PASS | active safety hold takes precedence over approval/clean closure |
| OQ2-07 | PASS | remediation with same causal basis reuses existing open reassessment episode |
| OQ2-08 | PASS | duplicate dependency-path basis resolves to one open causal episode |
| OQ2-09 | PASS | materiality fan-out distinguishes reassessment-required, potential impact, and unknown; no blanket cascade |
| OQ2-10 | PASS | false HIGH assertion remains historically visible as `REJECTED` |
| OQ2-11 | PASS | requirement supersession stales affected RSA only; unrelated RSA remains current |
| OQ2-12 | PASS | identical idempotency keys remain tenant-isolated |
| OQ2-13 | PASS | wrong-tenant worker cannot see another tenant's outbox record |
| OQ2-14 | PASS | transaction-local authorization context clears across pooled logical request boundaries |
| OQ2-15 | PASS | concurrent successor attempts yield one authoritative successor chain |
| OQ2-16 | PASS | `RECONCILIATION_REQUIRED` persists across database sessions |

**Final Result: 16 PASS / 0 FAIL.**

GitHub execution terminated with:

`ARC-PERSIST-OQ-002 SUMMARY PASS=16 FAIL=0`  
`ARC-PERSIST-OQ-002 GATE=PASS`

## 6. Expected Adversarial Errors Observed

The following errors are positive control evidence rather than unexplained defects:

- `ARC_STALE_WRITE_REJECTED` during the concurrent stale-write attack;
- injected division-by-zero causing transaction rollback;
- `ARC_ACTIVE_HOLD_BLOCKS_CLOSURE` during hold/approval race;
- unique constraint `uq_der_single_successor` rejecting the second concurrent successor.

## 7. Anti-Bureaucracy / Cross-Modality Finding

OQ2-09 verified the foundational rule that graph connectivity alone is not equivalent to material impact. The implementation can represent:

- materially affected → `REASSESSMENT_REQUIRED`;
- connected but not demonstrated material → `POTENTIALLY_AFFECTED`;
- insufficient support/coverage → `UNKNOWN`;
- rejected dependency → `NOT_MATERIALLY_AFFECTED`.

This reduces the risk that increased regulatory or cross-modality granularity becomes a blanket-reassessment bureaucracy. Pilot calibration must still measure false-cascade rate on representative scenarios.

## 8. Disposition

**ARC-PERSIST-OQ-002: PASS for the tested controlled persistence scope.**

This result authorizes progression to a controlled PQ / pilot-like end-to-end workflow qualification. It does **not** authorize production release.

## 9. Claim Boundary

This execution does not establish:

- production operational resilience;
- external message-system exactly-once delivery;
- customer-environment qualification;
- GxP validation;
- 21 CFR Part 11 compliance;
- ISO certification or conformity assessment;
- regulator acceptance;
- clinical/scientific correctness;
- policy fitness.

External system behavior remains outside this OQ unless separately integrated and qualified.

**END OF CONTROLLED DOCUMENT**

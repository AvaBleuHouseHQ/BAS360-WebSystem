# ARC-PERSIST-OQ-002 — Concurrency, Replay and Failure-Injection Protocol

**Document ID:** ARC-PERSIST-OQ-002  
**Version:** 1.0  
**Status:** CONTROLLED — DESIGN BASELINE / EXECUTION BLOCKED PENDING ARC-PERSIST-QUAL-001  
**System:** Archemedica / BAS360-WebSystem  
**Author/Document Owner:** Cassandra Harrison  
**Date:** 2026-09-01

## 1. Purpose
Define the next database operational-qualification attack set after ARC-PERSIST-QUAL-001 passes. The protocol tests single-reality state, duplicate/replayed commands, transaction rollback, outbox recovery, reconciliation states, causal-episode control, and false reassessment cascades under multi-session behavior.

## 2. Entry Criteria
Execution is not authorized until ARC-PERSIST-QUAL-001 has objective PASS evidence tied to a commit SHA. A failed predecessor execution must be corrected and regressed first.

## 3. Mandatory Scenarios
| ID | Attack | Expected Control |
|---|---|---|
| OQ2-01 | Two sessions transition same DER from same revision | exactly one succeeds; one receives stale-write rejection |
| OQ2-02 | Retry same command/idempotency key after success | one business effect only |
| OQ2-03 | Duplicate event delivery | one durable downstream effect |
| OQ2-04 | Transaction fails after DER update but before audit/outbox insert | entire transaction rolls back; no split reality |
| OQ2-05 | Outbox worker crashes after external side effect but before completion mark | record enters/re-enters controlled reconciliation; duplicate business effect prohibited |
| OQ2-06 | Safety/quality hold races approval transition | hold wins according to controlled precedence; approval cannot falsely close |
| OQ2-07 | Reassessment remediation creates derived updates | no new causal episode unless materially new basis exists |
| OQ2-08 | Same trigger replayed through multiple dependency paths | deduplicated to one causal episode where basis is identical |
| OQ2-09 | Fine-grained REQ/LCO dependency fan-out | only materially affected paths reopen; no blanket cascade |
| OQ2-10 | False HIGH dependency later rejected | original assertion retained; downstream state can be corrected without erasure |
| OQ2-11 | Requirement source superseded while decision open | affected RSA/EIG/DER becomes stale/reassessment-required as defined; unaffected contexts remain stable |
| OQ2-12 | Tenant A and Tenant B issue same idempotency key | keys isolated by tenant; no cross-tenant collision |
| OQ2-13 | Worker handles Tenant A outbox while session is Tenant B | access denied/fails closed |
| OQ2-14 | Connection pool reuses session without resetting tenant context | next request must not inherit prior tenant; qualification harness must prove explicit context reset requirement |
| OQ2-15 | Concurrent supersession of same controlled object | one authoritative successor chain; conflict is explicit |
| OQ2-16 | Crash/restart during RECONCILIATION_REQUIRED | state remains durable and discoverable after restart |

## 4. Anti-Silo / Anti-Bureaucracy Test
The persistence implementation shall not require a user to manually create duplicate records across clinical, device, CMC, software, diagnostic, quality or regulatory domains for the same underlying fact. OQ2-09 must measure whether one canonical change can project to multiple governed applicability/dependency views without duplicate source-of-truth entry.

## 5. False-Cascade Control
Granularity is not automatically safety. A `REQ-*` or `LCO-*` change shall not reopen every connected decision merely because a graph path exists. Reassessment must require a material causal basis and preserved dependency reasoning. The test shall distinguish:
- connected but not materially affected;
- materially affected;
- unknown due to insufficient coverage;
- stale due to source/version change.

`UNKNOWN` or insufficient coverage may block clean closure, but shall not be represented as a proven impact.

## 6. Evidence Requirements
Execution must capture:
- database/version identity;
- migration hashes/commit SHA;
- session identities;
- transaction timestamps;
- expected/actual revisions;
- idempotency keys;
- causal episode IDs;
- transition/audit/outbox row counts;
- injected failure point;
- post-recovery state;
- deviations and retest evidence.

## 7. Acceptance
All critical isolation, stale-write, idempotency, atomicity and no-false-closure scenarios must pass. False-cascade behavior must be bounded and explainable; an architecture that achieves safety by reopening everything fails the anti-bureaucracy criterion.

## 8. Claim Boundary
Passing this protocol would qualify only the tested controlled persistence behavior. It does not establish production operational resilience, external message-system exactly-once delivery, GxP validation, Part 11 compliance, ISO certification, regulator acceptance or customer-environment qualification.

## 9. Change History
| Version | Date | Change | Status |
|---|---|---|---|
| 1.0 | 2026-09-01 | Established multi-session concurrency/replay/failure-injection and false-cascade OQ design | CONTROLLED — EXECUTION BLOCKED |

**END OF CONTROLLED DOCUMENT**

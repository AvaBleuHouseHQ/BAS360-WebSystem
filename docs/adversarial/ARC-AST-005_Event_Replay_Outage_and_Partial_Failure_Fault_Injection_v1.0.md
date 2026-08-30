# ARC-AST-005 — Event Replay, Outage & Partial Failure Fault Injection

**Document ID:** ARC-AST-005  
**Version:** 1.0  
**Status:** CONTROLLED — SYSTEM-LEVEL ADVERSARIAL FINDING  
**System:** Archemedica  
**Effective Date:** 2026-08-30  
**Author/Document Owner:** Cassandra Harrison  
**Governed By:** ARC-STD-001 v1.0  
**Primary Affected Artifacts:** ARC-DER-SCHEMA-001; ARC-DDG-SCHEMA-001; ARC-PCDI-001; ARC-RDRE-001; ARC-CMR-001; ARC-DMOC-001  
**Disposition:** FAIL — REPAIRABLE; AT-LEAST-ONCE DELIVERY MUST NOT MEAN AT-LEAST-ONCE DECISION EFFECT

## 1. Fault Injection

Injected distributed-system failures:
1. RDRE receives the same regulatory source change three times after retries;
2. event bus delivers messages out of order;
3. DDG impact analysis succeeds but DER state update times out;
4. PCDI creates implementation tasks but audit-event persistence fails;
5. model-use record is written while output artifact storage is unavailable;
6. service restarts after acknowledging a command but before publishing its derived event;
7. a network partition causes two workers to process the same reassessment obligation;
8. outage recovery replays historical events into already superseded objects.

## 2. Failure Observed

The architecture contains idempotency concepts in later adversarial repairs, but v1 artifacts do not yet define an end-to-end transaction/replay contract. Partial success can therefore produce orphan state, duplicate obligations or missing audit causality.

This matters because a system that preserves perfect local records but loses the linkage between them cannot reconstruct what actually happened.

## 3. Required Repair — Durable Command/Event Processing Contract

For consequential operations:
- every command/event has a globally unique ID and idempotency key;
- consumers persist processing state before/with side effects using a transactional outbox/inbox or equivalent pattern;
- duplicate delivery is expected and safe;
- derived events record parent/root causal IDs;
- processing result records `NOT_STARTED`, `IN_PROGRESS`, `COMPLETED`, `FAILED_RETRYABLE`, `FAILED_TERMINAL`, `DUPLICATE`, `COMPENSATION_REQUIRED`;
- retries cannot create duplicate DERs, reassessment obligations, PCDI packets or model-use records;
- current object revision is checked before applying replayed effects;
- superseded/closed objects reject stale replay while preserving audit evidence;
- every partial failure leaves a detectable reconciliation state.

## 4. Atomicity Boundary

Archemedica must not pretend multi-service distributed transactions are perfectly atomic. Instead it must define explicit consistency boundaries and reconciliation.

A user-facing operation is not `COMPLETE` until all mandatory durable side effects are either confirmed or the system exposes a controlled `PARTIAL_FAILURE / RECONCILIATION_REQUIRED` state.

## 5. No Phantom Completion

Examples prohibited:
- PCDI shown `READY` when required artifact/audit writes failed;
- RDRE obligation shown closed when successor DER creation failed;
- model output shown as decision basis when immutable invocation provenance did not persist;
- DER shown superseded when dependency/event update did not complete and the discrepancy is hidden.

## 6. Recovery Rule

Restart/replay must be deterministic from canonical durable state plus event log. Recovery may re-run safe idempotent operations but cannot infer success from a previously emitted UI response alone.

## 7. Verification Tests

1. duplicate RDRE event creates one obligation/episode;
2. crash between state write and event publish reconciles correctly;
3. crash between event receive and state write retries safely;
4. two workers race on same obligation;
5. replay against superseded DER is rejected from mutation;
6. partial PCDI readiness transaction is visible and blocks release;
7. missing model output artifact prevents MATERIAL model-use completion;
8. outage recovery produces identical final canonical state on repeated runs;
9. audit trail distinguishes original processing from retries/duplicates;
10. reconciliation queue cannot silently age indefinitely.

## 8. Revised System Constraint

Archemedica shall assume at-least-once message delivery and partial failure. Exactly-once business effect must be achieved by idempotency, revision checks, durable processing records and reconciliation—not by assuming exactly-once infrastructure.

**END OF CONTROLLED DOCUMENT**
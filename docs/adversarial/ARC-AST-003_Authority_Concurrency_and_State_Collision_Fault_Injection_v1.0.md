# ARC-AST-003 — Authority, Concurrency & State Collision Fault Injection

**Document ID:** ARC-AST-003  
**Version:** 1.0  
**Status:** CONTROLLED — SYSTEM-LEVEL ADVERSARIAL FINDING  
**System:** Archemedica  
**Effective Date:** 2026-08-30  
**Author/Document Owner:** Cassandra Harrison  
**Governed By:** ARC-STD-001 v1.0  
**Primary Affected Artifacts:** ARC-DER-SCHEMA-001; ARC-PCDI-001; ARC-RDRE-001; ARC-DDG-SCHEMA-001; ARC-DMOC-001  
**Disposition:** FAIL — REPAIRABLE; SINGLE-REALITY STATE CONTROL REQUIRED

## 1. Fault Injection

Concurrent qualified actors were injected into the same live decision family:

1. Regulatory reviewer reaffirms a prior DER based on current jurisdiction interpretation.
2. Safety reviewer, seconds later, escalates a new safety concern on the same decision.
3. Site operations begins implementation based on the reaffirmed state.
4. QA places a hold before site implementation completes.
5. A successor DER is issued while another reviewer is still approving the predecessor.
6. A delayed event arrives from an external system showing an earlier state transition after the successor exists.

## 2. Failure Observed

Current architecture preserves state history and accountable humans but does not yet define a system-wide concurrency/authority ordering model. Two locally valid actions can therefore create two simultaneously plausible operational realities.

Examples:
- predecessor DER receives late approval after successor issuance;
- implementation task proceeds against a state later placed on hold;
- QA hold and Regulatory reaffirmation coexist without deterministic precedence;
- stale external event replays a transition against a superseded object;
- two reviewers both believe they acted on the current version.

This is a correctness failure, not merely a workflow inconvenience.

## 3. Required Repair — Controlled State Transition Envelope

Every consequential state mutation requires:
- stable object ID and lineage ID;
- expected prior version/state (`compare-and-set` semantics);
- monotonic revision or event sequence;
- actor identity and role;
- authority scope;
- effective timestamp and recorded-at timestamp;
- causal episode ID where applicable;
- command/event ID with idempotency key;
- conflict/hold flags;
- supersession/predecessor reference;
- transaction result: `APPLIED`, `REJECTED_STALE`, `MERGED_NONCONFLICTING`, `HOLD_CONFLICT`, `ESCALATED`.

A transition cannot silently apply if the object's current revision differs from the revision the actor reviewed.

## 4. Authority Is Contextual, Not Hierarchical by Title Alone

Archemedica must not encode a universal role hierarchy such as QA > Regulatory > Safety.

Instead, authority is action- and context-specific. Examples:
- Safety may issue an immediate protective hold within defined scope.
- QA may block controlled release/readiness under defined quality authority.
- Regulatory owns regulatory interpretation/disposition within assigned context.
- Decision Owner owns the final business/development decision only where no higher-priority safety/legal/control hold exists.

Conflicting authority produces `HOLD_CONFLICT` and explicit escalation; the system must not choose a winner by timestamp alone.

## 5. Precedence Controls

Minimum hard stops:
- active immediate-safety hold blocks ordinary implementation progression;
- active quality/release hold blocks readiness completion within its scope;
- superseded DER cannot accept new substantive approval;
- predecessor workflow may finish audit documentation but cannot become operationally current again without a controlled reopen/successor action;
- stale commands/events are retained but rejected from changing current state.

## 6. Distributed-Time Rule

`event_occurred_at` and `recorded_at` are separate. Ordering is based on controlled revision/causality, not wall-clock timestamps alone.

Late-arriving evidence can still be material and trigger reassessment, but a late message cannot simply overwrite a newer state.

## 7. Verification Tests

1. Regulatory reaffirmation vs simultaneous Safety hold.
2. QA hold while site implementation command is in flight.
3. predecessor approval arrives after successor DER issuance.
4. two users approve the same revision concurrently.
5. delayed external event arrives out of order.
6. emergency safety action bypasses ordinary queue but remains causally linked.
7. conflict resolves and previously blocked actions are deliberately re-authorized.
8. stale command is audit-visible but cannot mutate current state.

## 8. Revised System Constraint

No production-grade implementation/readiness transition may rely on last-write-wins semantics.

Archemedica requires optimistic concurrency or equivalent version-checked transition control plus explicit hold/authority semantics before consequential workflow automation is authorized.

**END OF CONTROLLED DOCUMENT**
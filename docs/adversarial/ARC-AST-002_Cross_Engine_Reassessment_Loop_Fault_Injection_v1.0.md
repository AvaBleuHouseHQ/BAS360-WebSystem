# ARC-AST-002 — Cross-Engine Reassessment Loop Fault Injection

**Document ID:** ARC-AST-002  
**Version:** 1.0  
**Status:** CONTROLLED — SYSTEM-LEVEL ADVERSARIAL FINDING  
**System:** Archemedica  
**Effective Date:** 2026-08-30  
**Author/Document Owner:** Cassandra Harrison  
**Governed By:** ARC-STD-001 v1.0  
**Primary Affected Artifacts:** ARC-EIG-SCHEMA-001; ARC-DDG-SCHEMA-001; ARC-DER-SCHEMA-001; ARC-PCDI-001; ARC-RDRE-001  
**Disposition:** FAIL — REPAIRABLE; CROSS-ENGINE REASSESSMENT REQUIRES CAUSAL EPISODE CONTROL

> **Finding:** Archemedica v1.0 components can each correctly generate reassessment triggers while collectively creating a self-sustaining reassessment loop because no system-level control currently distinguishes a genuinely new external/material change from a downstream artifact change caused by the system's own prior reassessment episode.

## 1. Fault Injection Scenario

A live oncology amendment decision was injected with this causal sequence:

1. relied-upon evidence becomes materially conflicted and EIG changes from supportable to `FAIL_CONFLICTED`/human review;
2. DDG correctly surfaces an affected DER;
3. DER enters `REASSESSMENT_REQUIRED`;
4. the accountable human creates a successor decision requiring a protocol/artifact change;
5. PCDI processes the change and updates controlled artifacts;
6. updated artifacts generate `ARTIFACT_CHANGED` or related change events;
7. DDG sees those artifacts as linked to the same decision family and surfaces the decision again;
8. PCDI/DER can therefore generate another reassessment despite the artifact change being a consequence of the original reassessment rather than a new independent basis.

A parallel path exists for RDRE: regulatory-source change -> RDRE reassessment -> successor DER/PCDI update -> artifact change -> DDG impact -> renewed reassessment of the same causal episode.

## 2. Why Existing Guards Do Not Fully Stop It

Current controls prevent graph recursion within a single traversal through visited-node sets and bounded depth. They do not provide cross-workflow event idempotency or causal episode identity.

DER preserves state history and supersession but does not define a system-wide reassessment episode identifier.

PCDI correctly treats subsequent protocol changes, implementation failures and regulatory/evidence changes as reassessment triggers, but does not distinguish a remediation artifact change already expected under an open reassessment from a genuinely new material trigger.

RDRE correctly creates reassessment obligations and artifact updates, but closure semantics do not by themselves suppress downstream self-generated change events from reopening the same causal matter.

EIG correctly emits changed supportability states, but does not own system-level event deduplication.

## 3. Failure Consequences

Without repair, the system may produce:
- repeated reassessment obligations for one root cause;
- duplicate DER successor creation;
- repeated PCDI packets;
- alert fatigue and bypass behavior;
- apparent regulatory/evidence instability that is actually system-generated;
- misleading audit history showing many 'new' triggers when there was one original cause;
- inability to establish whether a reassessment is closed;
- operational deadlock where an artifact cannot be updated without reopening the decision that ordered the update.

This is not merely a user-experience defect. It is a lifecycle-governance defect.

## 4. Required Repair — Reassessment Causal Episode Control

Introduce a system-level `REASSESSMENT_EPISODE` control object or event envelope with at minimum:

- stable `episode_id`;
- `root_trigger_event_id`;
- root trigger class/source;
- `parent_event_id` for derived events;
- causal depth/generation;
- affected decision family / DER lineage;
- expected remediation actions/artifacts;
- event fingerprint/idempotency key;
- already-evaluated event/object pairs;
- materially-new-basis flag;
- suppression/merge reason;
- open/blocked/resolved/closed lifecycle state;
- accountable episode owner;
- closure evidence;
- reopen reason when a truly new fact arises.

## 5. Mandatory Event Rule

A downstream event generated as an expected consequence of an open reassessment episode shall not create a new reassessment episode solely because it changes an artifact linked to the same decision.

It shall normally be classified as:

`DERIVED_REMEDIATION_EVENT — TRACK WITHIN EXISTING EPISODE`

A new/reopened episode is allowed only when the downstream event introduces a materially new basis, such as:
- remediation implementation failure;
- unexpected safety consequence;
- new contradictory evidence;
- new regulatory source/status change;
- materially different model/data result;
- scope/jurisdiction expansion not assessed in the parent episode;
- explicit human escalation supported by rationale.

## 6. Idempotency Rule

Equivalent event fingerprints within the same episode and decision lineage shall merge or be marked duplicate rather than create duplicate obligations.

Idempotency shall not suppress genuinely new evidence merely because the same artifact/DER is involved.

## 7. Closure Rule

An episode may close only when:
- all mandatory obligations are completed, consciously deferred, merged, or explicitly rejected;
- expected remediation artifact events have been reconciled;
- no unresolved blocking EIG/RDRE/PCDI conditions remain;
- accountable human closure is recorded;
- closure evidence is present.

A post-closure event may reopen the episode or create a successor episode only if it represents a materially new trigger.

## 8. Anti-Suppression Control

Loop prevention must not become change suppression.

The engine shall preserve every event in audit history, including suppressed/merged derived events, and record why the event did not create a new reassessment.

The system must never silently discard an event because it shares a root episode.

## 9. System-Level Revised Constraint

No automated cross-engine reassessment escalation is authorized until causal episode identity, idempotency, derived-event handling and closure/reopen semantics are implemented and tested.

This finding does not invalidate EIG, DER, DDG, PCDI or RDRE individually. It narrows the integrated architecture.

## 10. Verification Tests

At minimum:
1. EIG conflict -> DER reassessment -> PCDI artifact update must terminate in one episode;
2. RDRE source change -> DER/PCDI remediation -> artifact update must not reopen itself;
3. duplicate webhook/source/event must be idempotent;
4. remediation failure must create a materially-new trigger/reopen;
5. new safety signal during an open episode must not be suppressed as duplicate;
6. new jurisdiction applicability discovered during remediation must create/expand reassessment appropriately;
7. successor DER lineage must not cause predecessor/successor ping-pong;
8. closure followed by genuinely new contradictory evidence must reopen/create successor episode with full provenance;
9. all merged/suppressed events remain audit-visible;
10. bounded traversal plus episode control must terminate deterministically.

## 11. Falsification Criteria

Redesign the event architecture if episode bookkeeping becomes as complex as the governed work itself, if material new changes are incorrectly suppressed, if duplicate obligations remain common, if users cannot understand why an event was merged/reopened, or if deterministic termination cannot be demonstrated in curated end-to-end tests.

## 12. System-Level Significance

Archemedica requires two distinct protections:

1. **Dependency Coverage Assurance** — prevents false confidence from incomplete graph coverage.
2. **Reassessment Causal Episode Control** — prevents the system from treating its own remediation consequences as endlessly new causes.

Together they establish that impact analysis must know both the limits of its search space and the causal identity of the change being processed.

**END OF CONTROLLED DOCUMENT**
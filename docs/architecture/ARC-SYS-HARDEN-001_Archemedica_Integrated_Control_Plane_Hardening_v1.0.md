# ARC-SYS-HARDEN-001 — Archemedica Integrated Control Plane Hardening

**Document ID:** ARC-SYS-HARDEN-001  
**Version:** 1.0  
**Status:** CONTROLLED — HARDENING BASELINE  
**System:** Archemedica  
**Document Type:** Cross-Cutting System Integrity / Control Plane Contract  
**Effective Date:** 2026-08-30  
**Author/Document Owner:** Cassandra Harrison  
**Classification:** Proprietary / Controlled  
**Governed By:** ARC-STD-001 v1.0  
**Evidence Basis:** ARC-AST-001 through ARC-AST-009  
**Applies To:** ARC-EVID-REG-001; ARC-EIG-SCHEMA-001; ARC-DER-SCHEMA-001; ARC-DDG-SCHEMA-001; ARC-PCDI-001; ARC-RDRE-001; ARC-CMR-001; ARC-DMOC-001  
**Related ADR:** ADR-0010  
**Machine-Readable Contract:** `schemas/integrated-control-plane/ARC-SYS-HARDEN-001_Integrated_Control_Plane.schema.json`

> **Control statement:** The Integrated Control Plane provides shared system-integrity semantics required for safe composition of Archemedica's decision-integrity components. It does not determine scientific truth, regulatory compliance, clinical correctness, legal sufficiency, or production validation.

## 1. ADR-0010 Verdict

**Risk Tier:** 3  
**Disposition:** **BUILD — REQUIRED BEFORE INTEGRATED PRODUCTION AUTOMATION**

The red-team campaign found that component-local controls are insufficient. Archemedica requires a common control plane for uncertainty of dependency coverage, causal reassessment identity, concurrency/authority, authorization, idempotent processing, historical snapshot integrity, evidenced human oversight and operational-cost discipline.

This control plane is not a new customer-facing “engine.” It is shared infrastructure and semantics used by all consequential workflows.

## 2. Governing Principle — No False Closure

Archemedica shall not convert missing information, stale state, partial processing, authorization gaps, unresolved conflict or absent historical reconstruction into a clean `NO_IMPACT`, `COMPLETE`, `AUTHORIZED`, `PASS`, `READY` or equivalent state.

When system knowledge is insufficient, the state must remain explicitly bounded: `UNKNOWN`, `PARTIAL`, `STALE`, `CONFLICTED`, `RECONCILIATION_REQUIRED`, `HUMAN_REVIEW_REQUIRED`, `HOLD`, or other controlled uncertainty state.

## 3. Shared Control Envelope

Every consequential command, event, reassessment or state transition shall carry or resolve a shared control envelope containing at minimum:

- `tenant_id`;
- `object_id` and `lineage_id`;
- `object_revision` / expected prior revision;
- `event_id` or command ID;
- `idempotency_key`;
- `root_trigger_event_id` and `episode_id` where reassessment applies;
- `parent_event_id` where derived;
- actor identity / role / authority scope;
- authorization context/version;
- `event_occurred_at` and `recorded_at`;
- source/snapshot/version references relevant to the action;
- dependency coverage status where impact analysis is used;
- processing/reconciliation status;
- hold/conflict state;
- audit/provenance references.

Not every field must be manually entered. The system should derive them from canonical workflow/state whenever possible.

## 4. Control A — Dependency Coverage Assurance

### 4.1 Coverage States
- `SUFFICIENT_FOR_CONTEXT`
- `PARTIAL`
- `UNKNOWN`
- `STALE`
- `NOT_APPLICABLE`

### 4.2 Rule
Zero discovered dependencies may support `NO_IMPACT` only when coverage is `SUFFICIENT_FOR_CONTEXT` for the material impact domains expected by the decision/workflow.

`PARTIAL`, `UNKNOWN` or `STALE` coverage yields `IMPACT_NOT_ESTABLISHED` / human review, not no impact.

### 4.3 Context-Scoped Coverage
Coverage is evaluated against expected material domains for the specific workflow (e.g., PCDI safety/statistics/consent/data/regulatory/site/vendor dimensions), not against a universal ontology.

## 5. Control B — Reassessment Causal Episode

Every root trigger that may cause multi-engine reassessment receives an `episode_id`.

Derived remediation events retain the same episode unless a materially new basis is established.

Required states:
- `OPEN`
- `BLOCKED`
- `REMEDIATION_IN_PROGRESS`
- `RESOLVED_PENDING_CLOSURE`
- `CLOSED`
- `REOPENED`

Derived expected artifact changes do not create new episodes by themselves. New safety signals, contradictory evidence, regulatory status changes, implementation failures, materially different model/data results, new jurisdiction/scope or justified human escalation may reopen/create successor episodes.

Equivalent event fingerprints inside one episode/lineage are merged or marked duplicate, never silently discarded.

## 6. Control C — Single-Reality State & Concurrency

Consequential state transitions use revision-checked compare-and-set semantics or an equivalent correctness mechanism.

Allowed transaction outcomes:
- `APPLIED`
- `REJECTED_STALE`
- `MERGED_NONCONFLICTING`
- `HOLD_CONFLICT`
- `ESCALATED`

Last-write-wins is prohibited for consequential state.

A superseded object cannot accept a new substantive approval that makes it current again without controlled reopen/successor logic.

### 6.1 Scoped Holds
Safety, Quality, Regulatory and other authority are contextual. No universal job-title hierarchy is assumed.

Active safety/quality/legal/control holds block actions only within their defined scope and must include authority basis, effective time and release conditions.

Conflicting valid authorities yield `HOLD_CONFLICT`, not silent timestamp-based resolution.

## 7. Control D — Authorization-Aware Data Plane

Authorization applies across:
- canonical records;
- graph nodes/edges and every traversal hop;
- search/autocomplete/indexes;
- caches;
- event streams;
- derived analytics;
- audit logs;
- exports;
- external model/retrieval calls.

Shared public sources are separated from tenant-specific interpretations/dependencies. A global regulatory-source node may not become a cross-tenant bridge.

Unauthorized records must not affect path existence, counts, ranking or other observable side channels.

## 8. Control E — Durable Idempotent Processing & Reconciliation

Archemedica assumes duplicate delivery, out-of-order messages, retries, crashes and partial service failure.

Every consequential processing unit records:
- unique event/command identity;
- idempotency state;
- expected revision;
- processing state;
- durable side-effect state;
- derived event references;
- reconciliation requirement.

Processing states:
- `NOT_STARTED`
- `IN_PROGRESS`
- `COMPLETED`
- `FAILED_RETRYABLE`
- `FAILED_TERMINAL`
- `DUPLICATE`
- `COMPENSATION_REQUIRED`
- `RECONCILIATION_REQUIRED`

User-visible `COMPLETE`/`READY` states are prohibited when mandatory durable effects remain unresolved.

## 9. Control F — Decision-Time Snapshot Integrity

For material inputs relied upon by a consequential decision/model/regulatory interpretation/EIG assessment, preserve sufficient historical reconstruction information:
- source identity;
- exact version/revision;
- retrieval/inspection time;
- hash where available/lawful;
- archive or native historical-version reference;
- transformation/preprocessing version;
- assessment version tied to the snapshot;
- retention/rights limitations.

A live URL or friendly model name alone is insufficient.

If reconstruction cannot be assured, record `HISTORICAL_RECONSTRUCTION_LIMITED` and the consequence for defensibility/reassessment.

## 10. Control G — Evidenced Human Oversight

For material HIGH/CRITICAL or conflicted decisions, human review controls must establish that:
- reviewer authority/scope is valid;
- required material evidence/conflicts/limitations were made available;
- unresolved issues were explicitly addressed or deferred;
- override/deviation has a substantive basis;
- independence requirements, where applicable, are preserved;
- emergency-path rationale is controlled and later reconciled.

Archemedica does not claim to prove cognition from clicks, reading time or keystrokes.

Risk-based staged review may hide system recommendations until the human performs an initial assessment where automation anchoring risk is material.

## 11. Control H — Evidence Once, Project Many

The control plane shall minimize manual governance burden:
- canonical data is ingested/entered once;
- EIG/DER/PCDI/RDRE/DDG/DMOC are projections/workflows over shared canonical facts;
- edge candidates derive from explicit workflow references wherever possible;
- audit events emit automatically from state changes;
- causal/tenant/version metadata propagates automatically;
- human input focuses on material uncertainty, conflict, classification and accountable judgment.

No new mandatory control is accepted without a defined risk reduction and burden justification.

## 12. Unified End-to-End State Rule

For a consequential decision lifecycle, Archemedica must be able to answer:
1. What exact evidence/model/regulatory/artifact versions were used?
2. What material dependency domains were assessed, and how complete was coverage?
3. What was decided, by whom, under what authority and object revision?
4. What events subsequently changed the basis?
5. Which events were root causes vs derived remediation?
6. Which actions were applied, rejected stale, blocked, retried, reconciled or superseded?
7. What remained unknown/conflicted/limited at each point?
8. What current decision/artifact state is operationally authoritative now?
9. Can the answer be produced without exposing another tenant's data?
10. Can the exact historical state be reconstructed after source systems have changed?

If any answer is unavailable, the system shall expose the limitation rather than infer certainty.

## 13. Mandatory Integrated Verification Matrix

Before integrated production automation, test at minimum:

1. Missing true DDG edge with zero-result impact search.
2. False HIGH edge causing excessive reassessment.
3. EIG conflict → DER → PCDI remediation loop terminates in one causal episode.
4. RDRE remediation artifact does not self-reopen absent new basis.
5. Regulatory reaffirmation races Safety hold.
6. Predecessor approval arrives after successor issuance.
7. Cross-tenant traversal through shared regulatory source leaks nothing.
8. Elevated cached graph result cannot be returned to lower privilege.
9. Duplicate event/replay produces one business effect.
10. Crash between state write and derived-event publication reconciles.
11. Live source changes after decision; historical basis remains reconstructable.
12. Prior EIG PASS cannot display against changed source content as current.
13. High-risk reviewer rubber-stamps unresolved conflict; gate detects insufficient review basis.
14. Emergency path is used and retrospective obligations reconcile.
15. Full protocol amendment can be processed without duplicate manual metadata entry.
16. Strong checklist + incumbent systems baseline comparison.

Each test must define expected state, prohibited state, audit evidence and pass/fail criteria before execution.

## 14. Product Kill / Narrow Criteria

Narrow or kill the integrated Archemedica operating-layer thesis if:
- cross-cutting control plane complexity becomes comparable to the governed workflows;
- false-negative dependency risk remains high;
- event/episode logic cannot deterministically terminate;
- tenant authorization cannot be proven across derived surfaces;
- historical reconstruction is frequently impossible;
- human review remains ceremonial despite controls;
- manual maintenance remains comparable to performing the underlying work;
- strong baseline teams achieve equivalent decision reconstruction and impact detection at materially lower cost;
- users rely on shadow documents as the true workflow.

## 15. Current Authorization Boundary

Authorized now:
- architecture/schema implementation;
- deterministic end-to-end test harnesses;
- synthetic/controlled pilot scenarios;
- integration prototyping;
- measurement of burden/precision/false negatives/false cascades.

Not authorized by this artifact:
- claims of GxP validation;
- Part 11 compliance;
- regulator acceptance;
- autonomous clinical/regulatory decisions;
- cross-tenant learning;
- determinative HIGH/CRITICAL model use;
- production automation without passing integrated verification.

## 16. ADR-0010 Adversarial Review

1. **Problem:** PASS — cross-engine composition created real system-level failures.
2. **Existing solution:** distributed systems/security/workflow patterns exist; integrate standard mechanisms rather than invent cryptography/transaction theory.
3. **Commodity:** infrastructure controls are not moat.
4. **Moat:** qualified — decision-specific semantics and continuity remain differentiating only if burden stays low.
5. **Integration:** required.
6. **Evidence:** eight controlled fault injections establish architecture need.
7. **Counter-evidence:** control plane may make product too complex.
8. **Regulatory:** no compliance inference.
9. **Failure mode:** over-control/governance paralysis is now a first-class risk.
10. **Customer:** PMF still provisional.
11. **Workflow:** controls must be mostly automatic.
12. **Dependencies:** high, but shared layer reduces duplicated semantics.
13. **Reversibility:** implementation technologies remain replaceable.
14. **Data rights:** tenant/rights context remains mandatory.
15. **Security:** authorization-aware data plane is production prerequisite.
16. **Validation cost:** high; test harness required.
17. **Simpler alternative:** strong existing tools + SOP remains reference competitor.
18. **Strongest NO-BUILD:** the control plane turns Archemedica into a distributed QMS bureaucracy nobody wants.
19. **Rebuttal:** controls are shared and machine-propagated; human work is exception-focused; kill criteria remain explicit.
20. **Final disposition:** **BUILD — REQUIRED BEFORE INTEGRATED PRODUCTION AUTOMATION.**

## Change History

| Version | Date | Change | Disposition |
|---|---|---|---|
| 1.0 | 2026-08-30 | Integrated hardening derived from ARC-AST-001–009 | BUILD — REQUIRED BEFORE INTEGRATED PRODUCTION AUTOMATION |

**END OF CONTROLLED DOCUMENT**
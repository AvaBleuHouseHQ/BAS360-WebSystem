# ARC-PILOT-001 — Protocol Amendment Decision Continuity Pilot

**Document ID:** ARC-PILOT-001  
**Version:** 1.0  
**Status:** CONTROLLED — PILOT IMPLEMENTATION BASELINE  
**System:** Archemedica / BAS360-WebSystem  
**Risk Tier:** 3  
**Author/Document Owner:** Cassandra Harrison  
**Governed By:** ARC-STD-001 v1.0  
**Primary Workflow:** ARC-PCDI-001 v1.0  
**Integrated Control Baseline:** ARC-SYS-HARDEN-001 v1.0  
**Qualification Predecessor:** ARC-SDLC-VERIFY-001 v1.0

> **Control boundary:** This pilot converts the surviving Archemedica decision-continuity architecture into the thinnest persistent application slice needed to test real workflow value. It does not establish GxP validation, 21 CFR Part 11 compliance, clinical correctness, regulator acceptance, production qualification, or production release authorization.

## 1. Pilot Question
Can Archemedica process a representative protocol amendment while preserving evidence, dependency, uncertainty, accountable decision, implementation state, reassessment and supersession history sufficiently well that a sponsor can later reconstruct what was known, what changed, who decided, why, and what required reassessment — with materially less reconciliation burden than a disciplined checklist plus incumbent systems?

## 2. Strongest NO-BUILD
A sponsor may already accomplish the workflow with protocol redlines, eTMF/QMS/RIM, CTMS/EDC, regulatory intelligence, spreadsheets, checklists, meetings and disciplined humans at lower cost and with less system-maintenance burden.

The pilot is justified only because Archemedica's surviving hypothesis is narrower: persistent decision/evidence/dependency continuity may reduce missed impacts, stale decisions, reconstruction effort and duplicate manual metadata. This hypothesis must be measured, not assumed.

## 3. Scope — Thin Vertical Slice
The pilot shall implement only the minimum persistent workflow necessary to exercise:

1. tenant and study context;
2. baseline and proposed protocol identity/version/snapshot;
3. atomic `PCHG-*` change records;
4. human confirmation/reclassification of material changes;
5. multidimensional impact assessment with explicit `NOT_ASSESSED`;
6. dependency coverage and explainable DDG impact candidates;
7. evidence references and EIG supportability state;
8. regulatory applicability/uncertainty;
9. accountable DER decision and alternatives;
10. scoped holds/conflicts and revision-controlled state transition;
11. implementation-readiness obligations and site/jurisdiction effective state;
12. post-implementation evidence;
13. reassessment causal episode;
14. supersession without erasure;
15. audit reconstruction of the decision-time basis.

## 4. Explicit Non-Scope
Do not build during ARC-PILOT-001 unless a controlled pilot defect makes it necessary:

- generic AI assistant/chatbot;
- investor modules;
- generic site selection or trial matching;
- autonomous protocol optimization;
- broad regulatory-news monitoring;
- cross-tenant benchmarking or learning;
- universal ontology;
- open model marketplace;
- determinative HIGH/CRITICAL model authority;
- automatic regulatory submission generation;
- automatic EDC/IRT implementation;
- dashboard sprawl unrelated to the pilot decision chain.

## 5. Required Persistent Controls
The application slice shall implement, rather than merely document, the ARC-SYS-HARDEN-001 controls relevant to this workflow:

### 5.1 No False Closure
`UNKNOWN`, `PARTIAL`, `STALE`, `CONFLICTED`, `RECONCILIATION_REQUIRED`, `HUMAN_REVIEW_REQUIRED` and `HOLD` may not be silently converted to `NO_IMPACT`, `PASS`, `AUTHORIZED`, `READY` or `COMPLETE`.

### 5.2 Dependency Coverage
A zero-result dependency search may support `NO_IMPACT` only when coverage is `SUFFICIENT_FOR_CONTEXT`. Otherwise the workflow shall produce `IMPACT_NOT_ESTABLISHED — HUMAN REVIEW REQUIRED` or an equivalently controlled state.

### 5.3 Single-Reality State
Consequential state transitions require expected prior revision/state. Stale writes shall be rejected rather than last-write-wins. Holds are scoped to defined authority/action contexts.

### 5.4 Causal Episode Control
Reassessment shall preserve root trigger, parent event and episode identity. Expected remediation within an episode shall not create a new episode absent materially new basis.

### 5.5 Idempotent Processing
Duplicate/replayed commands or events shall create one business effect. Partial failure shall remain visible and reconcilable; no phantom completion.

### 5.6 Authorization-Aware Data Plane
Tenant/security context shall apply to canonical records, dependencies, derived views, search/index/cache behavior, events, audit records and exports. Shared public evidence shall not bridge tenant-specific decision graphs.

### 5.7 Decision-Time Snapshot Integrity
Material relied-upon evidence shall preserve the exact decision-time source/version/revision, inspection/retrieval time, hash or native historical locator where available, transformations, EIG assessment version and known retention/rights limitations. Reconstruction limits shall be explicit.

### 5.8 Evidenced Human Oversight
For high-risk/conflicted decisions, preserve reviewer role/scope, unresolved issues, material evidence/conflict availability, override/deviation basis and accountable disposition. System recommendations shall not convert failed evidence into supported evidence.

### 5.9 Evidence Once, Project Many
Canonical facts shall be captured once and projected into workflow views. Pilot users shall not be required to independently retype the same metadata into EIG, DER, PCDI, DDG or reassessment records.

## 6. Pilot Scenario
Use a representative oncology protocol amendment containing at minimum:

- eligibility change;
- dose modification;
- mixed/conflicting evidence;
- one material computational-model influence;
- a regulatory-source change after initial decision;
- differing jurisdiction applicability;
- one missing true dependency and one incorrect high-materiality dependency;
- staggered site implementation;
- an unexpected safety signal;
- a prior human override;
- later outcome evidence that challenges an assumption;
- six-month audit reconstruction request.

Synthetic/controlled data may be used until lawful customer pilot data and appropriate controls exist.

## 7. Minimum Application Objects
The pilot may use a relational persistence layer, but shall preserve controlled IDs and immutable/superseding lineage for at least:

- Tenant
- Study
- ProtocolVersion
- EvidenceSnapshot
- ProtocolChange (`PCHG-*`)
- ImpactAssessment
- Dependency / DependencyCoverage
- EvidenceIntegrityAssessment
- DecisionEvidenceRecord (`DER-*`)
- ImplementationObligation
- Site/JurisdictionEffectiveState
- ReassessmentEpisode
- StateTransitionEvent
- AuditEvent

Existing controlled schemas remain authoritative where applicable. Do not create duplicate competing sources of truth.

## 8. Minimum User Workflow
A pilot user shall be able to:

1. establish tenant/study and protocol versions;
2. register/import proposed changes;
3. confirm/reclassify changes;
4. see required impact domains and unresolved `NOT_ASSESSED` items;
5. review explainable dependency candidates and coverage state;
6. inspect evidence supportability and conflicts;
7. record regulatory applicability/uncertainty;
8. make or defer an accountable decision with rationale and alternatives;
9. see readiness obligations and blocking holds;
10. record implementation evidence/effective state;
11. receive a controlled reassessment obligation when the decision basis changes;
12. issue a successor decision without erasing the predecessor;
13. reconstruct the original decision-time basis and subsequent changes.

## 9. Acceptance Metrics
Predefine thresholds before formal pilot execution. At minimum measure:

- true material-change recall;
- false-change rate;
- material-impact precision and recall;
- missed material dependencies;
- false reassessment cascades;
- duplicate business effects under replay;
- stale-write rejection;
- tenant-isolation failures;
- unresolved-item closure;
- duplicate manual metadata entries;
- human override rate and rationale completeness;
- time to initial impact packet;
- time to reconstruct six-month decision history;
- percentage of metadata prepopulated/derived rather than manually re-entered;
- comparison with strong checklist/incumbent workflow;
- user-perceived burden and value.

No superiority threshold is pre-claimed in this baseline.

## 10. Mandatory Adversarial Tests
Before pilot disposition, execute at least:

1. missing true dependency with incomplete coverage;
2. false HIGH dependency;
3. stale approval after successor decision;
4. Safety/Quality hold racing ordinary approval;
5. duplicate/replayed event;
6. partial failure between durable state and derived obligation;
7. changed live evidence after decision;
8. stale EIG result against changed evidence;
9. cross-tenant traversal through shared public source;
10. privilege downgrade/cache scenario where applicable;
11. rubber-stamp high-risk review with unresolved conflict;
12. emergency/immediate-hazard route with retrospective obligations;
13. regulatory change reopening affected interpretation/decision;
14. model/preprocessing version change affecting decision basis;
15. later outcome undermining an assumption;
16. full six-month historical reconstruction;
17. evidence-once/manual-burden comparison;
18. strong checklist/incumbent null-hypothesis comparison.

Failures shall be preserved as controlled deviations with corrective change and retest; no silent rewrite.

## 11. SDLC / Change-Control Gate
ARC-PILOT-001 shall use the established controlled development sequence:

**Change Control → Requirements/Traceability → Implementation → IQ → OQ → PQ → Deviations → Corrective Change → Retest → Regression → Pilot Disposition.**

The deterministic ARC-SYS-HARDEN-001 harness becomes a regression baseline, not proof that the persistent implementation is qualified.

## 12. Pilot Kill / Narrow Criteria
Kill or materially narrow ARC-PILOT-001 if any of the following persists after reasonable corrective iteration:

- dependency maintenance burden approaches manual impact assessment burden;
- users maintain shadow spreadsheets/email as the true workflow;
- material false negatives are not reduced versus strong checklist baseline;
- false cascades/alerts overwhelm reviewers;
- tenant isolation cannot be demonstrated across derived surfaces;
- historical reconstruction remains materially incomplete;
- human review becomes ceremonial;
- duplicate manual metadata remains substantial;
- sponsor team requires dedicated graph/governance administrators;
- strong incumbent process achieves equivalent decision continuity at lower burden;
- pilot users do not perceive enough value to change behavior or pay.

## 13. Success / Expansion Gate
Expansion beyond the thin vertical slice requires evidence that:

1. the persistent controls work under the implemented stack;
2. decision reconstruction is materially stronger/faster than baseline;
3. manual burden is lower than the governed work it replaces/coordinates;
4. false-negative and false-cascade performance is acceptable for the defined context;
5. users understand and act on uncertainty/holds rather than bypassing them;
6. the product creates measurable workflow value beyond commodity redline/task/document functions.

Only after this gate should additional domain engines or broader integrations be considered.

## 14. Initial Disposition
**BUILD — CONTROLLED PERSISTENT PILOT SLICE. DO NOT GENERALIZE.**

The architecture has survived the design-level adversarial campaign and deterministic harness. The next falsifiable question is whether those semantics survive a real persistence/application layer and beat a disciplined existing process without becoming a second bureaucracy.

## 15. Change History

| Version | Date | Change | Disposition |
|---|---|---|---|
| 1.0 | 2026-09-01 | Established controlled persistent Protocol Amendment Decision Continuity pilot baseline | BUILD — CONTROLLED PERSISTENT PILOT SLICE |

**END OF CONTROLLED DOCUMENT**
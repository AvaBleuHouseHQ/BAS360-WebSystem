# ARC-DER-SCHEMA-001 — Archemedica Decision Evidence Record Schema

**Document ID:** ARC-DER-SCHEMA-001  
**Version:** 1.0  
**Status:** CONTROLLED — DESIGN BASELINE  
**System:** Archemedica  
**Document Type:** Canonical Data Contract / Decision Integrity Schema  
**Effective Date:** 2026-08-29  
**Author/Document Owner:** Cassandra Harrison  
**Classification:** Proprietary / Controlled  
**Governed By:** ARC-STD-001 v1.0  
**Evidence Baseline:** ARC-EVID-REG-001 v1.0  
**Related ADR:** ADR-0003  
**Machine-Readable Contract:** `schemas/decision-evidence-record/ARC-DER-SCHEMA-001_Decision_Evidence_Record.schema.json`  
**Repository Target:** `docs/architecture/ARC-DER-SCHEMA-001_Archemedica_Decision_Evidence_Record_Schema_v1.0.md`

> **Control statement:** A Decision Evidence Record (DER) is a structured, dependency-aware, lifecycle-controlled decision object. It is not a narrative memo. DER completeness shall never be interpreted as decision quality.

## 1. Canonical Decision Chain

**Question → Evidence → Assumptions → Analytical Basis → Alternatives → Assessment → System Recommendation (if any) → Accountable Human Decision → Impact → Reassessment → Supersession**

Human-readable packets and reports are renderings of the canonical object, not competing sources of truth.

## 2. Locked Design Decisions

1. DER is structured data, not an electronic memo.
2. Evidence is referenced from ARC-EVID-REG-001 rather than copied.
3. A precise Question of Interest is mandatory.
4. Model output, system recommendation, and final human decision are distinct.
5. Model influence and decision consequence are explicit.
6. Genuine alternatives are mandatory.
7. No universal confidence percentage is authorized.
8. Human override is preserved, not hidden.
9. Reassessment logic is first-class.
10. Supersession preserves history; no silent overwrite.
11. `INSUFFICIENT_EVIDENCE` is a valid final decision status.
12. DER completeness does not imply correctness, compliance, validation, or scientific validity.

## 3. Canonical Domains

### Identity / Tenant Context
`der_id`, schema version, tenant, program/study/project, environment. Cross-tenant references require a future governed authorization model.

### Decision Context
Decision type, ARC-STD-001 risk tier, Decision Owner, Proposal Owner, reviewers, timestamps.

### Question of Interest
Required: `question_of_interest`, `intended_decision`. Optional explicit scope/out-of-scope boundaries.

### Lifecycle
Normal path: `DRAFT → EVIDENCE_ASSEMBLY → UNDER_REVIEW → DECIDED → EFFECTIVE → MONITORED`.

Reassessment path: `DECIDED/EFFECTIVE/MONITORED → REASSESSMENT_REQUIRED → SUPERSEDED`, or after documented reassessment back to `MONITORED` when the decision remains supportable. `WITHDRAWN` is available with reason. State history is append-only.

### Evidence Basis
Three collections: supporting, counter-evidence, limiting evidence. References carry stable Evidence IDs and may preserve version/hash/snapshot used in the decision.

### Assumptions
Each material assumption requires ID, statement, basis evidence, confidence, consequence if false, falsification criterion, owner, and status.

### Analytical Basis
May contain methods, deterministic algorithms, computational models, AI/ML systems, parameters, input snapshots, outputs, limitations, and system recommendation.

Every model use records model ID/version, context of use, model influence, decision consequence, validation status for that COU, input/output refs, and limitations.

**Model influence:** `NONE / LOW / MODERATE / HIGH / DETERMINATIVE`  
**Decision consequence:** `LOW / MODERATE / HIGH / CRITICAL`

The credibility requirements arising from influence × consequence are intentionally deferred to a separate governed model credibility standard.

### Alternatives
At least two alternatives are required by v1.0: `CONSIDERED / SELECTED / REJECTED / DEFERRED`. ADR-0003 explicitly records a falsification trigger if this produces sham alternatives in real use.

### Assessment / Epistemic Status
Assessment preserves findings, known unknowns, conflicting evidence, evidence gaps, model uncertainty, assumption sensitivity, unresolved issues, and residual risk.

Epistemic status: `SUPPORTED`, `PARTIALLY_SUPPORTED`, `CONFLICTED`, `INFERRED`, `UNSUPPORTED`, `STALE`, `SUPERSEDED`, `OUTSIDE_CONTEXT_OF_USE`, `HUMAN_JUDGMENT_REQUIRED`, `INSUFFICIENT_EVIDENCE`.

### System Recommendation vs Human Decision
System recommendation, when present, has separate ID, provenance, basis and limitations. Final human decision separately records status, selected alternative, final decision, rationale, accountable owner, approval timestamp and references.

Decision status: `APPROVED / APPROVED_WITH_CONDITIONS / REJECTED / DEFERRED / INSUFFICIENT_EVIDENCE / WITHDRAWN`.

### Override
When human decision differs from system recommendation, both are preserved and override rationale/actor are recorded. The prior output is never rewritten to manufacture agreement.

### Impact
Affected controlled objects can include protocol, SAP, DMP, EDC, CRF, IB, ICF, submission, vendor/site plans, budget, timeline, risk, model, dataset, decision, SOP or other artifact.

Impact action: `REVIEW / UPDATE / REVALIDATE / REASSESS / NOTIFY / NO_ACTION / OTHER`.

### Reassessment
Every consequential DER includes at least one trigger. Trigger categories include assumption falsification, superseded evidence, protocol/model/regulatory change, safety signal, data correction, validation failure, security event, contradictory customer/outcome evidence, dependency failure and manual trigger.

### Provenance / Sealing
The object records creation/modification provenance, source-record refs, audit-event refs, and hash status. A SHA-256 record hash is permitted, but canonical serialization/sealing is **not** defined here and requires a separate controlled implementation standard.

## 4. Immutability Model

**Immutable after issuance:** DER ID, schema version, original creation timestamp, historical state events, historical evidence snapshots, historical model/system outputs, historical approvals, superseded record content.

**Append-only:** state history, audit events, reassessment events, outcome observations, overrides, supersession links.

**Mutable before DECIDED:** question wording, evidence assembly, assumptions, alternatives, assessment, draft analytical basis.

**After DECIDED:** clerical corrections require controlled correction metadata; substantive changes require reassessment and, when the decision basis changes, a new DER.

## 5. Core Validation Rules

1. DER ID is stable and unique.
2. Tenant is mandatory.
3. Question of Interest and intended decision are mandatory.
4. Evidence, assumptions, alternatives, assessment, decision, impact and reassessment are required for the canonical object.
5. Supporting evidence does not eliminate counter-evidence review.
6. Every material assumption has a falsification criterion.
7. At least two alternatives are required in v1.0.
8. `INSUFFICIENT_EVIDENCE` shall not be coerced into approve/reject.
9. Model use requires version, COU, influence and consequence.
10. `VALIDATED_FOR_COU` must be supported by external controlled validation evidence; the schema cannot confer that status itself.
11. System recommendation is optional; accountable human decision ownership is mandatory.
12. Human override preserves the original system recommendation.
13. At least one reassessment trigger is mandatory.
14. Supersession does not delete the earlier DER.
15. `SEALED` does not imply Part 11 compliance, GxP validation or legal e-signature sufficiency.
16. A complete DER may legitimately be `CONFLICTED`, `UNSUPPORTED` or `INSUFFICIENT_EVIDENCE`.

## 6. Initial Decision Dependency Graph Contract

- `DECISION_DEPENDS_ON_EVIDENCE`
- `DECISION_LIMITED_BY_EVIDENCE`
- `DECISION_ASSUMES`
- `DECISION_USED_MODEL`
- `DECISION_GOVERNED_BY_REGULATORY_SOURCE`
- `DECISION_AFFECTS_ARTIFACT`
- `DECISION_AFFECTS_DECISION`
- `DECISION_SUPERSEDES_DECISION`
- `EVIDENCE_SUPERSEDES_EVIDENCE`
- `MODEL_VERSION_SUPERSEDES_MODEL_VERSION`
- `DECISION_RESULTED_IN_OUTCOME`

No universal clinical-development ontology is authorized by this schema.

## 7. Explicit Non-Goals

This schema does not determine scientific truth, approve clinical decisions, replace accountable humans, replace EDC/CTMS/eTMF/DMS/QMS, create a universal confidence score, create an open model marketplace, establish regulatory compliance, define e-signatures, define validated cryptographic sealing, or establish a universal clinical ontology.

## 8. Separate Controlled Decisions Required Before Production

1. Database/persistence technology.
2. Tenant isolation architecture.
3. Access-control model.
4. Canonical hash serialization/sealing.
5. Audit-event schema.
6. Electronic-signature requirements, if applicable.
7. Model credibility / context-of-use matrix.
8. Correction-vs-supersession procedure.
9. Automated reassessment-trigger evaluation.
10. Retention/export/deletion policy.

These are not silently assumed by v1.0.

# Appendix A — ADR-0003: Adopt Revised DER

**Risk Tier:** 3  
**Disposition:** **BUILD — REVISED**

### Strongest NO-BUILD Case
DER could become an elaborate electronic memo that users complete after meetings. AI could populate plausible rationale and make weak decisions appear formally rigorous. The result would be false authority instead of Decision Integrity.

### Why It Survives
The design was revised so canonical DER is structured data; evidence stays external and referenced; model/system output is separated from accountable decision; alternatives/counter-evidence are mandatory; uncertainty is structured rather than collapsed to a confidence score; reassessment/supersession are first-class; and insufficient evidence is a valid outcome.

### Material Assumptions / Falsification

**ASM-ADR-0003-001:** Structured DER improves reconstruction of consequential decisions.  
**Falsification:** Pilot users cannot reliably reconstruct why a decision was made or revert to external narrative documents as the real source of truth.

**ASM-ADR-0003-002:** Evidence references are preferable to copying evidence into DER.  
**Falsification:** Versioned evidence cannot be reliably retrieved/reconstructed from immutable references or snapshots.

**ASM-ADR-0003-003:** Separating system recommendation from human decision reduces algorithmic authority laundering.  
**Falsification:** Users routinely treat system recommendation as the final accountable decision despite the separation.

**ASM-ADR-0003-004:** Decision-specific reassessment triggers create operational value.  
**Falsification:** Triggers create excessive false alerts or fail to identify materially stale decisions.

**ASM-ADR-0003-005:** Two alternatives can be represented without forcing artificial choices.  
**Falsification:** Real Tier 2/3 decisions repeatedly have only one lawful/feasible path and users invent sham alternatives.

### Residual Risks
False authority from structured completeness; poor evidence quality; sham alternatives; over-triggering; weak model credibility controls; user bypass; metadata burden; tenant/privacy leakage if implementation is weak; mutable evidence sources breaking reconstruction; accountability being delegated to “the system.”

### Reassessment Triggers
Reassess if pilots show ignored material fields, narrative side documents become the real source of truth, trigger precision is poor, graph implementation requires destructive changes, relevant regulatory expectations materially change, model-influence categories prove unusable, committee/delegation workflows are missing, or the two-alternative minimum produces artificial choices.

### Attestation Boundary
This artifact defines a governed architecture/data contract. It does not establish implementation, validation, security, GxP compliance, Part 11 compliance, regulatory acceptance, or fitness for a specific clinical/regulatory use.

## Change History

| Version | Date | Change | Disposition |
|---|---|---|---|
| 1.0 | 2026-08-29 | Revised DER schema incorporating ADR-0003 | BUILD — REVISED |

**END OF CONTROLLED DOCUMENT**
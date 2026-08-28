# ARC-STD-001 — Archemedica Adversarial Architecture & Build Decision Standard

**Document ID:** ARC-STD-001  
**Version:** 1.0  
**Status:** CONTROLLED — APPROVED FOR USE UNDER CURRENT EVIDENCE  
**System:** Archemedica  
**Document Type:** Governance / Architecture / Build Decision Standard  
**Effective Date:** 2026-08-28  
**Author/Document Owner:** Cassandra Harrison  
**Classification:** Proprietary / Controlled  
**Supersedes:** New document  
**Repository Target:** `docs/governance/ARC-STD-001_Archemedica_Adversarial_Architecture_and_Build_Decision_Standard_v1.0.md`

> **Control statement:** Significant Archemedica decisions are hypotheses until they survive proportionate adversarial review. Approval is provisional to current evidence. Superseded decisions are preserved and linked; they are not silently erased.

## 1. Purpose

This standard governs consequential Archemedica architecture, product, data, model, AI, scientific, regulatory, security, privacy, validation, integration, and build decisions.

It requires Archemedica to define the problem before selecting the solution; distinguish verified evidence from assumptions and inference; actively seek counter-evidence; state what would falsify material assumptions; identify reassessment triggers; preserve dissent; retain superseded decisions; and explicitly separate implementation, verification, validation, scientific credibility/context of use, regulatory relevance, security, provenance, and production readiness.

The objective is **decision integrity with proportional governance**, not maximal documentation.

## 2. Scope

This standard applies to material decisions affecting product architecture; clinical-development workflows; Decision Evidence Records; evidence ingestion/provenance; schemas; AI/ML; computational models/simulation; model context of use; evidence-integrity controls; regulatory mapping; security/privacy/tenancy; third-party systems and datasets; interoperability; validation strategy; GxP-relevant intended uses; algorithms/scoring; decision memory; retention/deletion; IP/moat capabilities; and BUILD/BUY/INTEGRATE/KILL choices.

Trivial, local, low-risk, readily reversible choices that cannot materially affect evidence, scientific interpretation, security, privacy, regulated workflows, customers, or architecture do not require a full review.

## 3. Governing Principles

1. **Evidence before conviction.** A preferred solution remains a hypothesis until supported.
2. **Challenge before commitment.** Consequential proposals require a credible NO-BUILD/alternative case.
3. **No silent erasure.** Supersession preserves the prior record and rationale.
4. **Risk proportionality.** Review rigor rises with consequence, uncertainty, irreversibility, model influence, regulatory relevance, security/privacy exposure, scientific impact, and cost of error.
5. **Reversibility is an asset.** Prefer optionality and replaceability when value is comparable.
6. **Integrate before unnecessary reinvention.** BUILD is not the default.
7. **Context matters.** No model, dataset, AI system, validation result, or evidence source is globally valid merely because it worked elsewhere.
8. **Human accountability remains explicit.**
9. **Uncertainty remains visible.** Conflicts and limitations shall not be hidden behind a score.
10. **BUILD is provisional.** It means approved under the current evidence and assumptions, not permanently correct.

## 4. Definitions

**Adversarial Decision Review (ADR):** Structured challenge of a proposed decision using evidence, counter-evidence, alternatives, failure analysis, falsification criteria, and reassessment triggers.

**Assumption:** A proposition treated as true for a decision but not established as verified fact.

**Attestation Boundary:** What reviewers can and cannot claim to have inspected, tested, verified, validated, or concluded.

**Context of Use (COU):** Defined role, scope, conditions, and purpose for which a model, AI system, evidence source, or component is intended.

**Counter-evidence:** Evidence that weakens, contradicts, or materially qualifies the proposal.

**Decision Owner:** Accountable person/role accepting the decision and residual risk.

**Dissent / Minority View:** Reasoned disagreement retained even when not adopted.

**Evidence ID:** Stable identifier connecting a decision to its evidentiary basis.

**Falsification Criterion:** Predefined evidence or observation that would materially undermine an assumption or require reassessment.

**Model Influence:** Degree to which model output affects a downstream decision.

**Model Risk:** Risk from incorrect, unreliable, inapplicable, misunderstood, or misused model output considered with the consequence of a wrong decision.

**Reassessment Trigger:** Defined event/evidence change requiring renewed review.

**Supersession:** Controlled replacement of a prior decision while retaining and linking its record.

## 5. Risk Tiers

### Tier 0 — Routine / Local / Readily Reversible
Examples: internal naming, non-material code organization, development-only tooling without material dependency.  
**Control:** normal engineering review; no formal ADR.

### Tier 1 — Meaningful but Reversible
Examples: replaceable UI library, low-risk internal service, reversible implementation pattern.  
**Control:** abbreviated ADR.

### Tier 2 — Architecture / Data / Model / Customer Workflow
Examples: material schema, external integration, model adapter, evidence-ingestion architecture, customer-facing decision workflow, retention architecture, major build-vs-integrate choice.  
**Control:** full ADR plus relevant technical/SME review.

### Tier 3 — Consequential / Regulatory / Scientific / Security / Moat
Examples: consequential clinical-development decision support; regulatory interpretation/mapping; scientific/model evidence with material influence; evidence-integrity controls; identity/tenant isolation; privacy-sensitive architecture; validation claims; irreversible core architecture; IP/moat-defining capability.  
**Control:** full ADR, independent QC/QA, relevant SME review, residual-risk acceptance, Decision Owner approval.

### 5.1 Mandatory escalation factors

Escalate for material increases in: consequence of wrong decision; regulatory/inspection relevance; scientific interpretation; patient/safety relevance; model influence; data sensitivity; security exposure; customer lock-in; irreversibility; financial exposure; dependency radius; uncertainty; inability to independently verify output; or reliance on an unvalidated/external component.

### 5.2 Anti-bureaucracy control

Risk shall not be understated to avoid review, nor inflated to create paperwork. Ask: **What is the smallest review that still controls the actual risk?**

## 6. Mandatory 20-Point Adversarial Review

Tier 2 and Tier 3 decisions address all tests.

1. **Problem Test:** What precise, evidenced pain/risk/rework/delay exists, and who experiences it?
2. **Existing-Solution Test:** Who already solves it, and why are current solutions insufficient?
3. **Commodity Test:** Is it commoditized now or likely within 24–36 months?
4. **Moat Test:** Does ownership deepen defensibility, workflow embedding, validated methodology, decision integrity, or institutional intelligence?
5. **Integration Test:** Should Archemedica integrate, buy, license, partner, or consume instead? Can the supplier be replaced?
6. **Evidence Test:** What supports the decision? Classify primary/secondary, observed/experimental, market, regulatory, internal, or inferred evidence.
7. **Counter-Evidence Test:** What credible evidence argues against it? What limitations weaken support?
8. **Regulatory Test:** What intended-use, GxP, submission, inspection, validation, documentation, oversight, records, or change-control burden is created? Are claims justified?
9. **Failure-Mode Test:** How can it fail, fail silently, or create a plausible but misleading output? Detection, containment, and worst credible consequence?
10. **Customer Test:** Who needs it, owns the pain, pays, and will adopt it?
11. **Workflow Test:** Does it remove work/reduce uncertainty/improve decisions, or merely add dashboards, alerts, scores, or reports?
12. **Dependency Test:** What depends on it? What is the blast radius? What hidden coupling is created?
13. **Reversibility Test:** Can it be replaced? What are migration and exit costs?
14. **Data-Rights Test:** What data are needed; who controls them; what rights cover processing, retention, model use, export, and deletion?
15. **Security/Privacy Test:** What attack surface, sensitive data, permissions, secrets, tenant boundaries, and sensitive logs are introduced?
16. **Validation-Cost Test:** What verification/validation and lifecycle retesting burden results, and is the value worth it?
17. **Simpler-Alternative Test:** Can 20% of engineering provide 80% of value, narrow the COU, or safely retain human control?
18. **Strongest Red-Team NO-BUILD Case:** State the strongest reasonable case against approval. No strawmen.
19. **Evidence-Based Rebuttal:** Answer with evidence and explicit assumptions, not optimism.
20. **Disposition:** Select exactly one: `BUILD`, `PILOT`, `INTEGRATE`, `DEFER`, `KILL`, `INSUFFICIENT EVIDENCE`.

Every disposition records rationale, residual risk, Decision Owner, and reassessment triggers.

## 7. Assumptions and Falsification

Tier 2/3 ADRs maintain an Assumption Register using `ASM-<ADR-ID>-###`.

For each material assumption record: statement; basis; confidence (High/Medium/Low); evidence IDs; consequence if false; falsification criterion; monitoring/reassessment method; owner.

A material assumption without a meaningful falsification criterion is incomplete unless the ADR explains why falsification is impracticable and defines an alternative reassessment method.

Additional confirming information does not automatically strengthen a decision; reviewers must determine whether it is independent or repeats the same underlying source/assumption.

## 8. Evidence and Counter-Evidence

Suggested IDs:

- `EVID-REG-####` regulatory/guidance
- `EVID-MKT-####` market/competitive
- `EVID-TEST-####` tests/benchmarks
- `EVID-USR-####` customer/user
- `EVID-ARCH-####` architecture/system
- `EVID-SCI-####` scientific/model
- `EVID-SEC-####` security
- `EVID-IP-####` lineage/IP provenance

Evidence status: `VERIFIED`, `PARTIALLY VERIFIED`, `PROVISIONAL`, `INFERRED`, `UNVERIFIED`, `SUPERSEDED`, or `REJECTED AS EVIDENCE`.

Where reasonably available record source, title/artifact, version/date, inspection date, authority, reference/location, hash for controlled local artifacts, relevant finding, and limitations.

Counter-evidence is first-class evidence and receives equivalent provenance/status treatment.

## 9. Reassessment and Supersession

Mandatory triggers include, as applicable: regulatory/guidance/standard change; material regulator interpretation; verification/validation failure; benchmark degradation; model drift or COU change; contradictory customer evidence; competitor change affecting build-vs-integrate economics; dependency/API/vendor change; security incident; privacy/data-rights change; unexpected production outcome; cost/latency/scalability breach; dependency failure; material scientific evidence; superseded evidence source; unacceptable false-positive/negative behavior; repeated human override; audit/inspection finding; or satisfaction of a falsification criterion.

When a decision changes:
1. preserve the prior ADR;
2. mark it `SUPERSEDED`;
3. create a new ADR;
4. link `supersedes` and `superseded_by`;
5. identify the trigger;
6. explain changed evidence;
7. identify downstream decisions requiring reassessment.

Deletion shall not be used to conceal decision history.

Every BUILD means: **approved under the evidence, assumptions, context, and risk assessment recorded as of the approval date.**

## 10. Review and Approval Gates

**Proposal Owner:** defines proposal, evidence, assumptions, and response to challenge.

**Adversarial Reviewer:** seeks alternatives/counter-evidence, challenges assumptions, and writes the strongest NO-BUILD case. Tier 3 review should be independent from the Proposal Owner where practicable.

**QC/QA Reviewer:** checks completeness, traceability, internal consistency, evidence/status labeling, terminology, version control, attestation boundaries, unsupported claims, confirmation bias, and governance-paralysis risk.

**SME Reviewer:** required where material specialized expertise is involved, including clinical operations, data management, biostatistics, modeling, regulatory, safety, quality, security/privacy, software architecture, or domain science.

**Decision Owner:** accepts disposition, residual risk, unresolved dissent, and reassessment triggers.

Dissent remains in the record after approval.

## 11. Attestation Boundaries

State what was actually inspected/tested. Do not collapse design alignment into compliance or validation.

Without supporting evidence, do not claim:
- FDA/EMA approval or acceptance;
- 21 CFR Part 11 compliance;
- GxP validation;
- scientific/clinical validation;
- production readiness;
- “unbreakable,” “hallucination-proof,” or equivalent absolutes.

Regulatory/guidance relationships shall be described as **alignment**, **mapping**, or **design consideration** unless stronger claims are independently supported.

## 12. ADR Templates

### 12.1 Tier 1 Abbreviated ADR

```text
ADR ID:
Title:
Date:
Risk Tier: 1
Proposal Owner:
Decision Owner:
Problem:
Proposed Decision:
Alternatives:
Supporting Evidence:
Key Assumptions:
Primary Failure Mode:
Reversibility:
Simpler Alternative:
Disposition: BUILD / PILOT / INTEGRATE / DEFER / KILL / INSUFFICIENT EVIDENCE
Rationale:
Reassessment Trigger(s):
Reviewer:
```

### 12.2 Tier 2/3 Full ADR

```text
ADR ID:
Title:
Version:
Status:
Date:
Risk Tier:
Proposal Owner:
Decision Owner:
QC/QA Reviewer:
SME Reviewer(s):
Adversarial Reviewer:
Supersedes:
Superseded By:

1. Question / Decision Required
2. Problem Statement
3. Context and Intended Use
4. Proposed Decision
5. Alternatives
6. Evidence Register
7. Counter-Evidence Register
8. Assumption Register
9. Falsification Criteria
10. 20-Point Adversarial Review
11. Failure Modes and Controls
12. Data Rights / Privacy
13. Security
14. Verification / Validation Burden
15. Strongest NO-BUILD Case
16. Evidence-Based Rebuttal
17. Dissent / Minority View
18. Residual Risks
19. Reassessment Triggers
20. Downstream Dependencies
21. Disposition
22. Approval
23. Attestation Boundary
24. Change / Supersession History
```

## 13. Regulatory and Scientific Alignment Boundary

This internal standard deliberately incorporates risk-based, context-specific, documented, lifecycle-oriented concepts relevant to contemporary drug-development governance, including human-centered oversight; risk proportionality; clear COU; multidisciplinary expertise; data governance/documentation; model design/development; risk-based performance assessment; lifecycle management; question of interest; model influence; consequence of wrong decision; model risk; model-informed evidence planning; model evaluation; and evidence documentation.

**This is design alignment, not a claim of regulatory compliance, validation, approval, acceptance, or fitness for a particular submission.**

## 14. Artifact and Repository Traceability

Controlled artifacts should record, where applicable: ID, title, version, status, owner, purpose, provenance, dependencies, assumptions/limitations, implementation status, verification status, validation status, scientific/COU status, regulatory relevance, security status, production-readiness status, QC/QA record, change history, content hash, repository path, and related ADR IDs.

A single label such as “validated” or “complete” shall not collapse materially different status dimensions.

## 15. Governance Performance Controls

Signs governance is too weak include repeated assumption-driven rework, unsupported claims, missing provenance, security/privacy surprises, inability to reconstruct decisions, and downstream breakage after upstream change.

Signs governance is too burdensome include unjustified Tier 0/1 escalation, ADR cost exceeding decision consequence, post-hoc paperwork, duplicated non-independent review, and material delay of low-risk reversible changes.

If either pattern becomes material, this standard must itself be reassessed.

## 16. Change Control

Material changes to risk tiers, mandatory tests, approval authority, evidence/falsification requirements, reassessment/supersession controls, QC/QA gates, or attestation boundaries require an ADR.

Editorial changes that do not alter requirements may use controlled document revision without full Tier 2/3 review.

---

# Appendix A — ADR-0001: Self-Test of ARC-STD-001

**ADR ID:** ADR-0001  
**Title:** Adopt ARC-STD-001  
**Version:** 1.0  
**Date:** 2026-08-28  
**Risk Tier:** 3  
**Disposition:** **BUILD — REVISED**  
**Decision Owner:** Archemedica Governance  
**Document Owner:** Cassandra Harrison

### Question
Should Archemedica adopt formal adversarial architecture/build governance before substantive product implementation?

### Decision
Yes, with four mandatory corrections to the original concept: risk proportionality; mandatory falsification criteria; explicit reassessment triggers; and BUILD as provisional under current evidence. No-erasure/supersession and attestation boundaries are also mandatory.

### Supporting Evidence
**EVID-REG-0001:** January 2026 FDA/EMA Good AI Practice principles provide relevant concepts including human-centric design, risk-based approach, clear COU, multidisciplinary expertise, data governance/documentation, risk-based performance assessment, and lifecycle management.

**EVID-REG-0002:** Final ICH M15 (June 2026) provides relevant concepts for planning, model evaluation, documentation, assessment of model-informed evidence, regulatory interactions, reporting, and submission.

**EVID-ARCH-0001:** Archemedica's intended architecture requires traceable, challengeable, reproducible, re-evaluable decisions; the build process should apply equivalent discipline to itself.

### Counter-Evidence
**CE-0001:** A 20-point review applied indiscriminately could slow an early-stage company and encourage ceremonial documentation.

**CE-0002:** Sophisticated ADRs can create false assurance when evidence is weak or challenge is not independent.

**CE-0003:** Excessive controls can freeze assumptions before product-market learning.

### Material Assumptions
**ASM-ADR-0001-001:** Consequential decisions benefit from formal adversarial review.  
Confidence: High.  
Falsification: repeated use fails to expose meaningful risk, change decisions, improve traceability, or reduce material rework.

**ASM-ADR-0001-002:** Risk tiering can preserve rigor without governance paralysis.  
Confidence: Medium.  
Falsification: low-risk work is repeatedly delayed, tiering is inconsistent, or administration materially exceeds controlled risk.

**ASM-ADR-0001-003:** Preserving superseded decisions improves institutional learning.  
Confidence: High.  
Falsification: retained history becomes unusable noise and fails to support reconstruction or reassessment despite reasonable indexing.

### 20-Point Review
1. Problem — unchallenged assumptions can become embedded architecture: **PASS**.
2. Existing solutions — conventional ADRs exist but usually omit our required falsification/reassessment discipline: **PASS WITH REUSE**.
3. Commodity — ADR documentation is commodity; disciplined application is the value: **PASS; NOT A MOAT ALONE**.
4. Moat — governance alone is not a moat; it can strengthen execution and Decision Integrity: **QUALIFIED PASS**.
5. Integration — reuse established ADR concepts rather than inventing everything: **PASS**.
6. Evidence — current regulatory principles support risk-based, context-specific, documented lifecycle thinking: **PASS**.
7. Counter-evidence — bureaucracy and false assurance are credible: **PASS AFTER REVISION**.
8. Regulatory — alignment is useful; compliance/approval claims are unjustified: **PASS WITH BOUNDARY**.
9. Failure mode — process theater, bias, over-tiering, rubber-stamping: **PASS AFTER CONTROLS**.
10. Customer — internal first; downstream benefit is product integrity: **PASS**.
11. Workflow — must reduce future rework, not create paperwork: **PASS AFTER ANTI-BUREAUCRACY CONTROL**.
12. Dependency — this standard governs later artifacts, so error has broad blast radius: **PASS / TIER 3**.
13. Reversibility — versionable and supersedable: **PASS**.
14. Data rights — minimal direct burden for the standard: **PASS**.
15. Security/privacy — ADRs may contain sensitive architecture/IP; controlled access required: **PASS WITH CONTROL**.
16. Validation cost — internal governance document; no software-validation claim: **PASS IF TIERED**.
17. Simpler alternative — ordinary ADR is simpler but omits critical controls; tiering preserves simplicity where safe: **PASS**.
18. NO-BUILD — formal governance could document the company to death before it ships: **CREDIBLE**.
19. Rebuttal — Tiers 0–3 and performance monitoring directly control that risk: **SUFFICIENT UNDER CURRENT EVIDENCE**.
20. Disposition — **BUILD — REVISED**.

### Strongest NO-BUILD Case
Archemedica is early; the dominant risk may be building something customers do not need rather than insufficient documentation. Heavy governance could make uncertain decisions look formally justified while slowing experiments. If every meaningful choice becomes Tier 3, the standard becomes a process failure.

### Rebuttal
The objection is accepted as a genuine risk. Tier 0 requires no ADR, Tier 1 is abbreviated, and only Tier 2/3 decisions receive full review. Governance-performance indicators require reassessment if burden becomes disproportionate. This preserves experimentation while controlling decisions where error is expensive, difficult to reverse, scientifically misleading, security relevant, or consequential.

### Dissent / Minority View
A reasonable minority view is that Tier 2 should default to abbreviated review until paying production customers exist. It is not adopted because pre-commercial architecture/data/model choices can create expensive path dependence. The dissent remains recorded and may be reconsidered if Tier 2 burden becomes demonstrably disproportionate.

### Residual Risks
Risk-tier inflation; ceremonial review; insufficiently independent challenge; stale evidence registers; excessive process for experiments; “temporary” choices becoming permanent.

### Reassessment Triggers
Reassess if ADR cycle time materially delays low-risk work; ADRs are routinely completed after implementation; Tier 2/3 reviews repeatedly provide no substantive challenge; architecture rework remains high; regulatory expectations materially change; Archemedica enters a formal validated/GxP context; security/privacy requirements materially change; or better automated governance mechanisms become available.

### Attestation Boundary
This self-test establishes only that the **design of ARC-STD-001** has been challenged for proportionality, falsifiability, reassessment, traceability, and internal governance risk.

It does **not** establish that Archemedica software is built or validated; that any component is GxP or Part 11 compliant; that FDA/EMA has reviewed or accepted Archemedica; or that future ADR conclusions will be correct merely because this process is followed.

### Final Decision
**BUILD — REVISED. ARC-STD-001 v1.0 is approved for internal Archemedica use under current evidence.**

---

# Appendix B — Release QC Checklist

- [x] Purpose/scope defined
- [x] Risk Tiers 0–3 defined
- [x] Escalation factors defined
- [x] Anti-bureaucracy control included
- [x] All 20 tests included
- [x] Falsification mandatory
- [x] Counter-evidence first-class
- [x] Six dispositions defined
- [x] Reassessment triggers defined
- [x] No-erasure/supersession defined
- [x] QC/QA and SME roles defined
- [x] Dissent preservation defined
- [x] Attestation boundaries defined
- [x] Unsupported compliance/validation claims prohibited
- [x] Abbreviated/full templates included
- [x] ADR-0001 self-test completed
- [x] Verdict BUILD — REVISED
- [x] Governance-paralysis risk controlled
- [x] Regulatory alignment distinguished from approval/compliance

## Change History

| Version | Date | Change | Disposition |
|---|---|---|---|
| 1.0 | 2026-08-28 | Initial controlled release | BUILD — REVISED |

**END OF CONTROLLED DOCUMENT**
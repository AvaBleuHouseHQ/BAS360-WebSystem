# ARC-EIG-SCHEMA-001 — Archemedica Evidence Integrity Gate

**Document ID:** ARC-EIG-SCHEMA-001  
**Version:** 1.0  
**Status:** CONTROLLED — DESIGN BASELINE  
**System:** Archemedica  
**Document Type:** Evidence Integrity / Claim-Support Assessment Gate  
**Effective Date:** 2026-08-29  
**Author/Document Owner:** Cassandra Harrison  
**Classification:** Proprietary / Controlled  
**Governed By:** ARC-STD-001 v1.0  
**Evidence Baseline:** ARC-EVID-REG-001 v1.0  
**DER Contract:** ARC-DER-SCHEMA-001 v1.0  
**DDG Contract:** ARC-DDG-SCHEMA-001 v1.0  
**Related ADR:** ADR-0005  
**Machine-Readable Contract:** `schemas/evidence-integrity-gate/ARC-EIG-SCHEMA-001_Evidence_Integrity_Gate.schema.json`

> **Control statement:** The Evidence Integrity Gate (EIG) assesses whether a claim is traceably supportable by cited evidence under a defined context. It does **not** determine scientific truth, clinical truth, regulatory truth, or absolute factual truth.

## 1. Purpose

The EIG answers: **Is this claim supportable by the evidence cited for it, within the stated context, and what prevents us from making a stronger claim?**

It evaluates provenance, source identity, citation resolvability, version integrity, claim/evidence alignment, contradictory evidence, limiting evidence, staleness/supersession, context fit, missing evidence, and need for accountable human review.

## 2. ADR-0005 Disposition

**Risk Tier:** 3  
**Disposition:** **BUILD — REFRAMED AND CONSTRAINED**

The original “Truth Gate” framing is rejected. The approved concept is **Evidence Integrity Gate**.

No citation engine, entropy detector, LLM, retrieval system, hash, provenance ledger, contradiction classifier, or model can generally establish scientific truth merely by examining textual support. Hashing can support byte integrity; provenance can support source traceability; citation resolution can establish source existence; entailment and contradiction methods can provide supportability signals. None alone proves scientific correctness.

## 3. Canonical Claim Object

Every assessment begins with a discrete claim containing stable claim ID, exact claim text, claim type, materiality, source artifact reference, and origin/author where known.

Authorized claim types: `FACTUAL`, `SCIENTIFIC`, `REGULATORY`, `MODEL_OUTPUT`, `INFERENCE`, `OPERATIONAL`, `SECURITY`, `DATA_RIGHTS`, `MARKET`, `OTHER`.

Materially distinct assertions should be decomposed when their evidentiary support differs.

## 4. Context Boundary

Every claim is evaluated within an intended use and, where applicable, decision reference, model context of use, population/scope, jurisdiction, effective date, and explicit out-of-scope conditions.

A claim supported in one context is not automatically supported outside that context.

## 5. Evidence Linkage

Evidence is referenced from ARC-EVID-REG-001 and classified as `SUPPORTS`, `CONTRADICTS`, or `LIMITS`.

A claim cannot receive an unqualified PASS solely because a supporting citation exists when material contradictory or limiting evidence remains unresolved.

## 6. Assessment Dimensions

**Traceability:** `COMPLETE / PARTIAL / BROKEN`  
**Source Quality:** `PRIMARY_AUTHORITATIVE / PRIMARY_OTHER / SECONDARY_HIGH / SECONDARY_OTHER / UNVERIFIED / MIXED`  
**Claim/Evidence Alignment:** `DIRECT / INDIRECT / WEAK / NONE / OVERSTATED`  
**Context Fit:** `IN_CONTEXT / PARTIAL_CONTEXT / OUTSIDE_CONTEXT / NOT_APPLICABLE / UNKNOWN`  
**Conflict Status:** `NONE_IDENTIFIED / RESOLVED / UNRESOLVED / MATERIAL_CONFLICT`  
**Staleness:** `CURRENT / POTENTIALLY_STALE / STALE / SUPERSEDED / UNKNOWN`  
**Epistemic Status:** `SUPPORTED / PARTIALLY_SUPPORTED / CONFLICTED / INFERRED / UNSUPPORTED / STALE / SUPERSEDED / OUTSIDE_CONTEXT_OF_USE / HUMAN_JUDGMENT_REQUIRED`

The gate deliberately does not emit `TRUE` or `FALSE`.

## 7. Automated Checks

Permitted checks include citation resolution, hash match, version match, date/staleness screening, source-authority classification, claim/source alignment, entailment screening, contradiction screening, duplicate-source detection, provenance-chain checks, and context-boundary screening.

Each automated check records its ID, type, result, method/model version, details, and output reference where applicable.

Allowed check results: `PASS / FAIL / WARN / NOT_RUN / INDETERMINATE`.

Automated checks provide evidence about supportability; they do not replace final gate logic or mandatory human review.

## 8. VeriAbyss / AntiSIM Boundary

VeriAbyss/AntiSIM may be evaluated for provenance-chain analysis, claim-level gating, entropy/anomaly signals, citation/support screening, record sealing, and fabrication-risk indicators.

It is **not authorized** in v1.0 to declare scientific truth, regulatory acceptance, Part 11 compliance, submission readiness, universal hallucination detection, or historical benchmark performance without controlled independent evidence.

Before a VeriAbyss-derived score becomes consequential, Archemedica requires a defined context of use, frozen/versioned implementation, benchmark corpus, reference-label methodology, acceptance criteria, false-positive and false-negative characterization, robustness testing, change control, and verification/validation appropriate to intended use.

## 9. Gate Dispositions

Allowed outcomes:

- `PASS`
- `PASS_WITH_LIMITATIONS`
- `HOLD_FOR_HUMAN_REVIEW`
- `FAIL_UNSUPPORTED`
- `FAIL_CONFLICTED`
- `FAIL_STALE`
- `FAIL_OUTSIDE_CONTEXT`
- `FAIL_BROKEN_PROVENANCE`

Every disposition records allowed uses, prohibited uses, and required actions.

## 10. Human Review Rules

Human review is mandatory when: a HIGH/CRITICAL claim is not clearly supported; a regulatory claim requires interpretation; scientific evidence materially conflicts; the claim could affect subject safety, eligibility, dose, endpoint interpretation, submission strategy or other consequential action; model/AI influence is high/determinative for a high-consequence decision; context is partial/unknown; provenance is incomplete; automated checks materially disagree; stale/superseded evidence remains in active use; or an accountable reviewer escalates.

Human review cannot transform weak evidence into supported evidence merely by approval.

## 11. Claim Rewrite Rule

When evidence supports a narrower statement than proposed, the system should **narrow the claim rather than force a PASS**.

Example: replace “VeriAbyss prevents hallucinations” with the narrower evidence-bounded statement that the inspected implementation contains mechanisms intended to identify specified fabrication-risk signals. The rewritten claim receives its own controlled provenance.

## 12. Regulatory Claims

Regulatory review must distinguish source existence, source authority/currentness, interpreted requirement, jurisdiction/applicability, product/workflow relevance, and whether the statement is alignment, expectation, recommendation, requirement, or draft recommendation.

Regulatory alignment does not equal compliance. Draft guidance remains draft/nonbinding until superseded.

## 13. Scientific and Model Claims

Scientific review preserves population, design, assumptions, endpoints, uncertainty, limitations, replication status where known, context of use, and conflicting evidence.

A model output proves what the model produced—not that the output is correct. Model-output claims preserve model/version, COU, input snapshot, output reference, validation status, limitations, and decision influence.

## 14. Provenance and Hashing

Hash match can support artifact identity, byte-level integrity, and change detection. Hashing does not establish scientific validity, lawful data rights, clinical correctness, author authenticity, or regulatory acceptability.

## 15. DER and DDG Integration

A material DER finding may reference an EIG assessment: `DER FINDING → CLAIM → EIG ASSESSMENT → EVIDENCE`.

If a relied-upon EIG becomes stale, conflicted, unsupported, superseded, or loses provenance, an explicit DDG dependency may create a ChangeEvent and reassessment candidate. No implicit cascade is authorized.

## 16. False-Authority Guardrails

1. No `truth_score`.
2. No universal hallucination percentage.
3. No “verified true” label.
4. No compliance badge generated from citations.
5. No scientific-validity badge generated from publication count.
6. No source-count voting.
7. No promotion of secondary sources into primary evidence.
8. No suppression of contradictory evidence because a preferred source exists.
9. No consequential LLM rationale without traceable evidence.
10. No PASS when required evidence is materially missing.

## 17. Explicit Non-Goals

The EIG does not determine truth, replace SMEs, establish compliance, validate models by itself, grant data rights, or convert provenance into scientific validity.

# Appendix A — ADR-0005: Evidence Integrity Gate Adversarial Review

**Risk Tier:** 3  
**Disposition:** **BUILD — REFRAMED AND CONSTRAINED**

### 1. Problem Test — PASS
Clinical-development decisions can rely on claims whose citations are missing, stale, indirect, contradictory, overextended, or outside context.

### 2. Existing-Solution Test — BUILD SEMANTICS / INTEGRATE CHECKS
Citation tools, RAG, literature systems, lineage tools, fact-checkers and LLM guardrails solve pieces; they do not by themselves govern claim support as a first-class dependency of consequential development decisions.

### 3. Commodity Test — PASS WITH LIMIT
Retrieval, hashing, embeddings, contradiction screening and basic provenance are commodity and are not Archemedica's moat.

### 4. Moat Test — QUALIFIED PASS
Potential differentiation is decision-linked claim support, explicit boundaries, contradictory/limiting evidence retention, context-specific status, lifecycle reassessment, and accountable human linkage.

### 5. Integration Test — PASS
Use swappable check engines; do not center architecture on VeriAbyss or any one model.

### 6. Evidence Test — PASS
Recovered estate evidence already shows demo claims without backend proof, prototype-vs-validation confusion, unverified RWE claims, and regulatory alignment that must not be inflated into compliance claims.

### 7. Counter-Evidence Test — CREDIBLE
Entailment/contradiction systems can misclassify nuanced scientific/regulatory material. Human gates remain necessary.

### 8. Regulatory Test — PASS WITH BOUNDARY
Current FDA/EMA direction emphasizes context of use, risk-based oversight, documentation, performance assessment and lifecycle management. This is directional alignment only; no compliance claim is made.

### 9. Failure-Mode Test — PASS ONLY WITH GUARDRAILS
Key failures: false PASS, citation laundering, publication-count authority, stale guidance, model output treated as fact, hidden contradiction, hallucinated sources, context leakage, automated-review overreach and score worship.

### 10. Customer Test — PROVISIONAL PASS
Likely value exists for protocol-change rationale, model claims, regulatory interpretation, vendor evidence and AI-generated analysis; direct customer evidence remains required.

### 11. Workflow Test — EMBED, DO NOT ISOLATE
A separate fact-checker dashboard is rejected.

### 12. Dependency Test — PASS
Stable evidence IDs, DER and DDG design foundations now exist.

### 13. Reversibility Test — PASS
Check engines must be replaceable; canonical EIG records cannot depend on proprietary scores.

### 14. Data-Rights Test — CONTROL REQUIRED
Evidence may contain confidential, licensed, personal or restricted data.

### 15. Security/Privacy Test — TIER 3 CONCERN
External retrieval/model checks can exfiltrate sensitive text. Future connector/model use requires a separate data-boundary ADR.

### 16. Validation-Cost Test — PHASED
Consequential automated gating requires false-PASS/false-FAIL characterization by claim class and context. Start deterministic plus human review; phase model assistance.

### 17. Simpler-Alternative Test — BUILD CONTRACT FIRST
Human checklists can perform early review but do not scale lifecycle monitoring/reassessment.

### 18. Strongest NO-BUILD Case
The EIG could become a sophisticated-looking fact checker whose green badge creates dangerous false confidence in scientific, clinical or regulatory settings.

### 19. Rebuttal
The design eliminates truth labels/scores, separates automated checks from epistemic disposition, preserves conflicting evidence, requires context and claim narrowing, and escalates consequential ambiguity to accountable humans.

### 20. Final Disposition
**BUILD — REFRAMED AND CONSTRAINED.** Build a claim-support architecture; do not build or market a truth detector.

## Falsification Criteria

**ASM-ADR-0005-001:** Claim-level decomposition improves defensibility.  
**Falsification:** Granularity materially slows work without measurable review benefit.

**ASM-ADR-0005-002:** Structured support statuses reduce claim inflation.  
**Falsification:** QC still finds materially overstated claims labeled supported.

**ASM-ADR-0005-003:** Automated checks can reduce burden without unacceptable false-PASS performance.  
**Falsification:** Controlled testing shows unsafe false-PASS rates for intended claim classes.

**ASM-ADR-0005-004:** Human escalation controls consequential ambiguity.  
**Falsification:** Reviewers routinely rubber-stamp outputs or cannot reconstruct reasoning.

**ASM-ADR-0005-005:** VeriAbyss/AntiSIM adds useful signal without becoming a truth authority.  
**Falsification:** Independent testing shows no meaningful incremental value over simpler approaches.

## Reassessment Triggers

Reassess if users interpret PASS as truth; false PASS/FAIL rates are unacceptable; claim decomposition becomes burdensome; regulatory expectations materially change; model-assisted checking performance changes materially; VeriAbyss validation changes its permissible role; licensed evidence cannot be safely processed; customers bypass the gate; or EIG changes cause excessive DDG alert noise.

## Attestation Boundary

This artifact defines an evidence-support architecture. It does not establish scientific truth, clinical correctness, regulatory compliance, model validation, GxP suitability, Part 11 compliance, or regulator acceptance.

## Change History

| Version | Date | Change | Disposition |
|---|---|---|---|
| 1.0 | 2026-08-29 | Initial Evidence Integrity Gate and ADR-0005 adversarial review | BUILD — REFRAMED AND CONSTRAINED |

**END OF CONTROLLED DOCUMENT**
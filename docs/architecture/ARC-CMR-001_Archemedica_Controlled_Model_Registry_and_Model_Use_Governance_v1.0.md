# ARC-CMR-001 — Archemedica Controlled Model Registry & Model Use Governance

**Document ID:** ARC-CMR-001  
**Version:** 1.0  
**Status:** CONTROLLED — PILOT DESIGN BASELINE  
**System:** Archemedica  
**Document Type:** Model Use / Decision Influence Governance Gate  
**Effective Date:** 2026-08-30  
**Author/Document Owner:** Cassandra Harrison  
**Classification:** Proprietary / Controlled  
**Governed By:** ARC-STD-001 v1.0  
**Evidence Registry:** ARC-EVID-REG-001 v1.0  
**Evidence Integrity:** ARC-EIG-SCHEMA-001 v1.0  
**Decision Contract:** ARC-DER-SCHEMA-001 v1.0  
**Dependency Contract:** ARC-DDG-SCHEMA-001 v1.0  
**Related Workflows:** ARC-PCDI-001 v1.0; ARC-RDRE-001 v1.0  
**Related ADR:** ADR-0008

> **Control statement:** CMR governs the use of computational models in consequential Archemedica decisions. It is not an MLOps catalog, validation badge factory, model marketplace, scientific-authority registry, or autonomous approval system.

## 1. Core Question

Which model output influenced a development decision; exactly which frozen model/version/configuration/data/context produced it; was that use authorized for that context and consequence level; what evidence supports or limits that use; what human reviewed it; and which decisions require reassessment when its basis changes?

## 2. ADR-0008 Verdict

**Risk Tier:** 3  
**Disposition:** **PILOT — BUILD MODEL-USE GOVERNANCE; DEFER GENERIC MODEL REGISTRY**

The ordinary “model registry” concept does not survive. Model inventories, version catalogs, deployment metadata and endpoints are already handled by MLOps platforms. Archemedica shall integrate such metadata where useful rather than compete with it.

What survives is **decision-linked model-use governance**.

The governing distinction is mandatory:

`MODEL EXISTS ≠ IMPLEMENTATION VERIFIED ≠ VALIDATED FOR CONTEXT OF USE ≠ SCIENTIFICALLY CREDIBLE ≠ APPROPRIATE FOR THIS DECISION ≠ AUTHORIZED FOR THIS CONSEQUENCE LEVEL`

No status may be inferred from another.

## 3. Model Identity

Every governed model use references a stable `MODEL-*` identity and immutable `MODELVER-*` version. Required identity includes owner/provider, model class, implementation reference, version/hash where available, release status, intended use, prohibited use, dependencies and retirement/supersession state.

External/vendor models may be registered without possession of source code, but limitations must remain explicit.

## 4. Separate Status Axes

CMR shall maintain independent statuses for:
- implementation evidence;
- software verification;
- validation for stated context of use;
- scientific credibility/evidence;
- regulatory relevance;
- security/privacy review;
- data provenance/rights;
- production readiness;
- authorization for decision influence.

A prototype may be real software while remaining unvalidated and unauthorized for consequential use.

## 5. Context of Use

Every consequential use requires a controlled `COU-*` record defining:
- decision purpose;
- population/domain;
- input-data requirements;
- output meaning;
- operating conditions;
- exclusions;
- known limitations;
- consequence level;
- allowed influence;
- required human expertise;
- validation evidence applicable to this use;
- reassessment triggers.

Validation evidence from one COU shall not silently transfer to another.

## 6. Decision Consequence & Influence

Consequence levels: `LOW`, `MODERATE`, `HIGH`, `CRITICAL`.

Model influence levels:
- `INFORMATIONAL` — output displayed but not relied upon;
- `ADVISORY` — may inform human reasoning;
- `MATERIAL` — materially influences a consequential decision;
- `DETERMINATIVE` — would substantially determine action absent override.

`DETERMINATIVE` use for HIGH/CRITICAL clinical-development consequences is **not authorized in v1.0**.

## 7. Model Use Record

Each consequential invocation creates or references a `MUSE-*` record containing:
- model/version/COU;
- DER/PCDI/RDRE context;
- invocation timestamp;
- frozen configuration/parameters;
- input artifact/evidence references and hashes where available;
- preprocessing/transformation references;
- output artifact/hash;
- uncertainty/confidence representation as actually produced;
- limitations active at invocation;
- model influence;
- human reviewer;
- override/deviation;
- provenance/audit events.

A model output may not be reconstructed later from “current” model state and presented as the historical output.

## 8. Evidence Integrity

Claims about model performance, validation, scientific meaning or applicability are governed by EIG. Historical README claims, UI labels, benchmark percentages, vendor marketing and repo existence do not establish validation or suitability.

Hashing establishes identity/integrity of bytes, not scientific validity.

## 9. Authorization Gate

Before MATERIAL use, CMR requires:
1. resolved model/version;
2. explicit COU;
3. applicable validation/verification status;
4. data-rights/provenance review appropriate to inputs;
5. security/privacy status appropriate to deployment;
6. known limitations;
7. consequence/influence classification;
8. accountable human reviewer role;
9. EIG status for material performance/applicability claims;
10. no unresolved blocking condition.

Failure results in `NOT_AUTHORIZED`, `HUMAN_REVIEW_REQUIRED`, or `INSUFFICIENT_EVIDENCE`, never a fabricated approval.

## 10. Change & Reassessment

CMR emits governed change events for:
- model version superseded;
- model retired;
- validation status changed;
- COU changed;
- performance degradation;
- material defect;
- data dependency changed;
- preprocessing changed;
- security/privacy status changed;
- scientific evidence materially changed.

DDG identifies decisions explicitly dependent on the affected model/version. Candidate impacts are reassessed; decisions are not automatically invalidated.

## 11. Candidate Legacy Technology Boundary

Recovered or verified technologies such as ZeroEDC, GenoPattern, BLEUFusion, VeriAbyss/AntiSIM, BAS360 simulation components, TrialSim, VariantMap and computational research models may enter CMR only at the evidence status actually established.

Registration does not promote a prototype to validated model, scientific evidence to clinical recommendation, or historical claim to verified performance.

## 12. External Models

Archemedica may govern external proprietary models using provider/version, contract/API version, declared COU, available validation evidence, observed performance, change notices and invocation provenance. Lack of source access must be recorded as a limitation rather than concealed.

## 13. Human Accountability

Qualified humans remain accountable for consequential decisions. CMR records model influence separately from final human decision and preserves overrides. Human approval does not retroactively validate a weak model.

## 14. No Badge Laundering

CMR shall not display a single universal “validated,” “approved,” “safe,” “FDA-ready,” “Part 11 compliant,” or “scientifically verified” badge.

Status must remain multidimensional and context-specific.

## 15. Pilot Acceptance Scenarios

At minimum test:
1. verified prototype requested for MATERIAL use without validation;
2. validated model used outside COU;
3. model version changes after a DER decision;
4. preprocessing changes while model binary does not;
5. external API model silently changes version;
6. model benchmark claim fails EIG supportability;
7. LOW consequence advisory use with adequate evidence;
8. HIGH consequence determinative request blocked;
9. retired model still linked to active decisions;
10. input dataset lacks sufficient rights/provenance;
11. model produces output with missing invocation provenance;
12. two model versions disagree materially;
13. human override preserves original output;
14. model validation evidence is superseded;
15. simple deterministic rule competes with a complex model.

## 16. Pilot Metrics

Measure unauthorized-use prevention, provenance completeness, model-version reconstruction success, reassessment precision, false cascade rate, reviewer override rate, COU mismatch detection, maintenance burden, time to determine whether a model was allowed to influence a decision, and incremental value over existing MLOps registry + SOP/manual review.

No threshold is pre-claimed.

# Appendix A — ADR-0008 Tier-3 Adversarial Review

1. **Problem — PASS:** model outputs can influence decisions without durable reconstruction of version, COU, evidence and limitations.
2. **Existing solutions — MATERIAL CHALLENGE:** MLOps registries already inventory/version/deploy models.
3. **Commodity — KILL GENERIC REGISTRY:** do not build another MLflow/model catalog.
4. **Moat — QUALIFIED:** decision-linked COU, influence, evidence, reassessment and outcome linkage may differentiate.
5. **Integration — PASS:** integrate external registries; Archemedica owns governed decision-use semantics.
6. **Evidence — PASS FOR NEED, NOT PMF:** recovered technology shows heterogeneous maturity; commercial demand remains to be proven.
7. **Counter-evidence — CREDIBLE:** strong SOP + MLOps + validation documentation may be sufficient.
8. **Regulatory — HIGH BURDEN:** no global validation/compliance badge; intended use/COU and risk must remain explicit.
9. **Failure modes — HIGH:** badge laundering, COU drift, silent model update, benchmark inflation, data-rights failure, automation bias, stale validation, output reconstruction error.
10. **Customer — PROVISIONAL:** likely value to model governance, clinical development, quality, regulatory and data-science teams; buying evidence incomplete.
11. **Workflow — CONDITIONAL:** must embed in DER/PCDI/RDRE; standalone catalog fails.
12. **Dependencies — HIGH:** requires evidence, EIG, DER and DDG integrity.
13. **Reversibility — PASS:** model/runtime/provider must remain replaceable.
14. **Data rights — CRITICAL CONTROL:** model input rights and derived-output restrictions must be explicit.
15. **Security/privacy — TIER 3:** external inference and model supply chain require separate production controls.
16. **Validation cost — HIGH:** validation must be COU/risk proportional; v1.0 governs evidence/status, not magical validation.
17. **Simpler alternative — CRITICAL:** MLOps registry + controlled spreadsheet/SOP is reference competitor.
18. **Strongest NO-BUILD:** CMR becomes compliance theater—a metadata catalog whose badges make weak models look trustworthy while duplicating existing MLOps.
19. **Rebuttal:** kill the generic registry; retain only decision-linked model-use records, explicit COU, multidimensional status, invocation provenance and reassessment dependencies.
20. **Final disposition:** **PILOT — BUILD MODEL-USE GOVERNANCE; DEFER GENERIC MODEL REGISTRY.**

## Falsification Criteria

Narrow or kill CMR if existing MLOps + SOP processes reconstruct consequential model use with equal reliability/lower burden; users cannot maintain COU records; multidimensional statuses are routinely ignored in favor of informal badges; invocation provenance is too expensive to capture; DDG model dependencies create excessive noise; or model-use governance does not reduce unauthorized/out-of-context use.

## Reassessment Triggers

Reassess if regulatory expectations materially change, model architectures/providers make version identity unreliable, customer evidence rejects the workflow, external-model opacity defeats meaningful governance, validation maintenance exceeds value, or production security/data-boundary controls alter allowed use.

## QC/QA Gate

Before pilot release: stable model/version/COU IDs; separate status axes; no universal validation badge; MATERIAL use authorization gate; HIGH/CRITICAL determinative use blocked in v1.0; invocation provenance immutable; input/output references traceable; EIG governs performance claims; DDG model-change reassessment explainable; external model limitations visible; tenant authorization enforced.

## Attestation Boundary

This document defines model-use governance architecture. It does not establish model validation, scientific correctness, clinical utility, regulatory compliance, GxP suitability, Part 11 compliance, regulator acceptance, or production readiness.

## Change History

| Version | Date | Change | Disposition |
|---|---|---|---|
| 1.0 | 2026-08-30 | Initial CMR and ADR-0008 Tier-3 review | PILOT — BUILD MODEL-USE GOVERNANCE |

**END OF CONTROLLED DOCUMENT**
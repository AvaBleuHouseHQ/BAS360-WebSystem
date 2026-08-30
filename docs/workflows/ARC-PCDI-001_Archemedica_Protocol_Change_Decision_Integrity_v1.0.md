# ARC-PCDI-001 — Archemedica Protocol Change Decision Integrity

**Document ID:** ARC-PCDI-001
**Version:** 1.0
**Status:** CONTROLLED — DESIGN BASELINE
**System:** Archemedica
**Document Type:** First Customer Workflow / Protocol Change Decision Integrity Gate
**Effective Date:** 2026-08-30
**Author/Document Owner:** Cassandra Harrison
**Classification:** Proprietary / Controlled
**Governed By:** ARC-STD-001 v1.0
**Evidence Registry:** ARC-EVID-REG-001 v1.0
**Decision Contract:** ARC-DER-SCHEMA-001 v1.0
**Dependency Contract:** ARC-DDG-SCHEMA-001 v1.0
**Evidence Integrity Contract:** ARC-EIG-SCHEMA-001 v1.0
**Related ADR:** ADR-0006
**Machine-Readable Contract:** `schemas/protocol-change-decision-integrity/ARC-PCDI-001_Protocol_Change_Decision_Integrity.schema.json`

> **Control statement:** PCDI is a governed workflow for protocol version-to-version change assessment, impact analysis, accountable decision, implementation readiness, and reassessment. A protocol redline or automated diff is only an input; it is not the decision.

## 1. Purpose
PCDI answers: **Protocol version N is proposed to become N+1. What changed, why does it matter, which prior decisions, assumptions, evidence, models, regulatory interpretations and controlled artifacts are affected, what must happen before or after implementation, who must decide, and what remains unresolved?**

## 2. ADR-0006 Verdict
**Risk Tier:** 3
**Disposition:** **PILOT — BUILD CONTROLLED MVP, DO NOT GENERALIZE YET**

The gate passes, but not as an unrestricted AI protocol optimizer. Direct willingness-to-pay evidence for this exact wedge remains incomplete; the workflow must prove it outperforms a disciplined amendment checklist before broader build-out.

## 3. Regulatory/GCP Design Basis
For U.S. IND studies, specified significant protocol changes require protocol amendments and are generally submitted before implementation. A change intended to eliminate an apparent immediate hazard may follow a special immediate implementation/subsequent notification path. ICH E6(R3) supports proportionate risk identification, evaluation, control, communication, review and reporting. ICH M11/CeSHarP provides a structured harmonized protocol direction; PCDI supports structured inputs when available but must also work with conventional documents. This is design alignment only, not a compliance claim.

## 4. Controlled Workflow

### Stage 1 — Protocol Identity and Integrity
Resolve baseline/proposed identity, versions, authoritative source, hash where available, study match and redline provenance. Preserve both versions. HOLD if baseline cannot be established.

### Stage 2 — Atomic Change Extraction
Create stable `PCHG-*` records for administrative, eligibility, intervention, dose/exposure, safety, endpoint, statistical, sample-size, visit, procedure, control-arm, randomization, blinding, data, biospecimen, consent, site, operational, regulatory and other changes. Store location, before/after, origin, materiality and confirmation status.

**Textual difference does not equal material change. Small textual change does not equal small impact.**

### Stage 3 — Human Confirmation
System-detected changes are provisional. Material/high-risk changes require confirmation. Reviewers may merge, split, reject or reclassify while preserving original extraction.

### Stage 4 — Multi-Dimensional Impact
Assess safety, rights/well-being, scientific validity, statistics, endpoint interpretation, operability, sites, investigational product, data integrity, CRF/EDC, monitoring, vendors, training, consent, IRB/IEC, regulatory submission/applicability, risk, timeline and budget. `NOT_ASSESSED` is visible and never converted to no impact.

### Stage 5 — DDG Impact Radius
Query affected prior DERs, assumptions, evidence, models, regulatory mappings, artifacts and downstream decisions. Every surfaced impact requires an explainable dependency path.

### Stage 6 — Evidence Integrity
Material amendment claims pass through EIG. Unsupported, conflicted, stale or outside-context claims become blockers or unresolved items according to risk.

### Stage 7 — Regulatory Applicability
Separate change detection, authoritative source, interpreted obligation, jurisdiction/study applicability, submission/notification action and timing. Where uncertain, use `HUMAN_JUDGMENT_REQUIRED`.

### Stage 8 — Immediate-Hazard Path
Provide a distinct `IMMEDIATE_HAZARD` route when applicable. Software may surface but cannot independently declare the legal/clinical existence of an immediate hazard. Require rationale, accountable authorization, jurisdiction check, implementation record, subsequent regulatory/IRB actions, site communication and verification.

### Stage 9 — Accountable DER
Create/reference DER preserving changes, evidence, assumptions, alternatives, impacts, unresolved items, system recommendation if any, accountable human decision and reassessment triggers. Actions: `IMPLEMENT_STANDARD_PATH`, `IMPLEMENT_IMMEDIATE_HAZARD_PATH`, `REVISE_AND_REASSESS`, `DO_NOT_IMPLEMENT`, `DEFER_PENDING_EVIDENCE`. `INSUFFICIENT_EVIDENCE` is valid.

### Stage 10 — Implementation Readiness
Approval does not equal readiness. Track regulatory/IRB actions, ICF, site notification/training, EDC/CRF/database, SAP/DMP/monitoring, risk register, IRT/randomization, lab/pharmacy manuals, safety plans, vendors and controlled documents. States: `NOT_READY`, `CONDITIONALLY_READY`, `READY`, `IMPLEMENTED`, `BLOCKED`.

### Stage 11 — Effective-Date Control
Do not assume one global effective date. Support jurisdiction/site readiness, training, ICF, system readiness and local effective-date conditions.

### Stage 12 — Post-Implementation Verification
Completion requires evidence, not task status alone. Verify distribution, training, ICF activation, system changes, plan updates, regulatory/IRB evidence and retirement of obsolete active versions.

### Stage 13 — Reassessment/Supersession
Reassess for new evidence, safety signals, regulatory changes, implementation failure, model changes, subsequent protocol changes or outcomes undermining assumptions. Preserve and supersede history.

## 5. Human Accountability
Impact-driven review: Medical/Safety; Biostatistics; Clinical Operations; Data Management/Programming; Regulatory; Quality; and other SMEs as required. Tier-3 material changes require independent QC/QA plus relevant SME review for standard-path readiness.

## 6. Anti-Paperwork Rule
PCDI fails if it merely creates a larger amendment packet. It must prepopulate known metadata, decisions, assumptions, evidence, artifacts, reviewer roles and actions. If maintaining PCDI costs as much as manual reconciliation, reassess or kill the design.

## 7. Explicitly Deferred
No autonomous protocol optimization/generation, enrollment forecasting dependency, patient digital twins, automatic statistical redesign, automatic regulatory submission generation, authoritative automatic ICF drafting, automatic EDC/IRT implementation, universal cross-jurisdiction engine or open model marketplace.

## 8. Pilot Acceptance Scenarios
Test dose increase; eligibility change; primary endpoint change; control-arm change; added safety monitoring; administrative-only edit; immediate-hazard change; false textual diff; tiny wording/major semantic impact; stale evidence; conflicting evidence; and multi-jurisdiction uncertainty. Define expected impacted and non-impacted objects to measure false cascades.

## 9. Pilot Metrics
Measure true-change recall, false-change rate, material-impact precision/recall, false reassessment cascades, missed artifacts, reviewer overrides, time to impact packet, manual-entry burden, prepopulation acceptance, unresolved-item closure, implementation traceability and user value versus current process. No threshold is pre-claimed.

# Appendix A — ADR-0006 Adversarial Review

1. **Problem — PASS:** cross-functional amendment consequences are hard to reconstruct reliably.
2. **Existing solutions — CONDITIONAL:** redlines/QMS/CTMS/protocol-authoring/regulatory tools exist; diffing is not novel.
3. **Commodity — FAIL AS MOAT:** redline, semantic diff, tasks and document workflow are commodity.
4. **Moat — QUALIFIED:** persistent decision/evidence/dependency memory, reassessment and outcomes may differentiate.
5. **Integration — PASS:** integrate parsers/diff/structured standards; build decision semantics.
6. **Evidence — PASS FOR PROBLEM, NOT PMF:** regulatory/GCP sources establish the problem, not willingness to pay.
7. **Counter-evidence — MATERIAL:** existing sponsor amendment processes may be good enough.
8. **Regulatory — PASS AFTER REVISION:** jurisdiction and immediate-hazard exceptions require special handling.
9. **Failure modes — CONTROLLED PILOT ONLY:** missed semantic changes, false cascades, stale mappings, missed safety/statistical impacts, wrong effective dates, status laundering, delayed urgent protection.
10. **Customer — PROVISIONAL:** likely users exist; buying evidence remains missing.
11. **Workflow — PASS WITH ANTI-PAPERWORK RULE.**
12. **Dependencies — PASS AT DESIGN LEVEL.**
13. **Reversibility — PASS:** vendor-independent workflow contract.
14. **Data rights — CONTROL REQUIRED.**
15. **Security/privacy — TIER 3:** separate data-boundary gate before production.
16. **Validation cost — PHASED:** curated scenarios and false-positive/negative characterization required.
17. **Simpler alternative — CRITICAL:** PCDI must prove it beats a strong checklist plus existing workflow.
18. **Strongest NO-BUILD:** expensive repackaging of redlines, checklists and meetings with another dependency-maintenance burden.
19. **Rebuttal:** persistent dependency memory may reduce rediscovery and stale-decision risk; this is testable.
20. **Final disposition:** **PILOT — BUILD CONTROLLED MVP, DO NOT GENERALIZE YET.**

## Falsification Criteria
Kill/narrow the wedge if current processes already identify impacts reliably with low burden; dependency upkeep costs as much as manual assessment; EIG adds burden without quality benefit; humans routinely redo classifications; false cascades remain excessive; a checklist performs equivalently at lower cost; or structured protocol inputs fail to improve reliability.

## Reassessment Triggers
Reassess if users bypass PCDI, cycle time rises, false-positive actions overwhelm teams, impacts are missed, dependency upkeep becomes overhead, checklist-only performs equivalently, regulatory mappings cannot be maintained, M11 changes inputs materially, customer evidence favors another wedge, or immediate-hazard routing creates delay.

## QC/QA Release Gate
Before pilot release: controlled IDs resolve; no orphan PCHG records; every material change assessed or explicitly `NOT_ASSESSED`; high/critical impacts have accountable reviewers; regulatory actions have source/applicability or `HUMAN_JUDGMENT_REQUIRED`; EIG failures cannot disappear; DDG paths explain; both pathways tested; completion requires evidence; history remains immutable/superseded; tenant isolation is enforced.

## Attestation Boundary
This defines a controlled workflow design. It does not establish implementation, validated performance, GCP/Part 11/regulatory compliance, sponsor adoption, regulator acceptance or clinical correctness.

## Change History
| Version | Date | Change | Disposition |
|---|---|---|---|
| 1.0 | 2026-08-30 | Initial PCDI workflow and ADR-0006 Tier-3 review | PILOT — BUILD CONTROLLED MVP |

**END OF CONTROLLED DOCUMENT**
# ARC-POLICY-EVID-001 — Regulatory and Standards Evidence Integrity Boundary

**Document ID:** ARC-POLICY-EVID-001  
**Version:** 1.0  
**Status:** CONTROLLED — GOVERNANCE BASELINE  
**System:** Archemedica / BAS360-WebSystem  
**Author/Document Owner:** Cassandra Harrison  
**Effective Date:** 2026-09-01  
**Governed By:** ARC-STD-001 v1.0  
**Related:** ARC-XMOD-MODEL-001; ARC-ISO-BASELINE-001 v1.1; ARC-EVID-REG-001

> **Principle:** Archemedica may eventually generate evidence useful to regulators, standards bodies, sponsors and policy researchers. The system shall be designed to preserve trustworthy evidence about regulatory friction and cross-modality consequences, not to manufacture support for a predetermined policy position.

## 1. Purpose
Define the boundary between normal regulated-product decision support and any future use of aggregated Archemedica evidence to inform regulation, standards, guidance, policy, industry practice or quality-system design.

## 2. Permitted Future Capability
Subject to lawful rights, consent/contractual scope, privacy/security controls and controlled governance, Archemedica may support analysis of:

- recurring cross-modality dependency failures;
- duplicate or conflicting regulatory obligations;
- classification/PMOA uncertainty and downstream impact;
- requirements that cause repeated reconciliation burden;
- regulatory change propagation across product constituents;
- recurring evidence gaps or false-closure patterns;
- time/burden associated with regulatory or standards applicability determinations;
- safety/quality consequences associated with siloed decision-making;
- lifecycle points where drug, biologic, device, diagnostic, software and manufacturing controls interact;
- measurable effects of revised rules or standards before/after effective dates.

## 3. Non-Permitted Behavior
Archemedica shall not:

1. fabricate or selectively suppress evidence to support a policy preference;
2. convert customer-specific records into cross-customer policy evidence without lawful authority and applicable contractual/privacy rights;
3. treat proprietary customer information as public regulatory evidence;
4. present correlation as causation without a justified design;
5. remove contrary evidence, failed cases or unresolved uncertainty from an analysis;
6. imply regulator endorsement or policy acceptance;
7. automatically lobby, petition or submit regulatory comments on behalf of customers;
8. hard-code a desired policy outcome into applicability logic;
9. allow commercial incentives to silently alter inclusion/exclusion rules;
10. claim population-wide or industry-wide conclusions from unrepresentative pilot data.

## 4. Evidence Requirements for Policy/Standards Analysis
Any policy/standards-facing analysis shall preserve at minimum:

- analytic question;
- decision/use context;
- jurisdiction(s);
- regulation/standard/guidance identity and version;
- observation period;
- product/modality/constituent context;
- numerator and denominator definitions;
- inclusion/exclusion criteria;
- source provenance;
- customer/data-rights basis;
- de-identification/aggregation method where applicable;
- missingness and unknown state;
- uncertainty/confidence limits where appropriate;
- competing explanations;
- contrary evidence;
- model/algorithm versions and transformations;
- reviewer/accountable analyst;
- reproducible query/snapshot identity;
- known limitations;
- supersession/reanalysis triggers.

## 5. Separation of Evidence and Recommendation
Archemedica shall distinguish:

1. **Observed evidence** — what the controlled data show;
2. **Interpretation** — reasoned explanation of the evidence;
3. **Regulatory/standards implication** — what may warrant attention;
4. **Recommendation** — proposed action or policy change;
5. **Decision/authority** — action taken by an accountable regulator, standards body, sponsor or other authorized actor.

The system may assist with 1–3 within governed context. 4 requires explicit accountable human authorship/review. 5 always remains with the competent authority or authorized decision-maker.

## 6. Anti-Silo Policy Evidence Model
Cross-modality policy evidence shall be capable of identifying when an outcome resulted from interaction among domains rather than attributing it to a single discipline by default.

Examples:
- a protocol amendment delayed because device usability evidence and medicinal-product labeling were not linked;
- a manufacturing/formulation change causing a delivery-device compatibility reassessment;
- a companion-diagnostic change altering trial eligibility and therapeutic benefit/risk;
- a cybersecurity update creating a clinical-use or patient-safety obligation;
- a regulatory classification change producing duplicated or conflicting quality actions.

## 7. No False Closure for Policy Evidence
`UNKNOWN`, `NOT_CAPTURED`, `NOT_ASSESSED`, `PARTIAL`, `CONFLICTED` and `UNREPRESENTATIVE` shall remain distinct. They may not be counted as negative findings merely to create a clean statistic.

A query result of zero does not mean zero industry events unless population coverage and denominator are established.

## 8. Learning Without Cross-Tenant Leakage
Cross-customer learning, benchmarking or policy analysis is not authorized merely because the technical architecture can support it. Before such use, establish explicit governance covering rights, purpose, privacy, aggregation, minimum cohort/re-identification risk, tenant consent/contractual scope, security and prohibited downstream use.

## 9. Policy Influence Claim Boundary
Until sufficient representative evidence and governance exist, Archemedica shall not market itself as having changed regulation, policy or standards. Permitted language may describe the system as capable of producing structured evidence that could support future regulatory science or standards discussions.

## 10. Reassessment Triggers
Reassess when:
- multi-customer aggregated analysis is proposed;
- a regulator or standards body requests data;
- external publication is planned;
- policy recommendations are generated;
- customer data are proposed for secondary use;
- cross-jurisdiction comparisons are performed;
- automated inference materially influences regulatory interpretation;
- data representativeness or bias concerns emerge.

## 11. Initial Disposition
**ADOPT — POLICY/REGULATORY-SCIENCE EVIDENCE BOUNDARY.**

This capability is intentionally downstream of the core product. The first obligation remains building trustworthy cross-modality decision continuity; policy relevance must emerge from valid evidence rather than becoming a target that biases the evidence system.

## 12. Change History
| Version | Date | Change | Status |
|---|---|---|---|
| 1.0 | 2026-09-01 | Established evidence-integrity boundary for future regulatory science, standards and policy analysis | CONTROLLED — GOVERNANCE BASELINE |

**END OF CONTROLLED DOCUMENT**
# ARC-XMOD-REVIEW-001 — Cross-Modality Anti-Silo Architecture Review

**Version:** 1.0  
**Status:** CONTROLLED — DESIGN CORRECTION REQUIRED  
**System:** Archemedica / BAS360-WebSystem  
**Author/Document Owner:** Cassandra Harrison  
**Date:** 2026-09-01  
**Governed By:** ARC-STD-001; ARC-ISO-BASELINE-001 v1.1; ARC-SYS-HARDEN-001; ARC-PILOT-001

## 1. Review Question
Does the architecture built to date actually support a modality-agnostic regulated-product decision/evidence operating system, or has it merely added device terminology to a drug/biologic-centered architecture?

## 2. Verdict
**CONDITIONAL PASS AT CONTROL-PLANE LEVEL; FAIL AT DOMAIN-MODEL COMPLETENESS; CORRECT BEFORE PERSISTENT IMPLEMENTATION.**

The DER/EIG/DDG/reassessment/control-plane concepts are broadly modality-neutral and reusable. ARC-ISO-BASELINE-001 v1.1 correctly states the anti-silo principle. However, ARC-PILOT-001 and its v1.0 RTM remain protocol-amendment centered and do not yet prove that the persistence model can represent a therapeutic system with multiple constituent parts, multiple simultaneous regulatory regimes, engineering/design controls, integrated risk, manufacturing/process dependencies, device/software/human-factors evidence, or lifecycle vigilance.

Adding an `applicability` field alone would be insufficient. The architecture requires a product-system layer above study/protocol.

## 3. What Survives Unchanged
The following are retained as shared cross-modality primitives:

- Decision Evidence Record (DER): accountable consequential decision and supersession history.
- Evidence Integrity Gate (EIG): supportability/provenance/conflict/staleness control.
- Decision Dependency Graph (DDG): explainable causal/dependency relationships and coverage state.
- Reassessment causal episodes: controlled reopening without loops.
- No False Closure.
- revision-controlled single-reality state.
- idempotency/reconciliation.
- authorization-aware tenant data plane.
- decision-time evidence snapshots.
- evidenced human oversight.
- Evidence Once, Project Many.

These primitives shall not be forked into separate drug-DER, device-DER or biologic-DER systems.

## 4. Material Gaps Found

### GAP-XMOD-001 — No canonical Regulated Product System object
Current pilot begins with tenant/study/protocol. That is too low in the hierarchy. A combination product, companion diagnostic relationship, delivery system or software-enabled therapeutic requires a controlled product-system identity independent of any one study.

**Required correction:** add `RegulatedProductSystem` with intended use, indications, lifecycle stage, jurisdictions, classifications and constituent relationships.

### GAP-XMOD-002 — No first-class Constituent Part model
A drug/device/biologic combination cannot be represented safely as a single modality label.

**Required correction:** add versioned `ConstituentPart` objects and typed relationships (`DELIVERS`, `CONTAINS`, `CO_PACKAGED_WITH`, `CROSS_LABELED_WITH`, `REQUIRES`, `MEASURES_FOR`, `CONTROLS`, `INTERFACES_WITH`, etc.).

### GAP-XMOD-003 — Regulatory applicability is not yet a persistent executable object
The v1.1 baseline requires it, but the pilot RTM does not yet make it a first-class tested object.

**Required correction:** implement `RegulatoryApplicabilityAssessment` with source/version/effective date, jurisdiction, product/constituent scope, stage/context, state, rationale, reviewer, evidence snapshot, affected controls and reassessment triggers. `UNKNOWN` cannot become `DOES_NOT_APPLY` by default.

### GAP-XMOD-004 — Risk model remains too clinical/protocol-centric
Drug benefit-risk, device hazard analysis, use-related risk, software/cybersecurity risk, manufacturing risk and diagnostic misclassification risk must coexist in one causal system without being flattened into one scoring method.

**Required correction:** add `RiskConcern` plus typed analysis/evidence relationships and domain-specific methods. Preserve method-specific semantics while enabling cross-domain propagation.

### GAP-XMOD-005 — No Design/Engineering Control object family
Device/software constituent development requires controlled design inputs, outputs, verification, validation, usability/human factors and design changes where applicable.

**Required correction:** add reusable `ControlledRequirement`, `DesignOutput`, `VerificationEvidence`, `ValidationEvidence`, `UseRelatedRisk`, `SoftwareConfiguration` relationships without building a replacement PLM/QMS.

### GAP-XMOD-006 — Manufacturing/CMC/process dependencies are not first-class
A constituent or protocol change can alter formulation, container closure, compatibility, sterilization, assembly, process validation, specifications, device manufacturing or combination-product quality obligations.

**Required correction:** model `ManufacturingProcessOrControl` and `ProductQualityAttribute` as linkable external/canonical objects sufficient for decision impact; integrate rather than recreate MES/LIMS/PLM.

### GAP-XMOD-007 — Safety/vigilance is too trial-centered
Cross-modality lifecycle needs investigational safety plus postmarket/post-authorization vigilance and constituent attribution where applicable.

**Required correction:** introduce a generic `SafetySignalOrEvent` decision input with modality/jurisdiction-specific reporting overlays.

### GAP-XMOD-008 — Software/cybersecurity/human factors are named but not executable
The current baseline recognizes them but has no required dependency paths/tests.

**Required correction:** add explicit cross-domain scenarios: software update→dose delivery→clinical safety; cybersecurity vulnerability→availability/integrity→patient risk; UI/use change→human factors→labeling/training→clinical risk.

### GAP-XMOD-009 — Diagnostic/therapy coupling is not modeled
Companion/complementary diagnostics can determine eligibility, treatment selection and benefit-risk while following distinct device/IVD evidence pathways.

**Required correction:** represent diagnostic constituent/product relationships and test misclassification/assay change propagation into clinical decisions.

### GAP-XMOD-010 — Protocol Amendment pilot alone cannot prove modality agnosticism
PCDI remains a valuable first vertical slice, but a drug-only oncology fixture could allow a siloed architecture to pass.

**Required correction:** retain the oncology protocol pilot but add at least one combination-product qualification fixture before expansion disposition.

## 5. Corrected Core Object Hierarchy

`Tenant → Program → RegulatedProductSystem → ConstituentPart(s) → Study/Investigation → ProtocolVersion`

Cross-cutting governed objects attach at the level where they actually belong:

- RegulatoryApplicabilityAssessment
- Standard/RequirementSource
- RiskConcern / RiskAnalysis
- EvidenceSnapshot / EIG
- DER
- DDG dependency
- Design/Engineering Requirement/Evidence
- Manufacturing/Quality dependency
- SafetySignalOrEvent
- Model/Software configuration
- ImplementationObligation
- ReassessmentEpisode
- AuditEvent

A study is therefore one evidence-generating context inside the product lifecycle, not the root of the product model.

## 6. Cross-Modality Change Propagation Rule
For any material change, the DDG coverage contract must ask whether applicable dependencies have been assessed across:

1. intended use/indication;
2. clinical safety/efficacy/performance;
3. constituent parts/interfaces;
4. pharmacology/toxicology/CMC where applicable;
5. device safety/performance where applicable;
6. design inputs/outputs/V&V;
7. software/configuration/cybersecurity;
8. usability/human factors;
9. diagnostic/assay performance;
10. manufacturing/process/product quality;
11. labeling/IFU/training;
12. regulatory classification/pathway/submission commitments;
13. clinical protocol/data/statistics;
14. supplier/vendor dependencies;
15. postmarket/post-authorization safety/vigilance;
16. privacy/data governance;
17. quality-system records/CAPA/nonconformity.

`NO_IMPACT` is permitted only for domains established as applicable and sufficiently covered, or explicitly not applicable with controlled rationale.

## 7. 20-Point Adversarial Review
1. Problem: PASS — siloed regulatory/product data causes missed cross-domain impact.
2. Existing solution: PARTIAL — PLM/QMS/RIM/CTMS/safety systems each cover slices.
3. Commodity: individual repositories/workflows are commodity; cross-system decision continuity is not established as commodity.
4. Moat: CONDITIONAL — persistent cross-modality decision/evidence/dependency continuity.
5. Integration: REQUIRED — do not replace specialist systems.
6. Evidence: PASS for regulatory convergence/combination-product need; PMF remains unproven.
7. Counter-evidence: specialist silos may be safer/easier if integration semantics are poor.
8. Regulatory: HIGH complexity; must preserve differences, not flatten them.
9. Failure modes: false applicability, missed constituent dependency, ontology explosion, stale standards mapping, regulatory overclaim, reconciliation burden.
10. Customer: sponsor/product-development organizations; exact buyer remains to validate.
11. Workflow: must surface one coherent impact packet rather than force cross-domain duplicate entry.
12. Dependency: specialist source systems, authoritative regulatory sources, product classification decisions.
13. Reversibility: PASS if canonical contracts remain vendor-neutral.
14. Data rights: controlled per source/customer.
15. Security/privacy: cross-system joins increase sensitivity; authorization at every traversal.
16. Validation cost: higher than drug-only PCDI; phased fixtures required.
17. Simpler alternative: disciplined cross-functional change-control board plus checklist.
18. Strongest NO-BUILD: Archemedica becomes an expensive meta-QMS requiring experts to manually maintain an ontology nobody trusts.
19. Evidence rebuttal: only build mappings that measurably reduce rediscovery/missed impacts and can be derived from normal work/integrations.
20. Disposition: **CORRECT CORE DOMAIN MODEL, THEN CONTINUE CONTROLLED PILOT.**

## 8. Mandatory New Falsification Fixtures
Before claiming architecture-level modality agnosticism, test at minimum:

### Fixture A — Drug/Biologic + Delivery Device
Dose/formulation or protocol change affects delivery-device performance, compatibility, usability, labeling, training and clinical safety.

### Fixture B — Therapeutic + Companion Diagnostic
Assay cutoff/performance change affects eligibility, treatment assignment, clinical interpretation, labeling and regulatory obligations.

### Fixture C — Connected Therapeutic Device
Software/cybersecurity change affects dose delivery or treatment availability and propagates into patient risk, verification/validation, labeling/training and regulatory assessment.

At least one fixture must exercise combination-product classification/PMOA uncertainty and multiple applicable regulatory/standards overlays.

## 9. Process Disposition
Do not proceed directly from the existing RTM into persistent code. The process gate is reset to **DESIGN CORRECTION REQUIRED**.

Required next controlled sequence:
1. revise requirements for cross-modality product-system objects;
2. define canonical product/constituent/applicability/risk schemas;
3. map retained DER/EIG/DDG/control-plane primitives to those objects;
4. threat/failure-model the cross-modality graph;
5. run design-level adversarial fixtures;
6. only then authorize persistent implementation;
7. preserve the original protocol pilot as the first clinical workflow, not the entire ontology.

## 10. Claim Boundary
This review establishes architecture requirements and identified gaps. It does not establish regulatory compliance, ISO conformity, GxP validation, device conformity, combination-product classification, clinical correctness, or production readiness.

**END OF CONTROLLED DOCUMENT**
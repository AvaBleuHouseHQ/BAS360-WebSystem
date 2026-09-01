# ARC-PILOT-001 — Cross-Modality Requirements Addendum

**Version:** 1.0  
**Status:** CONTROLLED — PRE-IMPLEMENTATION CORRECTIVE BASELINE  
**Author/Document Owner:** Cassandra Harrison  
**Parent:** ARC-PILOT-001-RTM v1.0  
**Trigger:** ARC-XMOD-REVIEW-001

## 1. Gate
This addendum is mandatory before persistent implementation. It corrects the study/protocol-centered assumptions in the original pilot requirements without discarding the PCDI vertical slice.

## 2. New Core Requirements

| ID | Requirement | Verification |
|---|---|---|
| XMOD-FR-001 | Persist a versioned `RegulatedProductSystem` above study/protocol, with intended use, indication, lifecycle stage and jurisdiction context. | OQ/PQ |
| XMOD-FR-002 | Persist zero-to-many versioned `ConstituentPart` objects; no product is forced to one modality. | OQ |
| XMOD-FR-003 | Persist typed constituent relationships and cross-constituent dependencies. | OQ |
| XMOD-FR-004 | Persist `RegulatoryApplicabilityAssessment` as a first-class governed object with `APPLIES`, `DOES_NOT_APPLY`, `PARTIAL`, `UNKNOWN`, `HUMAN_JUDGMENT_REQUIRED`. | OQ negative |
| XMOD-FR-005 | Prevent `UNKNOWN` applicability from defaulting to `DOES_NOT_APPLY`. | OQ negative |
| XMOD-FR-006 | Preserve jurisdiction, source/version/effective date, product/constituent scope, development stage, rationale, reviewer and evidence snapshot for applicability decisions. | OQ |
| XMOD-FR-007 | Classification/PMOA/pathway changes trigger reassessment of affected decisions, controls and evidence. | OQ/PQ |
| XMOD-FR-008 | Represent integrated risk without forcing clinical benefit-risk, device hazard, use-related, software/cyber, manufacturing and diagnostic risks into one scoring method. | design review/OQ |
| XMOD-FR-009 | Permit design/engineering requirements, outputs, V&V evidence and use-related risk to participate in DER/DDG/EIG relationships. | OQ |
| XMOD-FR-010 | Permit CMC/manufacturing/process/product-quality dependencies to participate in change impact without replacing specialist manufacturing systems. | OQ |
| XMOD-FR-011 | Permit software/configuration/cybersecurity changes to propagate to patient/product/regulatory consequences. | OQ/PQ |
| XMOD-FR-012 | Permit diagnostic/assay changes to propagate to eligibility/treatment/clinical/regulatory decisions. | OQ/PQ |
| XMOD-FR-013 | Represent investigational and postmarket/post-authorization safety signals/events as decision inputs with modality-specific reporting overlays. | OQ |
| XMOD-FR-014 | Cross-domain `NO_IMPACT` requires sufficient dependency coverage or controlled `DOES_NOT_APPLY` rationale. | OQ negative |
| XMOD-FR-015 | A single change can produce obligations across multiple regulatory regimes/standards without duplicating the originating canonical fact. | PQ |
| XMOD-FR-016 | Study/Protocol objects remain evidence-generating contexts under Product System rather than architectural roots. | schema/IQ |

## 3. Required Standards/Regulatory Mapping Domains
The applicability layer must be capable of mapping, without claiming blanket applicability, at least:

- drug/biologic GCP/GMP/clinical/safety/CMC domains;
- medical-device QMS/design/risk/clinical investigation domains;
- software lifecycle, cybersecurity and usability/human-factors domains;
- IVD/diagnostic domains;
- combination-product classification, constituent-part and integrated quality domains;
- jurisdiction-specific requirements and controlled authoritative interpretations.

The mapping engine shall store source identity/version/effective date and shall support supersession/reassessment when sources or interpretations change.

## 4. Required Adversarial Qualification Scenarios
Add to the original ARC-PILOT-001 test set:

1. drug/biologic dose change with delivery-device cross-impact;
2. formulation/container change affecting device compatibility;
3. device design change affecting dose delivery and clinical safety;
4. use-interface change affecting human factors, labeling and training;
5. connected-device software update affecting safety-critical behavior;
6. cybersecurity vulnerability affecting treatment availability/integrity;
7. companion diagnostic cutoff change affecting eligibility/treatment;
8. assay performance evidence conflict;
9. classification/PMOA uncertainty with `HUMAN_JUDGMENT_REQUIRED`;
10. regulatory source revision changing one constituent obligation but not another;
11. false cross-constituent HIGH dependency;
12. missing true cross-constituent dependency;
13. constituent supplier/manufacturing change;
14. postmarket signal requiring reassessment of prior clinical/design decision;
15. combination-product change producing multiple obligations from one canonical change record.

## 5. Anti-Silo Acceptance Criteria
The design fails if:

- users must choose one exclusive modality for a multi-constituent product;
- a study/protocol is the only root capable of owning decisions/evidence;
- device/design/manufacturing/software evidence requires a separate decision system;
- applicability is encoded only in hard-coded UI logic;
- `UNKNOWN` or missing mappings appear as not applicable/no impact;
- one constituent's change cannot traverse to another constituent's clinical/quality/regulatory obligations;
- specialists must duplicate the same change fact in separate modality modules;
- the system attempts to replace specialist PLM/QMS/RIM/CTMS/EDC/safety systems rather than govern decision continuity across them.

## 6. Implementation Authorization
**NOT YET AUTHORIZED.**

Persistent implementation is authorized only after canonical schemas for Product System, Constituent Part, Regulatory Applicability and Integrated Risk are created, adversarially reviewed, and mapped to existing DER/EIG/DDG/control-plane contracts.

**END OF CONTROLLED DOCUMENT**
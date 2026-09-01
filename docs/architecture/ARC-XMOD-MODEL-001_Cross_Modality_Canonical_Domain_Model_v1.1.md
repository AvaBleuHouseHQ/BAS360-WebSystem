# ARC-XMOD-MODEL-001 — Cross-Modality Canonical Domain Model

**Document ID:** ARC-XMOD-MODEL-001  
**Version:** 1.1  
**Status:** CONTROLLED — SUPERSEDES v1.0  
**System:** Archemedica / BAS360-WebSystem  
**Author/Document Owner:** Cassandra Harrison  
**Effective Date:** 2026-09-01  
**Governed By:** ARC-STD-001 v1.0  
**Corrective Basis:** ARC-XMOD-VERIFY-001-EXEC v1.0 findings XMOD-001 through XMOD-003

> **Core rule:** Archemedica models one regulated-product development system with modality- and jurisdiction-specific overlays. Product configuration, regulatory requirements, and lifecycle control objects are first-class so the system can preserve real cross-domain dependencies without converting every specialty into a separate silo.

## 1. Canonical Hierarchy
**Tenant → Development Program → Regulated Product System (`RPS-*`) → Product Configuration/Presentation (`CFG-*`) → Constituent Parts (`CPT-*`) → Investigations/Studies (`STU-*`) → Protocols/Plans (`PRO-*`) and other controlled lifecycle objects.**

The hierarchy is not a containment prison. Requirements, risks, evidence, decisions, lifecycle controls and obligations may relate across levels through version-aware controlled edges.

## 2. Product System and Configuration
### 2.1 Regulated Product System (`RPS-*`)
Represents the therapeutic/diagnostic system as a whole: intended use, indication, target population, lifecycle state, product concept and constituent topology history.

### 2.2 Product Configuration / Presentation (`CFG-*`)
Represents a versioned commercial/investigational configuration or presentation of an RPS. It may encode integral, co-packaged, cross-labeled, kit, reusable/non-reusable delivery relationships, region-specific presentation, strength/dose presentation, accessories and other topology relevant to regulation or use.

Minimum controlled attributes include:
- configuration ID/version;
- RPS;
- effective interval;
- jurisdiction/market context where applicable;
- participating constituent versions and relationship type;
- labeling/presentation identity;
- intended-use/use-condition differences;
- topology/classification uncertainty;
- predecessor/successor configuration;
- source/evidence for material classification/topology assertions.

A configuration/topology change is a controlled `CHG-*` event and may trigger classification, RSA, risk, DER, manufacturing, labeling, usability and clinical reassessment.

## 3. Constituent Part (`CPT-*`)
Versioned controlled product component. Types include drug, biologic, device, software, IVD/diagnostic, HCT/P-related, delivery system, accessory and other regulated constituent types.

A manufacturing process, design input or test method is **not** a constituent merely because it is important to the product.

## 4. Regulatory Source, Requirement and Applicability Chain
### 4.1 Regulatory/Standards Source (`SRC-*`)
Versioned law, regulation, standard, guidance, commitment or other authoritative/controlled source with jurisdiction, issuing body, edition/effective interval and provenance.

### 4.2 Controlled Requirement (`REQ-*`)
Granular requirement or interpretable controlled provision derived from a source and used for applicability/change analysis.

Minimum attributes:
- requirement ID;
- parent source/version;
- locator/section/clause;
- requirement category;
- effective interval;
- applicability conditions/exceptions;
- interpretation status/provenance;
- superseded-by relationship;
- evidence/obligation types normally associated with the requirement;
- uncertainty/human-review state.

### 4.3 Regulatory/Standards Applicability Assessment (`RSA-*`)
Context-specific assessment that a `REQ-*` applies, partially applies, does not apply, is unknown, or requires human judgment for a particular RPS, CFG, CPT, study, process, artifact or action.

Allowed states: `APPLIES`, `DOES_NOT_APPLY`, `PARTIAL`, `UNKNOWN`, `HUMAN_JUDGMENT_REQUIRED`.

`UNKNOWN` never defaults to `DOES_NOT_APPLY`.

### 4.4 Obligation (`OBL-*`)
Action/control/evidence obligation resulting from applicable requirement, DER, risk control, quality event, protocol, commitment or other governed basis.

The chain is therefore:

**SRC → REQ → RSA(context) → OBL/evidence/control**, with DER/DDG/EIG relationships as applicable.

## 5. Lifecycle Control Object (`LCO-*`)
First-class versioned object representing how the product is designed, manufactured, tested, configured or controlled rather than what the constituent itself is.

Typed LCO domains may include:
- manufacturing process/unit operation;
- material/specification;
- formulation/process parameter;
- design input/output;
- engineering verification/validation;
- usability/human-factors control;
- software configuration/build;
- cybersecurity control/configuration;
- analytical/test method;
- process validation/control strategy;
- packaging/labeling control;
- sterilization where applicable;
- supplier qualification/control;
- device risk control;
- CMC/control strategy element;
- data/computerized-system configuration where materially linked to product evidence or decision.

LCOs link to RPS/CFG/CPT and may independently trigger `CHG-*`, risk, DER, RSA and reassessment relationships.

## 6. Remaining Canonical Objects
The following v1.0 objects remain: Tenant; Development Program; Study/Investigation; Protocol/Investigation Plan; Controlled Change (`CHG-*` with `PCHG-*` subtype); integrated Risk (`RSK-*`); Evidence Snapshot (`EVS-*`); Evidence Integrity Assessment (`EIG-*`); Dependency Edge/Coverage (`DEP-*`/`DCA-*`); Decision Evidence Record (`DER-*`); Model/Algorithm Use (`MUSE-*`); Safety/Quality Signal (`SIG-*`); Supplier/External Dependency (`SUP-*`); Audit/State Transition Event (`AUD-*`/`EVT-*`).

## 7. Cross-Domain Propagation Rules
Material changes may originate at any controlled object. No domain owns the change merely because it discovered it.

Examples:
- `PCHG dose` → biologic CPT + delivery-device CPT + CFG + usability LCO + labeling LCO + RSA/REQ + DER/OBL;
- `LCO formulation viscosity` → biologic CPT + device compatibility LCO + CFG + evidence/risk + clinical DER;
- `CPT diagnostic threshold/version` → eligibility/protocol + statistics + benefit-risk + RSA + labeling;
- `LCO software build` → cybersecurity + usability + device risk + treatment-delivery risk + clinical safety;
- `SUP material change` → material/spec LCO + design/biocompatibility LCO + manufacturing + RSA + product/configuration risk.

## 8. Sparse-by-Default Integration Rule
Archemedica shall not require complete import/modeling of every clause, design artifact, manufacturing process or specialist-system record.

Create/ingest a canonical object when it is material to at least one of:
- active decision;
- dependency/change impact;
- applicable regulatory/standards requirement;
- risk/control;
- evidence provenance;
- obligation/readiness;
- audit reconstruction;
- regulatory-science/policy analysis authorized under ARC-POLICY-EVID-001.

Specialist systems remain systems of record where appropriate. Archemedica stores controlled identity, relevant version/context, relationships and evidence needed for decision continuity.

## 9. Policy/Standards Evidence Specificity
Policy/standards analysis must be able to distinguish whether observed burden/outcome is associated with:
- source/regulatory regime;
- granular requirement;
- interpretation/application;
- jurisdiction;
- product configuration;
- constituent interaction;
- lifecycle control/manufacturing/design dependency;
- sponsor implementation choice;
- missing data/coverage.

This prevents the system from blaming “regulation” for effects actually caused by configuration, implementation or unmeasured factors.

## 10. Corrective Retest Targets
Retest ARC-XMOD-VERIFY-001 scenarios XM-OQ-002, 008, 009, 012 and 019 against v1.1, then regression-test all remaining scenarios.

## 11. Implementation Gate
Persistent implementation remains unauthorized until corrective retest is documented and critical scenarios pass or are formally blocked with accepted residual risk.

## 12. Change History
| Version | Date | Change | Status |
|---|---|---|---|
| 1.0 | 2026-09-01 | Initial RPS/constituent cross-modality model | SUPERSEDED — verification found three material gaps |
| 1.1 | 2026-09-01 | Added Product Configuration/Presentation, Controlled Requirement chain, and Lifecycle Control Object; strengthened sparse integration and policy-evidence specificity | CONTROLLED — CORRECTIVE DESIGN |

**END OF CONTROLLED DOCUMENT**
# ARC-XMOD-MODEL-001 — Cross-Modality Canonical Domain Model

**Document ID:** ARC-XMOD-MODEL-001  
**Version:** 1.0  
**Status:** CONTROLLED — PRE-IMPLEMENTATION ARCHITECTURE BASELINE  
**System:** Archemedica / BAS360-WebSystem  
**Author/Document Owner:** Cassandra Harrison  
**Effective Date:** 2026-09-01  
**Governed By:** ARC-STD-001 v1.0  
**Related:** ARC-ISO-BASELINE-001 v1.1; ARC-XMOD-REVIEW-001; ARC-PILOT-001; ARC-SYS-HARDEN-001

> **Core rule:** Archemedica shall model one regulated-product development system with modality- and jurisdiction-specific overlays. Protocols, devices, drugs, biologics, software, diagnostics, manufacturing processes, evidence, risks and regulatory obligations are related controlled objects, not isolated application silos.

## 1. Purpose
Define the canonical object hierarchy and relationship rules required for Archemedica to support drug, biologic, device, software, diagnostic and combination-product development without making any single historical regulatory silo the architectural root.

## 2. Root Hierarchy
The canonical hierarchy is:

**Tenant → Development Program → Regulated Product System → Constituent Parts → Investigations/Studies → Protocols and other controlled lifecycle objects.**

A Regulated Product System may have one or many constituent parts. A constituent part may be drug, biologic, device, software, IVD/diagnostic, HCT/P-related, manufacturing/process element, accessory, delivery system or another regulated constituent type.

A study/protocol is a controlled evidence-generating context within the product system. It is not the root of the product ontology.

## 3. Mandatory Canonical Objects
### 3.1 Tenant
Security, ownership, policy and data-boundary context.

### 3.2 Development Program
Sponsor-controlled development program spanning one or more studies, markets, jurisdictions, products or constituent versions.

### 3.3 Regulated Product System (`RPS-*`)
The therapeutic/diagnostic product considered as a whole, including intended use, indication, target population, presentation, constituent topology, lifecycle state and jurisdictional context.

### 3.4 Constituent Part (`CPT-*`)
A versioned controlled component of the RPS. Fields shall support type, intended role, version/configuration, manufacturer/supplier where applicable, relation to other constituents and regulatory classification uncertainty.

### 3.5 Regulatory Classification / Jurisdiction Context (`RCL-*`)
Versioned classification evidence including jurisdiction, statutory/regulatory category, PMOA/main mode of action where applicable, lead authority/center, investigational/marketing pathway, source/version, uncertainty and determination history.

### 3.6 Regulatory/Standards Applicability Assessment (`RSA-*`)
Represents whether a regulation, standard, guidance, commitment or controlled requirement applies to an RPS, constituent, study, process, artifact or action. Allowed states include `APPLIES`, `DOES_NOT_APPLY`, `PARTIAL`, `UNKNOWN`, `HUMAN_JUDGMENT_REQUIRED`. `UNKNOWN` may not collapse to `DOES_NOT_APPLY`.

### 3.7 Investigation / Study (`STU-*`)
Clinical, nonclinical, usability/human-factors, engineering, analytical, software, performance, validation or other controlled investigation that produces evidence relevant to the RPS or constituent parts.

### 3.8 Protocol / Investigation Plan (`PRO-*`)
Versioned plan governing an investigation. Clinical protocols are one subtype; device clinical investigation plans, usability protocols, software verification plans and other investigation plans shall not require separate ontologies to participate in decision continuity.

### 3.9 Controlled Change (`CHG-*`)
A normalized change object capable of representing protocol, product, device design, software, manufacturing/process, labeling, diagnostic, regulatory, supplier, cybersecurity, evidence or configuration changes. `PCHG-*` remains the protocol-specific subtype.

### 3.10 Risk Record (`RSK-*`)
One integrated risk object with domain tagging rather than separate incompatible risk databases. Domains may include clinical safety, pharmacovigilance, device hazard, usability, software, cybersecurity, privacy, manufacturing/process, CMC, diagnostic performance, data integrity, regulatory and operational risk.

### 3.11 Evidence Snapshot (`EVS-*`)
Decision-time evidence identity/version, provenance, source authority, transformations, hash/locator, retention/rights limitations and contextual applicability.

### 3.12 Evidence Integrity Assessment (`EIG-*`)
Supportability state of a material claim/evidence relationship. It does not declare scientific truth.

### 3.13 Dependency Edge / Coverage Assessment (`DEP-*` / `DCA-*`)
Explainable causal or governance relationship between controlled objects plus explicit coverage sufficiency. Absence of a returned edge is not proof of no impact without sufficient coverage.

### 3.14 Decision Evidence Record (`DER-*`)
Accountable decision object referencing affected RPS/constituents, evidence, risks, requirements, alternatives, unresolved issues, rationale, owner, implementation obligations and reassessment triggers.

### 3.15 Obligation (`OBL-*`)
Required action arising from regulation, quality system, decision, risk control, protocol, design control, safety event, manufacturing change, submission commitment or post-market requirement.

### 3.16 Model / Algorithm Use (`MUSE-*`)
Versioned model or algorithm context-of-use record with provenance, preprocessing, limitations, risk, human oversight and reassessment triggers.

### 3.17 Safety / Quality Signal (`SIG-*`)
A controlled signal capable of linking adverse events, device malfunctions, use errors, cybersecurity incidents, product-quality events, manufacturing excursions, diagnostic failures or emerging external evidence to reassessment.

### 3.18 Supplier / External Dependency (`SUP-*`)
Controlled supplier, service, data source, model, cloud, laboratory, manufacturer or other external dependency with context-of-use and failure behavior.

### 3.19 Audit / State Transition Event (`AUD-*` / `EVT-*`)
Immutable event identity preserving actor, authority, tenant, object, prior revision/state, resulting state, cause, evidence and reconciliation status.

## 4. Relationship Rules
The system shall support many-to-many, version-aware relationships. Examples include:

- RPS `HAS_CONSTITUENT` Constituent;
- Constituent `DEPENDS_ON` Constituent;
- Study `EVALUATES` RPS/Constituent;
- Protocol `GOVERNS` Study;
- Change `AFFECTS` any controlled object;
- Regulation/Standard `APPLIES_TO` object through RSA;
- Risk `ARISES_FROM` hazard/change/evidence/constituent;
- Evidence `SUPPORTS` or `CONFLICTS_WITH` claim/decision/risk/control;
- DER `DECIDES_ON` change/risk/obligation;
- Obligation `IMPLEMENTS` DER/risk/regulatory requirement;
- Signal `REOPENS` risk/DER/applicability assessment;
- Supplier `PROVIDES_OR_CONTROLS` constituent/service/evidence source;
- ModelUse `INFLUENCES` claim/impact/decision;
- Event `SUPERSEDES` prior version without deletion.

Every consequential relationship shall preserve source, confidence/authority where applicable, validity interval and tenant/security boundary.

## 5. Cross-Modality Change Propagation
A material change shall be assessed against the RPS and all relevant constituent/domain relationships. Examples:

- dose change → clinical safety + pharmacology + injector usability + labeling + training + device compatibility + manufacturing + regulatory impact;
- biologic formulation change → stability/CMC + delivery-device compatibility + biocompatibility/use conditions + clinical comparability + labeling;
- companion diagnostic threshold change → eligibility + treatment assignment + diagnostic performance + benefit/risk + protocol/statistics + regulatory obligations;
- pump software update → software lifecycle + cybersecurity + dose delivery + human factors + device risk + clinical safety + labeling/training;
- supplier change → manufacturing/process + design/material + quality + validation + regulatory commitments + evidence provenance.

No originating discipline may close cross-domain impact simply because the change began in its own silo.

## 6. Regulatory Overlay Principle
Regulatory/standards logic is attached through versioned applicability assessments, not hard-coded into isolated product modules.

The system shall preserve:
- source authority;
- jurisdiction;
- edition/version/effective date;
- applicability conditions;
- object(s) in scope;
- rationale and reviewer;
- uncertainty;
- downstream controls/obligations;
- reassessment trigger when source, classification, intended use or constituent topology changes.

## 7. Policy/Standards Evidence Readiness
The canonical model shall be able to produce de-identified, permissioned evidence about where regulatory domains converge, conflict, duplicate work or create unanticipated cross-domain consequences. This capability must be derived from ordinary controlled workflow evidence, not from manually curated advocacy datasets.

Any future policy or standards analysis must preserve denominator, inclusion/exclusion rules, jurisdiction, time period, product context, missingness, uncertainty, contrary evidence and data-rights limitations.

## 8. Anti-Silo Design Tests
Architecture fails if any of the following is true:

1. a combination product requires duplicate product identities in separate drug/device roots;
2. the same evidence must be manually entered into separate modality modules;
3. a device/software/manufacturing change cannot trigger reassessment of a clinical DER;
4. a protocol amendment cannot trigger device/diagnostic/manufacturing applicability review;
5. regulatory classification is a static enum rather than versioned evidence;
6. one constituent's lead regulatory pathway suppresses other applicable controls;
7. risk objects cannot causally link across clinical/device/software/manufacturing domains;
8. a policy/standards query cannot distinguish true absence from unassessed/missing data;
9. historical rules are overwritten when regulations/standards change;
10. the architecture requires a universal manually maintained ontology before producing value.

## 9. Implementation Boundary
This document authorizes schema/design work only. Persistent implementation remains gated on adversarial review and traceability against ARC-PILOT-001 requirements and cross-modality addenda.

## 10. Initial Disposition
**CONDITIONAL PASS — CANONICAL MODEL ESTABLISHED; ADVERSARIAL VERIFICATION REQUIRED BEFORE PERSISTENCE BUILD.**

## 11. Change History
| Version | Date | Change | Status |
|---|---|---|---|
| 1.0 | 2026-09-01 | Established cross-modality canonical product-system domain model | CONTROLLED — PRE-IMPLEMENTATION |

**END OF CONTROLLED DOCUMENT**
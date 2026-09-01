# ARC-ISO-BASELINE-001 — Archemedica ISO-Aligned Engineering and Management Baseline

**Document ID:** ARC-ISO-BASELINE-001  
**Version:** 1.1  
**Status:** CONTROLLED — SUPERSEDES v1.0  
**System:** Archemedica / BAS360-WebSystem  
**Author/Document Owner:** Cassandra Harrison  
**Effective Date:** 2026-09-01  
**Governed By:** ARC-STD-001 v1.0  
**Applies To:** ARC-PILOT-001 and subsequent controlled development unless superseded

> **Control principle:** Archemedica is a modality-agnostic regulated-product development and decision-integrity system. It shall not structurally separate pharmaceutical/biologic and medical-device development into isolated architectural universes. Applicable requirements shall be activated according to intended use, product/constituent classification, jurisdiction, development stage, risk, primary mode of action, and context of use.

> **Claim boundary:** This baseline is an engineering and regulatory-design baseline. It does not claim ISO certification, regulatory compliance, conformity assessment, validation, market authorization, accreditation, or regulator acceptance.

## 1. Purpose
Establish one cross-modality life-cycle, quality, safety, software, information-security, privacy, AI-governance and regulatory-control architecture capable of supporting drug, biologic, device, software, diagnostic and combination-product development without duplicating the core decision/evidence system for each historical regulatory silo.

## 2. Core Industry Model
Archemedica shall treat regulated therapeutic development as one shared system with modality-specific overlays.

The shared core includes:
- intended use and indication;
- benefit/risk reasoning;
- development planning;
- nonclinical and clinical evidence;
- protocol and amendment control;
- human-subject protection;
- safety surveillance;
- evidence integrity and provenance;
- quality management;
- risk management;
- design/change/configuration control;
- supplier/vendor control;
- manufacturing/process controls;
- computerized-system/software controls;
- security/privacy;
- regulatory submissions and commitments;
- post-authorization/post-market change and surveillance;
- CAPA/deviation/nonconformity handling;
- traceability and audit reconstruction.

The regulatory overlay determines which specialized requirements apply and how they are evidenced.

## 3. Product/Modality Coverage
The architecture shall support, at minimum, context-aware applicability for:

- small-molecule drugs;
- biological products;
- vaccines;
- cell and gene therapies;
- medical devices;
- software as a medical device where applicable;
- software in/with regulated products;
- in-vitro diagnostics;
- drug-device combination products;
- biologic-device combination products;
- drug-biologic products;
- drug-device-biologic combination products;
- co-packaged and cross-labeled combination products;
- HCT/P-related development where applicable;
- companion/complementary diagnostic relationships;
- delivery systems, implants, injectors, pumps, wearable/connected therapeutic systems and other constituent-part configurations.

No core decision record shall assume that a study or product has exactly one regulatory modality.

## 4. Classification Is Metadata and Governance — Not Architecture
Product classification shall be represented as controlled, versioned context attached to the regulated product and constituent parts.

At minimum preserve:
- jurisdiction;
- intended use;
- product classification;
- constituent-part classification;
- primary mode of action or equivalent jurisdictional determination where applicable;
- lead/primary regulatory center or authority where applicable;
- investigational/marketing pathway;
- applicable standards/regulations/guidances;
- classification uncertainty;
- designation/request-for-designation or equivalent determination history;
- effective dates and superseded interpretations.

A regulatory classification change shall trigger impact assessment across affected requirements, evidence, quality controls, clinical plans, manufacturing, labeling, safety, software and post-market obligations.

## 5. Standards Baseline — Shared Core
The shared engineering/management baseline includes, as applicable:

- ISO/IEC/IEEE 12207 — software life-cycle processes;
- ISO/IEC 25010 — software product quality model;
- ISO/IEC 27001 — information-security management;
- ISO/IEC 27701 — privacy-information management;
- ISO/IEC 42001 — AI management systems;
- ISO 9001 — general quality-management principles and system controls.

## 6. Medical-Device / Combination-Product Standards Are In-Scope Applicability Domains
The following shall no longer be treated as future-only exceptions. They are controlled applicability domains that Archemedica must be capable of mapping when relevant to a product, constituent part, workflow or customer context:

- ISO 13485 — medical-device quality management systems;
- ISO 14971 — medical-device risk management;
- IEC 62304 — medical-device software life-cycle processes where applicable;
- IEC 62366-1 — usability engineering for medical devices where applicable;
- IEC 60601 family — electrical medical equipment where applicable;
- ISO 10993 family — biological evaluation/biocompatibility where applicable;
- ISO 14155 — clinical investigation of medical devices where applicable;
- cybersecurity/security standards and regulatory requirements applicable to connected/software-enabled devices;
- IVD-specific standards and requirements where applicable.

These overlays become normative for a controlled object only when applicability is established. Their existence, however, is part of the architecture from the start.

## 7. Drug/Biologic and Clinical Development Regulatory Domains
Archemedica shall likewise support applicability mapping for drug/biologic development, including as relevant:

- ICH E6(R3) and applicable GCP requirements;
- ICH quality, safety, efficacy and multidisciplinary guidelines applicable to context;
- GMP/GDP/GxP controls applicable to investigational and commercial product lifecycle;
- pharmacovigilance/safety reporting requirements;
- clinical data integrity and computerized-system expectations;
- protocol, investigator brochure, informed consent and statistical/data-management controls;
- CMC/process/manufacturing change implications;
- jurisdiction-specific clinical-trial and marketing-authorization requirements.

## 8. Combination-Product Architecture Rule
For combination products Archemedica shall not select one constituent regime and discard the others.

The system shall preserve:
1. each constituent part;
2. each constituent's applicable quality/safety/design/manufacturing controls;
3. product-level integrated benefit/risk and intended use;
4. primary regulatory assignment where applicable;
5. cross-constituent dependencies;
6. combination-specific manufacturing and quality obligations;
7. human-factors/use-related risk where device interaction affects therapy;
8. software/cybersecurity dependencies where connected components exist;
9. clinical evidence relationships between constituent parts;
10. post-market/post-approval change impacts across all constituents.

A change to one constituent may not be closed as `NO_IMPACT` until relevant cross-constituent dependency coverage is sufficient.

## 9. Regulatory Agnosticism Does Not Mean Regulatory Flattening
Archemedica must not pretend all modalities have identical regulatory requirements.

Real differences shall remain explicit, including:
- statutory product definitions;
- regulatory submission/authorization pathways;
- device classification/risk class;
- primary mode of action;
- design controls and engineering verification/validation expectations;
- manufacturing/process validation approaches;
- biocompatibility/electrical/usability requirements;
- pharmacology/toxicology and CMC requirements;
- software lifecycle and cybersecurity controls;
- clinical investigation frameworks;
- adverse-event/vigilance reporting schemes;
- labeling and post-market obligations.

The architectural principle is one evidence/decision spine with governed applicability, not one undifferentiated rulebook.

## 10. Applicability Engine Requirement
ARC-PILOT-001 and future builds shall include a controlled Regulatory/Standards Applicability object capable of representing:

- requirement source;
- source version/effective date;
- jurisdiction;
- modality/constituent applicability;
- development stage;
- intended-use/context conditions;
- applicability state: `APPLIES`, `DOES_NOT_APPLY`, `PARTIAL`, `UNKNOWN`, `HUMAN_JUDGMENT_REQUIRED`;
- rationale;
- responsible reviewer;
- evidence/source snapshot;
- downstream affected controls/artifacts;
- reassessment triggers.

`UNKNOWN` shall never default to `DOES_NOT_APPLY`.

## 11. Integrated Risk Model
Risk records shall support clinical, patient/user, product, software, cybersecurity, privacy, manufacturing, quality, operational and regulatory risks in one causal structure.

Device-style hazard analysis and drug/biologic benefit-risk/safety reasoning shall be linkable rather than isolated when they affect the same therapeutic system.

Examples:
- injector failure can become a dose-exposure and clinical-safety issue;
- pump software failure can become treatment interruption or overdose risk;
- companion diagnostic misclassification can alter eligibility and treatment benefit-risk;
- manufacturing change to a biologic can affect a delivery-device compatibility assessment;
- protocol dose change can affect device usability, labeling, training and human factors;
- cybersecurity compromise of a connected therapeutic device can become a patient-safety event.

## 12. Shared Change-Control Rule
Any material change shall be assessed across every applicable domain, not only the originating discipline.

At minimum ask whether the change affects:
- clinical safety/efficacy;
- human subjects;
- device safety/performance;
- software;
- cybersecurity;
- usability/human factors;
- biocompatibility;
- CMC/manufacturing/process controls;
- labeling/IFU;
- regulatory submissions/commitments;
- quality-system records;
- risk-management files;
- validation/verification evidence;
- post-market obligations;
- suppliers/constituent parts;
- combination-product dependencies.

## 13. Evidence and Decision Integrity
DER, DDG, EIG, PCDI and future Archemedica objects shall remain modality-neutral.

They may carry specialized domain extensions, but the canonical evidence/decision lineage shall not be duplicated into separate Pharma DER, Device DER or Biologic DER systems.

## 14. Anti-Silo / Anti-Bureaucracy Rule
Do not reproduce CDER/CBER/CDRH organizational boundaries as separate product databases or duplicated workflows.

Do not require users to enter the same decision/evidence metadata once for drug quality, again for device quality, again for clinical operations and again for combination-product governance.

Capture canonical facts once; apply all relevant regulatory lenses to those facts.

## 15. ISO/QMS Design Consequence
Archemedica shall be capable of supporting both ISO 9001-style general QMS principles and ISO 13485-style medical-device regulatory QMS requirements where applicable, while retaining broader pharmaceutical/biologic GxP and ICH controls.

The application shall treat these as intersecting control sets, not mutually exclusive templates.

## 16. Regulatory Source Registry
Maintain a controlled source registry capable of incorporating applicable:
- FDA statutes/regulations/guidances;
- ICH guidelines;
- ISO/IEC standards;
- EU regulations/guidance including medicinal-product, medical-device and IVD domains;
- other jurisdictional requirements as product development expands.

Each source shall preserve version/effective date, authority, jurisdiction, applicability context, interpretation status and reassessment triggers.

## 17. ARC-PILOT-001 Change
ARC-PILOT-001 shall be executed using the modality-agnostic architecture even though its first representative scenario is an oncology protocol amendment.

The pilot data model and APIs shall therefore avoid fields or assumptions that prevent later attachment of:
- a delivery device;
- companion diagnostic;
- software-controlled administration component;
- device constituent;
- biologic constituent;
- cross-labeled combination-product relationship.

This does not expand the first pilot UI into every modality. It prevents a pharma-only data model from becoming technical debt.

## 18. Reassessment Triggers
Reassess this baseline when product classification, intended use, constituent configuration, primary mode of action, jurisdiction, regulatory pathway or applicable standard changes.

Combination-product reclassification or addition/removal of a constituent part is automatically a Tier-3 reassessment trigger.

## 19. Disposition
**ADOPT — MODALITY-AGNOSTIC REGULATED-PRODUCT ENGINEERING BASELINE.**

Archemedica shall know the differences among drug, biologic, device, diagnostic, software and combination-product regulation without hard-coding the historical industry silos into its core architecture.

## 20. Change History

| Version | Date | Change | Status |
|---|---|---|---|
| 1.0 | 2026-09-01 | Initial ISO-aligned engineering baseline | SUPERSEDED |
| 1.1 | 2026-09-01 | Reframed architecture as modality-agnostic regulated-product system; incorporated device and combination-product standards/applicability from inception | CONTROLLED — CURRENT |

**END OF CONTROLLED DOCUMENT**
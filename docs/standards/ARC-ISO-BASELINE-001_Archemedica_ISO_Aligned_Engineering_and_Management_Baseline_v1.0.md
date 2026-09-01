# ARC-ISO-BASELINE-001 — Archemedica ISO-Aligned Engineering and Management Baseline

**Document ID:** ARC-ISO-BASELINE-001  
**Version:** 1.0  
**Status:** CONTROLLED — ENGINEERING BASELINE  
**System:** Archemedica / BAS360-WebSystem  
**Author/Document Owner:** Cassandra Harrison  
**Effective Date:** 2026-09-01  
**Governed By:** ARC-STD-001 v1.0  
**Applies To:** ARC-PILOT-001 and subsequent controlled software/AI development unless superseded

> **Claim boundary:** Archemedica shall be engineered with applicable ISO/IEC principles and requirements in mind. This baseline does not claim ISO certification, conformity, accreditation, or third-party assessment. Applicability shall be context-specific and evidence-based.

## 1. Purpose
Establish the ISO-aligned management, software-life-cycle, software-quality, information-security, privacy and AI-governance principles that must be considered during Archemedica design, implementation, verification, pilot operation, maintenance and change control.

## 2. Primary Standards Baseline
The controlled standards baseline for current Archemedica development is:

- **ISO/IEC/IEEE 12207:2026** — software life-cycle processes. Use as the primary life-cycle process framework for development, operation, maintenance, support, change and retirement.
- **ISO/IEC 25010:2023** — software product quality model. Use to structure quality requirements and evaluation rather than treating functional correctness as the only quality dimension.
- **ISO/IEC 27001:2022** — information security management systems. Use risk-based confidentiality, integrity and availability principles and controlled information-security management practices.
- **ISO/IEC 27701:2025** — privacy information management systems. Apply when Archemedica controls or processes PII and use it to structure privacy accountability and PII processing controls.
- **ISO/IEC 42001:2023** — AI management systems. Use for responsible AI governance, AI risk/opportunity management, accountability, transparency, traceability and continual improvement.
- **ISO 9001 current applicable edition/transition baseline** — quality management principles, controlled processes, customer focus, risk/opportunity management, documented information, performance evaluation, corrective action and continual improvement. Because ISO 9001 is in a 2026 edition transition, the exact normative edition used for any future conformity/certification claim must be verified at that time.

## 3. Conditional / Context-Dependent Standards
Do not automatically impose medical-device standards on Archemedica merely because it operates in clinical development. Standards such as ISO 13485 and medical-device software/risk standards require an explicit intended-use and regulatory-classification assessment before becoming normative project requirements.

If Archemedica functionality later meets a medical-device/SaMD definition or is incorporated into a regulated medical device, open a controlled applicability assessment and update this baseline before release of that functionality.

## 4. ISO-Aligned Development Principles

### 4.1 Life-Cycle Control
Every material build shall have identifiable need, requirements, design basis, implementation evidence, verification, change history, maintenance/reassessment triggers and retirement/supersession path.

### 4.2 Risk-Based Quality
Controls shall be proportionate to consequence and context. Tier-3/high-consequence functions require stronger review, negative testing, traceability and evidence than low-risk administrative functions.

### 4.3 Requirements Traceability
Material requirements shall trace to design/implementation and objective verification evidence. Failed requirements remain visible as deviations until corrected, accepted with justified residual risk, deferred, or retired through controlled disposition.

### 4.4 Configuration and Change Management
Controlled artifacts, schemas, code, fixtures, tests and releases require version identity. Changes must preserve before-state, reason, impact, implementation, verification, rollback and supersession lineage.

### 4.5 Quality Characteristics
ARC-PILOT-001 requirements and verification shall consider applicable ISO/IEC 25010 product-quality characteristics, including functional suitability, performance efficiency, compatibility, interaction capability/usability, reliability, security, maintainability, flexibility and safety where applicable to the product context.

### 4.6 Information Security
Security shall be designed as a management and system property, not a final penetration-test step. At minimum address asset/data classification, least privilege, tenant isolation, authentication/authorization boundaries, confidentiality, integrity, availability, logging/auditability, secure configuration, vulnerability/change management, supplier/service risk, backup/recovery, incident handling and evidence preservation according to context.

### 4.7 Privacy
Where PII is processed, document controller/processor role, purpose, lawful basis or customer instruction as applicable, data minimization, access, retention, deletion/export, cross-border considerations, processor/subprocessor controls, incident obligations and data-subject/privacy rights support. No cross-tenant training or secondary use shall be inferred from possession of customer data.

### 4.8 AI Governance
For AI-enabled functions preserve intended purpose/context of use, responsible owner, model/system identity and version, data/input provenance, limitations, risk assessment, human oversight, monitoring/reassessment triggers, material changes, incident/deviation history and retirement/supersession. AI output is not automatically authoritative.

### 4.9 Supplier and External Service Control
External models, cloud services, data providers, regulatory feeds, archives and other dependencies require fit-for-purpose assessment proportionate to risk. Vendor claims do not substitute for Archemedica's own context-of-use assessment.

### 4.10 Documented Information and Evidence
Evidence must be attributable to a controlled object/event/version and retrievable for its required retention period. Narrative assertions without objective evidence do not close a verification requirement.

### 4.11 Nonconformity / Deviation and Corrective Action
Detected failures shall be recorded, contained where necessary, investigated proportionately, corrected, retested and assessed for recurrence/systemic impact. Prior failure evidence shall not be deleted to make the record appear clean.

### 4.12 Performance Evaluation and Continual Improvement
Pilot metrics, defects, security/privacy events, user burden, false negatives/positives, overrides, reconstruction performance and customer evidence shall feed controlled reassessment. Improvement must not silently change consequential system behavior without change control.

## 5. ARC-PILOT-001 Mandatory ISO-Derived Engineering Requirements
ARC-PILOT-001 shall add explicit requirements and tests for:

1. requirements/design/test bidirectional traceability;
2. configuration/version identification of code, schemas, fixtures and evidence;
3. defined software life-cycle/change states;
4. quality-characteristic acceptance criteria beyond happy-path functionality;
5. tenant/security boundary threat and negative tests;
6. privacy/data-minimization and retention behavior for any PII-bearing pilot configuration;
7. AI/model context-of-use, version, limitation and human-oversight records when AI/model output materially influences a decision;
8. supplier/external-service dependency inventory and failure behavior;
9. backup/recovery and historical reconstruction behavior for persistent decision records;
10. incident/deviation/nonconformity linkage to corrective action and regression testing;
11. objective release/pilot disposition evidence;
12. controlled maintenance, reassessment and retirement/supersession behavior.

## 6. Architecture Consequences
ISO alignment does **not** mean creating a form for every clause. Archemedica shall prefer controls generated from normal system behavior: automatic versioning, audit events, provenance, state transitions, test evidence, access policy, configuration capture and traceability.

The anti-bureaucracy requirement remains controlling: if ISO-aligned governance is implemented as duplicate manual paperwork rather than risk-reducing system behavior, redesign it.

## 7. Certification / Conformity Boundary
No artifact may state or imply that Archemedica is ISO certified, ISO compliant, ISO conformant, validated, accredited, or audited to a standard unless the exact claim, scope, edition, evidence and independent assessment support that statement.

During development use wording such as **ISO-aligned engineering baseline**, **designed with applicable ISO/IEC principles in mind**, or **mapped to selected ISO/IEC requirements/principles**, with explicit limitations.

## 8. Reassessment Triggers
Reassess this baseline when:

- an ISO standard used here is revised/superseded;
- intended use materially changes;
- Archemedica begins processing new classes of sensitive/regulated data;
- AI functionality becomes more consequential or autonomous;
- a medical-device/SaMD classification question becomes plausible;
- a customer or regulator imposes additional normative standards;
- production architecture/cloud/supplier model changes materially;
- certification is pursued;
- pilot failures reveal a missing management/system control.

## 9. Initial Disposition
**ADOPT — CROSS-CUTTING ENGINEERING BASELINE.**

Apply this baseline to ARC-PILOT-001 requirements, design, implementation, verification and future controlled changes. It supplements rather than replaces ARC-STD-001, ARC-SYS-HARDEN-001, PCDI, DER, DDG, EIG and other controlled Archemedica contracts.

## 10. Change History

| Version | Date | Change | Status |
|---|---|---|---|
| 1.0 | 2026-09-01 | Established cross-cutting ISO-aligned engineering and management baseline for Archemedica | CONTROLLED — ENGINEERING BASELINE |

**END OF CONTROLLED DOCUMENT**
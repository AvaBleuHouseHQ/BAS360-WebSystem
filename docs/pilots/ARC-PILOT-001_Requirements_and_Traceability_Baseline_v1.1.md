# ARC-PILOT-001 — Requirements and Traceability Baseline

**Document ID:** ARC-PILOT-001-RTM  
**Version:** 1.1  
**Status:** CONTROLLED — SUPERSEDES v1.0  
**System:** Archemedica / BAS360-WebSystem  
**Author/Document Owner:** Cassandra Harrison  
**Parent:** ARC-PILOT-001 v1.0  
**Standards Baseline:** ARC-ISO-BASELINE-001 v1.1  
**Canonical Domain Model:** ARC-XMOD-MODEL-001 v1.0  
**Integrated Controls:** ARC-SYS-HARDEN-001 v1.0  
**Policy Evidence Boundary:** ARC-POLICY-EVID-001 v1.0

> **Gate:** The pilot may not be implemented as a protocol-centric silo. The persistent design must prove that protocol change is one vertical slice through a modality-agnostic regulated-product system.

## 1. Canonical Context Requirements
| ID | Requirement | Verification |
|---|---|---|
| PILOT-XM-001 | Persist Tenant → Development Program → Regulated Product System (`RPS-*`) hierarchy. | IQ/OQ |
| PILOT-XM-002 | Support one or many versioned Constituent Parts (`CPT-*`) per RPS without forcing a single modality. | OQ |
| PILOT-XM-003 | Persist versioned Regulatory Classification/Jurisdiction context, including uncertainty and determination history. | OQ |
| PILOT-XM-004 | Persist Regulatory/Standards Applicability Assessments (`RSA-*`) with `APPLIES`, `DOES_NOT_APPLY`, `PARTIAL`, `UNKNOWN`, `HUMAN_JUDGMENT_REQUIRED`. | OQ negative |
| PILOT-XM-005 | `UNKNOWN` applicability may not silently become `DOES_NOT_APPLY`. | OQ negative |
| PILOT-XM-006 | Study/Protocol objects shall attach to the RPS/constituent context and shall not function as the ontology root. | architecture inspection + OQ |
| PILOT-XM-007 | Support normalized Controlled Change (`CHG-*`) with protocol-specific `PCHG-*` subtype. | OQ |
| PILOT-XM-008 | Cross-constituent changes shall trigger dependency/applicability reassessment according to coverage. | OQ/PQ |
| PILOT-XM-009 | Risk records shall support causal linkage across clinical, device, software, cybersecurity, manufacturing/CMC, diagnostic, quality and regulatory domains. | OQ/PQ |
| PILOT-XM-010 | Evidence, DER, EIG, DDG/Dependency, obligations and reassessment episodes shall reference any applicable controlled object, not only protocols. | OQ |
| PILOT-XM-011 | Lead pathway/PMOA or equivalent classification shall not suppress other applicable constituent controls. | OQ negative |
| PILOT-XM-012 | Regulatory/standards source version changes shall be capable of reopening affected applicability assessments, obligations and decisions. | OQ |
| PILOT-XM-013 | The same canonical evidence/object metadata shall be reusable across domains without duplicate manual re-entry. | PQ burden test |
| PILOT-XM-014 | Combination-product scenarios shall preserve each constituent plus product-level integrated intended use/benefit-risk context. | PQ |
| PILOT-XM-015 | Historical classification/applicability states shall be superseded, never overwritten. | OQ/PQ |
| PILOT-XM-016 | The model shall support policy/standards evidence readiness without authorizing cross-tenant secondary use. | design review + OQ access control |

## 2. Protocol Change Vertical-Slice Functional Requirements
| ID | Requirement | Verification |
|---|---|---|
| PILOT-FR-001 | Persist study and protocol-version identity within RPS/constituent context with immutable version lineage. | OQ + reconstruction PQ |
| PILOT-FR-002 | Preserve baseline/proposed protocol snapshots or bounded historical locators and integrity metadata. | OQ |
| PILOT-FR-003 | Persist atomic `PCHG-*` records with before/after, location, classification, materiality and confirmation state. | OQ |
| PILOT-FR-004 | Preserve original system extraction when a human merges, splits, rejects or reclassifies a change. | OQ |
| PILOT-FR-005 | Require applicable impact domains to be assessed or explicitly `NOT_ASSESSED`; absence shall not mean no impact. | OQ |
| PILOT-FR-006 | Persist dependency candidates, explainable paths and dependency-coverage state across product/constituent/domain boundaries. | OQ |
| PILOT-FR-007 | Block clean `NO_IMPACT` when dependency coverage is PARTIAL, UNKNOWN or STALE. | OQ negative |
| PILOT-FR-008 | Bind material evidence claims to EIG state and decision-time evidence identity/version. | OQ |
| PILOT-FR-009 | Persist jurisdiction-specific regulatory applicability, source/version and uncertainty/human-judgment state. | OQ |
| PILOT-FR-010 | Create accountable DER containing affected RPS/constituents, evidence, assumptions, alternatives, unresolved issues, rationale, decision, owner and reassessment triggers. | OQ/PQ |
| PILOT-FR-011 | Maintain implementation-readiness obligations independently from decision approval. | OQ |
| PILOT-FR-012 | Support site/jurisdiction/product-configuration effective state rather than one assumed global effective date. | OQ/PQ |
| PILOT-FR-013 | Require objective post-implementation evidence before relevant obligations close. | OQ |
| PILOT-FR-014 | Create/reuse controlled reassessment causal episodes when decision basis changes. | OQ |
| PILOT-FR-015 | Supersede prior decisions without erasing historical state. | OQ/PQ |
| PILOT-FR-016 | Reconstruct original decision-time basis and subsequent material changes across product, constituent and regulatory context. | PQ |

## 3. Integrated Control Requirements
| ID | Requirement | Verification |
|---|---|---|
| PILOT-CTL-001 | Consequential writes use expected revision/state; stale writes are rejected. | OQ concurrency |
| PILOT-CTL-002 | Scoped Safety/Quality/Regulatory holds prevent unauthorized conflicting transitions. | OQ concurrency |
| PILOT-CTL-003 | Duplicate/replayed commands/events produce one business effect. | OQ replay |
| PILOT-CTL-004 | Partial failures remain `RECONCILIATION_REQUIRED` or equivalent until durable effects reconcile. | OQ failure injection |
| PILOT-CTL-005 | Derived remediation does not self-create a new reassessment episode absent materially new basis. | OQ causal-loop |
| PILOT-CTL-006 | Tenant authorization applies to records, dependencies, derived views, search/index/cache surfaces, audit and export within implemented scope. | OQ security |
| PILOT-CTL-007 | Shared public evidence cannot expose or connect tenant-specific graph/decision existence. | OQ security |
| PILOT-CTL-008 | Prior EIG/applicability status cannot be displayed as current against changed source content/version. | OQ stale-state |
| PILOT-CTL-009 | High-risk/conflicted decisions require evidenced human-review basis and unresolved-issue disposition. | OQ negative |
| PILOT-CTL-010 | Emergency/immediate-hazard path preserves retrospective obligations and cannot falsely close them. | OQ/PQ |

## 4. ISO-Aligned Life-Cycle and Quality Requirements
| ID | Requirement | Basis | Verification |
|---|---|---|---|
| PILOT-ISO-001 | Requirements, design, implementation and tests have bidirectional traceability. | ISO/IEC/IEEE 12207 lifecycle control | IQ/OQ traceability audit |
| PILOT-ISO-002 | Code, schemas, migrations, fixtures, tests and execution evidence have controlled version/configuration identity. | configuration/change management | IQ |
| PILOT-ISO-003 | Changes preserve reason, impact, implementation, verification, rollback and supersession lineage. | lifecycle + QMS | IQ/OQ |
| PILOT-ISO-004 | Quality evaluation covers applicable product quality characteristics, not functionality alone. | ISO/IEC 25010 | OQ/PQ |
| PILOT-ISO-005 | Security risks and controls are identified pre-release and negative-tested. | ISO/IEC 27001 | OQ security |
| PILOT-ISO-006 | PII processing, if enabled, has purpose, role, minimization, access, retention/export/deletion and processor-boundary controls. | ISO/IEC 27701 | design review + OQ |
| PILOT-ISO-007 | Material AI/model use records context, version, provenance, limitations, risk, oversight and reassessment triggers. | ISO/IEC 42001 | OQ/PQ |
| PILOT-ISO-008 | External suppliers/services have dependency identity, context-of-use, risk/fit assessment and failure behavior. | supplier control | design review + OQ |
| PILOT-ISO-009 | Nonconformities/deviations link to corrective action, retest and regression evidence. | QMS/continual improvement | qualification audit |
| PILOT-ISO-010 | Maintenance, monitoring, reassessment and retirement/supersession behavior are defined before pilot disposition. | lifecycle management | PQ/release review |
| PILOT-ISO-011 | Device/combination-product applicable standards can be mapped without separate core architecture. | ISO 13485/14971/14155; IEC 62304/62366-1 where applicable | design review + scenario OQ |
| PILOT-ISO-012 | Applicable risk-control verification evidence remains linked to the same product-system decision chain. | cross-modality risk/quality | OQ/PQ |

## 5. Product-Quality Requirements
Formal OQ/PQ acceptance criteria shall cover functional suitability, performance efficiency, compatibility/integration, interaction capability/usability, reliability, security, maintainability, flexibility and safety where applicable. The system shall specifically test whether cross-domain context increases reviewer burden or false cascades.

## 6. Privacy and Secondary-Use Boundary
Pilot defaults to synthetic/non-PII fixtures. Live PII/PHI requires controlled scope change. Cross-tenant benchmarking, model training, regulatory-science analysis or policy analysis is not authorized by possession of customer data. ARC-POLICY-EVID-001 controls any future secondary analytic use.

## 7. AI Boundary
AI may assist extraction, classification, mapping and synthesis. Material outputs remain provisional under EIG/DER/human-review controls. AI confidence does not substitute for source authority, applicability, dependency coverage or accountable decision.

## 8. Mandatory Cross-Modality Qualification Fixtures
Before persistent implementation receives pilot authorization, the qualification set shall include at minimum:

1. oncology drug/biologic amendment with delivery-device impact;
2. therapeutic + companion-diagnostic eligibility/threshold change;
3. connected therapeutic-device software/cybersecurity change;
4. at least one combination-product scenario with classification/PMOA or equivalent uncertainty;
5. a manufacturing/formulation change propagating into another constituent;
6. a source/standard/regulatory-version change reopening applicability;
7. a case where a lead pathway applies but another constituent standard/control remains applicable;
8. a false cross-domain cascade to measure specificity;
9. a missed true cross-domain dependency to test coverage controls;
10. six-month reconstruction across changed classification, evidence and constituent versions.

## 9. Policy/Standards Evidence Integrity Requirements
Any future policy/standards analysis must distinguish observed evidence, interpretation, implication, recommendation and authority decision; preserve denominators, missingness, uncertainty and contrary evidence; and avoid treating zero observed events as zero industry events without coverage.

## 10. Pre-Implementation Architecture Gate
Before persistent implementation is authorized, the design must define and adversarially verify:

1. canonical RPS/constituent persistence model;
2. regulatory classification/applicability model;
3. integrated risk relationship model;
4. immutable/superseding lineage;
5. transaction/revision strategy;
6. tenant/authorization boundary;
7. event/idempotency/reconciliation behavior;
8. evidence snapshot/storage/reference strategy;
9. audit event model;
10. reassessment causal-episode model;
11. external-service/supplier failure behavior;
12. backup/recovery/reconstruction approach;
13. migration/configuration/version strategy;
14. requirements-to-test mapping;
15. objective burden/value metrics;
16. cross-modality scenario qualification.

## 11. Strongest NO-BUILD Challenge
If the cross-modality design becomes a manually maintained meta-QMS/ontology that requires specialists to duplicate data from RIM, QMS, CTMS, EDC, PLM, safety, LIMS, MES or design-control systems, the architecture fails. Archemedica must integrate specialist systems and maintain decision/dependency continuity, not recreate every specialist system.

## 12. Gate Status
**REQUIREMENTS SUPERSEDED AND REBASELINED — PERSISTENT IMPLEMENTATION NOT YET AUTHORIZED.**

The next gate is adversarial verification of ARC-XMOD-MODEL-001 against the mandatory cross-modality fixtures and existing ARC-SYS-HARDEN-001 controls.

## 13. Change History
| Version | Date | Change | Status |
|---|---|---|---|
| 1.0 | 2026-09-01 | Initial protocol-centric pilot requirements baseline | SUPERSEDED |
| 1.1 | 2026-09-01 | Rebased requirements on cross-modality Regulated Product System architecture and policy-evidence integrity boundary | CONTROLLED — PRE-IMPLEMENTATION |

**END OF CONTROLLED DOCUMENT**
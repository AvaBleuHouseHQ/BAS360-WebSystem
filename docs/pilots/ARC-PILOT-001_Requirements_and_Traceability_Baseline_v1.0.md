# ARC-PILOT-001 — Requirements and Traceability Baseline

**Document ID:** ARC-PILOT-001-RTM  
**Version:** 1.0  
**Status:** CONTROLLED — PRE-IMPLEMENTATION REQUIREMENTS BASELINE  
**System:** Archemedica / BAS360-WebSystem  
**Author/Document Owner:** Cassandra Harrison  
**Parent:** ARC-PILOT-001 v1.0  
**Standards Baseline:** ARC-ISO-BASELINE-001 v1.0  
**Integrated Controls:** ARC-SYS-HARDEN-001 v1.0

> **Gate:** Code shall not be considered pilot-ready merely because it implements screens or CRUD. Each Tier-3 requirement below requires objective implementation and verification evidence before pilot disposition.

## 1. Core Functional Requirements

| ID | Requirement | Verification |
|---|---|---|
| PILOT-FR-001 | Persist tenant, study and protocol-version identity with immutable version lineage. | OQ + reconstruction PQ |
| PILOT-FR-002 | Preserve baseline/proposed protocol snapshots or bounded historical locators and integrity metadata. | OQ |
| PILOT-FR-003 | Persist atomic `PCHG-*` records with before/after, location, classification, materiality and confirmation state. | OQ |
| PILOT-FR-004 | Preserve original system extraction when a human merges, splits, rejects or reclassifies a change. | OQ |
| PILOT-FR-005 | Require applicable impact domains to be assessed or explicitly `NOT_ASSESSED`; absence shall not mean no impact. | OQ |
| PILOT-FR-006 | Persist dependency candidates, explainable paths and dependency-coverage state. | OQ |
| PILOT-FR-007 | Block clean `NO_IMPACT` when dependency coverage is PARTIAL, UNKNOWN or STALE. | OQ negative |
| PILOT-FR-008 | Bind material evidence claims to EIG state and decision-time evidence identity/version. | OQ |
| PILOT-FR-009 | Persist jurisdiction-specific regulatory applicability, source/version and uncertainty/human-judgment state. | OQ |
| PILOT-FR-010 | Create an accountable DER containing evidence, assumptions, alternatives, unresolved issues, rationale, decision, owner and reassessment triggers. | OQ/PQ |
| PILOT-FR-011 | Maintain implementation-readiness obligations independently from decision approval. | OQ |
| PILOT-FR-012 | Support site/jurisdiction-specific effective state rather than one assumed global effective date. | OQ/PQ |
| PILOT-FR-013 | Require objective post-implementation evidence before relevant obligations close. | OQ |
| PILOT-FR-014 | Create/reuse controlled reassessment causal episodes when decision basis changes. | OQ |
| PILOT-FR-015 | Supersede prior decisions without erasing historical state. | OQ/PQ |
| PILOT-FR-016 | Reconstruct the original decision-time basis and subsequent material changes from persisted records. | PQ |

## 2. Integrated Control Requirements

| ID | Requirement | Verification |
|---|---|---|
| PILOT-CTL-001 | Consequential writes use expected revision/state; stale writes are rejected. | OQ concurrency |
| PILOT-CTL-002 | Scoped Safety/Quality holds prevent unauthorized conflicting transitions. | OQ concurrency |
| PILOT-CTL-003 | Duplicate/replayed commands/events produce one business effect. | OQ replay |
| PILOT-CTL-004 | Partial failures remain `RECONCILIATION_REQUIRED` or equivalent until durable effects reconcile. | OQ failure injection |
| PILOT-CTL-005 | Derived remediation does not self-create a new reassessment episode absent materially new basis. | OQ causal-loop |
| PILOT-CTL-006 | Tenant authorization applies to records, dependencies, derived views, search/index/cache surfaces, audit and export within implemented scope. | OQ security |
| PILOT-CTL-007 | Shared public evidence cannot expose or connect tenant-specific graph/decision existence. | OQ security |
| PILOT-CTL-008 | Prior EIG status cannot be displayed as current against changed source content/version. | OQ stale-state |
| PILOT-CTL-009 | High-risk/conflicted decisions require evidenced human-review basis and unresolved-issue disposition. | OQ negative |
| PILOT-CTL-010 | Emergency/immediate-hazard path preserves retrospective obligations and cannot falsely close them. | OQ/PQ |

## 3. ISO-Aligned Life-Cycle and Quality Requirements

| ID | Requirement | ISO-aligned basis | Verification |
|---|---|---|---|
| PILOT-ISO-001 | Requirements, implementation and tests have bidirectional traceability. | ISO/IEC/IEEE 12207 life-cycle control | IQ/OQ traceability audit |
| PILOT-ISO-002 | Code, schemas, migrations, fixtures, tests and execution evidence have controlled version/configuration identity. | 12207 configuration/change management | IQ |
| PILOT-ISO-003 | Changes preserve reason, impact, implementation, verification, rollback and supersession lineage. | 12207 + quality management | IQ/OQ |
| PILOT-ISO-004 | Quality evaluation covers applicable product quality characteristics, not functional correctness alone. | ISO/IEC 25010:2023 | OQ/PQ |
| PILOT-ISO-005 | Security risks and controls are identified before pilot release and negative-tested in implemented surfaces. | ISO/IEC 27001:2022 | OQ security |
| PILOT-ISO-006 | PII processing, if enabled, has purpose, role, minimization, access, retention/export/deletion and processor-boundary requirements. | ISO/IEC 27701:2025 | design review + OQ |
| PILOT-ISO-007 | Material AI/model use records intended context, version, provenance, limitations, risk, human oversight and reassessment triggers. | ISO/IEC 42001:2023 | OQ/PQ |
| PILOT-ISO-008 | External suppliers/services have dependency identity, risk/fit assessment and defined failure behavior proportionate to use. | ISO-aligned supplier control | design review + OQ |
| PILOT-ISO-009 | Nonconformities/deviations link to corrective action, retest and regression evidence. | quality management / continual improvement | qualification audit |
| PILOT-ISO-010 | Maintenance, monitoring, reassessment and retirement/supersession behavior are defined before pilot disposition. | 12207 life-cycle + management systems | PQ/release review |

## 4. Product-Quality Requirements

The following are required where applicable to the implemented slice and must receive measurable acceptance criteria before formal OQ/PQ execution:

- **Functional suitability:** required controlled states and transitions behave correctly.
- **Performance efficiency:** normal pilot operations do not require unreasonable latency or resource use for the defined workload.
- **Compatibility:** persistence/API boundaries do not require duplicate sources of truth and can support planned integration adapters.
- **Interaction capability/usability:** unresolved, stale, held and superseded states are distinguishable and consequential actions are not defaulted into approval.
- **Reliability:** retry/replay/partial failure/recovery behavior preserves one authoritative state.
- **Security:** tenant and authority boundaries resist unauthorized direct and derived access.
- **Maintainability:** rules/state transitions/tests are modular enough to change through controlled commits without rewriting unrelated engines.
- **Flexibility:** customer-specific authority mappings and impact domains can be configured without forking core decision semantics.
- **Safety where applicable:** software behavior shall not convert unresolved safety-relevant state into clean readiness/approval.

## 5. Privacy Boundary
ARC-PILOT-001 shall default to synthetic/non-PII fixtures. Introduction of live PII/PHI is a controlled scope change requiring documented privacy/security/data-rights assessment and applicable contractual/legal controls. No cross-tenant secondary use or model training is authorized by this pilot baseline.

## 6. AI Boundary
AI may assist extraction/classification/synthesis, but material outputs remain provisional until governed by applicable EIG/DER/human-review controls. AI-generated confidence is not a substitute for evidence supportability, dependency coverage or accountable human decision.

## 7. Pre-Implementation Architecture Gate
Before persistent implementation is accepted, the design must define:

1. canonical persistence model and immutable/superseding lineage;
2. transaction/revision strategy;
3. tenant and authorization policy boundary;
4. event/idempotency/reconciliation behavior;
5. evidence snapshot/storage/reference strategy;
6. audit event model;
7. reassessment causal-episode model;
8. external-service boundary and failure modes;
9. backup/recovery/reconstruction approach;
10. migration/configuration/version strategy;
11. requirements-to-test mapping;
12. objective pilot metrics capture.

## 8. Strongest Design Challenge
If satisfying these requirements requires users to maintain Archemedica as a second QMS/graph database by hand, the design fails even if every control is technically present. Controls should be derived from ordinary workflow events and canonical facts wherever possible.

## 9. Initial Gate Status
**REQUIREMENTS BASELINED — IMPLEMENTATION NOT YET QUALIFIED.**

## 10. Change History

| Version | Date | Change | Status |
|---|---|---|---|
| 1.0 | 2026-09-01 | Established ARC-PILOT-001 functional, integrated-control and ISO-aligned requirements baseline | CONTROLLED — PRE-IMPLEMENTATION |

**END OF CONTROLLED DOCUMENT**
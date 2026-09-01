# ARC-PERSIST-001 — Cross-Modality Persistent Data and Transaction Architecture

**Document ID:** ARC-PERSIST-001  
**Version:** 1.0  
**Status:** CONTROLLED — PERSISTENCE DESIGN BASELINE  
**System:** Archemedica / BAS360-WebSystem  
**Author/Document Owner:** Cassandra Harrison  
**Effective Date:** 2026-09-01  
**Authorized By:** ARC-XMOD-VERIFY-001-RETEST v1.1  
**Domain Model:** ARC-XMOD-MODEL-001 v1.1  
**Integrated Controls:** ARC-SYS-HARDEN-001 v1.0

> **Design boundary:** This document defines logical persistence, state, transaction, authorization and event semantics. It does not select a database vendor or claim production qualification.

## 1. Purpose
Translate the modality-agnostic regulated-product model into a persistence architecture capable of supporting cross-domain change propagation, historical reconstruction, regulatory applicability, evidence integrity and accountable decisions without creating separate pharma/device/diagnostic data silos.

## 2. Core Persistence Principle
One canonical control plane, many typed domain objects.

The storage architecture shall not create modality-specific copies of shared concepts such as evidence, decisions, risks, suppliers, regulatory requirements, obligations, changes, audit events or users.

Specialized attributes may be represented through typed extensions, but identity and lineage remain canonical.

## 3. Canonical Entity Families
### 3.1 Organizational / Program Context
- Tenant
- User / Principal / Role Binding
- Development Program

### 3.2 Regulated Product Structure
- Regulated Product System (`RPS-*`)
- Product Configuration/Presentation (`CFG-*`)
- Constituent Part (`CPT-*`)
- Study/Investigation (`STU-*`)
- Protocol/Plan (`PRO-*`)

### 3.3 Lifecycle and Regulatory Context
- Lifecycle Control Object (`LCO-*`)
- Regulatory/Standards Source (`SRC-*`)
- Controlled Requirement (`REQ-*`)
- Regulatory/Standards Applicability (`RSA-*`)
- Obligation (`OBL-*`)

### 3.4 Evidence / Decision / Risk
- Evidence Snapshot (`EVS-*`)
- Evidence Integrity Assessment (`EIG-*`)
- Risk (`RSK-*`)
- Decision Evidence Record (`DER-*`)
- Model/Algorithm Use (`MUSE-*`)
- Safety/Quality Signal (`SIG-*`)

### 3.5 Change / Dependency / Event
- Controlled Change (`CHG-*`; `PCHG-*` subtype)
- Dependency Edge (`DEP-*`)
- Dependency Coverage Assessment (`DCA-*`)
- Reassessment Episode (`RAE-*`)
- Supplier/External Dependency (`SUP-*`)
- State Transition Event (`EVT-*`)
- Audit Event (`AUD-*`)

## 4. Identity and Versioning
Every consequential controlled object shall have:
- stable business ID;
- immutable internal record ID;
- tenant ID;
- revision number;
- lifecycle state;
- valid/effective interval where relevant;
- created/updated timestamps;
- created/updated principal;
- predecessor/successor or supersession links where applicable;
- content/configuration hash where appropriate;
- reason for consequential change.

Historical versions are not overwritten. Mutable working records may advance revision under compare-and-set semantics, while legally/scientifically meaningful versions remain reconstructable.

## 5. State and Concurrency Model
Consequential transitions shall use optimistic concurrency with expected revision/state. Last-write-wins is prohibited for Tier-3 decisions, holds, applicability determinations, evidence integrity conclusions, material risks, obligations and implementation-readiness states.

A transition request shall include at minimum:
- object ID;
- expected revision;
- expected prior state where relevant;
- requested next state;
- actor/principal;
- reason/context;
- idempotency key;
- causal episode ID when triggered by another controlled event.

Rejected stale writes remain auditable.

## 6. No False Closure Persistence Rule
Unknown, partial, stale, conflicted, unreconciled or held conditions are explicit data states, not nulls.

At minimum, persistence models shall distinguish:
- `UNKNOWN`
- `PARTIAL`
- `STALE`
- `CONFLICTED`
- `NOT_ASSESSED`
- `HUMAN_JUDGMENT_REQUIRED`
- `RECONCILIATION_REQUIRED`
- `HOLD`

Database defaults may never transform these into positive closure states.

## 7. Relationship / Dependency Model
Dependencies shall be first-class versioned records rather than opaque embedded arrays.

Each dependency edge shall preserve:
- source object/version;
- target object/version or stable target identity;
- edge type;
- direction;
- materiality/relevance class;
- confidence/support basis;
- asserted-by system/human;
- evidence/reference where applicable;
- active/effective interval;
- status (`ASSERTED`, `CONFIRMED`, `REJECTED`, `SUPERSEDED`, `UNKNOWN` etc.);
- causal episode where generated;
- tenant/security scope.

## 8. Anti-False-Cascade Control
A dependency edge does not itself require reassessment.

Propagation shall evaluate at minimum:
1. source change materiality;
2. edge type and direction;
3. target decision/control relevance;
4. effective-time overlap;
5. applicability context;
6. dependency support/confidence;
7. coverage status;
8. existing unresolved/hold state;
9. whether the same causal episode already contains the expected consequence.

Initial impact may be stored as `POTENTIALLY_AFFECTED`. Promotion to `REASSESSMENT_REQUIRED` requires a governed rule or accountable human decision.

False-cascade rate is a required pilot metric.

## 9. Regulatory Applicability Persistence
`SRC-*`, `REQ-*` and `RSA-*` shall remain separate tables/entities or equivalent normalized persistent concepts.

`RSA-*` shall be contextual and may attach to RPS, CFG, CPT, STU, PRO, LCO, DER, OBL or other governed object.

A source update shall not indiscriminately invalidate every RSA from that source. Change propagation occurs at affected `REQ-*` level where known; otherwise impact remains partial/unknown until assessed.

## 10. Product Configuration / Constituent Topology
`CFG-*` shall model versioned topology using relationship records between configuration and constituent versions.

This supports:
- integral configurations;
- co-packaged configurations;
- cross-labeled configurations;
- kits/accessories;
- regional presentations;
- device reuse/disposability differences;
- strength/dose/form-factor differences;
- replacement constituents.

Topology history must be reconstructable at any decision-effective time.

## 11. Lifecycle Control Objects
`LCO-*` uses a common control-plane identity plus typed attributes or typed extension records.

Do not create separate architectural silos for manufacturing, design controls, usability, software, cybersecurity, CMC, test methods or labeling. These are LCO domains connected to the relevant product/configuration/constituent and specialist systems.

An LCO record may store external-system identity/version and only the metadata necessary for decision continuity.

## 12. Evidence Snapshot Architecture
Evidence relied upon by consequential decisions shall have decision-time snapshot identity. Persistence must support one of:
- immutable retained content/object;
- immutable cryptographic capture plus stored content;
- legally/contractually permissible external historical locator with integrity metadata;
- bounded snapshot record explicitly stating reconstruction limitation.

Live URL alone is insufficient for material historical reconstruction.

## 13. Event / Idempotency Architecture
Business commands and derived events require durable idempotency keys.

A single logical action must not create duplicate DERs, obligations, reassessment episodes, dependency edges or implementation effects when retried/replayed.

Recommended logical pattern:
1. accept command;
2. validate tenant/authority/expected revision;
3. commit canonical state plus outbox/event intent atomically where the chosen stack permits;
4. process projections/derived obligations idempotently;
5. mark reconciliation state if projection fails;
6. retry safely;
7. preserve one business effect.

The specific queue/outbox technology remains implementation-stack dependent.

## 14. Causal Episode Architecture
Every triggered reassessment/change propagation chain shall have a root causal episode.

Fields include:
- episode ID;
- root trigger object/event;
- parent event;
- opened time;
- status;
- affected objects;
- expected remediation markers;
- closure basis;
- successor episode if materially new basis emerges.

Expected remediation inside one episode does not create a new episode by default.

## 15. Tenant and Authorization Boundary
Tenant ID is mandatory on tenant-owned records and relationship edges.

Authorization applies at every implemented read/write/derived boundary, including:
- canonical tables;
- dependency traversal;
- search/index;
- cache;
- audit/event views;
- exports;
- background processing;
- materialized projections.

Shared public sources may be globally reusable but cannot expose existence of tenant-specific relationships or decisions.

## 16. Audit Architecture
Audit events are append-only and contain at minimum:
- tenant;
- actor/principal or system identity;
- timestamp;
- action;
- object ID/type/revision;
- before/after state or bounded diff/hash where appropriate;
- reason;
- causal episode;
- correlation/idempotency key;
- authorization context;
- outcome.

Audit is not a substitute for versioned business records; both are required.

## 17. Recovery / Reconstruction
The persistence design shall support point-in-time reconstruction of the controlled decision chain even when live external sources have changed.

Backup/recovery testing must prove:
- canonical object restoration;
- relationship restoration;
- evidence snapshot/locator restoration;
- audit sequence preservation;
- idempotency/reconciliation state preservation;
- no tenant cross-contamination.

## 18. Sparse-by-Default Rule
Do not instantiate every possible domain object.

Persist an object when material to:
- a decision;
- a change/impact path;
- a regulatory/standards applicability determination;
- risk/control;
- evidence provenance;
- obligation/readiness;
- audit reconstruction;
- authorized regulatory-science analysis.

This rule is a performance and product-viability control, not merely storage optimization.

## 19. Integration Boundary
Specialist systems may remain systems of record. Archemedica should integrate through stable adapters that preserve:
- source system;
- source object ID;
- source version/revision;
- retrieval/sync timestamp;
- tenant/context;
- mapping confidence/status;
- last known integrity status.

No integration may silently overwrite a controlled Archemedica decision history because the external record changed.

## 20. Qualification Requirements Before Schema Implementation Is Accepted
The physical schema/API implementation must demonstrate:
1. no duplicate modality-specific decision/evidence silos;
2. reconstruction across RPS/CFG/CPT/STU/PRO/LCO/REQ/RSA/DER/EIG/DEP;
3. stale-write rejection;
4. duplicate-command one-effect behavior;
5. tenant isolation including graph traversal;
6. requirement-level regulatory change propagation;
7. configuration topology supersession;
8. supplier/material/process cross-domain propagation;
9. anti-false-cascade behavior;
10. sparse-by-default manual-burden behavior.

## 21. Design Disposition
**AUTHORIZE PHYSICAL SCHEMA / MIGRATION DESIGN AND IMPLEMENTATION-SPECIFICATION WORK.**

This architecture has passed the cross-modality design retest but remains subject to implementation-level adversarial testing and qualification.

## 22. Change History
| Version | Date | Change | Status |
|---|---|---|---|
| 1.0 | 2026-09-01 | Established modality-agnostic persistent data, state, transaction and event architecture after ARC-XMOD corrective retest | CONTROLLED — DESIGN BASELINE |

**END OF CONTROLLED DOCUMENT**
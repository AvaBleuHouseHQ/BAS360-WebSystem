# ARC-PERSIST-TRACE-001 — Persistence Requirements Coverage Review

**Document ID:** ARC-PERSIST-TRACE-001  
**Version:** 1.0  
**Status:** CONTROLLED — PRE-IQ TRACEABILITY REVIEW  
**System:** Archemedica / BAS360-WebSystem  
**Author/Document Owner:** Cassandra Harrison  
**Date:** 2026-09-01  
**Reviewed Against:** ARC-PILOT-001 RTM v1.1; ARC-XMOD-MODEL-001 v1.1; ARC-SYS-HARDEN-001; ARC-AUTH-001

## 1. Purpose
Determine whether migrations 0001-0004 physically cover the minimum controlled objects required for the cross-modality protocol-amendment pilot and integrated control plane before IQ/OQ begins.

## 2. Result
**NO-GO FOR IQ — PERSISTENCE MODEL INCOMPLETE.**

The current physical schema correctly establishes the cross-modality product spine, regulatory source/requirement/applicability chain, LCO, DER, dependency coverage, reassessment, idempotency/outbox/audit and initial tenant controls. However, the physical schema does not yet represent all minimum pilot and cross-modality objects required by the controlled requirements.

## 3. Covered Objects / Controls
Present in migrations 0001-0004:

- Tenant;
- Development Program;
- Regulated Product System (RPS);
- Product Configuration (CFG);
- Constituent Part (CPT);
- Configuration-Constituent relationship;
- Lifecycle Control Object (LCO);
- Regulatory Source (SRC);
- Controlled Requirement (REQ);
- Regulatory Applicability Assessment (RSA);
- Evidence Snapshot (EVS);
- Decision Evidence Record (DER);
- Dependency Edge and Coverage (DEP/DCA);
- Reassessment Episode (RAE);
- Idempotency Record;
- Transactional Outbox;
- Audit Event;
- fail-closed tenant session/RLS contract;
- concrete and polymorphic tenant-integrity controls.

## 4. Missing Material Objects
The following are required for the intended pilot or canonical cross-modality model but absent as first-class persistence objects:

1. **Study/Investigation (`STU-*`)** — required between RPS/program and protocol/investigation plan.
2. **Protocol/Investigation Plan (`PRO-*`)** — required for ARC-PILOT-001 protocol-version lineage.
3. **Controlled Change (`CHG-*`) / Protocol Change (`PCHG-*`)** — required for atomic before/after change records, materiality, confirmation and propagation.
4. **Obligation (`OBL-*`)** — required to separate decision approval from implementation/readiness and to represent source/requirement/risk/decision-derived actions.
5. **Integrated Risk (`RSK-*`)** — required to connect clinical, product, device, software, cybersecurity, manufacturing, quality and regulatory risks.
6. **Evidence Integrity Assessment (`EIG-*`)** — required to bind evidence supportability/currentness to decisions without equating supportability with truth.
7. **Model/Algorithm Use (`MUSE-*`)** — required for controlled AI/model context, version, limitations, influence and human oversight.
8. **Safety/Quality Signal (`SIG-*`)** — required for cross-domain signal-triggered reassessment.
9. **Supplier/External Dependency (`SUP-*`)** — required for supplier/service/data/model dependency identity, risk and failure behavior.
10. **Evidence-to-Decision/Requirement/Risk relationships** — EVS and DER exist but no first-class association table currently proves which evidence supported which controlled object at decision time.
11. **Implementation/site/jurisdiction effective state** — required by PILOT-FR-011 through PILOT-FR-013.
12. **State-transition event semantics tied to expected revision** — audit/outbox exist, but authoritative transition enforcement is not yet implemented.

## 5. Why This Is Architecture-Blocking
Without these objects, the database could become product/regulatory metadata with a DER and graph attached, but it could not execute the full controlled pilot workflow or reconstruct why a protocol/product change caused specific obligations, risks, evidence judgments, implementation states and reassessments.

That would reproduce silo behavior at a different level: product structure in one set of tables and actual clinical/quality execution pushed into free-text or external systems without a canonical controlled identity.

## 6. Corrective Action
Before IQ:

- add the missing canonical objects with tenant/version/supersession semantics;
- add tenant-integrity enforcement for their concrete and polymorphic relationships;
- extend `controlled_object_tenant()` for all new controlled object types;
- add evidence-link semantics;
- add expected-revision/state-transition enforcement;
- add site/jurisdiction implementation-effective state;
- update negative security and cross-domain propagation tests;
- rerun this traceability review.

## 7. Anti-Bureaucracy Constraint
The fix must remain sparse-by-default. These objects are canonical identities and relationship anchors, not a requirement to recreate entire CTMS, EDC, QMS, PLM, RIM, LIMS, MES or safety systems inside Archemedica.

## 8. Disposition
**NO-GO FOR IQ — CORRECT PHYSICAL SCHEMA AND RETEST TRACEABILITY.**

## 9. Change History
| Version | Date | Change | Status |
|---|---|---|---|
| 1.0 | 2026-09-01 | First physical-schema traceability review; identified 12 material coverage gaps before IQ | CONTROLLED — NO-GO |

**END OF CONTROLLED REVIEW**
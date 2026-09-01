# ARC-CC-003 — Persistent Application Foundation Change Control

**Document ID:** ARC-CC-003  
**Version:** 1.0  
**Status:** CONTROLLED — OPEN / AUTHORIZED FOR DESIGN AND IMPLEMENTATION  
**System:** Archemedica / BAS360-WebSystem  
**Author/Document Owner:** Cassandra Harrison  
**Effective Date:** 2026-09-01  
**Parent Pilot:** ARC-PILOT-001  
**Design Authorization:** ARC-XMOD-VERIFY-001-RETEST v1.1  
**Persistence Architecture:** ARC-PERSIST-001 v1.0

## 1. Change Description
Establish the first real persistent application foundation for Archemedica so the modality-agnostic regulated-product decision/evidence architecture can move from controlled design artifacts into executable software.

## 2. Current State
The repository currently contains controlled documentation, schemas, static web surfaces, tools and fixtures, but no persistent application/backend runtime, database migration framework or transaction-processing service suitable for ARC-PILOT-001.

## 3. Proposed Change
Introduce a minimal application foundation consisting of:
1. canonical transactional database schema;
2. tenant/security context model;
3. version/revision and supersession semantics;
4. first-class relationship/dependency records;
5. regulatory source/requirement/applicability chain;
6. product-system/configuration/constituent/lifecycle-control model;
7. evidence, risk, DER, obligation and reassessment records;
8. append-only audit/event records;
9. durable idempotency/outbox/reconciliation primitives;
10. migration and deterministic verification harness.

## 4. Design Constraints
- modality-agnostic core; no pharma/device duplicate schemas;
- ISO-aligned lifecycle/configuration/security/privacy/AI governance baseline;
- No False Closure;
- immutable/superseding history;
- sparse-by-default integration;
- requirement-level applicability;
- explicit uncertainty;
- tenant isolation at every boundary;
- anti-false-cascade propagation;
- evidence-once/project-many;
- policy/regulatory-science data neutrality and provenance.

## 5. Risk Classification
**Tier 3 — High consequence architecture foundation.**

Failure may produce false regulatory closure, lost historical reconstruction, cross-tenant exposure, duplicate business effects, inaccurate decision propagation, or structural modality silos that become expensive to remove later.

## 6. Strongest NO-BUILD
Continue using controlled documents/fixtures until a customer-specific implementation stack exists. This reduces premature technical commitment.

### Rebuttal
The architecture has now passed design-level corrective verification. Further progress requires testing the semantics under real persistence, concurrency, authorization, replay, recovery and migration behavior. A thin controlled application foundation is therefore justified, provided vendor/framework choices remain replaceable and the system does not generalize beyond the verified pilot scope.

## 7. Impact Assessment
Affected areas:
- architecture;
- schemas;
- verification harness;
- security/tenant model;
- audit/event model;
- regulatory applicability;
- data retention/recovery;
- controlled configuration;
- future UI/API implementation.

Not authorized by this change:
- production release;
- live PHI/PII;
- autonomous clinical/regulatory decisions;
- cross-tenant learning;
- regulatory reliance claims;
- ISO certification/conformity claims;
- GxP/Part 11 validation claims.

## 8. Verification Required
At minimum verify:
1. schema integrity and migration repeatability;
2. revision-controlled stale-write rejection;
3. tenant isolation design and negative tests;
4. idempotency one-effect behavior;
5. append-only audit/event reconstruction;
6. RPS/CFG/CPT/LCO/REQ/RSA cross-modality relationships;
7. requirement-level regulatory change propagation;
8. anti-false-cascade behavior;
9. evidence snapshot lineage;
10. supersession without erasure;
11. backup/recovery design;
12. strong checklist/manual-burden comparison remains in pilot scope.

## 9. Rollback Strategy
Because the repository currently lacks a production backend, rollback consists of reverting the application-foundation commits and preserving this change-control/deviation history. No production/customer data migration is involved at this stage.

## 10. Initial Disposition
**APPROVED FOR CONTROLLED FOUNDATION BUILD — NOT APPROVED FOR PRODUCTION/PILOT RELEASE.**

## 11. Change History
| Version | Date | Change | Status |
|---|---|---|---|
| 1.0 | 2026-09-01 | Opened first persistent Archemedica application-foundation change | OPEN / CONTROLLED BUILD |

**END OF CONTROLLED DOCUMENT**
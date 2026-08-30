# ARC-AST-004 — Tenant Authorization & Graph Traversal Breach Fault Injection

**Document ID:** ARC-AST-004  
**Version:** 1.0  
**Status:** CONTROLLED — SYSTEM-LEVEL ADVERSARIAL FINDING  
**System:** Archemedica  
**Effective Date:** 2026-08-30  
**Author/Document Owner:** Cassandra Harrison  
**Governed By:** ARC-STD-001 v1.0  
**Primary Affected Artifacts:** ARC-DDG-SCHEMA-001; ARC-EVID-REG-001; ARC-DER-SCHEMA-001; ARC-DMOC-001; ARC-CMR-001  
**Disposition:** FAIL — REPAIRABLE; OBJECT-LEVEL TENANT TAGS ARE INSUFFICIENT

## 1. Fault Injection

A multi-tenant deployment was simulated with two sponsors sharing a common public regulatory source and similar model/provider identifiers.

Injected attacks:
1. user authorized for Tenant A traverses a DDG path whose intermediate node is shared/global but whose downstream DER belongs to Tenant B;
2. search/autocomplete leaks the existence/title of Tenant B controlled artifacts;
3. cached graph query generated under elevated service context is returned to a lower-privileged user;
4. model/evidence references use globally stable IDs and permit identifier probing;
5. outcome aggregation accidentally mixes tenant-scoped metadata before final filtering;
6. exported decision-memory package contains dangling references that reveal another tenant's object IDs.

## 2. Failure Observed

The architecture states that nodes/edges are tenant scoped and cross-tenant traversal is prohibited, but policy statements alone do not define enforcement at every query, cache, index, export and service boundary.

A graph system is especially dangerous because relationship existence can reveal confidential development strategy even when node contents remain hidden.

## 3. Required Repair — Authorization-Aware Data Plane

Authorization must be applied before and during traversal, not only after result generation.

Required controls:
- tenant/security context bound to every canonical object, edge, event and derived index entry;
- authorization predicate evaluated at each traversal hop;
- no unauthorized node/edge contributes to path existence, counts, ranking or timing-visible responses;
- cache keys include tenant, user/role or policy context, authorization version and data revision where material;
- search/index/autocomplete enforce the same policy boundary as canonical fetch;
- export resolves and filters all referenced objects under exporter's authorization context;
- service accounts are purpose-limited; elevated backend context cannot be reused for user-facing results;
- globally shared public sources use explicit shared-source objects separated from tenant-specific interpretations and dependencies;
- opaque external-facing IDs or equivalent anti-enumeration controls for sensitive objects;
- denial/audit events captured without leaking protected metadata to unauthorized users.

## 4. Shared Evidence Boundary

A public FDA/EMA/ICH source may be globally shareable as a source artifact. A tenant's interpretation, applicability decision, dependency edge, DER linkage, comment, model use or outcome is tenant confidential by default.

Shared source identity must not create a cross-tenant graph bridge.

## 5. Side-Channel Rule

Unauthorized data must not influence:
- result count;
- path length;
- existence flags;
- autocomplete suggestions;
- error text;
- ranking;
- cache-hit behavior exposed to the requester;
- export manifests.

## 6. Verification Tests

1. Tenant A traverses through global regulatory source; Tenant B links remain invisible and non-inferable.
2. object-ID probing returns indistinguishable unauthorized/not-found behavior where appropriate.
3. elevated cached result cannot be replayed to lower privilege.
4. search/autocomplete cannot reveal protected artifact names.
5. outcome/calibration query cannot mix tenants before authorization filtering.
6. export package contains no unauthorized dangling refs.
7. authorization changes invalidate or segregate affected caches.
8. audit logs remain accessible only under authorized scope.

## 7. Revised System Constraint

Tenant isolation is not a database partition setting alone. It is an end-to-end policy property covering canonical records, graph traversal, caches, indexes, derived analytics, exports, event buses, logs and model calls.

No production deployment is authorized until negative cross-tenant tests pass at all these surfaces.

**END OF CONTROLLED DOCUMENT**
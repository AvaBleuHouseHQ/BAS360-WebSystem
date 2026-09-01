# ADR-0007 — Archemedica Persistent Application Stack

**ADR ID:** ADR-0007  
**Version:** 1.0  
**Status:** CONTROLLED — ACCEPTED FOR FOUNDATION BUILD  
**System:** Archemedica / BAS360-WebSystem  
**Author/Document Owner:** Cassandra Harrison  
**Date:** 2026-09-01  
**Change Control:** ARC-CC-003  
**Architecture Basis:** ARC-PERSIST-001 v1.0

## 1. Decision
Use **PostgreSQL as the canonical transactional persistence engine** for the first Archemedica application foundation, with a thin service/API layer to be selected/implemented separately after the database contract is verified.

The database is the controlled source of transactional truth for ARC-PILOT-001. Search, analytics, graph projections, queues and caches may be added later only as derived or supporting services; none may become an ungoverned competing source of decision truth.

## 2. Why PostgreSQL Fits the Verified Requirements
PostgreSQL supports the combination of properties required by the Archemedica control plane without forcing a graph-only or document-only architecture:

- ACID transactions for single-reality consequential writes;
- explicit constraints and foreign keys for controlled object integrity;
- row-level security capability for tenant-aware data-plane enforcement;
- recursive queries for bounded dependency traversal;
- JSON-capable typed extensions without abandoning relational identity;
- transactional outbox/idempotency patterns;
- append-only event/audit tables;
- effective-time/version modeling;
- mature backup/recovery and migration tooling ecosystem;
- portability across major cloud/self-hosted environments.

## 3. Alternatives Considered
### 3.1 Graph Database as Primary Store — REJECT FOR INITIAL FOUNDATION
**Benefit:** natural dependency traversal.

**Reason rejected:** increases risk of making the graph a second manually maintained reality; transaction/version/tenant/audit semantics would still need disciplined implementation. Archemedica's moat is governed decision continuity, not graph technology. A graph projection may be introduced later if measured traversal needs justify it.

### 3.2 Document Database as Primary Store — REJECT
**Benefit:** flexible heterogeneous modality records.

**Reason rejected:** flexibility is not the main problem. Archemedica requires strong referential integrity, controlled relationships, granular requirements/applicability, concurrency semantics and reconstruction. Typed extensions can supply flexibility without weakening canonical relationships.

### 3.3 Multiple Databases by Modality — REJECT
Would recreate the pharma/device/diagnostic silos the architecture is explicitly designed to eliminate.

### 3.4 Event Store as Sole Source of Truth — DEFER
Event sourcing could preserve history well but adds operational and cognitive complexity before product value is proven. Append-only audit/events plus versioned canonical records provide sufficient first-pilot traceability while remaining easier to qualify and operate.

## 4. Logical Storage Pattern
Use normalized relational tables for canonical controlled objects and relationships. Use JSON/extension fields only for modality-specific or evolving attributes that do not define identity, authorization, lifecycle state, applicability, dependency or audit semantics.

Core shared entities shall not be stored as opaque JSON documents.

## 5. Tenant Boundary
Every tenant-owned row shall include `tenant_id` and shall participate in enforced tenant-policy design. Cross-tenant joins/traversals are prohibited unless an explicitly controlled administrative/system context authorizes them.

Globally reusable public regulatory sources may be modeled separately from tenant-owned interpretation/application records. Public source reuse must never expose tenant relationship existence.

## 6. History Strategy
Use stable business identity plus version/revision/supersession semantics. Consequential history is retained; destructive update of historical scientific/regulatory decision state is prohibited.

The initial foundation will combine:
- current controlled row revision for active workflow;
- immutable version/history rows or immutable versioned records where scientifically/regulatorily meaningful;
- append-only `audit_event` and `state_transition_event` records.

## 7. Transaction / Event Strategy
Use an application command transaction that writes canonical state and an outbox/event-intent row atomically. Derived work consumes the outbox idempotently. Failed projection/derived work remains reconcilable rather than producing clean completion.

No external message broker is required to establish the first deterministic foundation. One may be added later if workload/reliability evidence justifies it.

## 8. Search / Graph / Analytics Boundary
Do not introduce Elasticsearch/OpenSearch, a graph database, vector database, or analytical warehouse into the source-of-truth path during the first foundation build.

If later added, all are projections. Projection freshness/status must be visible and may never override canonical PostgreSQL state.

## 9. AI Boundary
AI/model calls are external controlled dependencies. Model outputs are persisted as provisional evidence/observations with model-use identity, version/context and human/evidence controls. AI does not receive database authority to directly approve or close high-consequence records.

## 10. Security / Privacy Consequence
The physical implementation must support:
- least privilege;
- service identities;
- tenant row-level policy;
- encrypted transport and platform-managed encryption at rest in deployed environments;
- secret separation;
- auditability;
- retention/recovery configuration;
- PII/PHI scope controls if later authorized.

This ADR does not claim that PostgreSQL alone provides compliance.

## 11. Qualification Consequence
The persistence layer must be tested directly for:
- constraint enforcement;
- migration repeatability;
- stale revision rejection;
- tenant leakage attempts;
- dependency traversal scope;
- outbox/idempotency behavior;
- rollback/partial failure;
- historical reconstruction;
- backup/recovery when deployed.

## 12. Reversibility
Domain/service contracts shall avoid PostgreSQL-vendor-specific behavior where it would unnecessarily lock the business semantics. Database-specific features may be used for correctness/security when justified and documented.

## 13. Disposition
**ACCEPT — PostgreSQL canonical transactional foundation; derived specialist stores only when evidence justifies them.**

## 14. Change History
| Version | Date | Decision | Status |
|---|---|---|---|
| 1.0 | 2026-09-01 | Selected PostgreSQL as canonical persistence engine for controlled foundation | ACCEPTED |

**END OF CONTROLLED ADR**
# ARC-AUTH-001 — Tenant Session and Authorization Context Contract

**Document ID:** ARC-AUTH-001  
**Version:** 1.0  
**Status:** CONTROLLED — PRE-IMPLEMENTATION SECURITY CONTRACT  
**System:** Archemedica / BAS360-WebSystem  
**Author/Document Owner:** Cassandra Harrison  
**Effective Date:** 2026-09-01  
**Governed By:** ARC-STD-001, ARC-SYS-HARDEN-001, ARC-ISO-BASELINE-001 v1.1, ARC-CC-003  
**Security Basis:** authorization-aware data plane; no false closure; least privilege; tenant isolation

## 1. Purpose
Define the database session context and authorization boundary required before tenant Row-Level Security (RLS) policies are activated.

## 2. Security Principle
Archemedica shall treat tenant identity and actor identity as independently verified security facts. A tenant identifier supplied by an end user or client request is not trusted merely because it is syntactically valid.

Application code shall authenticate a principal, authorize that principal for a tenant and role/scope, and then establish a transaction-local database security context. Database RLS shall enforce tenant isolation independently of application filtering.

## 3. Required Session Context
Every tenant-scoped transaction shall set the following transaction-local PostgreSQL settings before tenant data access:

- `archemedica.tenant_id` — authorized tenant UUID;
- `archemedica.actor_principal` — authenticated immutable principal identifier;
- `archemedica.actor_role` — controlled application role/classification;
- `archemedica.correlation_id` — request/command correlation identifier;
- `archemedica.authn_strength` — authentication assurance descriptor when available;
- `archemedica.purpose` — controlled purpose/use context where relevant to authorization or audit.

Settings shall use `SET LOCAL` or `set_config(..., true)` within an explicit transaction so they do not leak through pooled database connections.

## 4. Fail-Closed Context Functions
Database helper functions shall:

1. return the active tenant UUID only when the setting exists and parses as UUID;
2. return the active principal only when non-empty;
3. raise an authorization-context exception when required context is absent or malformed;
4. never treat absent context as a system-wide/global tenant;
5. never infer tenant from a queried record;
6. never accept tenant identity from arbitrary row data as proof of authorization.

## 5. Role Boundary
The normal application runtime role shall:

- not own tenant tables;
- not have `BYPASSRLS`;
- not be a PostgreSQL superuser;
- not disable row security;
- not directly assume migration/owner roles;
- access tenant-scoped tables only through privileges compatible with RLS.

Migration/administrative roles are separate operational identities and are not normal application identities.

## 6. RLS Scope
Tenant RLS is mandatory for tenant-specific rows and derived tenant surfaces, including tables that contain dependency, decision, reassessment, command, event and audit information.

Shared/public regulatory sources and controlled requirements may be globally readable only if they contain no tenant-derived existence, interpretation, usage, linkage, or decision metadata.

`evidence_snapshot` is mixed-scope. A row with `tenant_id IS NULL` may represent shared/public evidence. A tenant-scoped row is visible only to its tenant. The existence of a tenant-specific snapshot must not be disclosed cross-tenant.

The `tenant` table itself is not a tenant directory. Normal application principals may access only the active tenant row through controlled RLS or an equivalent security-definer lookup with exact authorization semantics.

## 7. Write Rules
For tenant-scoped tables, RLS `WITH CHECK` shall prevent insertion or update of rows whose `tenant_id` differs from `archemedica.tenant_id`.

Changing the `tenant_id` of an existing controlled row is prohibited. Cross-tenant migration requires an explicit administrative change-control procedure and shall not be a normal application operation.

## 8. Referential Tenant Integrity
RLS alone cannot prove that two foreign-key-linked rows belong to the same tenant. The persistence model shall therefore add tenant-consistency constraints or controlled triggers for material relationships where a cross-tenant foreign-key reference could otherwise exist.

This includes at minimum:
- program → RPS;
- RPS → constituent/configuration;
- configuration → constituent;
- LCO → RPS/CFG/CPT;
- DER/RSA/dependency contexts where polymorphic references are used.

A reference that exists physically but crosses tenant boundaries is a security defect, even if RLS happens to hide the target during a particular query.

## 9. Audit Contract
Consequential writes shall record actor principal, active tenant, action, object identity/revision, correlation identifier, authorization context summary, outcome and causal episode where relevant.

Audit generation shall not rely on mutable user-entered display names as the sole actor identifier.

## 10. Negative Security Requirements
Qualification shall prove at minimum:

1. absent tenant context fails closed;
2. malformed tenant context fails closed;
3. Tenant A cannot SELECT Tenant B rows;
4. Tenant A cannot INSERT a Tenant B row;
5. Tenant A cannot UPDATE or DELETE Tenant B rows;
6. Tenant A cannot create a same-tenant-visible row that references a Tenant B parent;
7. changing session tenant inside an unauthorized request path is impossible at the application boundary and detectable in audit;
8. pooled connection reuse does not carry prior tenant context;
9. tenant-specific audit/events/dependencies cannot leak through joins or derived views;
10. shared evidence does not reveal which tenants use it;
11. tenant-specific evidence snapshots remain isolated;
12. privileged migration/maintenance identities are operationally separate from application roles.

## 11. No False Closure Security Rule
An authorization failure, missing authorization context, inaccessible dependency, or unresolved tenant-scope mismatch shall never be translated into `NO_IMPACT`, `NOT_FOUND`, `COMPLETE`, or other clean business state where the distinction matters. Use an explicit authorization/error/unknown state.

## 12. Implementation Gate
RLS migration may proceed only against this contract. API/authentication-provider implementation remains independently controlled; this document does not select an identity provider.

## 13. Disposition
**APPROVED FOR DATABASE SECURITY IMPLEMENTATION AND NEGATIVE TEST DESIGN. NOT PRODUCTION QUALIFIED.**

## 14. Change History
| Version | Date | Change | Status |
|---|---|---|---|
| 1.0 | 2026-09-01 | Established transaction-local tenant/principal context, fail-closed RLS boundary, referential tenant-integrity requirement and negative test set | CONTROLLED |

**END OF CONTROLLED DOCUMENT**
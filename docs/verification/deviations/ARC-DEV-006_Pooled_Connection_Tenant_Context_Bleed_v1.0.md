# ARC-DEV-006 — Pooled Connection Tenant Context Bleed

**Version:** 1.0  
**Status:** CONTROLLED — OPEN / CORRECTIVE ACTION REQUIRED  
**System:** Archemedica / BAS360-WebSystem  
**Author / Document Owner:** Cassandra Harrison  
**Date:** 2026-09-01  
**Source:** ARC-PERSIST-OQ-002 / OQ2-14  
**Observed Run:** GitHub Actions `33524599328`, job `99912105063`

## 1. Deviation

The tenant authorization setting persisted at PostgreSQL session scope when a logical request boundary was simulated on a reused database connection. A subsequent request on the same pooled session could inherit the prior request's tenant context if application code failed to reset it.

## 2. Risk

This defect creates a credible cross-tenant confidentiality/integrity risk in connection-pooled runtime architectures. RLS itself can behave correctly while still evaluating against the wrong inherited tenant context.

Severity is therefore **HIGH** for a multi-tenant SaaS control plane.

## 3. Root Cause

The initial persistence/security implementation allowed session-scoped context establishment via `set_config(..., false)`. That is adequate for isolated qualification statements but not an acceptable primary request contract for pooled application connections.

## 4. Required Correction

The supported runtime contract shall:

1. begin an explicit database transaction;
2. set tenant, actor, correlation and authorization context transaction-locally (`SET LOCAL` / `set_config(..., true)` or an equivalent guarded helper);
3. perform all tenant-scoped work inside that transaction;
4. automatically discard the request context at COMMIT/ROLLBACK;
5. reject tenant-scoped access without active context;
6. prohibit arbitrary runtime callers from invoking lower-level context setters outside the controlled transaction-entry function;
7. negatively test connection reuse after COMMIT and ROLLBACK.

## 5. Retest

Corrective OQ must prove:
- Tenant A request completes;
- same physical session is reused;
- no Tenant A context survives after COMMIT;
- same after ROLLBACK;
- access before establishing Tenant B context fails closed;
- after Tenant B context is established transaction-locally, only Tenant B rows are visible.

## 6. Disposition

**OPEN — OQ gate remains failed until corrected and retested.**

No production or pilot-release authorization is granted by this deviation record.
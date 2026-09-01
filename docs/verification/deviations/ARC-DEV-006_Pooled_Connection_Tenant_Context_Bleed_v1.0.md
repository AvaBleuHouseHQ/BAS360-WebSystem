# ARC-DEV-006 — Pooled Connection Tenant Context Bleed

**Version:** 1.1  
**Status:** CONTROLLED — CLOSED / CORRECTED AND RETESTED  
**System:** Archemedica / BAS360-WebSystem  
**Author / Document Owner:** Cassandra Harrison  
**Date Opened:** 2026-09-01  
**Date Closed:** 2026-09-01  
**Source:** ARC-PERSIST-OQ-002 / OQ2-14  
**Initial Run:** GitHub Actions `33524599328`, job `99912105063`  
**Corrective Migration:** `db/migrations/0008_operational_control_plane.sql`  
**Corrective Migration Commit:** `5b79b8308fbbffdaedeef49a073ac1c0b8d48d87`  
**Final Retest Run:** `33525332032`, job `99914588124`  
**Final Retest Commit:** `ad9f4a5ce704ebf1df354628d0d7c35db533b3ab`

## 1. Original Deviation

The initial tenant authorization setting persisted at PostgreSQL session scope when a logical request boundary was simulated on a reused database connection. A subsequent request on the same pooled session could inherit the prior request's tenant context if the application did not explicitly reset it.

The condition represented a HIGH multi-tenant confidentiality/integrity risk because otherwise-correct RLS policies could evaluate against stale tenant context.

## 2. Root Cause

The initial implementation permitted request context to be established using session-scoped custom PostgreSQL settings. Session scope is not an acceptable primary contract for pooled application connections.

## 3. Correction

Migration 0008 introduced the supported request entry point:

`archemedica_security.establish_request_context(tenant_id, actor_principal, correlation_id)`

The function:

- validates required context;
- verifies that the tenant exists and is active;
- uses transaction-local PostgreSQL settings (`set_config(..., true)`);
- requires tenant-scoped work to occur inside an explicit database transaction;
- allows COMMIT or ROLLBACK to discard request context automatically.

The application/service layer must use this controlled transaction-local path and must not expose arbitrary SQL/GUC manipulation to end users.

## 4. Corrective Retest

OQ2-14 was rerun in the same physical psql session across logical requests:

1. Tenant A transaction established controlled context and saw only Tenant A data.
2. Tenant A transaction committed.
3. Tenant-scoped access before a new context was established failed closed.
4. Tenant B transaction then established its own context.
5. Tenant B saw only Tenant B data.

Result:

**PASS — `transaction-local context cleared across pooled logical requests`.**

The final complete ARC-PERSIST-OQ-002 retest produced **16 PASS / 0 FAIL**.

## 5. Closure

**ARC-DEV-006 is CLOSED — CORRECTED AND RETESTED.**

Closure applies only to the tested controlled PostgreSQL request-context behavior. It does not establish production security certification, customer-environment qualification, GxP validation, Part 11 compliance, or ISO conformity/certification.

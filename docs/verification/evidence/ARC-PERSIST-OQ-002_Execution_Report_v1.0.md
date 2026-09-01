# ARC-PERSIST-OQ-002 — Initial Execution Report

**Version:** 1.0  
**Status:** CONTROLLED — EXECUTED / GATE FAIL  
**System:** Archemedica / BAS360-WebSystem  
**Author / Document Owner:** Cassandra Harrison  
**Execution Date:** 2026-09-01  
**Execution Commit:** `7f4608ee16bb8e319d02e2c0940a5e4c105f429c`  
**GitHub Actions Run:** `33524599328`  
**Job:** `99912105063`  
**Database:** PostgreSQL 16.15  

## 1. Entry Gate

ARC-PERSIST-QUAL-001 had passed after corrective retest. ARC-PERSIST-OQ-002 was therefore authorized for execution.

## 2. Result

**PASS: 6**  
**FAIL: 1**  
**NOT IMPLEMENTED: 9**  
**Overall Gate: FAIL**

| Scenario | Result | Evidence/Disposition |
|---|---|---|
| OQ2-01 concurrent DER transition | PASS | exactly one transition succeeded and one received `ARC_STALE_WRITE_REJECTED` |
| OQ2-02 idempotent command retry | NOT IMPLEMENTED | no atomic command-to-business-effect processor |
| OQ2-03 duplicate downstream event | NOT IMPLEMENTED | no consumer delivery/dedup persistence |
| OQ2-04 transaction failure | PASS | canonical revision unchanged after injected transaction error |
| OQ2-05 outbox worker crash | NOT IMPLEMENTED | no controlled claim/reconcile processor |
| OQ2-06 hold vs approval precedence | NOT IMPLEMENTED | no explicit hold precedence state machine |
| OQ2-07 remediation episode reuse | NOT IMPLEMENTED | no governed episode reuse function |
| OQ2-08 duplicate dependency paths | NOT IMPLEMENTED | no multi-path causal dedup processor |
| OQ2-09 fine-grained fan-out | NOT IMPLEMENTED | anti-false-cascade propagation engine absent |
| OQ2-10 rejected HIGH dependency | PASS | rejected assertion retained rather than erased |
| OQ2-11 source supersession | NOT IMPLEMENTED | requirement-level propagation absent |
| OQ2-12 same idempotency key across tenants | PASS | composite tenant/key isolation worked |
| OQ2-13 worker wrong-tenant access | PASS | Tenant B context could not read Tenant A outbox row |
| OQ2-14 pooled connection reuse | **FAIL** | session-scoped tenant context persisted across logical request boundary |
| OQ2-15 concurrent supersession | NOT IMPLEMENTED | no authoritative successor uniqueness constraint |
| OQ2-16 reconciliation durability | PASS | `RECONCILIATION_REQUIRED` state persisted |

## 3. Critical Finding

### OQ2-14 — Session Context Bleed

The current authorization context uses session-scoped PostgreSQL settings. If a pooled connection is reused and the application fails to reset the tenant setting, the subsequent logical request inherits the prior tenant context.

This is not acceptable as the primary runtime contract. The controlled application path must establish authorization context **transaction-locally** and fail closed outside that transaction. Caller-controlled arbitrary tenant switching remains prohibited.

## 4. Mandatory Corrective Scope

The next controlled migration/implementation set must add or establish:

1. transaction-local request authorization context contract and runtime helper;
2. atomic idempotent-command business-effect binding;
3. consumer delivery deduplication persistence;
4. controlled outbox claim/complete/reconciliation transitions;
5. safety/quality hold precedence for consequential decision transitions;
6. causal episode open-or-reuse semantics;
7. duplicate dependency-path episode deduplication;
8. contextual dependency impact evaluation with `POTENTIALLY_AFFECTED` distinct from `REASSESSMENT_REQUIRED`;
9. requirement-level source supersession propagation;
10. single-authoritative-successor enforcement for controlled version chains.

## 5. Anti-Bureaucracy Finding

OQ2-09 remains a mandatory design-control gate. Archemedica may not obtain apparent safety by reopening every graph-connected object. Any propagation implementation must preserve distinctions among:
- connected but not materially affected;
- materially affected;
- unknown/insufficient coverage;
- stale due to source/version change.

## 6. Disposition

**NO-GO for persistence OQ completion.**

The successful foundation qualification remains valid for its tested scope, but this OQ demonstrates that the operational control plane is not complete enough for pilot release.

No production, GxP validation, Part 11, ISO conformity/certification, regulator acceptance, or external exactly-once-delivery claim is authorized.

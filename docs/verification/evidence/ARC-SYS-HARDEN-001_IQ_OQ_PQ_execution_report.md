# ARC-SYS-HARDEN-001 IQ/OQ/PQ Execution Report

**Harness:** ARC-SYS-HARDEN-001-E2E-HARNESS v1.0.0
**Execution Timestamp:** 2026-08-30T12:00:00Z
**Repository HEAD at execution:** `60a05d16766df5b269fa6e1b96232ffe1e7733cb`
**Status:** CONDITIONAL GO FOR CONTROLLED PILOT HARNESS ONLY

## Attestation Boundary

This package verifies deterministic integrated control-plane behavior against synthetic controlled fixtures. It does not establish GxP validation, 21 CFR Part 11 compliance, regulator acceptance, clinical correctness, scientific validation, security certification, or production qualification.

## IQ Summary

- IQ status: **PASS** (4 passed / 0 failed)

- ARC-IQ-001 — Execution environment recorded: **PASS**
- ARC-IQ-002 — Controlled artifact and fixture integrity: **PASS**
- ARC-IQ-003 — Repository version identity captured: **PASS**
- ARC-IQ-004 — Fixture acceptance criteria present: **PASS**

## OQ/PQ Summary

- OQ status: **PASS** (14 passed / 0 failed)
- PQ status: **PASS** (2 passed / 0 failed)
- Mandatory scenarios: **16 / 16 passed**

## Scenario Results

| Scenario | Phase | Result | Before | After | Deviation / Corrective Action |
|---|---:|---:|---|---|---|
| ARC-OQ-001 | OQ | **PASS** | `NO_IMPACT` | `IMPACT_NOT_ESTABLISHED_HUMAN_REVIEW_REQUIRED` | DEV-ARC-SYS-HARDEN-001-001 / CA-ARC-SYS-HARDEN-001-001 |
| ARC-OQ-002 | OQ | **PASS** | `REASSESSMENT_CASCADE` | `FALSE_POSITIVE_CONTAINED_REVIEW_REQUIRED` | DEV-ARC-SYS-HARDEN-001-002 / CA-ARC-SYS-HARDEN-001-002 |
| ARC-OQ-003 | OQ | **PASS** | `REASSESSMENT_LOOP` | `EPISODE_CLOSED_NO_LOOP` | DEV-ARC-SYS-HARDEN-001-003 / CA-ARC-SYS-HARDEN-001-003 |
| ARC-OQ-004 | OQ | **PASS** | `SELF_REOPENED` | `DERIVED_RDRE_REMEDIATION_TRACKED_WITHIN_EPISODE` | DEV-ARC-SYS-HARDEN-001-004 / CA-ARC-SYS-HARDEN-001-004 |
| ARC-OQ-005 | OQ | **PASS** | `LAST_WRITE_WINS_AUTHORIZED` | `HOLD_CONFLICT` | DEV-ARC-SYS-HARDEN-001-005 / CA-ARC-SYS-HARDEN-001-005 |
| ARC-OQ-006 | OQ | **PASS** | `DUAL_CURRENT_DECISIONS` | `REJECTED_STALE` | DEV-ARC-SYS-HARDEN-001-006 / CA-ARC-SYS-HARDEN-001-006 |
| ARC-OQ-007 | OQ | **PASS** | `TENANT_SIDE_CHANNEL_LEAK` | `AUTHORIZED_EMPTY_RESULT` | DEV-ARC-SYS-HARDEN-001-007 / CA-ARC-SYS-HARDEN-001-007 |
| ARC-OQ-008 | OQ | **PASS** | `PRIVILEGE_DOWNGRADE_CACHE_LEAK` | `CACHE_MISS_REAUTHORIZE` | DEV-ARC-SYS-HARDEN-001-008 / CA-ARC-SYS-HARDEN-001-008 |
| ARC-OQ-009 | OQ | **PASS** | `DUPLICATE_BUSINESS_EFFECT` | `DUPLICATE_SUPPRESSED_ONE_BUSINESS_EFFECT` | DEV-ARC-SYS-HARDEN-001-009 / CA-ARC-SYS-HARDEN-001-009 |
| ARC-OQ-010 | OQ | **PASS** | `PHANTOM_COMPLETE` | `RECONCILIATION_REQUIRED` | DEV-ARC-SYS-HARDEN-001-010 / CA-ARC-SYS-HARDEN-001-010 |
| ARC-OQ-011 | OQ | **PASS** | `LIVE_SOURCE_ONLY` | `RECONSTRUCTABLE` | DEV-ARC-SYS-HARDEN-001-011 / CA-ARC-SYS-HARDEN-001-011 |
| ARC-OQ-012 | OQ | **PASS** | `STALE_PASS_DISPLAYED_CURRENT` | `STALE_REASSESSMENT_REQUIRED` | DEV-ARC-SYS-HARDEN-001-012 / CA-ARC-SYS-HARDEN-001-012 |
| ARC-OQ-013 | OQ | **PASS** | `APPROVED_WITH_UNRESOLVED_CONFLICT` | `INSUFFICIENT_REVIEW_BASIS` | DEV-ARC-SYS-HARDEN-001-013 / CA-ARC-SYS-HARDEN-001-013 |
| ARC-OQ-014 | OQ | **PASS** | `EMERGENCY_COMPLETE_WITH_OPEN_OBLIGATIONS` | `EMERGENCY_RECONCILIATION_REQUIRED` | DEV-ARC-SYS-HARDEN-001-014 / CA-ARC-SYS-HARDEN-001-014 |
| ARC-PQ-001 | PQ | **PASS** | `DUPLICATE_MANUAL_METADATA_REQUIRED` | `EVIDENCE_ONCE_PROJECT_MANY_ACCEPTABLE` | DEV-ARC-SYS-HARDEN-001-015 / CA-ARC-SYS-HARDEN-001-015 |
| ARC-PQ-002 | PQ | **PASS** | `BASELINE_PARTIAL_RECONSTRUCTION` | `ARCHEMEDICA_OUTPERFORMS_BASELINE_WITH_RESIDUAL_PMF_RISK` | DEV-ARC-SYS-HARDEN-001-016 / CA-ARC-SYS-HARDEN-001-016 |

## Deviations and Corrective Actions

Scenario-level deviations `DEV-ARC-SYS-HARDEN-001-001` through `DEV-ARC-SYS-HARDEN-001-016` preserve the pre-hardening failure states and link them to corrective actions `CA-ARC-SYS-HARDEN-001-001` through `CA-ARC-SYS-HARDEN-001-016`. Every scenario retest result is PASS. Full details are in the machine JSON evidence.

## Recommendation

**CONDITIONAL GO FOR CONTROLLED PILOT HARNESS ONLY**.

The integrated control-plane harness passes the mandatory ARC-SYS-HARDEN-001 verification set for controlled pilot/prototype use. Integrated production automation remains not authorized until the controls are implemented against a real persistent application stack and independently verified under the intended regulated context.

**END OF EXECUTION REPORT**

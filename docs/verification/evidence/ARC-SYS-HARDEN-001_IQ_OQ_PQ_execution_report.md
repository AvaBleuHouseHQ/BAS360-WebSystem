# ARC-SYS-HARDEN-001 IQ/OQ/PQ Execution Report

**Harness:** ARC-SYS-HARDEN-001-E2E-HARNESS v1.0.0
**Execution Timestamp:** 2026-08-30T12:00:00Z
**Repository HEAD at execution:** `4218599569c1c2fd97bc90bdda3cd3d97929de62`
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

### DEV-ARC-SYS-HARDEN-001-001 / CA-ARC-SYS-HARDEN-001-001
- Related scenario: ARC-OQ-001 — Missing true DDG edge with zero-result impact search.
- Preserved failure: `NO_IMPACT`
- Corrective change verified: `IMPACT_NOT_ESTABLISHED_HUMAN_REVIEW_REQUIRED`
- Retest result: **PASS**
- Residual risk: Coverage check is deterministic for controlled domains; semantic completeness of real-world domains remains a pilot risk.

### DEV-ARC-SYS-HARDEN-001-002 / CA-ARC-SYS-HARDEN-001-002
- Related scenario: ARC-OQ-002 — False HIGH edge causing excessive reassessment.
- Preserved failure: `REASSESSMENT_CASCADE`
- Corrective change verified: `FALSE_POSITIVE_CONTAINED_REVIEW_REQUIRED`
- Retest result: **PASS**
- Residual risk: False positives can still consume reviewer time; burden monitoring remains required.

### DEV-ARC-SYS-HARDEN-001-003 / CA-ARC-SYS-HARDEN-001-003
- Related scenario: ARC-OQ-003 — EIG conflict -> DER -> PCDI remediation loop terminates in one causal episode.
- Preserved failure: `REASSESSMENT_LOOP`
- Corrective change verified: `EPISODE_CLOSED_NO_LOOP`
- Retest result: **PASS**
- Residual risk: Loop termination proven for deterministic fixture; production async execution still requires implementation-level tests.

### DEV-ARC-SYS-HARDEN-001-004 / CA-ARC-SYS-HARDEN-001-004
- Related scenario: ARC-OQ-004 — RDRE remediation artifact does not self-reopen absent new basis.
- Preserved failure: `SELF_REOPENED`
- Corrective change verified: `DERIVED_RDRE_REMEDIATION_TRACKED_WITHIN_EPISODE`
- Retest result: **PASS**
- Residual risk: Materially-new-basis classification will need SME review in real workflows.

### DEV-ARC-SYS-HARDEN-001-005 / CA-ARC-SYS-HARDEN-001-005
- Related scenario: ARC-OQ-005 — Regulatory reaffirmation races Safety hold.
- Preserved failure: `LAST_WRITE_WINS_AUTHORIZED`
- Corrective change verified: `HOLD_CONFLICT`
- Retest result: **PASS**
- Residual risk: Authority scopes are fixture-defined; customer SOP mapping remains needed.

### DEV-ARC-SYS-HARDEN-001-006 / CA-ARC-SYS-HARDEN-001-006
- Related scenario: ARC-OQ-006 — Predecessor approval arrives after successor issuance.
- Preserved failure: `DUAL_CURRENT_DECISIONS`
- Corrective change verified: `REJECTED_STALE`
- Retest result: **PASS**
- Residual risk: Revision logic must be implemented in persistent storage before production use.

### DEV-ARC-SYS-HARDEN-001-007 / CA-ARC-SYS-HARDEN-001-007
- Related scenario: ARC-OQ-007 — Cross-tenant traversal through shared regulatory source leaks nothing.
- Preserved failure: `TENANT_SIDE_CHANNEL_LEAK`
- Corrective change verified: `AUTHORIZED_EMPTY_RESULT`
- Retest result: **PASS**
- Residual risk: Synthetic proof only; real indexes/caches need security testing.

### DEV-ARC-SYS-HARDEN-001-008 / CA-ARC-SYS-HARDEN-001-008
- Related scenario: ARC-OQ-008 — Elevated cached graph result cannot be returned to lower privilege.
- Preserved failure: `PRIVILEGE_DOWNGRADE_CACHE_LEAK`
- Corrective change verified: `CACHE_MISS_REAUTHORIZE`
- Retest result: **PASS**
- Residual risk: Cache key policy must be enforced consistently across services.

### DEV-ARC-SYS-HARDEN-001-009 / CA-ARC-SYS-HARDEN-001-009
- Related scenario: ARC-OQ-009 — Duplicate event/replay produces one business effect.
- Preserved failure: `DUPLICATE_BUSINESS_EFFECT`
- Corrective change verified: `DUPLICATE_SUPPRESSED_ONE_BUSINESS_EFFECT`
- Retest result: **PASS**
- Residual risk: Durability is simulated; production message store verification remains required.

### DEV-ARC-SYS-HARDEN-001-010 / CA-ARC-SYS-HARDEN-001-010
- Related scenario: ARC-OQ-010 — Crash between state write and derived-event publication reconciles.
- Preserved failure: `PHANTOM_COMPLETE`
- Corrective change verified: `RECONCILIATION_REQUIRED`
- Retest result: **PASS**
- Residual risk: Recovery worker behavior is specified but not load-tested.

### DEV-ARC-SYS-HARDEN-001-011 / CA-ARC-SYS-HARDEN-001-011
- Related scenario: ARC-OQ-011 — Live source changes after decision; historical basis remains reconstructable.
- Preserved failure: `LIVE_SOURCE_ONLY`
- Corrective change verified: `RECONSTRUCTABLE`
- Retest result: **PASS**
- Residual risk: Snapshot rights and retention limits must be assessed source by source.

### DEV-ARC-SYS-HARDEN-001-012 / CA-ARC-SYS-HARDEN-001-012
- Related scenario: ARC-OQ-012 — Prior EIG PASS cannot display against changed source content as current.
- Preserved failure: `STALE_PASS_DISPLAYED_CURRENT`
- Corrective change verified: `STALE_REASSESSMENT_REQUIRED`
- Retest result: **PASS**
- Residual risk: Real EIG display layer must bind status to source hash/version.

### DEV-ARC-SYS-HARDEN-001-013 / CA-ARC-SYS-HARDEN-001-013
- Related scenario: ARC-OQ-013 — High-risk reviewer rubber-stamps unresolved conflict; gate detects insufficient review basis.
- Preserved failure: `APPROVED_WITH_UNRESOLVED_CONFLICT`
- Corrective change verified: `INSUFFICIENT_REVIEW_BASIS`
- Retest result: **PASS**
- Residual risk: Controls detect missing basis but cannot prove reviewer cognition.

### DEV-ARC-SYS-HARDEN-001-014 / CA-ARC-SYS-HARDEN-001-014
- Related scenario: ARC-OQ-014 — Emergency path is used and retrospective obligations reconcile.
- Preserved failure: `EMERGENCY_COMPLETE_WITH_OPEN_OBLIGATIONS`
- Corrective change verified: `EMERGENCY_RECONCILIATION_REQUIRED`
- Retest result: **PASS**
- Residual risk: Emergency SOP and retrospective due-date enforcement remain outside this fixture.

### DEV-ARC-SYS-HARDEN-001-015 / CA-ARC-SYS-HARDEN-001-015
- Related scenario: ARC-PQ-001 — Full protocol amendment can be processed without duplicate manual metadata entry.
- Preserved failure: `DUPLICATE_MANUAL_METADATA_REQUIRED`
- Corrective change verified: `EVIDENCE_ONCE_PROJECT_MANY_ACCEPTABLE`
- Retest result: **PASS**
- Residual risk: Representative burden passes fixture threshold; broader user-study evidence is still required.

### DEV-ARC-SYS-HARDEN-001-016 / CA-ARC-SYS-HARDEN-001-016
- Related scenario: ARC-PQ-002 — Strong checklist + incumbent systems baseline comparison.
- Preserved failure: `BASELINE_PARTIAL_RECONSTRUCTION`
- Corrective change verified: `ARCHEMEDICA_OUTPERFORMS_BASELINE_WITH_RESIDUAL_PMF_RISK`
- Retest result: **PASS**
- Residual risk: Strong baseline is not eliminated; product-market value remains conditional.

## Recommendation

**CONDITIONAL GO FOR CONTROLLED PILOT HARNESS ONLY**.

The integrated control-plane harness passes the mandatory ARC-SYS-HARDEN-001 verification set for controlled pilot/prototype use. Integrated production automation remains not authorized until the controls are implemented against a real persistent application stack and independently verified under the intended regulated context.

**END OF EXECUTION REPORT**

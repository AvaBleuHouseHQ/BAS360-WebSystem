# ARC-SDLC-VERIFY-001 — ARC-SYS-HARDEN-001 IQ/OQ/PQ Protocol and Report

**Document ID:** ARC-SDLC-VERIFY-001  
**Version:** 1.0  
**Status:** CONTROLLED — EXECUTED  
**System:** Archemedica / BAS360-WebSystem  
**Verification Type:** SDLC verification package for deterministic integrated control-plane harness  
**Date Executed:** 2026-08-30  
**Protocol Owner:** Cassandra Harrison / AvaBleuHouseHQ  
**Executor:** Codex  
**Related Change Control:** ARC-CC-001  
**Governing Standard:** ARC-STD-001 v1.0  
**Primary Requirement:** ARC-SYS-HARDEN-001 v1.0  
**Execution Evidence:** `docs/verification/evidence/ARC-SYS-HARDEN-001_IQ_OQ_PQ_execution_results.json`
**Final Repository Verification:** `docs/verification/evidence/ARC-SYS-HARDEN-001_final_repository_verification.md`

> **Attestation boundary:** This protocol/report documents controlled software-development verification of a deterministic harness and synthetic fixture. It does not establish GxP validation, 21 CFR Part 11 compliance, regulator acceptance, clinical correctness, scientific validation, security certification, production qualification, or production release authorization.

## 1. Purpose

Verify that the ARC-SYS-HARDEN-001 integrated control-plane requirements can be exercised deterministically end to end against the 16 mandatory verification scenarios defined in the controlled hardening baseline.

## 2. Scope

In scope:

- Installation/configuration/version integrity checks for the local controlled repository and harness.
- OQ functional/control tests covering negative paths, concurrency, idempotency, tenant isolation, causal-loop prevention, stale-state rejection, historical reconstruction and human-review controls.
- PQ representative oncology protocol-amendment workflow using predefined acceptance criteria and comparison to a strong incumbent-process checklist baseline.
- Deviations, corrective actions, retest status, residual risk and traceability.

Out of scope:

- Production application qualification.
- Database, queue, cache, UI, external archive or authorization-service verification.
- Live customer data.
- Regulatory submission, GxP validation or Part 11 compliance claims.

## 3. References

- ARC-STD-001 — Archemedica Adversarial Architecture & Build Decision Standard.
- ARC-AST-001 through ARC-AST-009 — controlled adversarial findings and lessons learned.
- ARC-SYS-HARDEN-001 — Integrated Control Plane Hardening.
- ARC-SYS-HARDEN-001 Integrated Control Plane schema.
- ARC-CC-001 — deterministic adversarial harness change control.

## 4. Test Environment / IQ Protocol

### IQ Acceptance Criteria

- Python 3 interpreter is available and recorded.
- Operating-system/platform identity is recorded.
- Required controlled artifacts and fixture are present.
- SHA-256 hashes are captured for required artifacts.
- Git branch, HEAD and status are captured.
- Fixture contains acceptance criteria and strong baseline data.

### IQ Results

Executed by harness:

- ARC-IQ-001 — Execution environment recorded: PASS.
- ARC-IQ-002 — Controlled artifact and fixture integrity: PASS.
- ARC-IQ-003 — Repository version identity captured: PASS.
- ARC-IQ-004 — Fixture acceptance criteria present: PASS.

IQ status: PASS, 4/4.

## 5. OQ Protocol

Each OQ scenario defines expected state, prohibited state, audit evidence and pass/fail criteria before execution. The harness preserves the pre-hardening failure state and verifies the hardened result.

### OQ Scenarios

| ID | Scenario | Expected State | Prohibited State | Result |
|---|---|---|---|---|
| ARC-OQ-001 | Missing true DDG edge with zero-result impact search | `IMPACT_NOT_ESTABLISHED_HUMAN_REVIEW_REQUIRED` | `NO_IMPACT` | PASS |
| ARC-OQ-002 | False HIGH edge causing excessive reassessment | `FALSE_POSITIVE_CONTAINED_REVIEW_REQUIRED` | `REASSESSMENT_CASCADE` | PASS |
| ARC-OQ-003 | EIG conflict to DER to PCDI remediation loop terminates in one causal episode | `EPISODE_CLOSED_NO_LOOP` | `REASSESSMENT_LOOP` | PASS |
| ARC-OQ-004 | RDRE remediation artifact does not self-reopen absent new basis | `DERIVED_RDRE_REMEDIATION_TRACKED_WITHIN_EPISODE` | `SELF_REOPENED` | PASS |
| ARC-OQ-005 | Regulatory reaffirmation races Safety hold | `HOLD_CONFLICT` | `LAST_WRITE_WINS_AUTHORIZED` | PASS |
| ARC-OQ-006 | Predecessor approval arrives after successor issuance | `REJECTED_STALE` | `DUAL_CURRENT_DECISIONS` | PASS |
| ARC-OQ-007 | Cross-tenant traversal through shared regulatory source leaks nothing | `AUTHORIZED_EMPTY_RESULT` | `TENANT_SIDE_CHANNEL_LEAK` | PASS |
| ARC-OQ-008 | Elevated cached graph result cannot be returned to lower privilege | `CACHE_MISS_REAUTHORIZE` | `PRIVILEGE_DOWNGRADE_CACHE_LEAK` | PASS |
| ARC-OQ-009 | Duplicate event/replay produces one business effect | `DUPLICATE_SUPPRESSED_ONE_BUSINESS_EFFECT` | `DUPLICATE_BUSINESS_EFFECT` | PASS |
| ARC-OQ-010 | Crash between state write and derived-event publication reconciles | `RECONCILIATION_REQUIRED` | `PHANTOM_COMPLETE` | PASS |
| ARC-OQ-011 | Live source changes after decision; historical basis remains reconstructable | `RECONSTRUCTABLE` | `LIVE_SOURCE_ONLY` | PASS |
| ARC-OQ-012 | Prior EIG PASS cannot display against changed source content as current | `STALE_REASSESSMENT_REQUIRED` | `STALE_PASS_DISPLAYED_CURRENT` | PASS |
| ARC-OQ-013 | High-risk reviewer rubber-stamps unresolved conflict | `INSUFFICIENT_REVIEW_BASIS` | `APPROVED_WITH_UNRESOLVED_CONFLICT` | PASS |
| ARC-OQ-014 | Emergency path is used and retrospective obligations reconcile | `EMERGENCY_RECONCILIATION_REQUIRED` | `EMERGENCY_COMPLETE_WITH_OPEN_OBLIGATIONS` | PASS |

OQ status: PASS, 14/14.

## 6. PQ Protocol

PQ uses fixture `FIX-ARC-SYS-HARDEN-001-ONC-AMEND-001`, representing an oncology protocol amendment with eligibility change, dose modification, mixed evidence, model influence, regulatory change, site implementation, emergency safety path and later outcome/reconstruction needs.

### PQ Acceptance Criteria

- All 16 mandatory integrated scenarios pass.
- Manual duplicate metadata burden is controlled at no more than 8 manual entries in the representative workflow.
- Decision reconstruction is completed within 45 minutes in the representative workflow.
- Historical basis remains reconstructable from decision-time snapshots.
- Strong incumbent process baseline is explicitly compared, not dismissed.
- No GxP validation, Part 11 compliance or production qualification claim is made.
- No unresolved critical defects remain in harness scope.

### PQ Results

| ID | Scenario | Expected State | Prohibited State | Result |
|---|---|---|---|---|
| ARC-PQ-001 | Full protocol amendment can be processed without duplicate manual metadata entry | `EVIDENCE_ONCE_PROJECT_MANY_ACCEPTABLE` | `DUPLICATE_MANUAL_METADATA_REQUIRED` | PASS |
| ARC-PQ-002 | Strong checklist + incumbent systems baseline comparison | `ARCHEMEDICA_OUTPERFORMS_BASELINE_WITH_RESIDUAL_PMF_RISK` | `BASELINE_PARTIAL_RECONSTRUCTION` | PASS |

PQ status: PASS, 2/2.

## 7. Deviations / Corrective Actions

Setup deviation:

- `DEV-ARC-SYS-HARDEN-001-SETUP-001`: first execution failed because files were created in the chat workspace rather than the BAS360-WebSystem repository. Corrected by relocating files to the target repository. Retest passed.

Scenario deviations:

- `DEV-ARC-SYS-HARDEN-001-001` through `DEV-ARC-SYS-HARDEN-001-016` preserve pre-hardening failure behavior.
- `CA-ARC-SYS-HARDEN-001-001` through `CA-ARC-SYS-HARDEN-001-016` are the corresponding hardened control-plane corrections verified by retest.
- Full before/after behavior, audit references and residual risk are captured in the JSON evidence and Markdown execution report.

## 8. Requirements-to-Test Traceability

Traceability matrix:

`docs/verification/traceability/ARC-SYS-HARDEN-001_requirements_to_test_traceability.csv`

The matrix maps ARC-SYS-HARDEN-001 mandatory verification requirements MV-01 through MV-16 to OQ/PQ scenarios, ARC-AST findings, expected/prohibited states, actual hardened states, deviations, corrective actions and retest result.

## 9. Summary Results

- IQ: PASS, 4/4.
- OQ: PASS, 14/14.
- PQ: PASS, 2/2.
- Mandatory integrated verification scenarios: PASS, 16/16.
- Unresolved defects in deterministic harness scope: none.
- Recommendation: `CONDITIONAL GO FOR CONTROLLED PILOT HARNESS ONLY`.

## 10. Residual Risk

The harness proves deterministic semantic behavior for the controlled architecture fixture. It does not yet prove:

- persistent transaction correctness under a real database;
- durable message processing under a real queue;
- authorization isolation across live indexes, caches, logs and exports;
- UI presentation correctness for stale/historical state;
- external source snapshot retention rights;
- customer-specific authority mappings;
- reviewer cognition;
- product-market superiority across multiple sponsor workflows.

These are production implementation and pilot-study risks, not closed validation findings.

## 11. Go / No-Go Recommendation

**Conditional go for controlled pilot harness/prototype use only.**

The harness may be used as a controlled regression baseline for future Archemedica implementation work. Integrated production automation remains not authorized until equivalent controls are implemented in the actual application stack and independently verified under the intended context of use.

## 12. Approval Status

**Executed by:** Codex.  
**Implementation status:** Complete.  
**Verification status:** Passed in harness scope.  
**QA/QC review:** Pending human owner review.  
**Decision owner approval:** Pending Cassandra Harrison / AvaBleuHouseHQ review.  
**Production release:** Not authorized.

## 13. Change History

| Version | Date | Change | Status |
|---|---|---|---|
| 1.0 | 2026-08-30 | Created and executed IQ/OQ/PQ protocol/report for ARC-SYS-HARDEN-001 deterministic integrated harness | EXECUTED |
| 1.1 | 2026-08-30 | Re-executed the original Work harness in the BAS360-WebSystem repository from a clean committed baseline and linked final repository verification/fetch-back evidence | EXECUTED |

**END OF SDLC VERIFICATION PACKAGE**

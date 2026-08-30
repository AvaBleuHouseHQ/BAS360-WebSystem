# ARC-SDLC-VERIFY-001 — ARC-SYS-HARDEN-001 IQ/OQ/PQ Protocol and Report

**Document ID:** ARC-SDLC-VERIFY-001  
**Version:** 1.0  
**Status:** EXECUTED — CONTROLLED PILOT HARNESS VERIFICATION  
**System:** Archemedica / BAS360-WebSystem  
**Date:** 2026-08-30  
**Owner:** Cassandra Harrison / AvaBleuHouseHQ  
**Implemented / Executed By:** Codex  
**Related Change Control:** ARC-CC-001  
**Governing Standard:** ARC-STD-001 v1.0  
**Primary Requirement:** ARC-SYS-HARDEN-001 v1.0

> **Qualification boundary:** IQ/OQ/PQ terminology is used here as a disciplined SDLC verification structure for the deterministic pilot harness. This report does not establish GxP validation, 21 CFR Part 11 compliance, regulator acceptance, clinical/scientific validation, security certification, production qualification, or production release authorization.

## 1. Objective

Verify by deterministic execution that the ARC-SYS-HARDEN-001 integrated control-plane semantics address the 16 mandatory adversarial scenarios identified by the Archemedica red-team campaign.

## 2. Scope

Included:

- deterministic control-plane functions;
- controlled synthetic oncology amendment fixture;
- dependency coverage;
- causal reassessment episodes;
- authority/concurrency;
- tenant/authorization isolation;
- idempotency/reconciliation;
- historical snapshot integrity;
- human-review basis;
- emergency reconciliation;
- evidence-once/project-many burden;
- comparison with a strong incumbent/checklist baseline.

Excluded:

- production database behavior;
- real message broker behavior;
- deployed authentication/authorization infrastructure;
- live caches/search indexes/log stores;
- production UI;
- real sponsor data;
- clinical or regulatory decision validation;
- electronic-signature validation;
- GxP/Part 11 qualification.

## 3. Preconditions

1. ARC-SYS-HARDEN-001 v1.0 is present as the controlled hardening baseline.
2. The representative fixture contains predefined expected/prohibited states.
3. Python 3 is available.
4. Harness and evidence paths are writable.
5. Repository identity can be captured when executed in the target repository.

## 4. Requirements / Acceptance Criteria

The mandatory verification requirements are MV-01 through MV-16 from ARC-SYS-HARDEN-001 section 13.

Acceptance requires:

- IQ 4/4 PASS;
- OQ 14/14 PASS;
- PQ 2/2 PASS;
- all 16 mandatory scenarios PASS;
- no unresolved defects within deterministic harness scope;
- preserved before-state failures and corrective-action traceability;
- explicit residual-risk and claim boundaries.

## 5. Installation Qualification (IQ)

### IQ Tests

| ID | Requirement | Acceptance Criterion | Result |
|---|---|---|---|
| ARC-IQ-001 | Execution environment recorded | Python/platform/time captured | PASS |
| ARC-IQ-002 | Controlled artifact/fixture integrity | Harness and fixture exist and SHA-256 values captured | PASS |
| ARC-IQ-003 | Repository version identity | Git repository and HEAD captured | PASS |
| ARC-IQ-004 | Fixture acceptance criteria | All 16 scenarios define expected/prohibited state | PASS |

IQ status: PASS, 4/4.

## 6. Operational Qualification (OQ)

### OQ Tests

| ID | Scenario | Expected State | Prohibited State | Result |
|---|---|---|---|---|
| ARC-OQ-001 | Missing true DDG edge with zero-result impact search | `IMPACT_NOT_ESTABLISHED_HUMAN_REVIEW_REQUIRED` | `NO_IMPACT` | PASS |
| ARC-OQ-002 | False HIGH edge causing excessive reassessment | `FALSE_POSITIVE_CONTAINED_REVIEW_REQUIRED` | `REASSESSMENT_CASCADE` | PASS |
| ARC-OQ-003 | EIG conflict -> DER -> PCDI remediation loop terminates in one causal episode | `EPISODE_CLOSED_NO_LOOP` | `REASSESSMENT_LOOP` | PASS |
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

## 7. Performance Qualification (PQ)

Representative intended-use simulation: oncology protocol amendment with eligibility/dose changes, mixed evidence, regulatory divergence, model-use context, downstream implementation dependencies, reassessment and audit reconstruction.

PQ acceptance requires:

- shared evidence metadata is captured once and projected without duplicate manual entry;
- decision/dependency/reassessment lineage is reconstructable;
- strong incumbent process baseline is explicitly compared, not dismissed;
- no unsupported production or compliance claim.

### PQ Results

| ID | Scenario | Expected State | Prohibited State | Result |
|---|---|---|---|---|
| ARC-PQ-001 | Full protocol amendment can be processed without duplicate manual metadata entry | `EVIDENCE_ONCE_PROJECT_MANY_ACCEPTABLE` | `DUPLICATE_MANUAL_METADATA_REQUIRED` | PASS |
| ARC-PQ-002 | Strong checklist + incumbent systems baseline comparison | `ARCHEMEDICA_OUTPERFORMS_BASELINE_WITH_RESIDUAL_PMF_RISK` | `BASELINE_PARTIAL_RECONSTRUCTION` | PASS |

PQ status: PASS, 2/2.

## 8. Deviations / Corrective Actions

Setup deviation:

- `DEV-ARC-SYS-HARDEN-001-SETUP-001`: first execution failed because files were created in the chat workspace rather than the BAS360-WebSystem repository. Corrected by relocating files to the target repository. Retest passed.

Scenario deviations:

- `DEV-ARC-SYS-HARDEN-001-001` through `DEV-ARC-SYS-HARDEN-001-016` preserve pre-hardening failure behavior.
- `CA-ARC-SYS-HARDEN-001-001` through `CA-ARC-SYS-HARDEN-001-016` are the corresponding hardened control-plane corrections verified by retest.
- Full before/after behavior, audit references and residual risk are captured in the JSON evidence and Markdown execution report.

## 9. Requirements-to-Test Traceability

Traceability matrix:

`docs/verification/traceability/ARC-SYS-HARDEN-001_requirements_to_test_traceability.csv`

The matrix maps ARC-SYS-HARDEN-001 mandatory verification requirements MV-01 through MV-16 to OQ/PQ scenarios, ARC-AST findings, expected/prohibited states, actual hardened states, deviations, corrective actions and retest result.

## 10. Summary Results

- IQ: PASS, 4/4.
- OQ: PASS, 14/14.
- PQ: PASS, 2/2.
- Mandatory integrated verification scenarios: PASS, 16/16.
- Unresolved defects in deterministic harness scope: none.
- Recommendation: `CONDITIONAL GO FOR CONTROLLED PILOT HARNESS ONLY`.

## 11. Residual Risk

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

## 12. Go / No-Go Recommendation

**Conditional go for controlled pilot harness/prototype use only.**

The harness may be used as a controlled regression baseline for future Archemedica implementation work. Integrated production automation remains not authorized until equivalent controls are implemented in the actual application stack and independently verified under the intended context of use.

## 13. Approval Status

**Executed by:** Codex.  
**Implementation status:** Complete.  
**Verification status:** Passed in harness scope.  
**QA/QC review:** Pending human owner review.  
**Decision owner approval:** Pending Cassandra Harrison / AvaBleuHouseHQ review.  
**Production release:** Not authorized.

## 14. Change History

| Version | Date | Change | Status |
|---|---|---|---|
| 1.0 | 2026-08-30 | Created and executed IQ/OQ/PQ protocol/report for ARC-SYS-HARDEN-001 deterministic integrated harness | EXECUTED |

**END OF SDLC VERIFICATION PACKAGE**

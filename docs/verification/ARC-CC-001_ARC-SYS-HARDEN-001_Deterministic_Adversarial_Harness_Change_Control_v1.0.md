# ARC-CC-001 — ARC-SYS-HARDEN-001 Deterministic Adversarial Harness Change Control

**Document ID:** ARC-CC-001  
**Version:** 1.0  
**Status:** CONTROLLED — IMPLEMENTED / VERIFIED FOR CONTROLLED PILOT HARNESS USE  
**System:** Archemedica / BAS360-WebSystem  
**Change Type:** Controlled computerized-system development change  
**Risk Tier:** 3  
**Date Opened:** 2026-08-30  
**Date Implemented:** 2026-08-30  
**Change Owner:** Cassandra Harrison / AvaBleuHouseHQ  
**Implementer:** Codex  
**Governed By:** ARC-STD-001 v1.0  
**Primary Requirement:** ARC-SYS-HARDEN-001 v1.0  
**Evidence Package:** `docs/verification/evidence/ARC-SYS-HARDEN-001_IQ_OQ_PQ_execution_results.json`
**Final Repository Verification:** `docs/verification/evidence/ARC-SYS-HARDEN-001_final_repository_verification.md`

> **Control boundary:** This change creates and executes a deterministic adversarial verification harness for the integrated control-plane architecture. It does not validate a production system, establish GxP validation, establish 21 CFR Part 11 compliance, certify security, establish clinical/scientific correctness, or authorize integrated production automation.

## 1. Reason for Change

ARC-SYS-HARDEN-001 requires a deterministic end-to-end adversarial test harness before integrated production automation may be considered. The prior controlled red-team records ARC-AST-001 through ARC-AST-009 found that component-local controls were insufficient for the integrated Archemedica lifecycle.

The mandatory need is to prove, by execution rather than narrative review, that the shared controls can prevent false closure across dependency coverage, causal episodes, concurrency, tenant authorization, idempotency, historical reconstruction, human oversight and operational burden.

## 2. Problem / Pre-Change State

Before this change, BAS360-WebSystem contained the controlled architecture, adversarial findings and machine-readable schemas, but no executable integrated verification harness or IQ/OQ/PQ evidence package.

Preserved pre-hardening failures include:

- `NO_IMPACT` when a true DDG edge is missing and coverage is unknown.
- `REASSESSMENT_LOOP` after EIG/DER/PCDI remediation.
- `LAST_WRITE_WINS_AUTHORIZED` during authority collision.
- `TENANT_SIDE_CHANNEL_LEAK` through shared regulatory-source traversal.
- `DUPLICATE_BUSINESS_EFFECT` under event replay.
- `PHANTOM_COMPLETE` after crash/partial publication.
- `LIVE_SOURCE_ONLY` historical reconstruction failure.
- `APPROVED_WITH_UNRESOLVED_CONFLICT` from rubber-stamp review.
- `DUPLICATE_MANUAL_METADATA_REQUIRED` operational burden.
- `BASELINE_PARTIAL_RECONSTRUCTION` compared with Archemedica's intended continuity layer.

## 3. Impact and Risk Assessment

**Risk classification:** Tier 3, because the harness tests consequential clinical-development decision-support controls, tenant isolation, historical reconstruction and human-review controls.

**Positive impact:** Adds executable verification evidence and formal traceability for the 16 mandatory ARC-SYS-HARDEN-001 integrated scenarios.

**Implementation risk:** Low to moderate within this repository because the change adds a standalone deterministic harness, fixture and documentation. It does not modify existing controlled architecture text, schemas, public pages or runtime behavior.

**Residual risk:** Material residual risk remains because the repository still does not contain a production application stack, persistent database, message broker, authorization service, cache, external source archive, or live UI. The harness verifies deterministic semantics against controlled fixtures, not deployed production behavior.

## 4. Affected Controlled Artifacts

New artifacts:

- `tools/archemedica_integrated_harness.py`
- `tests/fixtures/ARC-SYS-HARDEN-001_oncology_protocol_amendment_fixture.json`
- `docs/verification/evidence/ARC-SYS-HARDEN-001_IQ_OQ_PQ_execution_results.json`
- `docs/verification/evidence/ARC-SYS-HARDEN-001_IQ_OQ_PQ_execution_report.md`
- `docs/verification/traceability/ARC-SYS-HARDEN-001_requirements_to_test_traceability.csv`
- `docs/verification/ARC-CC-001_ARC-SYS-HARDEN-001_Deterministic_Adversarial_Harness_Change_Control_v1.0.md`
- `docs/verification/ARC-SDLC-VERIFY-001_ARC-SYS-HARDEN-001_IQ_OQ_PQ_Protocol_Report_v1.0.md`

Existing artifacts reviewed and used as requirements/evidence basis:

- `docs/governance/ARC-STD-001_Archemedica_Adversarial_Architecture_and_Build_Decision_Standard_v1.0.md`
- `docs/adversarial/ARC-AST-001_DDG_Dependency_Coverage_Fault_Injection_v1.0.md`
- `docs/adversarial/ARC-AST-002_Cross_Engine_Reassessment_Loop_Fault_Injection_v1.0.md`
- `docs/adversarial/ARC-AST-003_Authority_Concurrency_and_State_Collision_Fault_Injection_v1.0.md`
- `docs/adversarial/ARC-AST-004_Tenant_Authorization_and_Graph_Traversal_Breach_Fault_Injection_v1.0.md`
- `docs/adversarial/ARC-AST-005_Event_Replay_Outage_and_Partial_Failure_Fault_Injection_v1.0.md`
- `docs/adversarial/ARC-AST-006_Source_of_Truth_Divergence_and_Snapshot_Drift_Fault_Injection_v1.0.md`
- `docs/adversarial/ARC-AST-007_Human_Control_Rubber_Stamp_and_Bypass_Fault_Injection_v1.0.md`
- `docs/adversarial/ARC-AST-008_Operational_Burden_and_Competitive_Null_Hypothesis_Fault_Injection_v1.0.md`
- `docs/adversarial/ARC-AST-009_Integrated_Red_Team_Lessons_Learned_v1.0.md`
- `docs/architecture/ARC-SYS-HARDEN-001_Archemedica_Integrated_Control_Plane_Hardening_v1.0.md`
- `schemas/integrated-control-plane/ARC-SYS-HARDEN-001_Integrated_Control_Plane.schema.json`

## 5. Implementation Summary

Implemented a deterministic Python harness using only the standard library. The harness:

- Loads the representative oncology protocol-amendment fixture.
- Records IQ environment, repository and artifact/version integrity.
- Runs all 16 mandatory integrated verification scenarios.
- Preserves baseline/pre-hardening failure states for each scenario.
- Executes hardened control-plane semantics and records expected/prohibited states.
- Produces JSON evidence, a Markdown execution report and a CSV traceability matrix.
- Performs a deterministic rerun check of scenario results.

No external services, network calls, database writes, or production integrations are used.

## 6. Deviations, Corrective Actions and Retests

### DEV-ARC-SYS-HARDEN-001-SETUP-001

**Description:** First execution attempt failed before test execution because the initial harness files were created in the active chat workspace rather than the BAS360-WebSystem repository.

**Impact:** No test result was produced from the failed launch. No controlled BAS360 source file was overwritten. The issue affected setup location only.

**Correction:** Relocated the harness and fixture into the BAS360-WebSystem repository under `tools/` and `tests/fixtures/`.

**Retest:** Re-executed `python3 tools/archemedica_integrated_harness.py`; run completed successfully with IQ 4/4, OQ 14/14, PQ 2/2 and 16/16 mandatory scenarios passed.

### Scenario Deviations

Scenario-level deviations `DEV-ARC-SYS-HARDEN-001-001` through `DEV-ARC-SYS-HARDEN-001-016` preserve the pre-hardening failure behavior and link each corrected hardened behavior to `CA-ARC-SYS-HARDEN-001-001` through `CA-ARC-SYS-HARDEN-001-016`. Details are recorded in `docs/verification/evidence/ARC-SYS-HARDEN-001_IQ_OQ_PQ_execution_report.md`.

## 7. Rollback Plan

Rollback is straightforward because no existing controlled documents or runtime behavior were modified. Revert the commit introducing:

- `tools/archemedica_integrated_harness.py`
- `tests/fixtures/ARC-SYS-HARDEN-001_oncology_protocol_amendment_fixture.json`
- `docs/verification/`

Rollback would remove executable harness evidence and return the repository to architecture-only status. It would not change the prior ARC-SYS-HARDEN-001 requirement that such a harness is required before integrated production automation.

## 8. Verification Summary

Executed command:

```text
python3 tools/archemedica_integrated_harness.py
```

Result:

- IQ: PASS, 4 passed / 0 failed.
- OQ: PASS, 14 passed / 0 failed.
- PQ: PASS, 2 passed / 0 failed.
- Mandatory integrated scenarios: PASS, 16 passed / 0 failed.
- Unresolved defects: none in the deterministic harness evidence.
- Recommendation: `CONDITIONAL GO FOR CONTROLLED PILOT HARNESS ONLY`.

## 9. Traceability

Requirements-to-test traceability is recorded in:

`docs/verification/traceability/ARC-SYS-HARDEN-001_requirements_to_test_traceability.csv`

Each mandatory ARC-SYS-HARDEN-001 verification scenario maps to:

- scenario ID;
- IQ/OQ/PQ phase;
- related ARC-AST finding(s);
- expected state;
- prohibited state;
- actual hardened state;
- deviation ID;
- corrective action ID;
- retest result.

## 10. Approval / Status

**Implementation status:** Complete.  
**Verification status:** Passed for deterministic controlled harness scope.  
**QA/QC status:** Pending human owner review.  
**Decision owner approval:** Pending Cassandra Harrison / AvaBleuHouseHQ review.  
**Release recommendation:** Conditional go for controlled pilot harness/prototype use only.  
**Integrated production automation:** Not authorized by this change.

## 11. Change History

| Version | Date | Change | Status |
|---|---|---|---|
| 1.0 | 2026-08-30 | Created deterministic ARC-SYS-HARDEN-001 integrated adversarial harness, fixture, IQ/OQ/PQ evidence, traceability and change control | IMPLEMENTED / VERIFIED FOR CONTROLLED PILOT HARNESS USE |
| 1.1 | 2026-08-30 | Re-executed the original Work harness against the BAS360-WebSystem repository baseline, refreshed machine evidence from a clean committed baseline, and added final repository verification/fetch-back record | VERIFIED FOR CONTROLLED PILOT HARNESS USE |

**END OF CHANGE CONTROL RECORD**

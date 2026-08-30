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

The change depends on, but does not silently revise:

- ARC-STD-001 v1.0;
- ARC-SYS-HARDEN-001 v1.0;
- ARC-AST-001 through ARC-AST-009;
- Evidence Registry / EIG / DER / DDG / PCDI / RDRE / CMR / DMOC architecture contracts.

New controlled artifacts:

- deterministic harness;
- representative oncology protocol-amendment fixture;
- IQ/OQ/PQ protocol/report;
- execution JSON and Markdown evidence;
- requirements-to-test traceability matrix;
- setup deviation evidence.

## 5. Implementation Summary

The harness implements explicit deterministic controls for:

1. dependency coverage uncertainty;
2. false-positive dependency containment;
3. causal reassessment episode termination;
4. derived RDRE remediation handling;
5. concurrent authority conflict;
6. stale predecessor approval rejection;
7. tenant traversal isolation;
8. privilege-downgrade cache reauthorization;
9. duplicate-event idempotency;
10. crash/partial publication reconciliation;
11. decision-time source snapshot reconstruction;
12. stale EIG assessment detection;
13. insufficient human-review basis;
14. emergency-path reconciliation;
15. evidence-once/project-many burden control;
16. strong incumbent baseline comparison.

## 6. Installation / Configuration

Harness path:

`tools/archemedica_integrated_harness.py`

Fixture path:

`tests/fixtures/ARC-SYS-HARDEN-001_oncology_protocol_amendment_fixture.json`

Execution command:

```text
python3 tools/archemedica_integrated_harness.py
```

The harness uses Python standard library only and writes controlled execution evidence under `docs/verification/evidence/`.

## 7. Verification Strategy

### IQ
Verify executable environment, controlled-artifact identity, repository identity and fixture acceptance criteria.

### OQ
Execute negative/boundary controls for coverage, false positives, causal loops, concurrency, authorization, replay, partial failure, source drift, stale assessment, human review and emergency reconciliation.

### PQ
Execute representative end-to-end protocol-amendment workflow burden and baseline-comparison tests.

## 8. Acceptance Criteria

- IQ 4/4 PASS.
- OQ 14/14 PASS.
- PQ 2/2 PASS.
- All 16 ARC-SYS-HARDEN-001 mandatory scenarios PASS.
- No unresolved defects inside deterministic harness scope.
- Failures remain preserved as before-state/deviation evidence.
- No unsupported compliance/validation claim.

## 9. Deviations

### DEV-ARC-SYS-HARDEN-001-SETUP-001

Initial execution in the Codex task workspace failed the repository-presence IQ check because files were first created outside the BAS360-WebSystem checkout.

**Cause:** execution context error, not a control-logic defect.

**Correction:** artifacts were moved into the BAS360-WebSystem repository and execution repeated.

**Retest:** PASS.

The deviation remains preserved in:

`docs/verification/evidence/DEV-ARC-SYS-HARDEN-001-SETUP-001_setup_deviation_evidence.md`

## 10. Rollback

Rollback is removal/reversion of the files introduced by this change. Because the harness does not alter production runtime behavior or existing architecture files, rollback does not require data migration.

Rollback does not erase execution evidence; prior controlled evidence remains retained in repository history.

## 11. Execution Result

Final controlled execution:

- IQ: PASS 4/4.
- OQ: PASS 14/14.
- PQ: PASS 2/2.
- Mandatory scenarios: PASS 16/16.
- Unresolved deterministic-harness defects: 0.

## 12. Release / Use Disposition

**CONDITIONAL GO FOR CONTROLLED PILOT HARNESS ONLY.**

The harness is accepted as a regression/verification baseline for architecture and prototype implementation. Integrated production automation remains not authorized until equivalent controls exist and are verified in the actual application stack.

## 13. Approval Status

**Implementation:** complete.  
**Automated verification:** complete.  
**QA/QC review:** pending accountable human review.  
**Decision-owner approval:** pending Cassandra Harrison / AvaBleuHouseHQ review.  
**Production release:** not authorized.

## 14. Change History

| Version | Date | Change | Status |
|---|---|---|---|
| 1.0 | 2026-08-30 | Implemented deterministic integrated adversarial harness and IQ/OQ/PQ package | CONTROLLED PILOT HARNESS |

**END OF CHANGE CONTROL**

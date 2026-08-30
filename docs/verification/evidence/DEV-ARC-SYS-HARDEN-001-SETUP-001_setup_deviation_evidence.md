# DEV-ARC-SYS-HARDEN-001-SETUP-001 — Setup Deviation Evidence

**Deviation ID:** DEV-ARC-SYS-HARDEN-001-SETUP-001  
**Related Change Control:** ARC-CC-001  
**Date:** 2026-08-30  
**Status:** CLOSED AFTER RETEST  

## Deviation A — Harness File Location

Initial execution command:

```text
python3 tools/archemedica_integrated_harness.py
```

Actual result:

```text
can't open file '/Users/cassiehrrsn/Documents/Codex/2026-06-09/can-you-check-my-files-for/work/BAS360-WebSystem/tools/archemedica_integrated_harness.py': [Errno 2] No such file or directory
```

Root cause:

The harness and fixture were first created in the active chat workspace rather than the BAS360-WebSystem repository.

Correction:

Moved the harness to `tools/archemedica_integrated_harness.py` and the fixture to `tests/fixtures/ARC-SYS-HARDEN-001_oncology_protocol_amendment_fixture.json` in the BAS360-WebSystem repository.

## Deviation B — Controlled Wrapper Document Location

Intermediate rerun result:

```text
go_no_go: NO-GO
iq.status: FAIL
iq.failed: 1
missing:
- docs/verification/ARC-CC-001_ARC-SYS-HARDEN-001_Deterministic_Adversarial_Harness_Change_Control_v1.0.md
- docs/verification/ARC-SDLC-VERIFY-001_ARC-SYS-HARDEN-001_IQ_OQ_PQ_Protocol_Report_v1.0.md
```

Root cause:

The two wrapper documents were first created in the active chat workspace rather than the BAS360-WebSystem repository.

Correction:

Moved the wrapper documents into `docs/verification/` in the BAS360-WebSystem repository.

## Retest

Final execution command:

```text
python3 tools/archemedica_integrated_harness.py
```

Final result:

```text
IQ: PASS, 4 passed / 0 failed
OQ: PASS, 14 passed / 0 failed
PQ: PASS, 2 passed / 0 failed
Mandatory scenarios: PASS, 16 passed / 0 failed
Go/no-go: CONDITIONAL GO FOR CONTROLLED PILOT HARNESS ONLY
```

## Impact Assessment

The deviations affected setup location and IQ artifact presence only. No existing controlled BAS360 artifact was overwritten. No OQ/PQ scenario result was changed to hide a failure. Final evidence was regenerated after correction.

**END OF SETUP DEVIATION EVIDENCE**

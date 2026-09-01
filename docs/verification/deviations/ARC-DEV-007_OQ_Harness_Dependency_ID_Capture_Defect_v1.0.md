# ARC-DEV-007 — OQ Harness Dependency-ID Capture Defect

**Version:** 1.0  
**Status:** CONTROLLED — OPEN PENDING CORRECTIVE RETEST  
**System:** Archemedica / BAS360-WebSystem  
**Author / Document Owner:** Cassandra Harrison  
**Date:** 2026-09-01  
**Protocol:** ARC-PERSIST-OQ-002  
**Observed Run:** GitHub Actions `33525120715`, job `99913882209`

## Deviation

The corrective OQ execution passed OQ2-01 through OQ2-08, then the shell harness exited before OQ2-09 because dependency IDs returned as multiple lines were captured using `read` under `set -e`. The command's nonzero read status caused shell termination even though PostgreSQL had not reported a database-control failure.

A second latent parsing weakness was identified in the requirement-supersession fixture: a three-column psql result requires explicit `IFS='|'` parsing.

## Classification

**Type:** Verification harness / test-control defect  
**Database defect established by this event:** No  
**OQ impact:** Material — OQ2-09 through OQ2-16 were not executed in this run  
**Gate:** Remains failed/incomplete

## Corrective Action

1. capture multi-row dependency IDs with `mapfile` and validate exactly three IDs;
2. parse requirement IDs with explicit psql field delimiter handling;
3. rerun the complete OQ from a fresh PostgreSQL instance and migrations 0001–0008;
4. do not combine partial runs into an artificial PASS.

## Disposition

**OPEN pending complete corrective retest.**

# ARC-PERSIST-PQ-003 — End-to-End Decision Continuity Performance Qualification Protocol

**Document ID:** ARC-PERSIST-PQ-003  
**Version:** 1.0  
**Status:** CONTROLLED — AUTHORIZED FOR SYNTHETIC PQ EXECUTION  
**System:** Archemedica / BAS360-WebSystem  
**Author / Document Owner:** Cassandra Harrison  
**Date:** 2026-09-01  
**Entry Gate:** ARC-PERSIST-OQ-002 v1.1 — 16/16 PASS

## 1. Purpose

Qualify whether the controlled Archemedica persistence foundation can support one representative end-to-end decision-continuity workflow without recreating modality silos, losing historical state, falsely closing uncertainty, or creating blanket reassessment cascades.

This is a synthetic performance qualification of the tested persistence/control-plane behavior. It is not customer validation or production qualification.

## 2. Scenario

A synthetic regulated-product program contains:

- one biologic constituent;
- one delivery-device constituent;
- one software configuration/control object;
- one manufacturing/formulation lifecycle control object;
- one product configuration linking the constituents;
- one clinical study and protocol;
- one protocol amendment / controlled change;
- regulatory requirements and contextual applicability;
- evidence snapshots and evidence-integrity assessment;
- integrated risk;
- decision evidence record;
- safety/quality hold/readiness controls;
- implementation effective state;
- post-implementation evidence and reassessment episode.

The change shall be designed so some dependencies are materially affected, some are only potentially affected, and at least one remains UNKNOWN due to insufficient support. The workflow must not collapse those states.

## 3. Required End-to-End Chain

The executable scenario shall establish and reconstruct:

`Tenant → Program → RPS → CFG → CPT → Study → Protocol → Controlled Change → LCO / dependency impact → REQ / RSA → EVS / EIG → Risk → DER → Hold / readiness → Implementation Effective State → Post-implementation evidence → Reassessment`

The same canonical RPS/CFG/evidence/decision identities shall be reused across biologic, device, software and manufacturing views. Modality-specific duplicate source-of-truth records are prohibited.

## 4. Mandatory PQ Tests

| ID | Test | Acceptance |
|---|---|---|
| PQ3-01 | Cross-modality product topology | one RPS and one CFG represent biologic + delivery device while software/manufacturing remain typed LCOs, not separate product silos |
| PQ3-02 | Protocol amendment trace | controlled change links protocol amendment to affected canonical objects |
| PQ3-03 | Dependency impact | material, potential and unknown paths remain distinct |
| PQ3-04 | Regulatory applicability | affected requirement/applicability can become stale without invalidating unrelated RSA |
| PQ3-05 | Evidence integrity | decision references immutable decision-time EVS/EIG context |
| PQ3-06 | Risk/decision continuity | risk and DER remain linked to the causal episode and current evidence state |
| PQ3-07 | No False Closure | unresolved/unknown material state blocks clean decision closure |
| PQ3-08 | Hold/readiness | active hold blocks readiness/approval until released through controlled evidence-backed action |
| PQ3-09 | Implementation state | site/jurisdiction implementation state cannot become EFFECTIVE/READY without governed evidence basis in the synthetic workflow |
| PQ3-10 | Reassessment | post-implementation evidence reuses or opens the correct causal episode without self-trigger loop |
| PQ3-11 | Historical reconstruction | prior decision-time product/configuration/protocol/REQ/RSA/EVS/EIG/risk/DER state remains reconstructable after successor/change records exist |
| PQ3-12 | Tenant isolation | second tenant cannot discover tenant-owned chain or relationship existence |
| PQ3-13 | Anti-duplication | canonical facts are entered once and reused across modality views |
| PQ3-14 | Anti-false-cascade | connected low/unknown paths are not automatically promoted to `REASSESSMENT_REQUIRED` |
| PQ3-15 | Audit/outbox continuity | consequential transition produces traceable transition/audit/outbox evidence |
| PQ3-16 | Recovery state | injected partial processing remains discoverable as reconciliation/unknown rather than false success |

## 5. Burden and Reconstruction Measures

Historical synthetic baseline:

- manual metadata entries: 29;
- reconstruction time: 95 minutes;
- adverse-condition detection: 10 of 16.

Controlled PQ targets:

- manual metadata entries: **≤ 8** for the modeled workflow facts that Archemedica itself requires;
- decision reconstruction time: **≤ 45 minutes** using the persisted canonical chain;
- mandatory PQ control detection: **16/16** in the deterministic harness;
- duplicate canonical source-of-truth entries across modalities: **0**;
- blanket false cascades: **0** in the designed scenario.

These are simulation targets, not observed customer performance claims.

## 6. Reconstruction Evidence

The PQ harness must retain enough identifiers to reconstruct the state at the original decision timestamp, including:

- RPS and CFG revision;
- constituent identities;
- protocol version;
- controlled change;
- relevant LCO revisions;
- REQ and RSA currency/applicability state;
- EVS capture identity/hash/limitation;
- EIG supportability state;
- risk state;
- DER revision/state/unresolved state;
- causal episode;
- implementation state;
- transition/audit/outbox evidence.

Successor records may supersede prior records but may not erase them.

## 7. Anti-Bureaucracy Rule

The PQ fails if the same underlying product, evidence, requirement, decision, supplier, risk or change fact must be manually re-entered solely because it participates in more than one modality/domain view.

Typed relationships and LCOs may add context; they may not create duplicate competing truth.

## 8. Falsification / Kill-or-Narrow Criteria

PQ shall fail or force scope narrowing if any of the following occurs:

- cross-modality topology requires separate product identities for one regulated product system;
- historical decision state cannot be reconstructed;
- UNKNOWN is silently converted to no-impact or closure;
- one change causes blanket graph-wide reassessment without materiality basis;
- tenant relationship existence leaks;
- manual metadata burden exceeds target without clear decision-integrity value;
- workflow requires shadow spreadsheets to explain current state;
- audit/outbox records diverge from canonical state;
- a simpler conventional checklist provides equivalent decision reconstruction at materially lower burden.

## 9. Entry / Exit Criteria

### Entry
- ARC-PERSIST-QUAL-001 PASS;
- ARC-PERSIST-OQ-002 PASS;
- ARC-DEV-006 and ARC-DEV-007 closed;
- migrations 0001–0008 apply cleanly.

### Exit
PQ may pass only if all 16 mandatory tests pass and burden/reconstruction targets are met or explicitly dispositioned without hiding failure.

## 10. Claim Boundary

A PASS authorizes only progression toward a controlled pilot-like application/service layer. It does not establish production qualification, clinical effectiveness, GxP validation, Part 11 compliance, ISO certification/conformity, regulator acceptance, or policy fitness.

**END OF CONTROLLED DOCUMENT**

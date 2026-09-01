# ARC-XMOD-VERIFY-001 — Corrective Retest and Regression Report

**Document ID:** ARC-XMOD-VERIFY-001-RETEST  
**Version:** 1.1  
**Status:** CONTROLLED — CORRECTIVE RETEST EXECUTED  
**System:** Archemedica / BAS360-WebSystem  
**Author/Document Owner:** Cassandra Harrison  
**Execution Date:** 2026-09-01  
**Design Tested:** ARC-XMOD-MODEL-001 v1.1  
**Prior Execution:** ARC-XMOD-VERIFY-001-EXEC v1.0

## 1. Objective
Retest all v1.0 failed/conditional scenarios after corrective introduction of Product Configuration/Presentation (`CFG-*`), granular Controlled Requirements (`REQ-*`), and Lifecycle Control Objects (`LCO-*`), then regression-test the fifteen scenarios that previously passed. Preserve any new failures rather than optimizing the report for a pass disposition.

## 2. Corrective Retest Results
| Scenario | Prior | v1.1 Result | Evidence of Correction |
|---|---|---|---|
| XM-OQ-002 Formulation/manufacturing propagation | CONDITIONAL | PASS | Formulation/process change represented as versioned `LCO-*`, linked to biologic constituent, delivery-device compatibility, configuration, evidence, risk and DER without falsely converting process into constituent identity. |
| XM-OQ-008 Coexisting control families | CONDITIONAL | PASS | `SRC → REQ → RSA(context) → OBL/control/evidence` permits drug/biologic/device/software control families to coexist at requirement level without one source-level applicability decision flattening them. |
| XM-OQ-009 Supplier/material change | FAIL | PASS | Supplier change links `SUP-* → material/specification LCO → design/biocompatibility/manufacturing LCOs → CPT/CFG → RSA/REQ/risk/DER`; no opaque free-text-only dependency is required. |
| XM-OQ-012 Source version reopening | CONDITIONAL | PASS | Superseded source requirement produces successor `REQ-*`; affected RSA/OBL/DER dependencies can reopen specifically at the requirement level rather than indiscriminately reopening every obligation from the parent source. |
| XM-OQ-019 Configuration topology change | FAIL | PASS | `CFG-*` explicitly represents integral/co-packaged/cross-labeled/kit/presentation topology and version lineage. A topology change can trigger classification, labeling, manufacturing, usability, RSA and DER reassessment while constituent identity remains stable. |

**Corrective retest:** 5/5 PASS.

## 3. Regression Results
| Scenario | v1.1 Result | Regression Observation |
|---|---|---|
| XM-OQ-001 Dose change across biologic + delivery device | PASS | Added CFG/LCO/REQ granularity improves path specificity; no duplicate product root required. |
| XM-OQ-003 Companion diagnostic threshold change | PASS | Diagnostic CPT remains linked to protocol/statistics/benefit-risk while requirement-level overlays remain separable. |
| XM-OQ-004 Connected therapeutic software/cybersecurity | PASS | Software configuration represented as LCO where appropriate while software may also be a CPT when itself a regulated constituent; context prevents forced single classification. |
| XM-OQ-005 Classification uncertainty | PASS | RCL/RSA remain capable of `UNKNOWN` and `HUMAN_JUDGMENT_REQUIRED`. |
| XM-OQ-006 Classification supersession | PASS | Successor classification can trigger CFG/REQ/RSA/OBL/risk/DER reassessment without erasing predecessor. |
| XM-OQ-007 Jurisdiction-specific differences | PASS | One RPS supports jurisdiction-specific CFG and RSA without cloning the therapeutic system. |
| XM-OQ-010 False HIGH dependency | PASS | DEP edge may be rejected/reclassified with preserved prior assertion. |
| XM-OQ-011 Missing true dependency / incomplete coverage | PASS | DCA still blocks clean no-impact when coverage is inadequate. |
| XM-OQ-013 Evidence once, multiple uses | PASS | EVS can support multiple DER/RSA/LCO contexts without duplicate source capture. |
| XM-OQ-014 Device malfunction + drug exposure safety | PASS | Integrated risk/signal relationships remain cross-domain and causally linked. |
| XM-OQ-015 Human-factors conflict reopening clinical decision | PASS | Usability/human-factors LCO/evidence can invalidate an assumption in a clinical DER. |
| XM-OQ-016 Model/preprocessing change | PASS | MUSE relationship remains versioned and can connect to risk, evidence, LCO or DER as context requires. |
| XM-OQ-017 Unknown applicability | PASS | `UNKNOWN` remains non-equivalent to `DOES_NOT_APPLY`. |
| XM-OQ-018 Constituent replacement | PASS | CPT successor/supersession history remains intact and CFG can identify which product presentations use which version. |
| XM-OQ-020 Policy/standards evidence query | PASS WITH CONTROL | REQ/CFG/LCO granularity improves causal specificity; ARC-POLICY-EVID-001 remains mandatory to separate observation, interpretation and recommendation. |

**Regression:** 15/15 PASS.

## 4. Anti-Bureaucracy Attack
The v1.1 model was re-challenged against the strongest NO-BUILD: Archemedica becomes a manually maintained meta-QMS/ontology that costs more to reconcile than the siloed systems it claims to connect.

### 4.1 Result
**CONDITIONAL PASS — architecture can avoid duplicate bureaucracy only if sparse-by-default and integration-first rules are enforced in implementation.**

### 4.2 Controls Required in Persistence Build
1. Do not preload every regulation, clause, process, artifact or design object merely because it exists.
2. Materialize `REQ-*`, `LCO-*`, `CFG-*` and dependency records when decision/risk/change/applicability/reconstruction context requires them.
3. Permit external systems to remain authoritative systems of record; Archemedica stores identity, version, relevant relationship and decision-continuity evidence.
4. Generate provenance, audit, version and state evidence automatically from normal transactions wherever possible.
5. Reuse canonical facts and evidence across views; no separate device/pharma copies of the same product fact.
6. Measure manual metadata entry and reconciliation burden during pilot; failure to reduce burden remains a kill/narrow criterion.

## 5. New Adversarial Challenge — Over-Granularity Cascade
The correction itself creates a new possible failure: finer CFG/REQ/LCO objects could cause excessive reassessment cascades.

### Challenge
A minor supplier specification revision affects an LCO linked to several constituents/configurations and hundreds of requirements. A naive graph implementation could reopen every DER and obligation.

### Required Control
Propagation must require contextual materiality, dependency type, coverage confidence, effective interval and decision relevance. `POTENTIALLY_AFFECTED` must not become `REASSESSMENT_REQUIRED` automatically without governed transition criteria. False-cascade rate must be measured.

### Result
**DESIGN CONTROL REQUIRED, NOT ARCHITECTURE BLOCKER.** The existing DDG/DCA/EIG/DER semantics can support the control, but persistence requirements must explicitly encode it.

## 6. Policy/Regulatory-Science Fitness Check
The v1.1 model is materially more suitable for future regulatory-science analysis because it can distinguish:
- source versus granular requirement;
- applicability interpretation versus rule text;
- product/constituent versus configuration;
- manufacturing/design/process dependency versus product identity;
- sponsor implementation choice versus regulatory obligation;
- observed operational outcome versus policy recommendation.

This supports neutral empirical analysis but does not establish that Archemedica is currently suitable for policymaking, regulatory reliance, or standards-setting. Those uses would require independent data quality, representativeness, governance, methodology and validation controls beyond the current pilot.

## 7. Gate Disposition
**PASS — AUTHORIZE PERSISTENT SCHEMA/DATA-MODEL DESIGN, NOT PILOT RELEASE.**

The cross-modality canonical model v1.1 survives the corrective retest and full design regression. The next authorized step is the persistent logical/physical schema and transaction architecture. Implementation must preserve sparse integration, anti-false-cascade control, version lineage, regulatory applicability uncertainty, tenant isolation and No False Closure.

This PASS does not authorize claims of ISO conformity, GxP validation, Part 11 compliance, regulatory acceptance, clinical correctness, policy fitness, or production release.

## 8. Traceability Status
- XMOD-001 Product Configuration/Presentation: CLOSED BY DESIGN / RETEST PASS
- XMOD-002 Regulatory Requirement Granularity: CLOSED BY DESIGN / RETEST PASS
- XMOD-003 Manufacturing/Design/Process Context: CLOSED BY DESIGN / RETEST PASS
- XMOD-004 Over-Granularity Cascade Risk: OPEN CONTROL REQUIREMENT FOR PERSISTENCE BUILD

## 9. Change History
| Version | Date | Change | Status |
|---|---|---|---|
| 1.1 | 2026-09-01 | Executed five corrective retests and fifteen-scenario regression; opened over-granularity cascade control; authorized persistent schema design | CONTROLLED — PASS TO NEXT DESIGN GATE |

**END OF CONTROLLED REPORT**
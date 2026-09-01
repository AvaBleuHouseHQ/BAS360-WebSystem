# ARC-XMOD-VERIFY-001 — Cross-Modality Architecture Adversarial Verification Protocol

**Document ID:** ARC-XMOD-VERIFY-001  
**Version:** 1.0  
**Status:** CONTROLLED — DESIGN VERIFICATION PROTOCOL  
**System:** Archemedica / BAS360-WebSystem  
**Author/Document Owner:** Cassandra Harrison  
**Effective Date:** 2026-09-01  
**Design Under Test:** ARC-XMOD-MODEL-001 v1.0  
**Requirements:** ARC-PILOT-001-RTM v1.1  
**Integrated Controls:** ARC-SYS-HARDEN-001 v1.0

> **Verification purpose:** attempt to break the cross-modality canonical model before authorizing persistent implementation. A scenario passes only if the model preserves one decision/evidence spine while retaining real regulatory differences, uncertainty, constituent-specific controls and historical reconstruction.

## 1. Acceptance Rule
Persistent implementation remains unauthorized unless all critical architecture scenarios have a defined representational path and none requires a new siloed root database/module to preserve correctness.

A scenario may pass with `HUMAN_JUDGMENT_REQUIRED`, `UNKNOWN`, `PARTIAL` or an explicit hold. It fails if the model creates false closure, loses constituent/domain context, overwrites history, requires duplicate canonical facts, or suppresses applicable controls because another pathway is primary.

## 2. Mandatory Scenario Matrix

| ID | Attack | Expected Architecture Behavior | Critical Failure |
|---|---|---|---|
| XM-OQ-001 | Biologic dose amendment affects prefilled autoinjector use conditions | One `CHG/PCHG` propagates from protocol into RPS, biologic constituent, device constituent, usability/training/labeling/applicability and DER obligations | Device impact invisible because protocol belongs to biologic study |
| XM-OQ-002 | Biologic formulation viscosity changes without protocol amendment | Manufacturing/CMC change can reopen device compatibility, risk, evidence and clinical decision dependencies | Only protocol changes can trigger clinical/device reassessment |
| XM-OQ-003 | Companion-diagnostic threshold changes patient eligibility | Diagnostic performance, eligibility, statistics, treatment assignment and benefit/risk share one causal episode | Diagnostic change trapped in separate IVD module |
| XM-OQ-004 | Connected pump software update addresses cybersecurity vulnerability but changes UI workflow | Software/cybersecurity change propagates to use-related risk, training, device safety and treatment delivery | Cybersecurity treated as IT-only change |
| XM-OQ-005 | PMOA/classification uncertain | `RCL/RSA` preserve uncertainty, alternative pathways and accountable human determination; no pathway suppression | System forces one modality enum before evidence exists |
| XM-OQ-006 | Lead authority/pathway changes after regulatory determination | New classification supersedes prior state and reopens impacted requirements/obligations/DERs | Historical interpretation overwritten |
| XM-OQ-007 | FDA and EU treat same drug-device configuration through different legal structures | Same RPS/constituents support jurisdiction-specific applicability and obligations without duplicate product identity | Separate US and EU product roots required |
| XM-OQ-008 | Device constituent meets applicable design/usability controls while medicinal constituent follows pharmaceutical quality requirements | Both control families coexist and link to product-level decision | Lead medicinal pathway erases device controls |
| XM-OQ-009 | Supplier changes polymer/contact material in delivery device | Supplier/material/design/biocompatibility/compatibility/manufacturing/regulatory impacts link through one change | Supplier event cannot reach clinical/product decisions |
| XM-OQ-010 | False cross-domain edge says lab manual is HIGH impact | Reviewer can reject/reclassify while preserving original edge and reducing false cascade | False edge becomes permanent/high by automation |
| XM-OQ-011 | True statistical dependency missing from graph | Incomplete DCA blocks clean no-impact | No returned edge becomes `NO_IMPACT` |
| XM-OQ-012 | Public standard/source changes | Source version change can reopen RSA and dependent obligations without cross-tenant leakage | Public source joins tenant decision graphs indiscriminately |
| XM-OQ-013 | Same evidence supports drug and device controls | Canonical EVS reused with context-specific applicability; no duplicate evidence entry | Separate copies required per modality |
| XM-OQ-014 | Device malfunction and adverse drug event arise from same delivery failure | One signal episode can link device malfunction, dose exposure and clinical safety | Separate safety silos prevent common cause analysis |
| XM-OQ-015 | Human-factors result contradicts prior protocol-operability assumption | EIG conflict reopens DER/obligations while preserving original decision-time evidence | Device usability evidence cannot challenge clinical DER |
| XM-OQ-016 | Software model version influences dose recommendation in a combination system | MUSE version/provenance/context-of-use links to RPS, evidence, risk and DER with human oversight | AI/model record isolated from regulated product context |
| XM-OQ-017 | Regulation/standard appears irrelevant but applicability is unassessed | State remains `UNKNOWN/NOT_ASSESSED`; no silent does-not-apply | Missing assessment becomes negative conclusion |
| XM-OQ-018 | One constituent retired/replaced while product continues | Constituent lineage supersedes without deleting historical study/decision relationships | Old constituent disappears from reconstruction |
| XM-OQ-019 | Co-packaged product becomes cross-labeled configuration | Product topology/version change triggers applicability and labeling/quality reassessment | Combination type is static metadata |
| XM-OQ-020 | Policy query asks whether a requirement causes delays | System can distinguish observed evidence, denominator, missingness, jurisdiction and competing causes; no industry-wide claim without coverage | Query turns missing data into zero and correlation into causal policy claim |

## 3. Multi-Jurisdiction Stress Test
Use one representative RPS containing medicinal/biologic and device constituents. Model at least U.S. and EU jurisdiction contexts with different legal/regulatory structures while keeping a single product-system identity.

Pass requires:
- shared constituent/evidence identity where factually identical;
- jurisdiction-specific classification/applicability records;
- separate obligations where requirements differ;
- traceable common underlying change;
- no flattening of legal differences;
- no duplicate manual canonical metadata solely because jurisdiction differs.

## 4. Cross-Modal Risk Stress Test
Create one causal chain that begins as an engineering/device event and ends as a clinical safety consequence, and one chain that begins as a clinical/protocol change and creates device/manufacturing/usability obligations.

Pass requires the risk/dependency model to traverse both directions without privileged domain ownership.

## 5. Regulatory Change Stress Test
Version a regulation, guidance or standard source after a decision. The architecture must identify potentially affected RSA/DER/OBL relationships using source identity and validity, open a controlled reassessment episode, and preserve the historical decision-time rule basis.

A new source does not automatically invalidate the old decision; it creates an impact/reassessment question.

## 6. Anti-Bureaucracy Stress Test
Compare two modeling approaches for each scenario:

A. canonical Evidence Once, Project Many model;
B. siloed specialist-record duplication.

Record manual canonical metadata entries, number of duplicate facts, reconciliation steps and number of specialist systems that must be manually synchronized.

The cross-modality architecture fails the product test if it preserves correctness only by making Archemedica another manually maintained regulatory ontology/QMS.

## 7. Policy/Standards Integrity Stress Test
Construct an intentionally biased analytic question such as: “Prove siloed regulation causes combination-product delays.”

Pass requires Archemedica to refuse the premise as evidence, reformulate to a neutral observable question, preserve contrary/negative cases, define denominator and missingness, and separate observation from recommendation.

## 8. Required Verification Evidence
For every scenario preserve:
- test fixture identity/version;
- expected controlled objects/relationships;
- expected uncertainty/holds;
- prohibited clean states;
- before/after design representation;
- deviation where model cannot represent the case;
- corrective architecture change if required;
- retest result;
- residual risk;
- traceability to ARC-PILOT-001-RTM v1.1 requirement IDs.

## 9. Exit Criteria
Architecture may move to persistent implementation only when:

1. all XM-OQ-001 through XM-OQ-020 have representational designs;
2. no critical scenario requires independent modality root ontologies;
3. missing/uncertain applicability does not false-close;
4. cross-constituent risk/change propagation is explainable;
5. jurisdiction-specific differences remain explicit;
6. existing DER/EIG/DDG/hardening controls remain reusable;
7. evidence-once burden is lower than siloed duplication in the controlled fixtures;
8. policy-evidence integrity scenario passes;
9. unresolved architecture failures are either corrected/retested or formally block implementation.

## 10. Initial Status
**PROTOCOL APPROVED FOR DESIGN VERIFICATION — NOT EXECUTED. PERSISTENT IMPLEMENTATION REMAINS ON HOLD.**

## 11. Change History
| Version | Date | Change | Status |
|---|---|---|---|
| 1.0 | 2026-09-01 | Established 20-scenario cross-modality adversarial architecture verification protocol | CONTROLLED — DESIGN VERIFICATION |

**END OF CONTROLLED DOCUMENT**
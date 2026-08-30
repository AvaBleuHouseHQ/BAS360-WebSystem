# ARC-DMOC-001 — Archemedica Decision Memory & Outcome Calibration

**Document ID:** ARC-DMOC-001  
**Version:** 1.0  
**Status:** CONTROLLED — PILOT DESIGN BASELINE  
**System:** Archemedica  
**Document Type:** Decision Memory / Outcome Learning Governance Gate  
**Effective Date:** 2026-08-30  
**Author/Document Owner:** Cassandra Harrison  
**Classification:** Proprietary / Controlled  
**Governed By:** ARC-STD-001 v1.0  
**Evidence Registry:** ARC-EVID-REG-001 v1.0  
**Decision Contract:** ARC-DER-SCHEMA-001 v1.0  
**Dependency Contract:** ARC-DDG-SCHEMA-001 v1.0  
**Evidence Integrity:** ARC-EIG-SCHEMA-001 v1.0  
**Model Use Governance:** ARC-CMR-001 v1.0  
**Related Workflows:** ARC-PCDI-001 v1.0; ARC-RDRE-001 v1.0  
**Related ADR:** ADR-0009

> **Control statement:** DMOC preserves the basis of consequential decisions and links later observable outcomes back to those decisions for controlled reassessment and calibration. It is not a pooled sponsor-data learning system, causal inference engine, autonomous self-training loop, performance leaderboard, or mechanism for rewriting historical decisions.

## 1. Core Question

What did we decide, what did we know and assume at the time, what happened afterward, which outcome is legitimately attributable or relevant to evaluating the decision, what did the outcome falsify or support, and what—if anything—must be reassessed?

## 2. ADR-0009 Verdict

**Risk Tier:** 3  
**Disposition:** **PILOT — BUILD TENANT-ISOLATED DECISION MEMORY; CONSTRAIN OUTCOME CALIBRATION**

Decision Memory survives. Broad “learning from every sponsor outcome” does not.

The system shall first provide durable, tenant-controlled reconstruction and outcome linkage. Cross-customer pooling, autonomous model retraining, causal claims from observational outcomes, and global benchmarking are deferred unless separate evidence, rights, governance and validation gates later authorize them.

## 3. Decision Memory Object

DMOC references canonical DERs rather than copying their rationale into a competing store. A memory index may contain stable references, searchable metadata, dependency pointers and outcome links, but DER remains canonical for the historical decision basis.

Historical decision state is immutable. Later knowledge is appended as outcome/reassessment evidence and never back-written into “what was known then.”

## 4. Outcome Object

Every `OUT-*` record shall identify:
- outcome type;
- observation window;
- observed value/event/status;
- source/evidence reference;
- provenance;
- completeness;
- data-rights status;
- relationship to decision;
- attribution status;
- confounders/limitations;
- reviewer;
- whether the outcome supports, contradicts, limits, or is merely associated with the prior decision basis.

## 5. Attribution Boundary

DMOC shall distinguish:
- `TEMPORALLY_AFTER`;
- `ASSOCIATED_WITH_DECISION`;
- `PLAUSIBLY_INFORMATIVE`;
- `CONTRADICTS_ASSUMPTION`;
- `SUPPORTS_ASSUMPTION`;
- `CAUSAL_ATTRIBUTION_NOT_ESTABLISHED`;
- `CAUSAL_ATTRIBUTION_SUPPORTED_BY_CONTROLLED_METHOD`.

The default for ordinary post-decision outcomes is **not causal**.

A favorable trial/site/program outcome does not prove that the prior decision caused it. A poor outcome does not by itself prove the decision was wrong.

## 6. Outcome Classes

V1 may govern outcomes such as:
- protocol amendment implementation result;
- amendment cycle time;
- site burden/implementation failure;
- enrollment/retention observation;
- query/data-quality observation;
- safety operational signal;
- endpoint/data-readiness consequence;
- regulatory feedback/action;
- inspection/audit finding;
- vendor performance consequence;
- model-use performance observation;
- forecast/calibration observation;
- decision reversal/rework;
- timeline/budget consequence;
- other controlled outcome.

Clinical efficacy/safety conclusions require their own scientific/statistical basis and are not inferred from operational outcome records.

## 7. Calibration

Calibration is authorized only when the original decision contained a forecast, probability, threshold, classification, expected range, or other prospectively testable assertion.

Calibration compares the frozen historical prediction with an outcome measured under a defined window and method.

It shall not manufacture a retrospective probability from narrative rationale merely to score the decision.

## 8. Decision Quality vs Outcome Quality

DMOC explicitly separates:
- **process quality at decision time** — evidence, assumptions, alternatives, uncertainty, governance;
- **outcome observed later**;
- **calibration quality**, where prospectively testable;
- **causal attribution**, where methodologically justified.

A well-governed decision may have an unfavorable outcome under uncertainty. A poorly governed decision may get lucky.

No universal “decision score” is authorized in v1.0.

## 9. Reassessment Logic

Outcome records may trigger DDG reassessment candidates when they:
- falsify a material assumption;
- contradict relied-upon evidence;
- reveal model degradation;
- demonstrate implementation failure;
- expose a previously unknown dependency;
- contradict a forecast outside controlled tolerance;
- reveal a material safety/regulatory/quality concern.

Outcomes do not automatically invalidate DERs. Accountable humans disposition reassessment.

## 10. Tenant Isolation & Rights

Decision Memory is sponsor/customer-specific by default.

V1 requirements:
- tenant isolation;
- role-based access;
- customer-controlled retention;
- exportability;
- deletion/retention behavior according to controlled policy and legal/contractual obligations;
- no cross-tenant model training by default;
- no cross-customer benchmarking by default;
- no pooled proprietary decision/outcome dataset by default.

Any future aggregation requires separate authorization covering rights, de-identification where relevant, privacy, contractual use, scientific validity and customer expectations.

## 11. Learning Boundary

“Learning” in v1 means humans and governed workflows can inspect historical decisions/outcomes, identify recurrent failure patterns, recalibrate explicitly testable forecasts and create controlled reassessment evidence.

It does **not** mean the system silently changes rules, prompts, models, thresholds or recommendations based on accumulated outcomes.

Any automated adaptation requires a separately governed model/change-control process.

## 12. Anti-Goodhart Controls

DMOC shall not rank teams or individuals using crude outcome success rates. Metrics susceptible to gaming—cycle time, amendment count, query count, enrollment speed, budget variance—must retain context and must not become universal proxies for decision quality.

## 13. PCDI Integration

For protocol-change decisions, DMOC may link outcomes such as implementation delay, site retraining burden, unanticipated downstream artifact changes, repeated amendment, regulatory feedback, unresolved issue recurrence and post-implementation defects back to the PCDI DER.

This enables testing whether PCDI actually improves amendment integrity rather than merely generating packets.

## 14. RDRE Integration

RDRE outcomes may include stale-decision discoveries, false reassessment cascades, missed affected artifacts, human overrides, time-to-impact packet and source-maintenance burden. These outcomes test whether regulatory dependency memory adds value over feed + manual assessment.

## 15. CMR Integration

Model-use outcomes may test forecast calibration, COU mismatch, model disagreement, override frequency, performance degradation and unauthorized-use prevention. DMOC shall never infer model validation from favorable anecdotal outcomes.

## 16. Pilot Acceptance Scenarios

At minimum test:
1. good process / unfavorable outcome;
2. poor process / favorable outcome;
3. prospectively stated forecast with measurable outcome;
4. narrative decision with no valid calibration target;
5. outcome falsifies a material assumption;
6. outcome occurs after decision but causal relation is unsupported;
7. protocol amendment creates unanticipated site burden;
8. RDRE creates false-positive reassessment cascade;
9. model version forecast is materially miscalibrated;
10. outcome evidence is incomplete/stale;
11. customer requests export of decision memory;
12. cross-tenant aggregation attempt is blocked;
13. historical DER is superseded but preserved;
14. metric would reward gaming if used as decision score;
15. repeated decision pattern suggests improvement but evidence is insufficient for automated adaptation.

## 17. Pilot Metrics

Measure decision reconstruction time, percentage of consequential decisions with valid outcome links, percentage of outcomes with adequate provenance, inappropriate causal-attribution rate, reassessment precision, calibration coverage for prospectively testable predictions, user effort to capture outcomes, export/reconstruction completeness, cross-tenant isolation failures, and whether historical memory reduces repeated decision/rework burden.

No performance threshold is pre-claimed.

# Appendix A — ADR-0009 Tier-3 Adversarial Review

1. **Problem — PASS:** organizations lose decision rationale and rarely connect later outcomes back to the basis that produced the decision.
2. **Existing solutions — MATERIAL:** QMS, audit trails, BI, data warehouses and retrospective reviews preserve pieces.
3. **Commodity — KILL GENERIC DATA WAREHOUSE:** storage/search/history alone are not moat.
4. **Moat — QUALIFIED:** decision-basis + dependency + outcome linkage + controlled reassessment may deepen the surviving decision-integrity spine.
5. **Integration — PASS:** keep canonical data in source systems; index/link rather than duplicate everything.
6. **Evidence — PASS FOR ARCHITECTURAL NEED, NOT PMF:** prior gates need outcomes to test their own value; commercial demand remains to be proven.
7. **Counter-evidence — STRONG:** outcome capture is notoriously incomplete; retrospective attribution is biased; users may not maintain it.
8. **Regulatory — CONTROLLED:** historical integrity, data rights, retention and auditability matter; no compliance claim.
9. **Failure modes — HIGH:** hindsight bias, causal laundering, Goodhart metrics, selective outcome capture, survivor bias, cross-tenant leakage, silent self-training, rewriting history.
10. **Customer — PROVISIONAL:** value strongest where organizations make repeated consequential decisions; buying evidence incomplete.
11. **Workflow — CONDITIONAL:** outcome capture must arise from existing workflow events where possible, not another manual reporting burden.
12. **Dependencies — HIGH:** DER/DDG/EIG/PCDI/RDRE/CMR semantics must remain stable.
13. **Reversibility — PASS:** outcome linkage can be retained even if analytics/calibration engines change.
14. **Data rights — CRITICAL:** proprietary sponsor outcomes cannot be assumed poolable.
15. **Security/privacy — TIER 3:** decision memory reveals strategy and performance; strict tenant/role controls required.
16. **Validation cost — MODERATE/HIGH:** calibration methods require prospectively defined targets and windows; causal analysis requires separate methods.
17. **Simpler alternative — CRITICAL:** DER archive + retrospective meeting may be enough for low-volume teams.
18. **Strongest NO-BUILD:** DMOC becomes an expensive graveyard of incomplete outcomes and misleading retrospective scores, while cross-customer “learning” creates unacceptable IP/privacy risk.
19. **Rebuttal:** constrain v1 to tenant-isolated memory, event-driven outcome capture, explicit attribution boundaries, prospective calibration only, and reassessment—not pooled learning.
20. **Final disposition:** **PILOT — BUILD TENANT-ISOLATED DECISION MEMORY; CONSTRAIN OUTCOME CALIBRATION.**

## Falsification Criteria

Narrow or kill DMOC if outcome capture requires sustained manual effort; fewer than a useful share of consequential decisions can obtain interpretable outcomes; users cannot distinguish association from causation; historical memory does not reduce reconstruction/rework; customer retention/export requirements make the architecture impractical; or a simple DER archive/retrospective process delivers equivalent value at materially lower burden.

## Reassessment Triggers

Reassess if customers request cross-tenant benchmarking, automated learning, causal analytics, pooled model training, new retention regimes, privacy constraints, outcome capture becomes burdensome, or calibration results are routinely misinterpreted as decision-quality scores.

## QC/QA Gate

Before pilot release: DER remains canonical; historical state cannot be rewritten; outcome provenance is required; attribution status is explicit; no default causal claim; calibration only for prospectively testable assertions; no universal decision score; cross-tenant pooling disabled; outcome-triggered DDG paths explainable; automated self-training disabled; export/retention behavior controlled.

## Attestation Boundary

This document defines decision-memory and outcome-calibration architecture. It does not establish causal validity, scientific validity, clinical benefit, regulatory compliance, model validation, sponsor performance, or correctness of historical decisions.

## Change History

| Version | Date | Change | Disposition |
|---|---|---|---|
| 1.0 | 2026-08-30 | Initial DMOC and ADR-0009 Tier-3 review | PILOT — BUILD TENANT-ISOLATED DECISION MEMORY |

**END OF CONTROLLED DOCUMENT**
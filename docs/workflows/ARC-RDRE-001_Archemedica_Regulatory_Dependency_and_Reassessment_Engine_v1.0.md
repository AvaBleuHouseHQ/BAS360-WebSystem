# ARC-RDRE-001 - Archemedica Regulatory Dependency & Reassessment Engine

**Document ID:** ARC-RDRE-001  
**Version:** 1.0  
**Status:** CONTROLLED - PILOT DESIGN BASELINE  
**System:** Archemedica  
**Document Type:** Regulatory Dependency / Reassessment Workflow Gate  
**Effective Date:** 2026-08-30  
**Author/Document Owner:** Cassandra Harrison  
**Classification:** Proprietary / Controlled  
**Governed By:** ARC-STD-001 v1.0  
**Evidence Registry:** ARC-EVID-REG-001 v1.0  
**Evidence Integrity Contract:** ARC-EIG-SCHEMA-001 v1.0  
**Decision Contract:** ARC-DER-SCHEMA-001 v1.0  
**Dependency Contract:** ARC-DDG-SCHEMA-001 v1.0  
**Related Workflow:** ARC-PCDI-001 v1.0  
**Related ADR:** ADR-0007  
**Machine-Readable Contract:** `schemas/regulatory-dependency-reassessment-engine/ARC-RDRE-001_Regulatory_Dependency_and_Reassessment_Engine.schema.json`

> **Control statement:** RDRE is a governed reassessment engine for controlled regulatory source/version changes. It is not a regulatory-news monitor, legal-opinion generator, compliance system, submission engine, or autonomous regulatory decision-maker.

## 1. Purpose

RDRE answers: **A controlled regulatory source or source version changed. Which active regulatory interpretations, rules, DERs, assumptions, and controlled artifacts may no longer be supportable under their recorded basis; what reassessment is required; who must dispose it; and what is superseded or closed?**

It provides a narrow chain:

`Controlled regulatory source/version change -> applicability/change assessment -> affected interpretations/rules -> DDG impact radius -> affected active DERs/artifacts -> reassessment obligation -> accountable human disposition -> supersession/closure`

RDRE does not decide what regulators will accept. It preserves regulatory judgment as a human accountable act.

## 2. ADR-0007 Verdict

**Risk Tier:** 3  
**Disposition:** **PILOT - BUILD CONTROLLED MVP, DO NOT GENERALIZE INTO REGULATORY INTELLIGENCE**

RDRE survives Tier-3 review only as a controlled, canonical-ingestion and reassessment workflow. It does not survive as a broad regulatory monitoring product because regulatory intelligence feeds, law-firm alerts, authority mailing lists, QMS workflows, and manual impact assessments already exist.

The pilot hypothesis is narrower:

> **Versioned regulatory decision memory plus DDG-backed impact radius must reduce missed stale interpretations and reconstruction burden more than a regulatory intelligence feed plus disciplined manual impact assessment.**

This is a falsifiable operational claim, not a compliance claim.

## 3. Authorized Scope

RDRE v1.0 is authorized only for:

- canonical ingestion of a known regulatory source/version change;
- source authority, status, jurisdiction, effective-date, and supersession screening;
- controlled assessment of whether existing regulatory interpretations/rules may be affected;
- DDG impact-radius analysis using explicit dependencies;
- identification of affected active DERs, PCDI packets, EIG assessments, and controlled artifacts;
- creation of reassessment obligations where justified;
- accountable human disposition;
- controlled supersession, reaffirmation, closure, or escalation.

## 4. Explicit Non-Scope

RDRE v1.0 does not:

- monitor the internet for regulatory news;
- decide whether a news item is canonically authoritative;
- scrape agencies or subscribe to feeds as a regulated control;
- replace regulatory affairs, legal counsel, quality, clinical, safety, or statistical judgment;
- claim GxP validation, 21 CFR Part 11 compliance, legal sufficiency, regulator acceptance, or submission readiness;
- generate binding interpretations without human approval;
- automatically invalidate DERs or controlled artifacts;
- create a universal jurisdiction engine;
- resolve conflicts between authorities by algorithm;
- handle emergency subject-safety actions as a delay-inducing gate.

## 5. Controlled Workflow

### Stage 1 - Canonical Source Identity

Resolve the regulatory source as a controlled evidence/regulatory-source record. Required identity includes authority, jurisdiction, title, document type, status, source URL or archive reference, publication date, effective date where available, version identifier, supersession relationship, retrieval/inspection timestamp, and hash or archive reference when captured.

News summaries, vendor alerts, blog posts, newsletters, conference commentary, and secondary summaries may be registered as signals or supporting context, but they are not canonical regulatory sources unless independently promoted under ARC-EVID-REG-001.

HOLD if source identity, authority, or current/superseded status cannot be established.

### Stage 2 - Source Status and Authority Classification

Classify the source as one of:

- `BINDING_LAW_OR_REGULATION`
- `FINAL_GUIDANCE_NONBINDING`
- `DRAFT_GUIDANCE`
- `FINAL_STANDARD`
- `DRAFT_STANDARD`
- `AGENCY_NOTICE`
- `Q_AND_A_OR_INTERPRETIVE`
- `ENFORCEMENT_OR_INSPECTION_SIGNAL`
- `SECONDARY_SIGNAL`
- `WITHDRAWN`
- `SUPERSEDED`
- `UNKNOWN`

The source status must remain visible through reassessment. A draft or nonbinding source may still matter, but its force and limits cannot be laundered into a binding obligation.

### Stage 3 - Change Assessment

Create atomic `RCHG-*` records for material source changes. Each record captures changed location, prior text or prior interpretation basis where available, new text or new source basis, change class, effective timing, affected topic, and materiality.

Authorized change classes:

- `NEW_SOURCE`
- `TEXT_CHANGED`
- `STATUS_CHANGED`
- `EFFECTIVE_DATE_CHANGED`
- `SUPERSESSION`
- `WITHDRAWAL`
- `SCOPE_CHANGED`
- `INTERPRETATION_CHANGED`
- `CONFLICT_IDENTIFIED`
- `CLARIFICATION`
- `CORRECTION`
- `OTHER`

A document publication is not automatically a material regulatory change. A small correction may be material if it affects a high-consequence interpretation.

### Stage 4 - Applicability Assessment

Assess applicability by jurisdiction, authority, product/study type, development phase, study status, investigational product/device/biologic context where relevant, population, site geography, submission pathway, and effective date.

Allowed applicability outcomes:

- `APPLICABLE`
- `POTENTIALLY_APPLICABLE`
- `NOT_APPLICABLE`
- `OUT_OF_SCOPE`
- `HUMAN_JUDGMENT_REQUIRED`
- `INSUFFICIENT_INFORMATION`

`NOT_APPLICABLE` requires rationale. `HUMAN_JUDGMENT_REQUIRED` is not a failure; it is a controlled stop against false authority.

### Stage 5 - Affected Interpretation and Rule Review

Identify affected regulatory interpretations/rules that cite, depend on, limit, or were derived from the changed source version. Each interpretation/rule must preserve:

- source basis and version used;
- interpretation owner;
- applicable jurisdictions and contexts;
- binding/nonbinding/draft status;
- effective-date assumptions;
- related EIG regulatory-claim assessment;
- related DER(s);
- supersession status.

RDRE may flag an interpretation as potentially stale, conflicted, outside context, or requiring human judgment. It cannot approve a new regulatory interpretation without accountable human disposition.

### Stage 6 - EIG Review for Regulatory Claims

Material regulatory claims pass through ARC-EIG-SCHEMA-001. EIG must distinguish source existence, source authority/currentness, interpreted requirement, jurisdiction/applicability, product/workflow relevance, and whether a statement is alignment, expectation, recommendation, requirement, or draft recommendation.

If EIG returns `HOLD_FOR_HUMAN_REVIEW`, `FAIL_STALE`, `FAIL_CONFLICTED`, `FAIL_OUTSIDE_CONTEXT`, `FAIL_UNSUPPORTED`, or `FAIL_BROKEN_PROVENANCE`, RDRE cannot silently close the reassessment as no action.

### Stage 7 - DDG Impact Radius

Create a DDG `REGULATORY_SOURCE_CHANGED` or related `ChangeEvent` only after canonical source identity and change assessment are established. Query explicit active relationships, especially:

- `DECISION_GOVERNED_BY_REGULATORY_SOURCE`
- `DECISION_DEPENDS_ON_EVIDENCE`
- `DECISION_LIMITED_BY_EVIDENCE`
- `DECISION_ASSUMES`
- `DECISION_AFFECTS_ARTIFACT`
- `DECISION_AFFECTS_DECISION`
- `EVIDENCE_SUPERSEDES_EVIDENCE`

Every surfaced DER/artifact must include an explainable path. No implicit regulatory dependency is authorized as canonical in v1.0.

### Stage 8 - Reassessment Obligation

For each candidate impact, decide whether reassessment is mandatory, advisory, not justified, or requires human triage.

Allowed obligation statuses:

- `REASSESSMENT_REQUIRED`
- `REASSESSMENT_ADVISORY`
- `HUMAN_TRIAGE_REQUIRED`
- `NO_ACTION_JUSTIFIED`
- `DUPLICATE_OF_EXISTING_REASSESSMENT`
- `CLOSED_NO_LONGER_ACTIVE`

Mandatory reassessment normally applies when an active DER or artifact has a high/critical dependency on a regulatory source version that is superseded, withdrawn, materially changed, newly conflicted, or determined outside its recorded context. Moderate and low dependencies require rule/SME review rather than count-based cascade.

### Stage 9 - Affected DERs and Controlled Artifacts

Affected objects may include DERs, PCDI packets, EIG assessments, protocols, SAPs, DMPs, ICFs, IBs, monitoring plans, risk registers, SOPs, submission plans, site/vendor instructions, training, regulatory trackers, and other controlled artifacts.

RDRE does not edit historical DER rationale. It creates reassessment events, successor DER requirements, artifact review tasks, or documented reaffirmations.

### Stage 10 - Accountable Human Disposition

A qualified human owner records one of:

- `REAFFIRM_NO_CHANGE`
- `UPDATE_INTERPRETATION`
- `SUPERSEDE_INTERPRETATION`
- `CREATE_SUCCESSOR_DER`
- `UPDATE_CONTROLLED_ARTIFACT`
- `CLOSE_NO_ACTION`
- `ESCALATE_TO_REGULATORY_LEGAL_QA`
- `DEFER_PENDING_AUTHORITY_OR_EVIDENCE`
- `WITHDRAW_PRIOR_POSITION`

Disposition must include rationale, reviewed source versions, effective-date logic, applicability rationale, unresolved conflicts, residual risk, required actions, and owner.

### Stage 11 - Supersession and Closure

If an interpretation/rule changes, preserve the prior version and create a successor. Link `supersedes` and `superseded_by`. If the prior interpretation remains valid for some jurisdictions or dates, narrow its context rather than globally superseding it.

Closure requires evidence that all required DER/artifact reassessments are complete, duplicated, not applicable, or consciously deferred by an accountable owner.

### Stage 12 - Emergency Safety and Immediate Hazard Boundary

RDRE must not delay changes intended to protect subjects or eliminate an apparent immediate hazard. If a regulatory source change relates to urgent safety action, RDRE may create retrospective reassessment, documentation, notification, and artifact-update obligations, but it cannot require completion before a qualified human-authorized emergency safety action proceeds.

PCDI's immediate-hazard pathway governs protocol-change execution. RDRE supplies source/version and reassessment context only.

## 6. Integration Contract

### ARC-EVID-REG-001

Regulatory sources, secondary signals, supersession records, and inspected versions are registered as evidence with `Supports` and `Does Not Establish`. Registration does not equal verification, authority, applicability, or compliance.

### ARC-EIG-SCHEMA-001

RDRE uses EIG for regulatory claim supportability. EIG failure, staleness, conflict, or human-review status remains visible and can trigger DDG reassessment.

### ARC-DER-SCHEMA-001

RDRE creates or updates reassessment events on affected DERs. DER lifecycle rules govern whether the decision is reaffirmed, moved to `REASSESSMENT_REQUIRED`, or superseded by a successor DER.

### ARC-DDG-SCHEMA-001

RDRE uses DDG as an impact-radius index over canonical records. DDG output is a candidate set with explainable paths, not a regulatory conclusion.

### ARC-PCDI-001

PCDI consumes RDRE outputs when protocol changes depend on regulatory source changes, interpretation changes, effective-date changes, or jurisdiction applicability. PCDI immediate-hazard routing remains distinct and may generate post-implementation RDRE reassessment obligations.

## 7. Failure Modes and Controls

| Failure Mode | Control |
|---|---|
| Secondary alert treated as authority | Canonical ingestion gate; `SECONDARY_SIGNAL` cannot drive mandatory reassessment alone |
| Draft/nonbinding source treated as binding | Source status field required and visible in every interpretation |
| Effective date assumed global | Jurisdiction/context/effective-date assessment required |
| Withdrawn or superseded guidance remains active | Supersession screening and DDG `REGULATORY_SOURCE_CHANGED` event |
| Conflicting authorities hidden | Conflict status and escalation disposition required |
| False dependency cascade | Explicit DDG paths, materiality thresholds, bounded traversal, no count-only escalation |
| Missed dependency | Pilot test sets with known impacted/non-impacted DERs/artifacts |
| Human judgment laundered as system output | Accountable disposition separate from system candidate |
| Maintenance burden exceeds value | Pilot metrics compare against feed plus manual assessment |
| Emergency safety action delayed | Immediate safety boundary; retrospective reassessment only where needed |

## 8. Pilot Acceptance Scenarios

Test at minimum:

1. final guidance supersedes draft guidance used by an active interpretation;
2. draft guidance is published but no active DER depends on it;
3. nonbinding guidance updates language that affects an active protocol amendment interpretation;
4. binding regulation effective date changes for one jurisdiction only;
5. agency withdraws a guidance cited by a high-materiality DER;
6. secondary regulatory-news alert is received without canonical source capture;
7. two authorities conflict across jurisdictions;
8. source is final but study type is outside applicability;
9. source change affects PCDI regulatory applicability but not protocol implementation readiness;
10. urgent safety/protocol change proceeds through PCDI immediate-hazard path and RDRE creates follow-up reassessment;
11. many low-materiality edges would cascade without thresholds;
12. prior interpretation remains valid for legacy effective dates but not future amendments.

## 9. Pilot Metrics

Measure:

- true affected-DER recall using curated scenarios;
- false reassessment cascade rate;
- missed artifact rate;
- percentage of candidate impacts with explainable DDG paths;
- percentage of dispositions requiring human override or reclassification;
- time to regulatory impact packet;
- time to close reassessment obligations;
- maintenance time per controlled regulatory source;
- proportion of secondary alerts rejected or deferred pending canonical source;
- value compared with regulatory intelligence feed plus manual impact assessment;
- user bypass rate;
- number of decisions/artifacts found stale that manual process missed.

No threshold is pre-claimed.

# Appendix A - ADR-0007 Tier-3 Adversarial Review

## A1. Problem Test

**PASS, NARROWED.** Regulatory source versions and interpretations can remain embedded in decisions after source status, language, effective dates, or applicability change. Manual reconstruction is difficult when decisions, protocol changes, artifacts, and interpretations are dispersed.

## A2. Existing-Solution Test

**MATERIAL CHALLENGE.** Regulatory intelligence feeds, agency notifications, legal/regulatory summaries, QMS change controls, spreadsheets, and manual impact assessments already exist. RDRE cannot win as an alert feed.

## A3. Commodity Test

**FAIL AS NEWS/MONITORING MOAT.** Monitoring, source feeds, and keyword alerts are commodity or vendor-served. Do not build broad monitoring in v1.0.

## A4. Moat Test

**QUALIFIED PASS.** Potential value lies in controlled regulatory interpretation versioning, dependency-aware reassessment, explicit source/effective-date/applicability context, and linkage to DER/DDG/PCDI artifacts.

## A5. Integration Test

**INTEGRATE SIGNALS; BUILD CONTROLLED SEMANTICS.** Consume external feeds or manual signals later if needed, but canonical ingestion and reassessment semantics remain Archemedica-controlled.

## A6. Evidence Test

**PASS FOR DESIGN NEED, NOT PMF.** ARC-STD-001, ARC-EVID-REG-001, ARC-EIG-SCHEMA-001, ARC-DER-SCHEMA-001, ARC-DDG-SCHEMA-001, and ARC-PCDI-001 establish internal architectural need for regulatory reassessment semantics. They do not establish customer demand or compliance.

## A7. Counter-Evidence Test

**CREDIBLE.** A disciplined regulatory team may already run effective manual impact assessment from trusted feeds. RDRE could create costly dependency upkeep, over-alerting, and false confidence.

## A8. Regulatory Test

**PASS WITH HARD BOUNDARY.** RDRE handles regulatory-source dependency and reassessment records only. It does not claim legal interpretation authority, compliance, validation, or regulator acceptance.

## A9. Failure-Mode Test

**PASS AFTER CONTROLS.** Key risks are wrong source authority, draft/final confusion, binding/nonbinding laundering, bad effective dates, wrong jurisdiction, false cascades, missed stale artifacts, conflict suppression, and delayed safety action. Controls are embedded in required fields, EIG, DDG explainability, human disposition, and emergency boundary.

## A10. Customer Test

**PROVISIONAL.** Likely users are regulatory affairs, quality, clinical operations, medical/safety, and study owners, but direct buying/adoption evidence remains incomplete.

## A11. Workflow Test

**CONDITIONAL PASS.** RDRE must produce a useful regulatory impact packet and reassessment queue. If users still do full manual reconstruction, it fails.

## A12. Dependency Test

**HIGH.** RDRE depends on evidence registry quality, explicit DDG edges, DER lifecycle controls, EIG regulatory-claim assessment, and PCDI artifact mappings. Poor upkeep will defeat it.

## A13. Reversibility Test

**PASS.** Records and schemas are vendor-neutral. External feed providers and graph infrastructure must remain replaceable.

## A14. Data-Rights Test

**CONTROL REQUIRED.** Regulatory sources may be public, licensed, archived, or internal legal analysis. RDRE must preserve rights and source restrictions.

## A15. Security/Privacy Test

**TIER-3 CONCERN.** Regulatory impact results can reveal confidential development strategy. Tenant and role authorization must apply to sources, interpretations, edges, DERs, and traversal results.

## A16. Validation-Cost Test

**PHASED.** Automated reassessment requires false-positive/false-negative characterization. v1.0 authorizes deterministic candidate generation plus human disposition, not autonomous closure.

## A17. Simpler-Alternative Test

**CRITICAL.** A regulatory intelligence feed plus manual impact checklist is the reference competitor. RDRE must beat it on missed stale decisions, reconstruction time, explainability, and maintenance burden.

## A18. Strongest NO-BUILD Case

RDRE may become a fragile regulatory metadata treadmill. Regulatory staff still need to read sources and make judgments, feeds already tell teams what changed, and maintaining source/version/applicability/DDG links may cost more than manual assessment. If false cascades are frequent, teams will ignore it; if the system appears authoritative, it may create worse risk than spreadsheets.

## A19. Evidence-Based Rebuttal

The design removes monitoring/news from v1.0, preserves source status and effective-date uncertainty, requires EIG supportability for regulatory claims, uses DDG only for explainable candidate impact, and requires accountable human disposition. The remaining value claim is measurable: persistent regulatory decision memory should reduce rediscovery and stale-decision risk.

## A20. Final Disposition

**PILOT - BUILD CONTROLLED MVP, DO NOT GENERALIZE INTO REGULATORY INTELLIGENCE.**

## Falsification Criteria

Kill or narrow RDRE if regulatory intelligence feeds plus manual impact assessment identify the same affected decisions/artifacts with lower burden; canonical ingestion takes longer than manual triage without reducing missed impacts; false cascades remain high; required DDG edges are too costly to maintain; regulatory staff routinely redo applicability analysis from scratch; source status/effective-date logic proves too jurisdiction-specific for the v1.0 model; or users bypass RDRE as paperwork.

## Reassessment Triggers

Reassess RDRE if source-authority classifications change, major jurisdictional regulatory frameworks shift, PCDI regulatory applicability needs exceed v1.0, EIG regulatory-claim statuses produce frequent holds, DDG path precision is poor, customer evidence favors a different wedge, emergency safety workflows are slowed, or maintenance burden exceeds measured benefit.

## QC/QA Release Gate

Before pilot release: canonical source identity resolves; source status is visible; draft/final/binding/nonbinding fields are required; effective-date assumptions are explicit; secondary signals cannot create mandatory reassessment alone; DDG paths explain every affected object; no automatic invalidation occurs; EIG failures remain blocking or escalated; human disposition is mandatory; supersession preserves prior versions; emergency safety path is not delayed; tenant authorization applies across traversal results.

## Attestation Boundary

This document defines a controlled workflow design and machine-readable contract. It does not establish implementation, legal sufficiency, regulatory compliance, GxP validation, Part 11 compliance, sponsor adoption, regulator acceptance, submission readiness, or correctness of any regulatory interpretation.

## Change History

| Version | Date | Change | Disposition |
|---|---|---|---|
| 1.0 | 2026-08-30 | Initial RDRE workflow and ADR-0007 Tier-3 review | PILOT - BUILD CONTROLLED MVP |

**END OF CONTROLLED DOCUMENT**
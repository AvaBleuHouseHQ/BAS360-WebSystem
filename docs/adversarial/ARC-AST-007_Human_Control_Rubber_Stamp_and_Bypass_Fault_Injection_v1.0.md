# ARC-AST-007 — Human Control, Rubber-Stamp & Bypass Fault Injection

**Document ID:** ARC-AST-007  
**Version:** 1.0  
**Status:** CONTROLLED — SYSTEM-LEVEL ADVERSARIAL FINDING  
**System:** Archemedica  
**Effective Date:** 2026-08-30  
**Author/Document Owner:** Cassandra Harrison  
**Governed By:** ARC-STD-001 v1.0  
**Primary Affected Artifacts:** ARC-DER-SCHEMA-001; ARC-EIG-SCHEMA-001; ARC-PCDI-001; ARC-RDRE-001; ARC-CMR-001  
**Disposition:** FAIL — REPAIRABLE; HUMAN-IN-THE-LOOP MUST BE EVIDENCED, NOT ASSUMED

## 1. Fault Injection

Injected human-control failures:
1. reviewers approve prepopulated DER/EIG fields without opening material evidence;
2. system recommendation anchors the reviewer and the human repeats it verbatim;
3. reviewer enters generic override text such as “clinical judgment” with no evidence basis;
4. required review is delegated to a user with insufficient domain scope;
5. repeated false-positive alerts cause users to bypass or bulk-clear obligations;
6. a senior approver accepts all prior reviewer conclusions without independently addressing unresolved conflict;
7. users move consequential discussion into email/meetings and complete Archemedica afterward as documentation theater;
8. an emergency path becomes a convenient shortcut for ordinary work.

## 2. Failure Observed

The architecture correctly requires accountable humans, but the existence of a human approval field does not establish meaningful human oversight. Under workload, authority pressure or automation bias, human gates can become ceremonial.

This is a central threat because Archemedica could make weak oversight look stronger than it really was.

## 3. Required Repair — Evidence of Review

For HIGH/CRITICAL or materially conflicted decisions, the system should capture review evidence proportionate to risk, such as:
- material evidence opened/inspected references or explicit acknowledgment of unavailable evidence;
- reviewer-specific unresolved issues addressed;
- independent rationale where the reviewer disagrees or where mandatory independence applies;
- conflict/limitation acknowledgment;
- role/scope qualification check;
- time/order metadata sufficient to identify impossible or obviously perfunctory review patterns;
- explicit basis for override/deviation;
- emergency-path rationale and retrospective confirmation.

The system must not use surveillance-like keystroke or reading-time metrics as proof of cognition. Review evidence supports process integrity; it cannot prove thought quality.

## 4. Anti-Anchoring Controls

For selected Tier-3 decisions, evaluate blinded or staged review patterns where appropriate:
- human assessment before system recommendation is revealed;
- independent SME review of specified high-risk dimensions;
- system recommendation shown with limitations/counter-evidence adjacent;
- no default-select approval buttons for consequential dispositions.

These controls are risk-based, not mandatory for every workflow.

## 5. Override Quality

An override must identify what is being overridden, why, supporting/limiting evidence, residual risk and accountable owner. Generic rationale may be accepted only for low-risk cases; for high-consequence uses it triggers `INSUFFICIENT_OVERRIDE_BASIS`.

Human authority cannot convert failed evidence into supported evidence. It may decide to proceed under uncertainty only when that uncertainty and responsibility are explicit.

## 6. Bypass Detection Without Punitive Metrics

Measure workflow health using aggregate signals:
- rate of obligations closed without evidence;
- repeated identical rationales;
- bulk-clear behavior;
- side-document reliance discovered in QC;
- emergency-route frequency;
- user-reported burden;
- independent QC disagreement rate.

Metrics are diagnostic and must not become crude individual performance scores.

## 7. Verification Tests

1. reviewer approves without addressing material conflict;
2. model/system recommendation creates anchoring disagreement in staged review;
3. unqualified role attempts required disposition;
4. generic override for HIGH consequence is blocked/escalated;
5. bulk-clear event creates QC signal;
6. side-document contains real rationale while DER is post hoc;
7. emergency path used without qualifying basis;
8. independent reviewer can disagree without system forcing consensus.

## 8. Revised System Constraint

“Human in the loop” is not an adequate control statement. Archemedica must demonstrate that required human judgment occurred at the right point, under the right authority, with material evidence/conflict visible, while avoiding false claims that software can prove genuine cognition.

**END OF CONTROLLED DOCUMENT**
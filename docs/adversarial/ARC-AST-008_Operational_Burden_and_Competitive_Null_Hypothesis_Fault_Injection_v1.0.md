# ARC-AST-008 — Operational Burden & Competitive Null-Hypothesis Fault Injection

**Document ID:** ARC-AST-008  
**Version:** 1.0  
**Status:** CONTROLLED — SYSTEM-LEVEL ADVERSARIAL FINDING  
**System:** Archemedica  
**Effective Date:** 2026-08-30  
**Author/Document Owner:** Cassandra Harrison  
**Governed By:** ARC-STD-001 v1.0  
**Primary Affected Artifacts:** Entire Archemedica decision-integrity spine  
**Disposition:** CONDITIONAL FAIL — PRODUCT VALUE NOT ESTABLISHED UNTIL MAINTENANCE BURDEN IS BEATEN

## 1. Null Hypothesis

Assume a disciplined sponsor already has:
- Veeva/eTMF/QMS/RIM or equivalent controlled-document systems;
- Medidata/EDC/CTMS or equivalent study systems;
- MLOps/model registry where relevant;
- regulatory intelligence feeds;
- SOPs/checklists/change control;
- experienced cross-functional humans;
- BI/data warehouse/search.

Null hypothesis:

> Archemedica adds more structured governance work than the risk/reconstruction burden it removes, and therefore becomes a high-cost reconciliation layer rather than a product customers willingly maintain.

## 2. Workload Walk

A single consequential protocol amendment was walked through the current architecture.

Potential objects/activities include evidence records, EIG claims, DER, assumptions, alternatives, DDG edges/materiality, PCDI atomic changes and impact dimensions, regulatory applicability/RDRE links, model-use records where applicable, reassessment triggers, causal episode tracking, coverage assurance, implementation readiness, post-implementation evidence, outcomes and audit events.

If users must manually populate most of these independently, the design fails operationally even if every object is logically sound.

## 3. Failure Observed

The architecture currently has enough distinct governed concepts that naïve implementation would create duplicate entry and reconciliation burden.

The system survives only if most structure is generated from existing work and human interaction rather than completed as separate forms.

This is the first test where the correct answer is not “add another control.” Adding controls can make the problem worse.

## 4. Required Repair — Evidence Once, Project Many

Adopt a strict anti-duplication architecture:
- canonical facts entered/ingested once;
- derived views project the same canonical data into EIG, DER, PCDI, RDRE, DDG and DMOC contexts;
- dependency edges generated from explicit references already captured in workflow wherever possible;
- coverage checks arise from workflow scope/templates rather than separate graph-maintenance forms;
- causal episode IDs propagate automatically;
- state transitions emit audit events automatically;
- controlled artifacts remain in source systems where appropriate;
- users review exceptions, uncertainty and material impacts rather than retyping metadata.

## 5. Human Work Budget

Every additional mandatory field/control must identify:
1. what decision risk it reduces;
2. whether the value can be derived automatically from existing canonical data;
3. which role is best positioned to supply it;
4. how often it is expected to change;
5. what happens if it is missing;
6. whether an existing system already owns it.

If no defensible answer exists, remove or defer the field/control.

## 6. Reference Competitor Test

PCDI/RDRE/CMR/DMOC pilots must compare against strong baseline processes, not dysfunctional strawmen.

Success must show material improvement in some combination of:
- missed-impact reduction;
- reconstruction time;
- stale-decision detection;
- implementation defect reduction;
- reassessment precision;
- audit/inspection response effort;
- cross-functional handoff quality;
- decision rework;
- user confidence with calibrated uncertainty;
while maintaining acceptable cycle time and upkeep burden.

## 7. Kill Criteria

Narrow or kill Archemedica as an integrated operating layer if:
- manual maintenance remains comparable to performing the underlying impact assessment;
- users maintain shadow spreadsheets/emails as the true workflow;
- graph/metadata upkeep requires dedicated administrators for small/medium sponsors;
- pilots cannot beat a disciplined checklist + existing systems on consequential outcomes/reconstruction;
- system-generated alerts are routinely ignored;
- customers value only isolated features that incumbents can easily replicate;
- the decision-integrity layer cannot operate primarily from integrations and exception-focused review.

## 8. Surviving Product Thesis

What survives this attack is not “more governance.”

The surviving thesis is:

> Archemedica should make existing clinical-development work remember its evidence, dependencies, uncertainty, accountable decision and later changes automatically enough that humans spend less time reconstructing decisions and more time resolving the few places where judgment is actually required.

If implementation violates that sentence, the product has drifted from its defensible purpose.

## 9. Revised System Constraint

No new core object, field, workflow or engine enters Archemedica solely because it improves theoretical completeness. It must earn its operational cost against the reference alternative.

**END OF CONTROLLED DOCUMENT**
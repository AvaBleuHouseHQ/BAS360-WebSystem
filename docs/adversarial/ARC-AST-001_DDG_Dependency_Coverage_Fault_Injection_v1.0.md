# ARC-AST-001 — DDG Dependency Coverage Fault Injection

**Document ID:** ARC-AST-001  
**Version:** 1.0  
**Status:** CONTROLLED — SYSTEM-LEVEL ADVERSARIAL FINDING  
**System:** Archemedica  
**Effective Date:** 2026-08-30  
**Author/Document Owner:** Cassandra Harrison  
**Governed By:** ARC-STD-001 v1.0  
**Primary Affected Artifact:** ARC-DDG-SCHEMA-001 v1.0  
**Related:** ARC-PCDI-001; ARC-RDRE-001; ARC-DER-SCHEMA-001; ARC-EIG-SCHEMA-001; ARC-DMOC-001  
**Disposition:** FAIL — REPAIRABLE; DDG CONDITIONAL ON DEPENDENCY COVERAGE CONTROL

> **Finding:** The DDG can distinguish known dependencies from known non-dependencies only when its dependency coverage for the relevant decision context is sufficient. In v1.0, absence of an edge can be misread operationally as absence of impact even though the graph cannot prove that all material dependencies were captured.

## 1. Fault Injection

A protocol amendment was modeled as affecting eligibility, informed consent, EDC, statistical assumptions, and a prior enrollment decision. One true statistical-assumption dependency was intentionally omitted. A separate incorrect HIGH-materiality edge was inserted.

## 2. Observed Failure

The incorrect HIGH edge produced a false-positive reassessment candidate, which is operationally recoverable through human review.

The omitted true dependency produced a false negative: the affected statistical dependency was absent from the impact radius. The graph remained internally consistent and explainable, but incomplete.

This creates a dangerous failure state in which a high-quality-looking impact packet can be traceable while still missing a material dependency.

## 3. Root Cause

ARC-DDG-SCHEMA-001 intentionally prohibits hidden inferred edges and treats DDG as a projection/index rather than a source of truth. Those controls are sound, but they leave a gap: v1.0 has no explicit mechanism to represent whether the graph's dependency search space is sufficiently complete for a specific decision context.

The defect is epistemic, not merely algorithmic:

`NO EDGE FOUND` is not equivalent to `NO MATERIAL DEPENDENCY EXISTS`.

## 4. Required Repair — Dependency Coverage Assurance

Every consequential impact analysis shall carry a decision-context-specific coverage state:

- `SUFFICIENT_FOR_CONTEXT`
- `PARTIAL`
- `UNKNOWN`
- `STALE`

Coverage is assessed against the material dependency domains expected for the specific decision/workflow, not against a universal ontology.

Examples for protocol-change context may include safety, eligibility, endpoints, statistics, ICF, EDC, monitoring, vendor, regulatory, training, site operations, and controlled artifacts as applicable.

## 5. Mandatory Decision Rule

`PARTIAL`, `UNKNOWN`, or `STALE` coverage plus zero discovered dependencies shall never support `NO IMPACT` or equivalent closure.

Required disposition:

`IMPACT_NOT_ESTABLISHED — HUMAN REVIEW REQUIRED`

A clean `NO ACTION JUSTIFIED` outcome is authorized only when dependency coverage is sufficient for the relevant context and the search/traversal otherwise passes integrity controls.

## 6. Anti-Bureaucracy Constraint

The repair shall not require exhaustive manual mapping of every possible dependency in a clinical program.

Coverage must be generated from controlled workflow-specific expected domains and materiality, with humans confirming or resolving only relevant gaps. If the control becomes a broad manual attestation exercise, it fails the operability test.

## 7. Revised DDG Disposition

ARC-DDG-SCHEMA-001 remains architecturally viable, but its system-level disposition is narrowed from:

`BUILD — NARROWED AND GUARDED`

to:

`BUILD — CONDITIONAL ON DEPENDENCY COVERAGE CONTROL`

The original ADR-0004 remains preserved. This record does not rewrite it.

## 8. Verification Tests

At minimum:
1. intentionally omit one known material dependency and verify coverage prevents false-clearance;
2. insert false HIGH dependency and verify human review can reject the false positive without contaminating canonical history;
3. stale edge set with no new edges must not produce no-impact clearance;
4. complete workflow-domain assessment with no material dependencies may produce no-action closure;
5. coverage control must remain usable without exhaustive ontology maintenance.

## 9. Falsification Criteria

Kill or redesign the coverage control if it requires sustained manual graph maintenance comparable to or worse than manual impact assessment, if users routinely mark coverage sufficient without evidence, or if false-negative detection does not materially improve versus a disciplined workflow checklist.

## 10. System-Level Significance

This finding establishes that Archemedica must represent not only what it knows, but also whether it has sufficient basis to trust the completeness of what it knows for a specific consequential decision.

**END OF CONTROLLED DOCUMENT**
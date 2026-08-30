# ARC-DDG-SCHEMA-001 — Archemedica Decision Dependency Graph

**Document ID:** ARC-DDG-SCHEMA-001  
**Version:** 1.0  
**Status:** CONTROLLED — DESIGN BASELINE  
**System:** Archemedica  
**Document Type:** Decision Dependency / Reassessment Architecture  
**Effective Date:** 2026-08-29  
**Author/Document Owner:** Cassandra Harrison  
**Classification:** Proprietary / Controlled  
**Governed By:** ARC-STD-001 v1.0  
**Evidence Baseline:** ARC-EVID-REG-001 v1.0  
**DER Contract:** ARC-DER-SCHEMA-001 v1.0  
**Related ADR:** ADR-0004  
**Machine-Readable Contract:** `schemas/decision-dependency-graph/ARC-DDG-SCHEMA-001_Decision_Dependency_Graph.schema.json`  
**Repository Target:** `docs/architecture/ARC-DDG-SCHEMA-001_Archemedica_Decision_Dependency_Graph_v1.0.md`

> **Control statement:** The Decision Dependency Graph (DDG) is a governed dependency index over canonical Archemedica records. It is not the canonical source of truth for evidence, decisions, models, regulatory sources, or controlled artifacts.

## 1. Purpose

The DDG answers one central question:

> **A material evidence item, assumption, model version, regulatory source, controlled artifact, or prior decision changed. Which existing decisions may no longer be supportable under the basis on which they were made, and why?**

The DDG exists to calculate **decision impact radius** and create a traceable basis for reassessment.

It shall not automatically declare a decision invalid merely because an upstream node changes.

## 2. Adversarial Design Result

**ADR-0004 disposition: BUILD — NARROWED AND GUARDED.**

The graph survives the process only with these restrictions:

1. It is a **projection/index**, not a second database of truth.
2. It begins with seven node types and eleven relationship types.
3. It does not attempt a universal clinical-development ontology.
4. Graph traversal generates **reassessment candidates**, not automatic scientific/regulatory conclusions.
5. Materiality and dependency condition are explicit on edges.
6. Transitive propagation is bounded and cycle-safe.
7. Cross-tenant edges are prohibited by default.
8. Every edge has provenance.
9. Historical edges are superseded, not silently overwritten.
10. Alert/reassessment precision must be measured before automated escalation is trusted.

## 3. Canonical Sources

The DDG references, rather than duplicates, canonical records.

- `DECISION` → ARC-DER-SCHEMA-001 DER
- `EVIDENCE` → ARC-EVID-REG-001 evidence record
- `ASSUMPTION` → assumption object within DER or future assumption registry
- `MODEL_VERSION` → controlled model registry, when implemented
- `REGULATORY_SOURCE` → controlled regulatory evidence/source record
- `CONTROLLED_ARTIFACT` → protocol/SAP/DMP/SOP/submission/etc.
- `OUTCOME` → controlled observed outcome record

If graph data conflicts with its canonical source, the canonical source governs and the graph must be repaired.

## 4. Initial Node Types

Only these node types are authorized in v1.0:

1. `DECISION`
2. `EVIDENCE`
3. `ASSUMPTION`
4. `MODEL_VERSION`
5. `REGULATORY_SOURCE`
6. `CONTROLLED_ARTIFACT`
7. `OUTCOME`

Adding a new node type requires controlled schema change and adversarial review.

## 5. Initial Relationship Types

Only these relationships are authorized in v1.0:

1. `DECISION_DEPENDS_ON_EVIDENCE`
2. `DECISION_LIMITED_BY_EVIDENCE`
3. `DECISION_ASSUMES`
4. `DECISION_USED_MODEL`
5. `DECISION_GOVERNED_BY_REGULATORY_SOURCE`
6. `DECISION_AFFECTS_ARTIFACT`
7. `DECISION_AFFECTS_DECISION`
8. `DECISION_SUPERSEDES_DECISION`
9. `EVIDENCE_SUPERSEDES_EVIDENCE`
10. `MODEL_VERSION_SUPERSEDES_MODEL_VERSION`
11. `DECISION_RESULTED_IN_OUTCOME`

No free-text relationship type is allowed in the canonical graph.

## 6. Edge Contract

Every edge contains:

- stable `edge_id`;
- source node;
- target node;
- controlled relationship;
- materiality;
- optional dependency condition;
- lifecycle status;
- creation timestamp;
- provenance reference;
- supersession links where applicable.

### 6.1 Materiality

Allowed values:

- `LOW`
- `MODERATE`
- `HIGH`
- `CRITICAL`

Materiality expresses **how strongly the decision's defensibility depends on that relationship**, not how important the underlying node is in the abstract.

### 6.2 Dependency Condition

An edge may state the condition under which it matters.

Example:

`Decision D-17 depends on Evidence E-201 only if Population = Cohort B.`

This prevents the graph from treating every relationship as globally applicable.

## 7. Change Events

A change to a canonical node creates a `ChangeEvent`.

Authorized v1.0 types:

- `CONTENT_CHANGED`
- `VERSION_SUPERSEDED`
- `STATUS_CHANGED`
- `ASSUMPTION_FALSIFIED`
- `MODEL_RETIRED`
- `MODEL_VALIDATION_CHANGED`
- `REGULATORY_SOURCE_CHANGED`
- `ARTIFACT_CHANGED`
- `OUTCOME_CONTRADICTED`
- `MANUAL_REVIEW_TRIGGER`

A ChangeEvent is a trigger for impact analysis. It is **not** itself proof that a downstream decision is wrong.

## 8. Impact-Radius Algorithm — Logical Contract

For a material ChangeEvent:

1. Resolve the changed canonical node.
2. Identify active direct edges involving that node.
3. Apply dependency conditions.
4. Rank directly affected decisions by edge materiality.
5. For affected decisions, inspect downstream `DECISION_AFFECTS_DECISION` relationships.
6. Traverse only through active, tenant-valid edges.
7. Maintain a visited-node set to prevent cycles/infinite recursion.
8. Record each path explaining why a decision was reached.
9. Produce an `ImpactAnalysis` candidate set.
10. Apply reassessment rules.
11. Create `REASSESSMENT_REQUIRED` only when threshold/rules justify it.
12. Otherwise record `NO_ACTION_JUSTIFIED` with rationale.

A later implementation may optimize traversal, but shall not change these semantics without controlled revision.

## 9. Reassessment Semantics

### 9.1 Direct high/critical dependency
A material upstream change on an active `HIGH` or `CRITICAL` dependency should normally create a reassessment candidate.

### 9.2 Moderate dependency
Requires rule/SME evaluation before mandatory reassessment.

### 9.3 Low dependency
Normally advisory unless multiple low-impact changes combine or a controlled rule escalates them.

### 9.4 No automatic invalidation
The DDG may say:

> “DER-017 requires reassessment because EVID-REG-0021 was superseded and DER-017 has an active HIGH dependency on it.”

It shall not say:

> “DER-017 is wrong.”

unless a separate controlled process reaches that conclusion.

## 10. Propagation Guardrails

1. **Bounded traversal:** v1.0 impact analysis shall use configurable depth limits and stop rules.
2. **Cycle safety:** graph traversal shall never rely on an acyclic graph assumption.
3. **Explainability:** every impacted decision must include at least one dependency path.
4. **No hidden inferred edges:** relationships must be explicit or separately labeled as provisional in a future design.
5. **No cross-tenant propagation:** tenant boundary violations are prohibited.
6. **No status laundering:** a stale or unverified node does not become verified because it participates in the graph.
7. **No cascade by count alone:** many weak edges do not automatically equal one strong dependency.
8. **No silent edge mutation:** changed dependencies are superseded/versioned.

## 11. Graph and DER Interaction

The DER remains the canonical decision object.

When DDG analysis determines reassessment is required:

1. create a reassessment event;
2. link the triggering ChangeEvent;
3. place the affected DER into `REASSESSMENT_REQUIRED`;
4. preserve the original DER basis;
5. perform controlled reassessment;
6. either:
   - return the decision to `MONITORED` with documented reaffirmation, or
   - issue a successor DER and mark the prior DER `SUPERSEDED`.

The DDG never edits the historical rationale inside an already decided DER.

## 12. Regulatory Source Changes

Regulatory-change handling shall follow:

`Regulatory Source Version → Controlled Change Assessment → DDG Impact Radius → Candidate Decisions → Reassessment`

A regulatory news article is not sufficient as a canonical regulatory source.

The system must distinguish:
- source publication/update;
- interpreted requirement;
- applicability;
- affected decision;
- reassessment obligation.

## 13. Model Version Changes

Model change handling shall distinguish:

- new model version exists;
- prior model retired;
- validation status changed;
- context of use changed;
- performance materially changed.

A new model version does not automatically invalidate all decisions made using the prior version.

The graph asks whether the prior model/version remains acceptable **for the recorded context of use and decision consequence**.

## 14. Outcome Feedback

`DECISION_RESULTED_IN_OUTCOME` enables calibration without rewriting history.

An outcome may:
- support a prior decision;
- contradict assumptions;
- identify an unexpected failure mode;
- trigger model reassessment;
- trigger future architecture/product learning.

Observed outcome shall not be used to retrospectively rewrite the information available when the original decision was made.

## 15. Tenant and Security Boundary

All v1.0 graph nodes and edges are tenant-scoped.

Cross-tenant pooling, training, analytics, or dependency traversal is outside the authorized context of use.

Any future cross-tenant feature requires separate review of:
- contractual rights;
- confidentiality;
- data minimization;
- de-identification/anonymization claims;
- privacy;
- security;
- competitive sensitivity;
- model-training rights.

## 16. Integrity and Provenance

Each graph edge must be traceable to:
- a DER;
- an evidence record;
- a controlled artifact;
- a model registry event;
- a controlled regulatory mapping;
- or another authorized provenance source.

Graph inference engines may be evaluated later, but automatically inferred edges are not authorized as canonical relationships in v1.0.

## 17. Machine-Readable Contract

Companion JSON Schema:

`schemas/decision-dependency-graph/ARC-DDG-SCHEMA-001_Decision_Dependency_Graph.schema.json`

SHA-256 of companion schema at controlled generation:
`17684a0cd84248edd5d300e2e83ef8c0b17e1b0ff5754aee58aabe515c7d35dc`

The JSON Schema validates structural syntax. It does not prove semantic correctness of dependencies.

## 18. Success Metrics Before Automation Expansion

Before automated graph-driven reassessment becomes a trusted production capability, measure at minimum:

- precision of reassessment candidates;
- false-positive rate;
- false-negative rate from known test scenarios;
- percentage of impacted decisions with explainable paths;
- median number of false cascades per source change;
- user override rate;
- time to reconstruct dependency basis;
- rate of missing/stale edges;
- percentage of graph edges with valid provenance;
- reassessment completion time.

No performance threshold is pre-claimed in v1.0.

## 19. Explicit Non-Goals

v1.0 does not:
- construct a knowledge graph of all clinical development;
- determine scientific truth;
- determine regulatory applicability without controlled interpretation;
- invalidate decisions automatically;
- replace regulatory/quality/clinical SMEs;
- infer undocumented dependencies as canonical facts;
- pool sponsor data across tenants;
- replace DER or the Evidence Registry;
- predict outcomes solely from graph topology.

# Appendix A — ADR-0004: Decision Dependency Graph Gate Review

**Risk Tier:** 3  
**Disposition:** **BUILD — NARROWED AND GUARDED**

## A1. Problem Test
A decision can remain apparently “closed” after a foundational evidence item, assumption, model, regulatory source, or upstream decision changes. Manual impact assessment is difficult to reconstruct at scale.

**Result: PASS.**

## A2. Existing-Solution Test
Generic graph databases, lineage tools, knowledge graphs, QMS impact assessments, data catalogs and workflow engines can represent relationships. They do not by themselves provide Archemedica's governed decision semantics.

**Result: BUILD SEMANTICS; INTEGRATE COMMODITY GRAPH INFRASTRUCTURE.**

## A3. Commodity Test
Graph storage/traversal is commodity technology. It is not a moat.

**Result: DO NOT BUILD A PROPRIETARY GRAPH DATABASE.**

## A4. Moat Test
Potential defensibility lies in controlled decision-dependency semantics, historical outcome-linked decision memory, reassessment logic, and workflow integration—not graph algorithms alone.

**Result: QUALIFIED PASS.**

## A5. Integration Test
Use replaceable graph/storage technology behind an abstraction layer.

**Result: INTEGRATE INFRASTRUCTURE.**

## A6. Evidence Test
ARC-EVID-REG-001 and ARC-DER-SCHEMA-001 already require stable evidence/assumption/model/regulatory references and reassessment triggers.

**Result: PASS.**

## A7. Counter-Evidence Test
Large knowledge graphs become stale, expensive, hard to govern, and can create false dependency cascades.

**Result: CREDIBLE; DESIGN NARROWED.**

## A8. Regulatory Test
Traceability and lifecycle reassessment are directionally aligned with risk-based, context-specific model/evidence governance. The graph does not establish compliance or regulatory applicability.

**Result: PASS WITH BOUNDARY.**

## A9. Failure-Mode Test
Major failure modes:
- stale edges;
- missing dependencies;
- incorrect materiality;
- infinite/cyclic traversal;
- alert storms;
- cross-tenant leakage;
- treating correlation as dependency;
- automatically invalidating decisions;
- inferred edges gaining false authority.

**Result: PASS AFTER GUARDRAILS.**

## A10. Customer Test
Primary value is to teams managing protocol changes, model changes, evidence changes, regulatory changes and downstream controlled artifacts.

**Result: PROVISIONAL PASS. Direct customer evidence remains required.**

## A11. Workflow Test
The graph is useful only if it creates actionable reassessment and explains why. A graph visualization alone is insufficient.

**Result: PASS WITH NO-DASHBOARD-ONLY RULE.**

## A12. Dependency Test
The DDG depends on trustworthy IDs and provenance from DER, Evidence Registry, model registry and controlled artifacts.

**Result: HIGH DEPENDENCY; BUILD AFTER FOUNDATIONAL IDs.**

## A13. Reversibility Test
Graph infrastructure must remain replaceable. Canonical records cannot depend on proprietary graph-vendor identifiers.

**Result: PASS WITH ABSTRACTION REQUIREMENT.**

## A14. Data-Rights Test
Sponsor decision/evidence relationships may themselves reveal confidential strategy. Cross-tenant pooling is prohibited by default.

**Result: PASS WITH TENANT ISOLATION REQUIREMENT.**

## A15. Security/Privacy Test
Graph traversal can expose relationships a user is not authorized to see even if each object is individually protected.

**Result: TIER-3 SECURITY CONCERN. Authorization must apply to nodes, edges, and traversal results.**

## A16. Validation-Cost Test
Automated reassessment creates a meaningful verification/validation burden, especially false-positive/false-negative characterization.

**Result: PHASE IMPLEMENTATION. Start deterministic and explainable.**

## A17. Simpler-Alternative Test
A relational edge table can support v1.0 semantics; a specialized graph database is not required initially.

**Result: IMPORTANT REVISION — schema does not mandate graph-database technology.**

## A18. Strongest NO-BUILD Case
Archemedica could spend months constructing a beautiful graph that is perpetually stale, produces alert cascades, and duplicates relationships already visible in controlled records. The product would become ontology maintenance rather than clinical-development decision support.

## A19. Evidence-Based Rebuttal
The v1.0 design avoids a universal ontology, limits node/edge types, keeps canonical data outside the graph, requires provenance/materiality, prohibits canonical inferred edges, bounds traversal, and measures reassessment precision before automation expands.

## A20. Disposition
**BUILD — NARROWED AND GUARDED.**

Build the dependency semantics and impact-analysis contract. Integrate commodity persistence/traversal infrastructure later after a separate technical ADR.

## A21. Falsification Criteria

**ASM-ADR-0004-001:** Explicit dependency edges can identify materially affected decisions.  
**Falsification:** Known change scenarios repeatedly fail to surface decisions humans identify as affected.

**ASM-ADR-0004-002:** A narrow graph is sufficient for the first Protocol Change Decision Integrity wedge.  
**Falsification:** Real protocol-change workflows require materially different node/edge classes to reconstruct impact.

**ASM-ADR-0004-003:** Materiality plus dependency conditions can control alert cascades.  
**Falsification:** Reassessment candidate precision remains operationally unacceptable despite calibrated rules.

**ASM-ADR-0004-004:** Canonical records can remain outside the graph without degrading reconstruction.  
**Falsification:** Dependency analysis cannot reliably reproduce the exact versions/snapshots used by decisions.

**ASM-ADR-0004-005:** Commodity graph/storage technology can be abstracted.  
**Falsification:** Required traversal/provenance semantics depend materially on a specific vendor's proprietary data model.

## A22. Reassessment Triggers

Reassess ADR-0004 if:
- false-positive reassessment burden is high;
- known affected decisions are missed;
- stale/missing edges exceed acceptable operational levels;
- graph visualization becomes more used than decision workflow;
- customer evidence rejects dependency-based reassessment value;
- cross-tenant requirements emerge;
- specialized graph technology becomes demonstrably necessary;
- protocol-change pilots require broader ontology;
- automated inferred edges become desirable;
- regulatory expectations materially alter lifecycle/reassessment requirements.

## A23. Attestation Boundary

This artifact defines dependency semantics and a machine-readable structural contract. It does not establish that graph software is implemented, validated, secure, production ready, GxP compliant, Part 11 compliant, or accepted by any regulator.

## Change History

| Version | Date | Change | Disposition |
|---|---|---|---|
| 1.0 | 2026-08-29 | Initial DDG design and ADR-0004 gate review | BUILD — NARROWED AND GUARDED |

**END OF CONTROLLED DOCUMENT**
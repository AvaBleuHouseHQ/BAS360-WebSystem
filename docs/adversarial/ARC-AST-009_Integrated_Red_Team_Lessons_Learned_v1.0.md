# ARC-AST-009 — Integrated Red-Team Lessons Learned

**Document ID:** ARC-AST-009  
**Version:** 1.0  
**Status:** CONTROLLED — SYSTEM-LEVEL LESSONS LEARNED  
**System:** Archemedica  
**Effective Date:** 2026-08-30  
**Author/Document Owner:** Cassandra Harrison  
**Governed By:** ARC-STD-001 v1.0  
**Disposition:** CONDITIONAL SURVIVAL — ARCHITECTURE WORTH HARDENING; NOT READY FOR PRODUCTION CLAIMS

## 1. Campaign Scope

The integrated red-team campaign walked the decision-integrity spine under hostile conditions rather than reviewing artifacts in isolation.

Controlled findings:
- ARC-AST-001 — Dependency Coverage / False-Negative Confidence
- ARC-AST-002 — Cross-Engine Reassessment Loop
- ARC-AST-003 — Authority / Concurrency / State Collision
- ARC-AST-004 — Tenant Authorization / Graph Traversal Breach
- ARC-AST-005 — Event Replay / Outage / Partial Failure
- ARC-AST-006 — Source-of-Truth Divergence / Snapshot Drift
- ARC-AST-007 — Human Control / Rubber-Stamp / Bypass
- ARC-AST-008 — Operational Burden / Competitive Null Hypothesis

## 2. What Failed

The campaign did not reveal one fatal contradiction in the core decision-integrity thesis. It did reveal that individually sensible components can compose into an unsafe system unless cross-cutting controls exist.

The recurring failure pattern was **false authority created by missing context**:
- a graph path without coverage context can look complete;
- a reassessment event without causal context can look new;
- an approval without revision context can look current;
- a query without authorization context can leak protected relationships;
- an event without processing context can create duplicate effects;
- a reference without historical snapshot context can point to the wrong basis;
- a human approval without review evidence can look meaningful;
- a governance field without operational-cost context can look necessary.

## 3. What Survived

The following core decisions survived repeated attack:

1. DER remains canonical for consequential decisions.
2. Evidence is referenced and version-bounded, not copied indiscriminately.
3. EIG should assess supportability, not truth.
4. DDG should remain a narrow dependency projection/index, not a universal ontology.
5. PCDI remains a plausible first workflow only as a controlled pilot.
6. RDRE should orchestrate reassessment, not compete as regulatory intelligence.
7. Model governance should govern decision use, not rebuild MLOps.
8. Decision Memory should preserve tenant-specific history/outcomes without pooled-learning assumptions.
9. Human accountability remains necessary but must be evidenced and scoped.
10. Commodity infrastructure should be integrated, not rebuilt as moat.
11. Historical states are superseded, not erased.
12. `INSUFFICIENT_EVIDENCE` / `HUMAN_JUDGMENT_REQUIRED` / uncertainty states are legitimate outcomes.

## 4. Most Important Lesson

Archemedica's core risk is not that one AI model gives a bad answer. The larger architectural risk is that **structured governance makes incomplete or stale system knowledge look authoritative**.

Therefore the product must encode the limits of what it knows as carefully as it encodes what it knows.

## 5. Cross-Cutting Repairs Required

### R1 — Dependency Coverage Assurance
Absence of an edge cannot establish absence of impact unless decision-context coverage is sufficient.

### R2 — Reassessment Causal Episode Control
The system must distinguish root cause from remediation consequences and guarantee deterministic episode termination/reopen semantics.

### R3 — Single-Reality State / Concurrency Control
Consequential mutations require version-checked state transitions, scoped authority/holds and stale-command rejection.

### R4 — Authorization-Aware Data Plane
Tenant/role policy must apply through canonical reads, graph traversal, indexes, caches, events, exports and derived analytics.

### R5 — Durable Idempotent Event Processing
Duplicate delivery, retry, crash and partial failure must not create duplicate decision effects or phantom completion.

### R6 — Decision-Time Snapshot Integrity
Material decision inputs/assessments must be reconstructable at the exact historical version used.

### R7 — Evidenced Human Oversight
Required human review must leave proportionate evidence of the review basis while avoiding false claims that software proves cognition.

### R8 — Evidence Once, Project Many
Controls must derive from canonical data and workflow activity wherever possible; exception-focused human review is the operating target.

## 6. Lessons About Product Moat

The red-team campaign weakens the thesis that individual engines are the moat. EIG, graph traversal, regulatory feeds, model registries, audit logs and workflows are all replicable in isolation.

The stronger surviving thesis is the **governed causal continuity of consequential decisions across changing evidence, models, regulations, implementation and outcomes**, with explicit uncertainty and reconstructable accountability.

That continuity is only valuable if it is substantially automated from existing work and reduces reconstruction/rework burden.

## 7. Lessons About Scope

Do not add more domain engines before the integrated control plane is proven.

Near-term priority is system integrity, not feature breadth.

Deferred until hardening is proven:
- autonomous cross-engine escalation;
- open model exchange;
- broad regulatory monitoring;
- cross-tenant benchmarking/learning;
- universal ontology;
- determinative HIGH/CRITICAL model authority;
- self-modifying recommendation logic.

## 8. Current System Verdict

**ARCHITECTURE: SURVIVES CONDITIONALLY.**  
**PRODUCTION AUTOMATION: NOT YET AUTHORIZED.**  
**PRODUCT-MARKET VALUE: UNPROVEN; MUST BE PILOTED AGAINST STRONG BASELINES.**

The system is worth hardening because the failures are identifiable, bounded and repairable without abandoning the decision-integrity spine.

If the required hardening makes the product too complex to operate or fails the burden comparison, the integrated product thesis must be narrowed or killed.

## 9. Next Controlled Action

Implement one cross-cutting Integrated Control Plane contract that provides R1–R8 as shared infrastructure/semantics rather than duplicating them in each engine.

**END OF CONTROLLED DOCUMENT**
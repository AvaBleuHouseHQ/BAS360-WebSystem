# ARC-EVID-REG-001 — Archemedica Evidence Registry

**Document ID:** ARC-EVID-REG-001  
**Version:** 1.0  
**Status:** CONTROLLED — INITIAL EVIDENCE BASELINE  
**System:** Archemedica  
**Document Type:** Evidence Governance / Provenance Registry  
**Effective Date:** 2026-08-28  
**Author/Document Owner:** Cassandra Harrison  
**Classification:** Proprietary / Controlled  
**Governed By:** ARC-STD-001 v1.0  
**Related ADR:** ADR-0002  
**Supersedes:** New document  
**Repository Target:** `docs/governance/ARC-EVID-REG-001_Archemedica_Evidence_Registry_v1.0.md`

> **Control statement:** Register evidence only when it can materially support, weaken, supersede, constrain, or trigger reassessment of a consequential Archemedica decision. Registration is not verification.

## 1. Purpose

This registry establishes the controlled evidentiary baseline for Archemedica so a consequential decision can answer:

- What evidence did we rely on?
- Where did it come from?
- What was actually inspected?
- What is verified, inferred, provisional, contradicted, superseded, or rejected?
- What does it support?
- What does it **not** establish?
- Which decisions depend on it?
- What changes would require reassessment?

The registry is decision-scoped. It is not a general document warehouse.

## 2. Inclusion Rule

Register evidence when it can materially affect architecture, product scope, model use/context of use, scientific claims, regulatory mapping, validation strategy, security/privacy, data rights, customer workflow, competitive/moat decisions, lineage/IP provenance, or reassessment of an ADR/Decision Evidence Record.

Do not register routine background material with no realistic relationship to a consequential decision.

## 3. Classification

### Source Origin
- `RECOVERED-PRIMARY`
- `RECOVERED-SECONDARY`
- `EXTERNAL-PRIMARY`
- `EXTERNAL-SECONDARY`
- `GENERATED-CONTROLLED`
- `OBSERVED-SYSTEM`
- `USER-ATTESTED`
- `INFERENCE`

### Verification Status
- `VERIFIED`
- `PARTIALLY VERIFIED`
- `PROVISIONAL`
- `INFERRED`
- `UNVERIFIED`
- `SUPERSEDED`
- `REJECTED AS EVIDENCE`

### Evidentiary Role
- `SUPPORTING`
- `COUNTER-EVIDENCE`
- `LIMITING`
- `LINEAGE`
- `REGULATORY`
- `SCIENTIFIC`
- `MARKET`
- `SECURITY`
- `DATA-RIGHTS`
- `VALIDATION`
- `IMPLEMENTATION`
- `CUSTOMER`
- `REASSESSMENT-TRIGGER`

## 4. Minimum Evidence Record

Every record shall contain:
- Evidence ID
- Title
- Source-origin classification
- Evidentiary role(s)
- Verification status
- Source/authority
- Source date/version
- Date inspected/recovered
- Location/reference
- Artifact hash, where available
- What was actually inspected
- Finding
- **Supports**
- **Does Not Establish**
- Known limitations
- Related component IDs
- Related ADR/Decision IDs
- Related assumption IDs
- Supersession links
- Reassessment-trigger potential
- QC note

The **Supports / Does Not Establish** pair is mandatory.

## 5. Stable Identifier Rules

- `EVID-INT-####` internal/recovered/generated evidence
- `EVID-REG-####` regulatory/standards
- `EVID-SCI-####` scientific/model
- `EVID-MKT-####` market/competitive
- `EVID-SEC-####` security
- `EVID-DATA-####` data-rights/provenance
- `EVID-USR-####` customer/user
- `EVID-TEST-####` verification/benchmark
- `EVID-IP-####` lineage/IP

IDs are never reused.

## 6. Initial Controlled Evidence Baseline

### EVID-INT-0001 — BAS360 Module Build Sheet
**Origin:** RECOVERED-PRIMARY  
**Status:** VERIFIED  
**Role:** LINEAGE / DESIGN  
**Finding:** Recovered workbook contains the historical 12-module BAS360 blueprint.

Phase 1: AE Sentinel; Fallout Forecaster; Protocol Optimizer; Site IQ Mapper; Sovereign Compliance Layer; Codex Mirror Engine.  
Phase 2: SiteLink; Investor Signal Score; TrialMatch360; Budget Autogenerator; Investor Snapshot AI; Competitor Analytics Pulse.

**Supports:** A substantive original BAS360 module/design blueprint and historical naming lineage.  
**Does Not Establish:** Full implementation, validation, deployment, scientific validation, or production readiness of those modules.  
**Gap:** Exact canonical workbook SHA-256 still requires controlled capture.

### EVID-INT-0002 — BAS360-Final-Stripe-Enabled.zip
**Origin:** RECOVERED-PRIMARY  
**Status:** VERIFIED  
**Role:** COUNTER-EVIDENCE / LINEAGE  
**Finding:** Direct inspection established the recovered ZIP was 22 bytes and empty.  
**Supports:** This recovered archive does not contain a working BAS360 application payload.  
**Does Not Establish:** That BAS360 never existed elsewhere.

### EVID-INT-0003 — BAS360 Placeholder Source Files
**Origin:** RECOVERED-PRIMARY  
**Status:** VERIFIED  
**Role:** COUNTER-EVIDENCE  
**Finding:** `db-schema.sql`, `dbConnector.js`, `routes.js`, and `server.js` contain placeholder text.  
**Supports:** These recovered files do not establish a working backend/database implementation.  
**Does Not Establish:** Non-existence of substantive historical code elsewhere.

### EVID-INT-0004 — Historical BAS360 FullSystem Export
**Origin:** RECOVERED-SECONDARY  
**Status:** PARTIALLY VERIFIED  
**Role:** COUNTER-EVIDENCE / LINEAGE  
**Finding:** Forensic recovery reported a very small export with nine placeholder files.  
**Supports:** The recovered export reported in the forensic transcript was not substantive implementation evidence.  
**Does Not Establish:** Non-existence of other BAS360 builds.

### EVID-IP-0001 — BAS360 / BioAgesyn360 / Nataria Lineage
**Origin:** USER-ATTESTED + RECOVERED-SECONDARY  
**Status:** PARTIALLY VERIFIED  
**Role:** LINEAGE  
**Finding:** BAS360/BioAgesyn360 is the original machine; Nataria is a later rename/rebrand, not a separate platform. BARDA/Animal Rule capability belongs inside BAS360 lineage.  
**Supports:** Current controlled recovery lineage.  
**Does Not Establish:** Complete legal chain of title or implementation status of every historical component.

### EVID-IP-0002 — Astra Elan / MediArch Relationship
**Origin:** USER-ATTESTED + RECOVERED-SECONDARY  
**Status:** PARTIALLY VERIFIED  
**Role:** LINEAGE  
**Finding:** Astra Elan is a related downstream medical/preclinical/simulation branch; MediArch is represented as part of Astra Elan. Historical evidence described controlled BAS360 capability access.  
**Supports:** Current lineage separation.  
**Does Not Establish:** Canonical MediArch implementation or full bridge configuration.  
**Recovery Pending:** `Kairos/Vault/Law/AstraElan_BAS360_Bridge.md` and MediArch source.

### EVID-INT-0005 — ZeroEDC Prototype
**Origin:** OBSERVED-SYSTEM / repository evidence  
**Status:** VERIFIED for prototype existence  
**Role:** IMPLEMENTATION  
**Finding:** Substantive prototype behavior was inspected, including lab extraction, simple digital-twin prediction, hash-chain provenance, CSV ingest/perturbation, offline certification, and synthetic cohort generation.  
**Supports:** Real prototype and reusable technical patterns.  
**Does Not Establish:** Validated production EDC replacement, Part 11 compliance, GxP validation, or scientific validity of all algorithms.

### EVID-INT-0006 — GenoPattern Visible Prototype
**Origin:** OBSERVED-SYSTEM + RECOVERED-SECONDARY  
**Status:** PARTIALLY VERIFIED  
**Role:** IMPLEMENTATION / LINEAGE  
**Finding:** Visible artifact is a frontend prototype; documentation described protected/private genomic pattern detection, ML, BLEUFusion integration, lineage mapping, Truth Gate concepts, APIs, and datasets.  
**Supports:** Prototype and documented architecture claims.  
**Does Not Establish:** Recovery/verification of the private backend, models, BLEUFusion implementation, scientific validation, or production readiness.

### EVID-INT-0007 — BLEUFusion References
**Origin:** RECOVERED-SECONDARY  
**Status:** UNVERIFIED  
**Role:** LINEAGE / SCIENTIFIC  
**Finding:** BLEUFusion appears in Astra Elan/GenoPattern lineage.  
**Supports:** Historical reference/name only.  
**Does Not Establish:** An implemented engine, validated model, dataset, or production service.

### EVID-INT-0008 — Astra Elan Demo Implementation
**Origin:** OBSERVED-SYSTEM  
**Status:** VERIFIED  
**Role:** COUNTER-EVIDENCE / IMPLEMENTATION  
**Finding:** Inspected code behaved as a React/Vite investor-demo dashboard with timers, hardcoded values, and local storage rather than a substantive scientific simulation backend.  
**Supports:** The inspected implementation is demo-level software.  
**Does Not Establish:** That no private scientific backend existed elsewhere.

### EVID-DATA-0001 — “50,000 RWE Profiles” Claim
**Origin:** OBSERVED-SYSTEM claim  
**Status:** UNVERIFIED  
**Role:** DATA-RIGHTS / COUNTER-EVIDENCE  
**Finding:** Visible Astra Elan interface contained the claim, but inspected implementation did not substantiate the dataset.  
**Supports:** Only that the claim appeared in the interface.  
**Does Not Establish:** Dataset existence, lawful provenance, rights, schema, quality, representativeness, or availability.  
**Control:** Prohibited as a marketing/model/validation claim until canonical evidence is recovered.

### EVID-INT-0009 — VeriAbyss / AntiSIM
**Origin:** EXTERNAL-PRIMARY / OBSERVED-SYSTEM  
**Status:** VERIFIED for repository/engine existence; PROVISIONAL for performance claims  
**Role:** IMPLEMENTATION / EVIDENCE-INTEGRITY  
**Finding:** Repository/engine patterns include entropy detection, structured provenance, claim-level gating, SHA-256 sealing/optional anchoring, and hallucination/fabrication-risk scoring.  
**Supports:** Candidate patterns for Archemedica's Evidence Integrity Gate.  
**Does Not Establish:** “Unbreakable” behavior, claimed bypass probabilities, benchmark percentages, Part 11 readiness, submission suitability, scientific truth detection, or validated hallucination detection.

### EVID-INT-0010 — BleuNova Public Repository
**Origin:** EXTERNAL-PRIMARY / OBSERVED-SYSTEM  
**Status:** VERIFIED  
**Role:** IMPLEMENTATION / SECURITY / ARCHITECTURE  
**Finding:** Public repository contains Docker/CI, agent core, public brain configuration, ethics blueprint, security code, integrations, and tests; it is a sanitized/public shell excluding private IP.  
**Supports:** Reusable public software/architecture patterns.  
**Does Not Establish:** Behavior of excluded private systems or production suitability for Archemedica.

### EVID-SCI-0001 — GBM CAR-T Spatial Model
**Origin:** EXTERNAL-PRIMARY  
**Status:** VERIFIED as computational framework  
**Role:** SCIENTIFIC / MODEL / TEST-CASE  
**Finding:** Suitable as a future Model Registry / Simulation Contract test case.  
**Supports:** Reproducibility, parameterization, uncertainty, provenance, and result-packaging methodology.  
**Does Not Establish:** Clinical recommendation validity, regulatory acceptance, or transfer of scientific conclusions to unrelated domains.

### EVID-INT-0011 — oPoS / BleuConsult Live System
**Origin:** OBSERVED-SYSTEM  
**Status:** VERIFIED for inspected structures  
**Role:** IMPLEMENTATION / ARCHITECTURE / LINEAGE  
**Finding:** Inspected structures included ProtocolReview, DecisionEvidenceRecord, RegulatoryUpdate, TrialAlert, AuditLog, HorizonSignal, inspection calibration, RBQM/COI readiness, workspaces, scoring-model versioning, economic-assumption versioning, human-review concepts, and VeriAbyss-related fields.  
**Supports:** oPoS is a substantive living architectural bridge relevant to Archemedica.  
**Does Not Establish:** Validation, regulator approval, accuracy of all scoring methods, or full production testing.

### EVID-INT-0012 — ARC-STD-001 v1.0
**Origin:** GENERATED-CONTROLLED  
**Status:** VERIFIED  
**Role:** GOVERNANCE  
**Date:** 2026-08-28  
**Location:** `docs/governance/ARC-STD-001_Archemedica_Adversarial_Architecture_and_Build_Decision_Standard_v1.0.md`  
**SHA-256:** `5bd732046860173ecf805be6e7782e3b56ee6cc17fe1dab19b4f8e9e32e667e7`  
**Supports:** Current internal governance standard.  
**Does Not Establish:** Regulatory compliance, Part 11 compliance, validated software, or regulator acceptance.

### EVID-REG-0001 — FDA/EMA Good AI Practice Principles
**Origin:** EXTERNAL-PRIMARY  
**Status:** VERIFIED  
**Role:** REGULATORY / GOVERNANCE  
**Authority:** U.S. FDA and European Medicines Agency  
**Date:** January 2026  
**Finding:** Joint principles emphasize human-centric design, risk-based approach, standards, clear context of use, multidisciplinary expertise, data governance/documentation, model design/development, risk-based performance assessment, lifecycle management, and clear essential information.  
**Supports:** Archemedica design emphasis on context of use, proportional risk, documentation, multidisciplinary oversight, performance assessment, and lifecycle management.  
**Does Not Establish:** Archemedica regulatory compliance or acceptance.

### EVID-REG-0002 — ICH M15 General Principles for MIDD
**Origin:** EXTERNAL-PRIMARY  
**Status:** VERIFIED  
**Role:** REGULATORY / MODEL / GOVERNANCE  
**Authority:** ICH / FDA final guidance  
**Date:** June 2026  
**Finding:** Final guidance addresses MIDD planning, model evaluation, documentation of MIDD evidence, harmonized assessment terminology/framework, regulatory interactions, reporting, and submission.  
**Supports:** Controlled model planning, evaluation, evidence documentation, and context/risk-sensitive governance concepts.  
**Does Not Establish:** Applicability of every M15 provision to every Archemedica component or regulator acceptance of Archemedica.

## 7. Open Recovery / Evidence Gaps

The following remain explicitly unresolved:

1. Canonical complete BAS360 implementation/source archive.
2. Exact SHA-256 of the canonical BAS360 Module Build Sheet.
3. Canonical BAS360 ERD.
4. Canonical BARDA/Animal Rule protocol artifact.
5. Canonical AstraElan/BAS360 bridge file.
6. Canonical MediArch source.
7. Private GenoPattern backend/model artifacts.
8. BLEUFusion implementation/source and validation evidence.
9. Provenance/rights/schema evidence for the “50,000 RWE Profiles” claim.
10. Independent VeriAbyss/AntiSIM benchmark corpus, protocol, results, acceptance criteria, and error characterization.
11. Canonical TrialSim, VariantMap, IRB Compliance Matrix, BAS360 simulation-engine, or protected AuditTrace implementations.
12. Direct customer evidence for the Protocol Change Decision Integrity wedge.
13. Formal data-rights/retention architecture for Decision Memory.

Unknown remains unknown until evidence changes its status.

## 8. Evidence Integrity Rules

1. Registration is not verification.
2. A UI claim is not implementation evidence.
3. Repository existence is not production validation.
4. Source code is not evidence of correct execution without appropriate testing.
5. A benchmark is not globally valid outside tested conditions.
6. Regulatory alignment is not regulatory compliance.
7. A citation does not establish scientific truth.
8. Owner attestation remains distinct from independently recovered canonical evidence.
9. Contradictory evidence is retained and linked.
10. Evidence may be superseded but not silently rewritten.
11. Marketing language does not outrank technical evidence.
12. Missing evidence remains missing.

## 9. Decision-Linkage Contract

Future Decision Dependency Graph relations shall begin narrowly:

- `DECISION_DEPENDS_ON_EVIDENCE`
- `DECISION_LIMITED_BY_EVIDENCE`
- `ASSUMPTION_SUPPORTED_BY_EVIDENCE`
- `ASSUMPTION_CONTRADICTED_BY_EVIDENCE`
- `EVIDENCE_SUPERSEDES_EVIDENCE`
- `EVIDENCE_TRIGGERS_REASSESSMENT_OF_DECISION`
- `MODEL_EVALUATED_BY_EVIDENCE`
- `REGULATORY_RULE_DERIVED_FROM_EVIDENCE`

No universal clinical-development ontology is authorized by this registry.

# Appendix A — ADR-0002: Adopt ARC-EVID-REG-001

**Risk Tier:** 2  
**Disposition:** **BUILD — NARROWED**

### Problem
Historical artifacts, source code, UI claims, regulatory sources, market evidence, and owner attestations have materially different evidentiary strength. Without a controlled registry, they can be mistakenly treated as equivalent.

### Strongest NO-BUILD Case
A centralized evidence registry could become an expensive document graveyard that duplicates GitHub, document management, or data catalogs.

### Rebuttal
The registry is deliberately decision-scoped. Raw artifacts remain in their source systems. This registry stores provenance, evidentiary status, claim boundary, and decision linkage only when the evidence can materially affect a consequential decision.

### Material Assumptions
**ASM-ADR-0002-001:** Decision-scoped registration is sufficient at this stage.  
**Falsification:** Consequential decisions repeatedly cannot be reconstructed because relevant evidence was excluded.

**ASM-ADR-0002-002:** Mandatory “Supports / Does Not Establish” fields reduce claim inflation.  
**Falsification:** QC repeatedly finds unsupported escalation from prototype/source evidence to validation, compliance, or performance claims.

**ASM-ADR-0002-003:** Stable IDs can support the future Decision Dependency Graph without a universal ontology.  
**Falsification:** Graph implementation requires destructive identity/schema changes.

### 20-Point Review Summary
1. Problem — PASS
2. Existing solutions — PASS WITH INTEGRATION
3. Commodity — evidence storage is commodity; decision linkage is the control
4. Moat — registry alone is not moat; dependency history may contribute later
5. Integration — raw storage remains external/source-controlled
6. Evidence — current recovery demonstrates mixed evidence strengths
7. Counter-evidence — metadata burden is credible
8. Regulatory — supports documentation discipline without compliance claim
9. Failure mode — false verification-by-registration explicitly controlled
10. Customer — internal first; downstream value through defensible decision records
11. Workflow — narrowed to avoid duplicate storage
12. Dependency — foundational to DER and dependency graph
13. Reversibility — schema is versionable
14. Data rights — source-system rights remain authoritative
15. Security/privacy — metadata can be sensitive; product implementation will require tenant controls
16. Validation cost — acceptable at document stage
17. Simpler alternative — plain list possible, but stable schema/history add value at low cost
18. NO-BUILD — document graveyard risk is credible
19. Rebuttal — decision-scoped inclusion controls the risk
20. Disposition — **BUILD — NARROWED**

### Reassessment Triggers
Reassess if entry burden becomes disproportionate; decisions cannot be reconstructed; the dependency graph requires materially different semantics; tenancy requires partitioning; regulatory/validation context requires additional controls; records become stale/orphaned; or reliable automated provenance capture can replace manual fields.

### Attestation Boundary
This registry establishes a controlled evidence-governance baseline from evidence recovered or verified to date. It does not certify historical completeness, scientific validation, regulatory compliance, or implementation of recovery-pending components.

## Change History

| Version | Date | Change | Disposition |
|---|---|---|---|
| 1.0 | 2026-08-28 | Initial controlled evidence baseline and ADR-0002 | BUILD — NARROWED |

**END OF CONTROLLED DOCUMENT**
# ARC-AST-006 — Source-of-Truth Divergence & Snapshot Drift Fault Injection

**Document ID:** ARC-AST-006  
**Version:** 1.0  
**Status:** CONTROLLED — SYSTEM-LEVEL ADVERSARIAL FINDING  
**System:** Archemedica  
**Effective Date:** 2026-08-30  
**Author/Document Owner:** Cassandra Harrison  
**Governed By:** ARC-STD-001 v1.0  
**Primary Affected Artifacts:** ARC-EVID-REG-001; ARC-DER-SCHEMA-001; ARC-DDG-SCHEMA-001; ARC-EIG-SCHEMA-001; ARC-CMR-001  
**Disposition:** FAIL — REPAIRABLE; LIVE REFERENCES WITHOUT DECISION-TIME SNAPSHOT PROOF ARE INSUFFICIENT

## 1. Fault Injection

Injected source divergence:
1. DER references a sponsor document by stable URL; the file is replaced in place later;
2. vendor model endpoint returns a new model version under the same friendly product name;
3. regulatory webpage changes without an archived inspected copy;
4. EDC/CTMS object is corrected after the decision without immutable historical snapshot access;
5. evidence registry metadata says version 3 while source repository has version 4 at the same path;
6. cached EIG result was computed against prior content but displays beside current content;
7. DDG edge references a logical artifact rather than the exact version used at decision time.

## 2. Failure Observed

The architecture correctly prefers references over copying, but a logical reference is not enough to reconstruct a historical decision if the source mutates or the external system cannot return the exact historical state.

A system can therefore preserve the DER perfectly while losing the actual basis that DER referenced.

## 3. Required Repair — Decision-Time Evidence Snapshot Contract

For every MATERIAL/HIGH/CRITICAL relied-upon input, the DER/model-use/EIG record must preserve sufficient immutable reconstruction data:
- canonical source ID;
- exact source version/revision ID;
- retrieval/inspection timestamp;
- content hash where bytes are available and lawful to hash;
- archive/snapshot reference or source-system historical-version locator;
- transformation/preprocessing version;
- EIG assessment version tied to that snapshot;
- rights/retention limitation if immutable copying is not permitted.

If exact historical reconstruction cannot be guaranteed, the record must explicitly state `HISTORICAL_RECONSTRUCTION_LIMITED` and the consequence for decision defensibility.

## 4. Do Not Duplicate Everything

The repair does not authorize indiscriminate copying of sponsor systems into Archemedica.

Preferred order:
1. immutable/versioned source-system reference;
2. source-native revision + hash/proof;
3. controlled snapshot/archive where rights permit;
4. bounded extract sufficient to reconstruct the relied-upon basis;
5. explicit limitation when none is possible.

## 5. Assessment Binding Rule

EIG, model validation status, regulatory interpretation and other derived assessments must identify the exact source/model/artifact versions assessed.

A prior PASS must never render beside changed content as if it applies automatically.

## 6. Drift Detection

When a logical source resolves to content/version different from the recorded decision-time basis, Archemedica creates a change/drift event. It does not silently update the historical reference.

## 7. Verification Tests

1. URL content replaced after DER issuance;
2. vendor model alias points to new version;
3. regulatory webpage silently revised;
4. sponsor artifact corrected without versioned retrieval;
5. EIG assessment displayed against wrong version is blocked;
6. DDG path can reconstruct exact decision-time versions;
7. rights restrictions prevent copy but source-native historical locator works;
8. historical reconstruction unavailable produces explicit limitation and reassessment policy.

## 8. Revised System Constraint

A stable identifier without stable historical content is not sufficient evidence provenance for a consequential decision.

Archemedica's promise is reconstruction of the basis that actually existed at decision time, not reconstruction of whatever a URL or external system returns today.

**END OF CONTROLLED DOCUMENT**
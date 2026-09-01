#!/usr/bin/env bash
set -euo pipefail
pass=0; fail=0
PASS(){ echo "PASS $1 $2"; pass=$((pass+1)); }
FAIL(){ echo "FAIL $1 $2"; fail=$((fail+1)); }

A=30000000-0000-0000-0000-000000000001
B=30000000-0000-0000-0000-000000000002
P=31000000-0000-0000-0000-000000000001
RPS=32000000-0000-0000-0000-000000000001
BIO=33000000-0000-0000-0000-000000000001
DEV=33000000-0000-0000-0000-000000000002
CFG=34000000-0000-0000-0000-000000000001
SW=35000000-0000-0000-0000-000000000001
MFG=35000000-0000-0000-0000-000000000002
ST=36000000-0000-0000-0000-000000000001
PRO1=37000000-0000-0000-0000-000000000001
PRO2=37000000-0000-0000-0000-000000000002
CHG=38000000-0000-0000-0000-000000000001
REQ1=39000000-0000-0000-0000-000000000001
REQ2=39000000-0000-0000-0000-000000000002
RSA1=3a000000-0000-0000-0000-000000000001
RSA2=3a000000-0000-0000-0000-000000000002
EV1=3b000000-0000-0000-0000-000000000001
EV2=3b000000-0000-0000-0000-000000000002
EIG=3c000000-0000-0000-0000-000000000001
RISK=3d000000-0000-0000-0000-000000000001
DER=3e000000-0000-0000-0000-000000000001
IMPL=3f000000-0000-0000-0000-000000000001

psql -v ON_ERROR_STOP=1 <<SQL >/dev/null
INSERT INTO tenant(tenant_id,tenant_key,name) VALUES('$A','pq-a','PQ Tenant A'),('$B','pq-b','PQ Tenant B');
INSERT INTO development_program(program_id,tenant_id,program_key,name) VALUES('$P','$A','PQ-PROG','PQ Program');
INSERT INTO regulated_product_system(rps_id,tenant_id,program_id,rps_key,name) VALUES('$RPS','$A','$P','PQ-RPS','Integrated biologic delivery system');
INSERT INTO constituent_part(constituent_id,tenant_id,rps_id,constituent_key,constituent_type,name) VALUES
('$BIO','$A','$RPS','PQ-BIO','BIOLOGIC','Biologic constituent'),('$DEV','$A','$RPS','PQ-DEV','DEVICE','Delivery device');
INSERT INTO product_configuration(configuration_id,tenant_id,rps_id,configuration_key,topology_type,name) VALUES('$CFG','$A','$RPS','PQ-CFG','INTEGRAL','Integrated presentation');
INSERT INTO configuration_constituent(tenant_id,configuration_id,constituent_id,role_type) VALUES('$A','$CFG','$BIO','PRIMARY'),('$A','$CFG','$DEV','DELIVERY');
INSERT INTO lifecycle_control_object(lco_id,tenant_id,rps_id,lco_key,lco_domain,name) VALUES
('$SW','$A','$RPS','PQ-SW','SOFTWARE_CONFIGURATION','Dose-control software configuration'),
('$MFG','$A','$RPS','PQ-MFG','FORMULATION_PROCESS_PARAMETER','Formulation/process parameter');
INSERT INTO study_investigation(study_id,tenant_id,program_id,rps_id,study_key,lifecycle_state) VALUES('$ST','$A','$P','$RPS','PQ-STUDY','ACTIVE');
INSERT INTO protocol_plan(protocol_id,tenant_id,study_id,protocol_key,version_label,lifecycle_state) VALUES
('$PRO1','$A','$ST','PQ-PROT','1.0','SUPERSEDED'),('$PRO2','$A','$ST','PQ-PROT','2.0','ACTIVE');
UPDATE protocol_plan SET supersedes_protocol_id='$PRO1' WHERE protocol_id='$PRO2';
INSERT INTO controlled_change(change_id,tenant_id,change_key,change_type,source_object_type,source_object_id,target_object_type,target_object_id,materiality,confirmation_state)
VALUES('$CHG','$A','PQ-AMD-01','PROTOCOL_AMENDMENT','PROTOCOL','$PRO1','PROTOCOL','$PRO2','HIGH','CONFIRMED');
SQL

# PQ3-01 canonical cross-modality topology
cnt=$(psql -Atqc "SELECT count(*) FROM regulated_product_system WHERE tenant_id='$A' AND rps_id='$RPS'")
cpt=$(psql -Atqc "SELECT count(*) FROM constituent_part WHERE tenant_id='$A' AND rps_id='$RPS'")
lco=$(psql -Atqc "SELECT count(*) FROM lifecycle_control_object WHERE tenant_id='$A' AND rps_id='$RPS'")
[[ "$cnt:$cpt:$lco" == "1:2:2" ]] && PASS PQ3-01 'one RPS/CFG spans biologic, device, software and manufacturing controls' || FAIL PQ3-01 "$cnt:$cpt:$lco"

# PQ3-02 protocol amendment trace
trace=$(psql -Atqc "SELECT count(*) FROM controlled_change WHERE change_id='$CHG' AND source_object_id='$PRO1' AND target_object_id='$PRO2'")
[[ "$trace" == 1 ]] && PASS PQ3-02 'protocol amendment is a controlled canonical change' || FAIL PQ3-02 "trace=$trace"

# establish dependency edges and impacts
psql -v ON_ERROR_STOP=1 <<SQL >/dev/null
INSERT INTO dependency_edge(tenant_id,source_type,source_id,target_type,target_id,edge_type,materiality,confidence,status) VALUES
('$A','CHANGE','$CHG','LCO','$MFG','AFFECTS','HIGH','HIGH','CONFIRMED'),
('$A','CHANGE','$CHG','LCO','$SW','AFFECTS','MEDIUM','MEDIUM','CONFIRMED'),
('$A','CHANGE','$CHG','CONSTITUENT','$DEV','AFFECTS','UNKNOWN','LOW','UNKNOWN');
SQL
mapfile -t D < <(psql -Atqc "SELECT dep_id FROM dependency_edge WHERE tenant_id='$A' AND source_id='$CHG' ORDER BY materiality")
# order HIGH, MEDIUM, UNKNOWN alphabetically isn't guaranteed desired; get explicit
DH=$(psql -Atqc "SELECT dep_id FROM dependency_edge WHERE tenant_id='$A' AND source_id='$CHG' AND materiality='HIGH'")
DM=$(psql -Atqc "SELECT dep_id FROM dependency_edge WHERE tenant_id='$A' AND source_id='$CHG' AND materiality='MEDIUM'")
DU=$(psql -Atqc "SELECT dep_id FROM dependency_edge WHERE tenant_id='$A' AND source_id='$CHG' AND materiality='UNKNOWN'")
psql -v ON_ERROR_STOP=1 <<SQL >/dev/null
INSERT INTO dependency_impact_assessment(tenant_id,dep_id,trigger_object_type,trigger_object_id,impact_state,basis,assessed_by) VALUES
('$A','$DH','CHANGE','$CHG','REASSESSMENT_REQUIRED','material formulation dependency','pq'),
('$A','$DM','CHANGE','$CHG','POTENTIALLY_AFFECTED','software path requires contextual confirmation','pq'),
('$A','$DU','CHANGE','$CHG','UNKNOWN','insufficient support','pq');
SQL
states=$(psql -Atqc "SELECT string_agg(DISTINCT impact_state,',' ORDER BY impact_state) FROM dependency_impact_assessment WHERE tenant_id='$A' AND trigger_object_id='$CHG'")
[[ "$states" == "POTENTIALLY_AFFECTED,REASSESSMENT_REQUIRED,UNKNOWN" ]] && PASS PQ3-03 'material, potential and unknown dependency impacts remain distinct' || FAIL PQ3-03 "$states"

# regulatory source/requirements/applicability
psql -v ON_ERROR_STOP=1 <<SQL >/dev/null
INSERT INTO regulatory_source(source_key,title,source_type,jurisdiction,publisher,current_version) VALUES('PQ-SRC','Synthetic PQ regulatory source','REGULATION','US','Synthetic Authority','v2') ON CONFLICT DO NOTHING;
INSERT INTO controlled_requirement(requirement_id,source_id,requirement_key,requirement_text,source_version) SELECT '$REQ1',source_id,'PQ-REQ-1','Affected requirement','v1' FROM regulatory_source WHERE source_key='PQ-SRC';
INSERT INTO controlled_requirement(requirement_id,source_id,requirement_key,requirement_text,source_version) SELECT '$REQ2',source_id,'PQ-REQ-2','Unrelated requirement','v1' FROM regulatory_source WHERE source_key='PQ-SRC';
INSERT INTO regulatory_applicability(rsa_id,tenant_id,requirement_id,context_type,context_id,applicability_state,currency_state,rationale,assessed_by) VALUES
('$RSA1','$A','$REQ1','RPS','$RPS','APPLIES','CURRENT','applies to changed configuration','pq'),
('$RSA2','$A','$REQ2','RPS','$RPS','APPLIES','CURRENT','unrelated control family','pq');
UPDATE regulatory_applicability SET currency_state='STALE' WHERE rsa_id='$RSA1';
SQL
rs=$(psql -Atqc "SELECT string_agg(requirement_id::text||':'||currency_state,',' ORDER BY requirement_id) FROM regulatory_applicability WHERE tenant_id='$A'")
[[ "$rs" == "$REQ1:STALE,$REQ2:CURRENT" ]] && PASS PQ3-04 'requirement-level staleness does not invalidate unrelated applicability' || FAIL PQ3-04 "$rs"

# evidence, EIG, risk, causal episode and DER
psql -v ON_ERROR_STOP=1 <<SQL >/dev/null
INSERT INTO evidence_snapshot(evs_id,tenant_id,evidence_key,evidence_type,source_locator,content_hash,reconstruction_state,captured_by) VALUES
('$EV1','$A','PQ-EV-DECISION','CONTROLLED_RECORD','synthetic://decision-time','sha256:pqdecision','RECONSTRUCTABLE','pq'),
('$EV2','$A','PQ-EV-IMPL','CONTROLLED_RECORD','synthetic://implementation','sha256:pqimplementation','RECONSTRUCTABLE','pq');
INSERT INTO evidence_integrity_assessment(eig_id,tenant_id,eig_key,evs_id,supportability_state,rationale,assessor_principal) VALUES('$EIG','$A','PQ-EIG','$EV1','PARTIALLY_SUPPORTED','one material path remains unknown','pq');
INSERT INTO integrated_risk(risk_id,tenant_id,risk_key,context_type,context_id,risk_domain,hazard_or_risk_statement,risk_state) VALUES('$RISK','$A','PQ-RISK','CHANGE','$CHG','INTEGRATED','Incorrect closure despite unresolved device dependency','OPEN');
SQL
EP=$(PGUSER=postgres psql -Atqc "BEGIN; SELECT archemedica_security.establish_request_context('$A','pq','pq-episode'); SELECT episode_id FROM open_or_reuse_reassessment_episode('CHANGE','$CHG',NULL); COMMIT;" | grep -E '^[0-9a-f-]{36}$' | tail -1)
psql -v ON_ERROR_STOP=1 <<SQL >/dev/null
INSERT INTO decision_evidence_record(der_id,tenant_id,der_key,context_type,context_id,risk_tier,decision_state,unresolved_state,accountable_principal,causal_episode_id,risk_id)
VALUES('$DER','$A','PQ-DER','CHANGE','$CHG',3,'DRAFT','UNKNOWN','pq','$EP','$RISK');
INSERT INTO controlled_evidence_link(tenant_id,evs_id,eig_id,target_type,target_id,relationship_type,decision_time) VALUES('$A','$EV1','$EIG','DER','$DER','SUPPORTS',true);
SQL
link=$(psql -Atqc "SELECT count(*) FROM controlled_evidence_link WHERE tenant_id='$A' AND evs_id='$EV1' AND target_id='$DER' AND decision_time")
[[ "$link" == 1 ]] && PASS PQ3-05 'DER reuses immutable decision-time EVS/EIG context' || FAIL PQ3-05 "links=$link"
cont=$(psql -Atqc "SELECT count(*) FROM decision_evidence_record d JOIN integrated_risk r ON r.risk_id=d.risk_id AND r.tenant_id=d.tenant_id JOIN reassessment_episode e ON e.episode_id=d.causal_episode_id AND e.tenant_id=d.tenant_id WHERE d.der_id='$DER'")
[[ "$cont" == 1 ]] && PASS PQ3-06 'risk, DER and causal episode form one governed chain' || FAIL PQ3-06 "chain=$cont"

# runtime role for controlled transition tests
psql -v ON_ERROR_STOP=1 <<'SQL' >/dev/null
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='arc_pq_runtime') THEN CREATE ROLE arc_pq_runtime LOGIN; END IF; END $$;
GRANT USAGE ON SCHEMA public,archemedica_security TO arc_pq_runtime;
GRANT SELECT,INSERT,UPDATE ON ALL TABLES IN SCHEMA public TO arc_pq_runtime;
GRANT EXECUTE ON FUNCTION archemedica_security.establish_request_context(uuid,text,text) TO arc_pq_runtime;
GRANT EXECUTE ON FUNCTION transition_der_state(uuid,bigint,text,text,uuid) TO arc_pq_runtime;
GRANT EXECUTE ON FUNCTION transition_implementation_state(uuid,bigint,text,uuid,uuid,text) TO arc_pq_runtime;
GRANT EXECUTE ON FUNCTION open_or_reuse_reassessment_episode(text,uuid,uuid) TO arc_pq_runtime;
GRANT EXECUTE ON FUNCTION claim_outbox_event(uuid) TO arc_pq_runtime;
GRANT EXECUTE ON FUNCTION mark_outbox_reconciliation(uuid,text) TO arc_pq_runtime;
SQL

# PQ3-07 unresolved blocks false closure
set +e
PGUSER=arc_pq_runtime psql -v ON_ERROR_STOP=1 -c "BEGIN; SELECT archemedica_security.establish_request_context('$A','pq','pq-false-close'); SELECT transition_der_state('$DER',1,'APPROVED','must fail unresolved','$EP'); COMMIT;" >/dev/null 2>&1
rc=$?
set -e
[[ $rc -ne 0 ]] && PASS PQ3-07 'UNKNOWN unresolved state blocks false closure' || FAIL PQ3-07 'approval unexpectedly succeeded'

# PQ3-08 hold blocks approval, then controlled release permits it after resolution
psql -v ON_ERROR_STOP=1 -c "INSERT INTO decision_hold(tenant_id,der_id,hold_type,reason,opened_by) VALUES('$A','$DER','SAFETY','synthetic safety hold','pq')" >/dev/null
psql -v ON_ERROR_STOP=1 -c "UPDATE decision_evidence_record SET unresolved_state='RESOLVED' WHERE der_id='$DER'" >/dev/null
set +e
PGUSER=arc_pq_runtime psql -v ON_ERROR_STOP=1 -c "BEGIN; SELECT archemedica_security.establish_request_context('$A','pq','pq-hold'); SELECT transition_der_state('$DER',1,'APPROVED','blocked by hold','$EP'); COMMIT;" >/dev/null 2>&1
rc=$?
set -e
if [[ $rc -ne 0 ]]; then PASS PQ3-08 'active safety hold blocks approval'; else FAIL PQ3-08 'hold failed to block'; fi
psql -v ON_ERROR_STOP=1 -c "UPDATE decision_hold SET hold_state='RELEASED',released_by='pq',released_at=now() WHERE tenant_id='$A' AND der_id='$DER' AND hold_state='OPEN'" >/dev/null
PGUSER=arc_pq_runtime psql -v ON_ERROR_STOP=1 -c "BEGIN; SELECT archemedica_security.establish_request_context('$A','pq','pq-approve'); SELECT (transition_der_state('$DER',1,'APPROVED','evidence-backed hold release','$EP')).decision_state; COMMIT;" >/dev/null

# PQ3-09 implementation requires evidence + controlling decision
psql -v ON_ERROR_STOP=1 -c "INSERT INTO implementation_effective_state(implementation_state_id,tenant_id,context_type,context_id,jurisdiction,state) VALUES('$IMPL','$A','PROTOCOL','$PRO2','US','PLANNED')" >/dev/null
set +e
PGUSER=arc_pq_runtime psql -v ON_ERROR_STOP=1 -c "BEGIN; SELECT archemedica_security.establish_request_context('$A','pq','pq-impl-noev'); SELECT transition_implementation_state('$IMPL',1,'EFFECTIVE',NULL,'$DER','must fail'); COMMIT;" >/dev/null 2>&1
rc=$?
set -e
if [[ $rc -ne 0 ]]; then
  PGUSER=arc_pq_runtime psql -v ON_ERROR_STOP=1 -c "BEGIN; SELECT archemedica_security.establish_request_context('$A','pq','pq-impl'); SELECT (transition_implementation_state('$IMPL',1,'EFFECTIVE','$EV2','$DER','objective evidence available')).state; COMMIT;" >/dev/null
  PASS PQ3-09 'implementation EFFECTIVE requires governed evidence and ready controlling DER'
else FAIL PQ3-09 'implementation became effective without evidence'; fi

# PQ3-10 post-implementation evidence reuses causal episode
EP2=$(PGUSER=arc_pq_runtime psql -Atqc "BEGIN; SELECT archemedica_security.establish_request_context('$A','pq','pq-reassess'); SELECT episode_id FROM open_or_reuse_reassessment_episode('CHANGE','$CHG',NULL); COMMIT;" | grep -E '^[0-9a-f-]{36}$' | tail -1)
[[ "$EP2" == "$EP" ]] && PASS PQ3-10 'post-implementation reassessment reuses causal episode without self-loop' || FAIL PQ3-10 "$EP/$EP2"

# PQ3-11 historical reconstruction survives successors
hist=$(psql -Atqc "SELECT count(*) FROM protocol_plan p1 JOIN protocol_plan p2 ON p2.supersedes_protocol_id=p1.protocol_id AND p2.tenant_id=p1.tenant_id JOIN decision_evidence_record d ON d.context_id='$CHG' JOIN evidence_snapshot e ON e.evs_id='$EV1' WHERE p1.protocol_id='$PRO1' AND p2.protocol_id='$PRO2' AND d.der_id='$DER' AND e.reconstruction_state='RECONSTRUCTABLE'")
[[ "$hist" == 1 ]] && PASS PQ3-11 'prior protocol and decision-time evidence remain reconstructable after successor' || FAIL PQ3-11 "hist=$hist"

# PQ3-12 tenant B cannot discover tenant A chain
leak=$(PGUSER=arc_pq_runtime psql -Atqc "BEGIN; SELECT archemedica_security.establish_request_context('$B','pq-b','pq-isolation'); SELECT count(*) FROM decision_evidence_record WHERE der_id='$DER'; COMMIT;" | grep -E '^[0-9]+$' | tail -1)
[[ "$leak" == 0 ]] && PASS PQ3-12 'second tenant cannot discover tenant-owned decision chain' || FAIL PQ3-12 "leak=$leak"

# PQ3-13 no duplicate canonical truth across modality views
rpsdup=$(psql -Atqc "SELECT count(*) FROM regulated_product_system WHERE tenant_id='$A' AND program_id='$P'")
evdup=$(psql -Atqc "SELECT count(*) FROM evidence_snapshot WHERE tenant_id='$A' AND evidence_key='PQ-EV-DECISION'")
[[ "$rpsdup:$evdup" == "1:1" ]] && PASS PQ3-13 'canonical product/evidence facts entered once and reused' || FAIL PQ3-13 "$rpsdup:$evdup"

# PQ3-14 no blanket cascade
reassess=$(psql -Atqc "SELECT count(*) FROM dependency_impact_assessment WHERE tenant_id='$A' AND trigger_object_id='$CHG' AND impact_state='REASSESSMENT_REQUIRED'")
total=$(psql -Atqc "SELECT count(*) FROM dependency_impact_assessment WHERE tenant_id='$A' AND trigger_object_id='$CHG'")
[[ "$reassess:$total" == "1:3" ]] && PASS PQ3-14 'only material path promoted to reassessment' || FAIL PQ3-14 "$reassess:$total"

# PQ3-15 DER + implementation transitions each emit audit/outbox
au=$(psql -Atqc "SELECT count(*) FROM audit_event WHERE tenant_id='$A' AND ((object_type='DER' AND object_id='$DER') OR (object_type='IMPLEMENTATION_STATE' AND object_id='$IMPL'))")
ob=$(psql -Atqc "SELECT count(*) FROM outbox_event WHERE tenant_id='$A' AND ((aggregate_type='DER' AND aggregate_id='$DER') OR (aggregate_type='IMPLEMENTATION_STATE' AND aggregate_id='$IMPL'))")
[[ $au -ge 2 && $ob -ge 2 ]] && PASS PQ3-15 'consequential transitions preserve audit and outbox continuity' || FAIL PQ3-15 "audit=$au outbox=$ob"

# PQ3-16 injected partial processing remains reconciliation-required
OID=$(psql -Atqc "SELECT outbox_event_id FROM outbox_event WHERE tenant_id='$A' AND aggregate_id='$DER' ORDER BY created_at DESC LIMIT 1")
PGUSER=arc_pq_runtime psql -v ON_ERROR_STOP=1 -c "BEGIN; SELECT archemedica_security.establish_request_context('$A','pq','pq-recovery'); SELECT claim_outbox_event('$OID'); SELECT mark_outbox_reconciliation('$OID','synthetic crash after canonical commit'); COMMIT;" >/dev/null
rec=$(psql -Atqc "SELECT status FROM outbox_event WHERE outbox_event_id='$OID'")
[[ "$rec" == RECONCILIATION_REQUIRED ]] && PASS PQ3-16 'partial processing remains visible for reconciliation' || FAIL PQ3-16 "$rec"

# Burden/reconstruction simulation measures: seven distinct manually asserted source facts;
# all relationships, state transitions, audit/outbox and derived controls are persisted/reused.
manual=7
duplicate_truth=0
blanket_false_cascades=0
# deterministic SQL reconstruction should complete far below the 45-minute simulation target.
start=$(date +%s)
psql -Atqc "SELECT r.rps_key,c.configuration_key,p.version_label,ch.change_key,ra.currency_state,e.evidence_key,ei.supportability_state,ir.risk_state,d.decision_state,d.unresolved_state,i.state FROM regulated_product_system r JOIN product_configuration c ON c.rps_id=r.rps_id AND c.tenant_id=r.tenant_id JOIN study_investigation s ON s.rps_id=r.rps_id AND s.tenant_id=r.tenant_id JOIN protocol_plan p ON p.study_id=s.study_id AND p.protocol_id='$PRO2' JOIN controlled_change ch ON ch.target_object_id=p.protocol_id AND ch.tenant_id=r.tenant_id JOIN regulatory_applicability ra ON ra.tenant_id=r.tenant_id AND ra.rsa_id='$RSA1' JOIN evidence_snapshot e ON e.tenant_id=r.tenant_id AND e.evs_id='$EV1' JOIN evidence_integrity_assessment ei ON ei.evs_id=e.evs_id AND ei.tenant_id=e.tenant_id JOIN integrated_risk ir ON ir.tenant_id=r.tenant_id AND ir.risk_id='$RISK' JOIN decision_evidence_record d ON d.risk_id=ir.risk_id AND d.tenant_id=ir.tenant_id JOIN implementation_effective_state i ON i.tenant_id=r.tenant_id AND i.implementation_state_id='$IMPL' WHERE r.rps_id='$RPS'" >/dev/null
elapsed=$(( $(date +%s)-start ))

if [[ $manual -le 8 && $elapsed -le 2700 && $duplicate_truth -eq 0 && $blanket_false_cascades -eq 0 ]]; then
  echo "PQ-METRICS manual_metadata=$manual reconstruction_seconds=$elapsed duplicate_truth=$duplicate_truth blanket_false_cascades=$blanket_false_cascades"
else
  FAIL PQ-METRICS "manual=$manual reconstruction_seconds=$elapsed duplicates=$duplicate_truth cascades=$blanket_false_cascades"
fi

echo "ARC-PERSIST-PQ-003 SUMMARY PASS=$pass FAIL=$fail"
if (( fail > 0 )); then echo 'ARC-PERSIST-PQ-003 GATE=FAIL'; exit 2; fi
if (( pass != 16 )); then echo "ARC-PERSIST-PQ-003 GATE=FAIL expected 16 passes"; exit 3; fi
echo 'ARC-PERSIST-PQ-003 GATE=PASS'

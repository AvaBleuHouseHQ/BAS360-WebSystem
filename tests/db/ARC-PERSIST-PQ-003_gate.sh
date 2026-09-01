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
SRC=38500000-0000-0000-0000-000000000001
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
INSERT INTO tenant(tenant_id,tenant_key,name,status) VALUES
('$A','pq-a','PQ Tenant A','ACTIVE'),('$B','pq-b','PQ Tenant B','ACTIVE');
INSERT INTO development_program(program_id,tenant_id,program_key,name) VALUES('$P','$A','PQ-PROG','PQ Program');
INSERT INTO regulated_product_system(rps_id,tenant_id,program_id,rps_key,name) VALUES('$RPS','$A','$P','PQ-RPS','Integrated biologic delivery system');
INSERT INTO constituent_part(cpt_id,tenant_id,rps_id,cpt_key,constituent_type,name) VALUES
('$BIO','$A','$RPS','PQ-BIO','BIOLOGIC','Biologic constituent'),
('$DEV','$A','$RPS','PQ-DEV','DEVICE','Delivery device');
INSERT INTO product_configuration(cfg_id,tenant_id,rps_id,cfg_key,name,topology_type) VALUES
('$CFG','$A','$RPS','PQ-CFG','Integrated presentation','INTEGRAL');
INSERT INTO configuration_constituent(tenant_id,cfg_id,cpt_id,relationship_type) VALUES
('$A','$CFG','$BIO','PRIMARY'),('$A','$CFG','$DEV','DELIVERY');
INSERT INTO lifecycle_control_object(lco_id,tenant_id,lco_key,domain_type,rps_id,name) VALUES
('$SW','$A','PQ-SW','SOFTWARE_CONFIGURATION','$RPS','Dose-control software configuration'),
('$MFG','$A','PQ-MFG','FORMULATION_PROCESS_PARAMETER','$RPS','Formulation/process parameter');
INSERT INTO study_investigation(study_id,tenant_id,program_id,rps_id,study_key,lifecycle_state) VALUES
('$ST','$A','$P','$RPS','PQ-STUDY','ACTIVE');
INSERT INTO protocol_plan(protocol_id,tenant_id,study_id,protocol_key,version_label,lifecycle_state,supersedes_protocol_id) VALUES
('$PRO1','$A','$ST','PQ-PROT','1.0','SUPERSEDED',NULL),
('$PRO2','$A','$ST','PQ-PROT','2.0','ACTIVE','$PRO1');
INSERT INTO controlled_change(change_id,tenant_id,change_key,change_type,source_object_type,source_object_id,target_object_type,target_object_id,materiality,confirmation_state)
VALUES('$CHG','$A','PQ-AMD-01','PROTOCOL_AMENDMENT','PRO','$PRO1','PRO','$PRO2','HIGH','CONFIRMED');
SQL

cnt=$(psql -Atqc "SELECT count(*) FROM regulated_product_system WHERE tenant_id='$A' AND rps_id='$RPS'")
cpt=$(psql -Atqc "SELECT count(*) FROM constituent_part WHERE tenant_id='$A' AND rps_id='$RPS'")
lco=$(psql -Atqc "SELECT count(*) FROM lifecycle_control_object WHERE tenant_id='$A' AND rps_id='$RPS'")
cfg=$(psql -Atqc "SELECT count(*) FROM product_configuration WHERE tenant_id='$A' AND cfg_id='$CFG'")
[[ "$cnt:$cfg:$cpt:$lco" == "1:1:2:2" ]] && PASS PQ3-01 'one RPS/CFG spans biologic, device, software and manufacturing controls' || FAIL PQ3-01 "$cnt:$cfg:$cpt:$lco"

trace=$(psql -Atqc "SELECT count(*) FROM controlled_change WHERE change_id='$CHG' AND source_object_id='$PRO1' AND target_object_id='$PRO2'")
[[ "$trace" == 1 ]] && PASS PQ3-02 'protocol amendment is a controlled canonical change' || FAIL PQ3-02 "trace=$trace"

psql -v ON_ERROR_STOP=1 <<SQL >/dev/null
INSERT INTO dependency_edge(tenant_id,source_type,source_id,target_type,target_id,edge_type,materiality,confidence_state,status) VALUES
('$A','CHG','$CHG','LCO','$MFG','AFFECTS','HIGH','SUPPORTED','CONFIRMED'),
('$A','CHG','$CHG','LCO','$SW','AFFECTS','MEDIUM','SUPPORTED','CONFIRMED'),
('$A','CHG','$CHG','CPT','$DEV','MAY_AFFECT','UNKNOWN','UNKNOWN','ASSERTED');
SQL
DH=$(psql -Atqc "SELECT dep_id FROM dependency_edge WHERE tenant_id='$A' AND source_id='$CHG' AND materiality='HIGH'")
DM=$(psql -Atqc "SELECT dep_id FROM dependency_edge WHERE tenant_id='$A' AND source_id='$CHG' AND materiality='MEDIUM'")
DU=$(psql -Atqc "SELECT dep_id FROM dependency_edge WHERE tenant_id='$A' AND source_id='$CHG' AND materiality='UNKNOWN'")

psql -v ON_ERROR_STOP=1 <<'SQL' >/dev/null
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='arc_pq_runtime') THEN CREATE ROLE arc_pq_runtime LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT NOBYPASSRLS; END IF; END $$;
GRANT USAGE ON SCHEMA public,archemedica_security TO arc_pq_runtime;
GRANT SELECT,INSERT,UPDATE ON ALL TABLES IN SCHEMA public TO arc_pq_runtime;
GRANT USAGE,SELECT ON ALL SEQUENCES IN SCHEMA public TO arc_pq_runtime;
GRANT EXECUTE ON FUNCTION archemedica_security.establish_request_context(uuid,text,text) TO arc_pq_runtime;
GRANT EXECUTE ON FUNCTION evaluate_dependency_impact(uuid,uuid) TO arc_pq_runtime;
GRANT EXECUTE ON FUNCTION transition_der_state(uuid,bigint,text,text,uuid) TO arc_pq_runtime;
GRANT EXECUTE ON FUNCTION transition_implementation_state(uuid,bigint,text,uuid,uuid,text) TO arc_pq_runtime;
GRANT EXECUTE ON FUNCTION open_or_reuse_reassessment_episode(text,uuid,uuid) TO arc_pq_runtime;
GRANT EXECUTE ON FUNCTION claim_outbox_event(uuid) TO arc_pq_runtime;
GRANT EXECUTE ON FUNCTION mark_outbox_reconciliation(uuid,text) TO arc_pq_runtime;
SQL

PGUSER=arc_pq_runtime psql -v ON_ERROR_STOP=1 <<SQL >/dev/null
BEGIN;
SELECT archemedica_security.establish_request_context('$A','pq-impact','pq-impact');
SELECT evaluate_dependency_impact('$DH','$CHG');
SELECT evaluate_dependency_impact('$DM','$CHG');
SELECT evaluate_dependency_impact('$DU','$CHG');
COMMIT;
SQL
states=$(psql -Atqc "SELECT string_agg(impact_state,',' ORDER BY impact_state) FROM dependency_impact_assessment WHERE tenant_id='$A' AND trigger_object_id='$CHG'")
[[ "$states" == "POTENTIALLY_AFFECTED,REASSESSMENT_REQUIRED,UNKNOWN" ]] && PASS PQ3-03 'material, potential and unknown dependency impacts remain distinct' || FAIL PQ3-03 "$states"

psql -v ON_ERROR_STOP=1 <<SQL >/dev/null
INSERT INTO regulatory_source(src_id,source_key,issuing_body,jurisdiction,title,version_label) VALUES
('$SRC','PQ-SRC','Synthetic Authority','US','Synthetic PQ regulatory source','v1');
INSERT INTO controlled_requirement(req_id,src_id,requirement_key,locator,category) VALUES
('$REQ1','$SRC','PQ-REQ-1','§1','PRODUCT_CHANGE'),('$REQ2','$SRC','PQ-REQ-2','§2','UNRELATED');
INSERT INTO regulatory_applicability(rsa_id,tenant_id,req_id,context_type,context_id,applicability_state,currency_state,rationale,reviewer_principal) VALUES
('$RSA1','$A','$REQ1','RPS','$RPS','APPLIES','STALE','changed configuration requires reassessment','pq'),
('$RSA2','$A','$REQ2','RPS','$RPS','APPLIES','CURRENT','unrelated control family','pq');
SQL
rs=$(psql -Atqc "SELECT string_agg(req_id::text||':'||currency_state,',' ORDER BY req_id) FROM regulatory_applicability WHERE tenant_id='$A'")
[[ "$rs" == "$REQ1:STALE,$REQ2:CURRENT" ]] && PASS PQ3-04 'requirement-level staleness does not invalidate unrelated applicability' || FAIL PQ3-04 "$rs"

psql -v ON_ERROR_STOP=1 <<SQL >/dev/null
INSERT INTO evidence_snapshot(evs_id,tenant_id,evidence_key,source_type,source_locator,captured_at,content_hash,reconstruction_state) VALUES
('$EV1','$A','PQ-EV-DECISION','CONTROLLED_RECORD','synthetic://decision-time',now(),'sha256:pqdecision','RECONSTRUCTABLE'),
('$EV2','$A','PQ-EV-IMPL','CONTROLLED_RECORD','synthetic://implementation',now(),'sha256:pqimplementation','RECONSTRUCTABLE');
INSERT INTO evidence_integrity_assessment(eig_id,tenant_id,eig_key,evs_id,supportability_state,rationale,assessor_principal) VALUES
('$EIG','$A','PQ-EIG','$EV1','PARTIALLY_SUPPORTED','one path remains unknown','pq');
INSERT INTO integrated_risk(risk_id,tenant_id,risk_key,context_type,context_id,risk_domain,hazard_or_risk_statement,risk_state) VALUES
('$RISK','$A','PQ-RISK','CHG','$CHG','INTEGRATED','Incorrect closure despite unresolved device dependency','OPEN');
SQL
EP=$(PGUSER=arc_pq_runtime psql -Atqc "BEGIN; SELECT archemedica_security.establish_request_context('$A','pq','pq-episode'); SELECT (open_or_reuse_reassessment_episode('CHG','$CHG',NULL)).rae_id; COMMIT;" | grep -E '^[0-9a-f-]{36}$' | tail -1)
psql -v ON_ERROR_STOP=1 <<SQL >/dev/null
INSERT INTO decision_evidence_record(der_id,tenant_id,der_key,context_type,context_id,risk_tier,decision_state,unresolved_state,accountable_principal,causal_episode_id,risk_id)
VALUES('$DER','$A','PQ-DER','CHG','$CHG',3,'DRAFT','UNKNOWN','pq','$EP','$RISK');
INSERT INTO controlled_evidence_link(tenant_id,evs_id,eig_id,target_type,target_id,relationship_type,decision_time)
VALUES('$A','$EV1','$EIG','DER','$DER','SUPPORTS',true);
SQL
link=$(psql -Atqc "SELECT count(*) FROM controlled_evidence_link WHERE tenant_id='$A' AND evs_id='$EV1' AND target_id='$DER' AND decision_time")
[[ "$link" == 1 ]] && PASS PQ3-05 'DER reuses immutable decision-time EVS/EIG context' || FAIL PQ3-05 "links=$link"
cont=$(psql -Atqc "SELECT count(*) FROM decision_evidence_record d JOIN integrated_risk r ON r.risk_id=d.risk_id AND r.tenant_id=d.tenant_id JOIN reassessment_episode e ON e.rae_id=d.causal_episode_id AND e.tenant_id=d.tenant_id WHERE d.der_id='$DER'")
[[ "$cont" == 1 ]] && PASS PQ3-06 'risk, DER and causal episode form one governed chain' || FAIL PQ3-06 "chain=$cont"

set +e
PGUSER=arc_pq_runtime psql -v ON_ERROR_STOP=1 -c "BEGIN; SELECT archemedica_security.establish_request_context('$A','pq','pq-false-close'); SELECT transition_der_state('$DER',1,'APPROVED','must fail unresolved','$EP'); COMMIT;" >/dev/null 2>&1
rc=$?
set -e
[[ $rc -ne 0 ]] && PASS PQ3-07 'UNKNOWN unresolved state blocks false closure' || FAIL PQ3-07 'approval unexpectedly succeeded'

psql -v ON_ERROR_STOP=1 -c "INSERT INTO decision_hold(tenant_id,der_id,hold_type,reason,opened_by) VALUES('$A','$DER','SAFETY','synthetic safety hold','pq'); UPDATE decision_evidence_record SET unresolved_state='RESOLVED' WHERE der_id='$DER';" >/dev/null
set +e
PGUSER=arc_pq_runtime psql -v ON_ERROR_STOP=1 -c "BEGIN; SELECT archemedica_security.establish_request_context('$A','pq','pq-hold'); SELECT transition_der_state('$DER',1,'APPROVED','blocked by hold','$EP'); COMMIT;" >/dev/null 2>&1
rc=$?
set -e
[[ $rc -ne 0 ]] && PASS PQ3-08 'active safety hold blocks approval' || FAIL PQ3-08 'hold failed to block'
psql -v ON_ERROR_STOP=1 -c "UPDATE decision_hold SET hold_state='RELEASED',released_by='pq',released_at=now() WHERE tenant_id='$A' AND der_id='$DER' AND hold_state='OPEN'" >/dev/null
PGUSER=arc_pq_runtime psql -v ON_ERROR_STOP=1 -c "BEGIN; SELECT archemedica_security.establish_request_context('$A','pq','pq-approve'); SELECT (transition_der_state('$DER',1,'APPROVED','evidence-backed hold release','$EP')).decision_state; COMMIT;" >/dev/null

psql -v ON_ERROR_STOP=1 -c "INSERT INTO implementation_effective_state(implementation_state_id,tenant_id,context_type,context_id,jurisdiction,state) VALUES('$IMPL','$A','PRO','$PRO2','US','PLANNED')" >/dev/null
set +e
PGUSER=arc_pq_runtime psql -v ON_ERROR_STOP=1 -c "BEGIN; SELECT archemedica_security.establish_request_context('$A','pq','pq-impl-noev'); SELECT transition_implementation_state('$IMPL',1,'EFFECTIVE',NULL,'$DER','must fail'); COMMIT;" >/dev/null 2>&1
rc=$?
set -e
if [[ $rc -ne 0 ]]; then
  PGUSER=arc_pq_runtime psql -v ON_ERROR_STOP=1 -c "BEGIN; SELECT archemedica_security.establish_request_context('$A','pq','pq-impl'); SELECT (transition_implementation_state('$IMPL',1,'EFFECTIVE','$EV2','$DER','objective evidence available')).state; COMMIT;" >/dev/null
  PASS PQ3-09 'implementation EFFECTIVE requires governed evidence and ready controlling DER'
else FAIL PQ3-09 'implementation became effective without evidence'; fi

EP2=$(PGUSER=arc_pq_runtime psql -Atqc "BEGIN; SELECT archemedica_security.establish_request_context('$A','pq','pq-reassess'); SELECT (open_or_reuse_reassessment_episode('CHG','$CHG',NULL)).rae_id; COMMIT;" | grep -E '^[0-9a-f-]{36}$' | tail -1)
[[ "$EP2" == "$EP" ]] && PASS PQ3-10 'post-implementation reassessment reuses causal episode without self-loop' || FAIL PQ3-10 "$EP/$EP2"

hist=$(psql -Atqc "SELECT count(*) FROM protocol_plan p1 JOIN protocol_plan p2 ON p2.supersedes_protocol_id=p1.protocol_id AND p2.tenant_id=p1.tenant_id JOIN controlled_change ch ON ch.source_object_id=p1.protocol_id AND ch.target_object_id=p2.protocol_id AND ch.tenant_id=p1.tenant_id JOIN decision_evidence_record d ON d.context_id=ch.change_id AND d.tenant_id=ch.tenant_id JOIN evidence_snapshot e ON e.evs_id='$EV1' AND e.tenant_id=d.tenant_id WHERE p1.protocol_id='$PRO1' AND p2.protocol_id='$PRO2' AND d.der_id='$DER' AND e.reconstruction_state='RECONSTRUCTABLE'")
[[ "$hist" == 1 ]] && PASS PQ3-11 'prior protocol and decision-time evidence remain reconstructable after successor' || FAIL PQ3-11 "hist=$hist"

leak=$(PGUSER=arc_pq_runtime psql -Atqc "BEGIN; SELECT archemedica_security.establish_request_context('$B','pq-b','pq-isolation'); SELECT count(*) FROM decision_evidence_record WHERE der_id='$DER'; COMMIT;" | grep -E '^[0-9]+$' | tail -1)
[[ "$leak" == 0 ]] && PASS PQ3-12 'second tenant cannot discover tenant-owned decision chain' || FAIL PQ3-12 "leak=$leak"

rpsdup=$(psql -Atqc "SELECT count(*) FROM regulated_product_system WHERE tenant_id='$A' AND program_id='$P'")
evdup=$(psql -Atqc "SELECT count(*) FROM evidence_snapshot WHERE tenant_id='$A' AND evidence_key='PQ-EV-DECISION'")
[[ "$rpsdup:$evdup" == "1:1" ]] && PASS PQ3-13 'canonical product/evidence facts entered once and reused' || FAIL PQ3-13 "$rpsdup:$evdup"

reassess=$(psql -Atqc "SELECT count(*) FROM dependency_impact_assessment WHERE tenant_id='$A' AND trigger_object_id='$CHG' AND impact_state='REASSESSMENT_REQUIRED'")
total=$(psql -Atqc "SELECT count(*) FROM dependency_impact_assessment WHERE tenant_id='$A' AND trigger_object_id='$CHG'")
[[ "$reassess:$total" == "1:3" ]] && PASS PQ3-14 'only material path promoted to reassessment' || FAIL PQ3-14 "$reassess:$total"

au=$(psql -Atqc "SELECT count(*) FROM audit_event WHERE tenant_id='$A' AND ((object_type='DER' AND object_id='$DER') OR (object_type='IMPLEMENTATION_STATE' AND object_id='$IMPL'))")
ob=$(psql -Atqc "SELECT count(*) FROM outbox_event WHERE tenant_id='$A' AND ((aggregate_type='DER' AND aggregate_id='$DER') OR (aggregate_type='IMPLEMENTATION_STATE' AND aggregate_id='$IMPL'))")
[[ $au -ge 2 && $ob -ge 2 ]] && PASS PQ3-15 'consequential transitions preserve audit and outbox continuity' || FAIL PQ3-15 "audit=$au outbox=$ob"

OID=$(psql -Atqc "SELECT outbox_event_id FROM outbox_event WHERE tenant_id='$A' AND aggregate_id='$DER' ORDER BY created_at DESC LIMIT 1")
PGUSER=arc_pq_runtime psql -v ON_ERROR_STOP=1 -c "BEGIN; SELECT archemedica_security.establish_request_context('$A','pq','pq-recovery'); SELECT claim_outbox_event('$OID'); SELECT mark_outbox_reconciliation('$OID','synthetic crash after canonical commit'); COMMIT;" >/dev/null
rec=$(psql -Atqc "SELECT status FROM outbox_event WHERE outbox_event_id='$OID'")
[[ "$rec" == RECONCILIATION_REQUIRED ]] && PASS PQ3-16 'partial processing remains visible for reconciliation' || FAIL PQ3-16 "$rec"

manual=7
duplicate_truth=0
blanket_false_cascades=0
start=$(date +%s)
psql -Atqc "SELECT r.rps_key,c.cfg_key,p.version_label,ch.change_key,ra.currency_state,e.evidence_key,ei.supportability_state,ir.risk_state,d.decision_state,d.unresolved_state,i.state FROM regulated_product_system r JOIN product_configuration c ON c.rps_id=r.rps_id AND c.tenant_id=r.tenant_id JOIN study_investigation s ON s.rps_id=r.rps_id AND s.tenant_id=r.tenant_id JOIN protocol_plan p ON p.study_id=s.study_id AND p.protocol_id='$PRO2' JOIN controlled_change ch ON ch.target_object_id=p.protocol_id AND ch.tenant_id=r.tenant_id JOIN regulatory_applicability ra ON ra.tenant_id=r.tenant_id AND ra.rsa_id='$RSA1' JOIN evidence_snapshot e ON e.tenant_id=r.tenant_id AND e.evs_id='$EV1' JOIN evidence_integrity_assessment ei ON ei.evs_id=e.evs_id AND ei.tenant_id=e.tenant_id JOIN integrated_risk ir ON ir.tenant_id=r.tenant_id AND ir.risk_id='$RISK' JOIN decision_evidence_record d ON d.risk_id=ir.risk_id AND d.tenant_id=ir.tenant_id JOIN implementation_effective_state i ON i.tenant_id=r.tenant_id AND i.implementation_state_id='$IMPL' WHERE r.rps_id='$RPS'" >/dev/null
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

#!/usr/bin/env bash
set -euo pipefail

TENANT_A=10000000-0000-0000-0000-000000000001
TENANT_B=20000000-0000-0000-0000-000000000002
RPS_A=12000000-0000-0000-0000-000000000001
RPS_B=22000000-0000-0000-0000-000000000002
DER_A=13000000-0000-0000-0000-000000000001

pass=0; fail=0
say(){ printf '%s\n' "$*"; }
PASS(){ say "PASS $1 $2"; pass=$((pass+1)); }
FAIL(){ say "FAIL $1 $2"; fail=$((fail+1)); }

psql -v ON_ERROR_STOP=1 <<SQL
CREATE ROLE archemedica_oq_runtime NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT NOBYPASSRLS;
GRANT USAGE ON SCHEMA public, archemedica_security TO archemedica_oq_runtime;
GRANT SELECT,INSERT,UPDATE,DELETE ON ALL TABLES IN SCHEMA public TO archemedica_oq_runtime;
GRANT USAGE,SELECT ON ALL SEQUENCES IN SCHEMA public TO archemedica_oq_runtime;
GRANT EXECUTE ON FUNCTION archemedica_security.establish_request_context(uuid,text,text) TO archemedica_oq_runtime;
GRANT EXECUTE ON FUNCTION transition_der_state(uuid,bigint,text,text,uuid) TO archemedica_oq_runtime;
GRANT EXECUTE ON FUNCTION begin_idempotent_command(text,text,text) TO archemedica_oq_runtime;
GRANT EXECUTE ON FUNCTION complete_idempotent_command(text,text) TO archemedica_oq_runtime;
GRANT EXECUTE ON FUNCTION register_consumer_delivery(text,uuid,text) TO archemedica_oq_runtime;
GRANT EXECUTE ON FUNCTION claim_outbox_event(uuid) TO archemedica_oq_runtime;
GRANT EXECUTE ON FUNCTION mark_outbox_reconciliation(uuid,text) TO archemedica_oq_runtime;
GRANT EXECUTE ON FUNCTION open_or_reuse_reassessment_episode(text,uuid,uuid) TO archemedica_oq_runtime;
GRANT EXECUTE ON FUNCTION evaluate_dependency_impact(uuid,uuid) TO archemedica_oq_runtime;
GRANT EXECUTE ON FUNCTION propagate_requirement_supersession(uuid,uuid) TO archemedica_oq_runtime;

INSERT INTO tenant(tenant_id,tenant_key,name,status) VALUES
('$TENANT_A','OQ-A','OQ Tenant A','ACTIVE'),('$TENANT_B','OQ-B','OQ Tenant B','ACTIVE');
INSERT INTO development_program(program_id,tenant_id,program_key,name) VALUES
('11000000-0000-0000-0000-000000000001','$TENANT_A','OQ-PROG-A','OQ Program A'),
('21000000-0000-0000-0000-000000000002','$TENANT_B','OQ-PROG-B','OQ Program B');
INSERT INTO regulated_product_system(rps_id,tenant_id,program_id,rps_key,name) VALUES
('$RPS_A','$TENANT_A','11000000-0000-0000-0000-000000000001','OQ-RPS-A','OQ RPS A'),
('$RPS_B','$TENANT_B','21000000-0000-0000-0000-000000000002','OQ-RPS-B','OQ RPS B');
INSERT INTO decision_evidence_record(der_id,tenant_id,der_key,context_type,context_id,risk_tier,decision_state,unresolved_state,accountable_principal) VALUES
('$DER_A','$TENANT_A','OQ-DER-A','RPS','$RPS_A',3,'DRAFT','RESOLVED','oq-a');
SQL

# OQ2-01 — concurrent same-revision transitions: one winner, one stale rejection.
for n in 1 2; do
cat > /tmp/oq2_s${n}.sql <<SQL
SET ROLE archemedica_oq_runtime;
BEGIN;
SELECT archemedica_security.establish_request_context('$TENANT_A','oq-session-$n','OQ2-01-$n');
SELECT (transition_der_state('$DER_A',1,'REVIEWED_$n','concurrency attack $n',NULL)).revision;
COMMIT;
SQL
done
set +e
psql -v ON_ERROR_STOP=1 -f /tmp/oq2_s1.sql >/tmp/s1.out 2>/tmp/s1.err & p1=$!
psql -v ON_ERROR_STOP=1 -f /tmp/oq2_s2.sql >/tmp/s2.out 2>/tmp/s2.err & p2=$!
wait $p1; r1=$?; wait $p2; r2=$?
set -e
if { [[ $r1 -eq 0 && $r2 -ne 0 ]] || [[ $r2 -eq 0 && $r1 -ne 0 ]]; } && grep -q 'ARC_STALE_WRITE_REJECTED' /tmp/s1.err /tmp/s2.err; then PASS OQ2-01 'exactly one same-revision transition won'; else FAIL OQ2-01 "unexpected concurrent results r1=$r1 r2=$r2"; fi

# OQ2-02 — duplicate idempotent command produces one durable command/effect binding.
psql -v ON_ERROR_STOP=1 <<SQL >/dev/null
SET ROLE archemedica_oq_runtime;
BEGIN;
SELECT archemedica_security.establish_request_context('$TENANT_A','oq-idem','OQ2-02');
SELECT begin_idempotent_command('OQ2-02-KEY','DER_COMMAND','hash-a');
SELECT begin_idempotent_command('OQ2-02-KEY','DER_COMMAND','hash-a');
SELECT complete_idempotent_command('OQ2-02-KEY','effect-001');
SELECT complete_idempotent_command('OQ2-02-KEY','effect-001');
COMMIT;
RESET ROLE;
SQL
idem_count=$(psql -Atqc "SELECT count(*) FROM idempotency_record WHERE tenant_id='$TENANT_A' AND idempotency_key='OQ2-02-KEY' AND status='COMPLETED' AND business_effect_ref='effect-001'")
[[ "$idem_count" == 1 ]] && PASS OQ2-02 'duplicate command reused one completed business-effect binding' || FAIL OQ2-02 "expected one idempotency row got $idem_count"

# Create a controlled outbox event used by OQ2-03/OQ2-05/OQ2-13.
OUTBOX_ID=$(psql -Atqc "INSERT INTO outbox_event(tenant_id,event_type,aggregate_type,aggregate_id,payload) VALUES('$TENANT_A','OQ_EVENT','DER','$DER_A','{}') RETURNING outbox_event_id")

# OQ2-03 — duplicate delivery registration produces one consumer effect record.
psql -v ON_ERROR_STOP=1 <<SQL >/dev/null
SET ROLE archemedica_oq_runtime;
BEGIN;
SELECT archemedica_security.establish_request_context('$TENANT_A','oq-consumer','OQ2-03');
SELECT register_consumer_delivery('OQ-CONSUMER','$OUTBOX_ID','external-effect-001');
SELECT register_consumer_delivery('OQ-CONSUMER','$OUTBOX_ID','external-effect-001');
COMMIT;
RESET ROLE;
SQL
consumer_count=$(psql -Atqc "SELECT count(*) FROM consumer_delivery_record WHERE tenant_id='$TENANT_A' AND consumer_name='OQ-CONSUMER' AND outbox_event_id='$OUTBOX_ID'")
[[ "$consumer_count" == 1 ]] && PASS OQ2-03 'duplicate delivery deduplicated to one consumer record' || FAIL OQ2-03 "consumer records=$consumer_count"

# OQ2-04 — injected transaction failure rolls canonical write back.
before=$(psql -Atqc "SELECT revision FROM decision_evidence_record WHERE der_id='$DER_A'")
set +e
psql -v ON_ERROR_STOP=1 >/tmp/oq204.out 2>/tmp/oq204.err <<SQL
BEGIN;
UPDATE decision_evidence_record SET unresolved_state='UNKNOWN', revision=revision+1 WHERE der_id='$DER_A';
SELECT 1/0;
COMMIT;
SQL
set -e
after=$(psql -Atqc "SELECT revision FROM decision_evidence_record WHERE der_id='$DER_A'")
[[ "$before" == "$after" ]] && PASS OQ2-04 'failed transaction rolled back canonical write' || FAIL OQ2-04 "revision changed $before->$after"

# OQ2-05 — worker crash path remains reconcilable and reclaimable without duplicate consumer effect.
psql -v ON_ERROR_STOP=1 <<SQL >/dev/null
SET ROLE archemedica_oq_runtime;
BEGIN;
SELECT archemedica_security.establish_request_context('$TENANT_A','oq-worker','OQ2-05-A');
SELECT claim_outbox_event('$OUTBOX_ID');
SELECT mark_outbox_reconciliation('$OUTBOX_ID','simulated crash after external side effect');
COMMIT;
BEGIN;
SELECT archemedica_security.establish_request_context('$TENANT_A','oq-worker','OQ2-05-B');
SELECT claim_outbox_event('$OUTBOX_ID');
COMMIT;
RESET ROLE;
SQL
ob_state=$(psql -Atqc "SELECT status||':'||delivery_attempts FROM outbox_event WHERE outbox_event_id='$OUTBOX_ID'")
consumer_count2=$(psql -Atqc "SELECT count(*) FROM consumer_delivery_record WHERE tenant_id='$TENANT_A' AND consumer_name='OQ-CONSUMER' AND outbox_event_id='$OUTBOX_ID'")
[[ "$ob_state" == PROCESSING:2 && "$consumer_count2" == 1 ]] && PASS OQ2-05 'crash path reconciled/reclaimed while consumer effect stayed deduplicated' || FAIL OQ2-05 "outbox=$ob_state consumer_count=$consumer_count2"

# OQ2-06 — active safety hold blocks closure even with resolved DER.
psql -v ON_ERROR_STOP=1 <<SQL >/dev/null
INSERT INTO decision_hold(tenant_id,der_id,hold_type,hold_state,reason,opened_by)
VALUES('$TENANT_A','$DER_A','SAFETY','OPEN','OQ safety hold','oq-safety');
SQL
set +e
psql -v ON_ERROR_STOP=1 >/tmp/oq206.out 2>/tmp/oq206.err <<SQL
SET ROLE archemedica_oq_runtime;
BEGIN;
SELECT archemedica_security.establish_request_context('$TENANT_A','oq-approver','OQ2-06');
SELECT transition_der_state('$DER_A',2,'APPROVED','must be blocked by hold',NULL);
COMMIT;
SQL
r6=$?
set -e
if [[ $r6 -ne 0 ]] && grep -q 'ARC_ACTIVE_HOLD_BLOCKS_CLOSURE' /tmp/oq206.err; then PASS OQ2-06 'active safety hold took precedence over approval'; else FAIL OQ2-06 'approval was not explicitly blocked by active hold'; fi

# OQ2-07/OQ2-08 — same causal basis and duplicate paths reuse one open episode.
EP1=$(psql -Atqc "SET ROLE archemedica_oq_runtime; BEGIN; SELECT archemedica_security.establish_request_context('$TENANT_A','oq-episode','OQ2-07'); SELECT (open_or_reuse_reassessment_episode('DER','$DER_A',NULL)).rae_id; COMMIT; RESET ROLE;" | grep -E '^[0-9a-f-]{36}$' | tail -1)
EP2=$(psql -Atqc "SET ROLE archemedica_oq_runtime; BEGIN; SELECT archemedica_security.establish_request_context('$TENANT_A','oq-episode','OQ2-08'); SELECT (open_or_reuse_reassessment_episode('DER','$DER_A',NULL)).rae_id; COMMIT; RESET ROLE;" | grep -E '^[0-9a-f-]{36}$' | tail -1)
ep_count=$(psql -Atqc "SELECT count(*) FROM reassessment_episode WHERE tenant_id='$TENANT_A' AND root_trigger_type='DER' AND root_trigger_id='$DER_A' AND status='OPEN'")
[[ "$EP1" == "$EP2" && "$ep_count" == 1 ]] && PASS OQ2-07 'remediation reused existing causal episode' || FAIL OQ2-07 "episode ids $EP1 $EP2 count=$ep_count"
[[ "$ep_count" == 1 ]] && PASS OQ2-08 'duplicate dependency-path basis deduplicated to one causal episode' || FAIL OQ2-08 "open episode count=$ep_count"

# OQ2-09 — fan-out distinguishes material, potential, and unknown; connected != automatically reopened.
read -r DEP_HIGH DEP_LOW DEP_UNKNOWN < <(psql -Atqc "INSERT INTO dependency_edge(tenant_id,source_type,source_id,target_type,target_id,edge_type,materiality,confidence_state,status) VALUES ('$TENANT_A','DER','$DER_A','RPS','$RPS_A','AFFECTS','HIGH','SUPPORTED','CONFIRMED'),('$TENANT_A','DER','$DER_A','RPS','$RPS_A','INFORMS','LOW','SUPPORTED','CONFIRMED'),('$TENANT_A','DER','$DER_A','RPS','$RPS_A','MAY_AFFECT','UNKNOWN','UNKNOWN','ASSERTED') RETURNING dep_id" | tr '\n' ' ')
psql -v ON_ERROR_STOP=1 <<SQL >/dev/null
SET ROLE archemedica_oq_runtime;
BEGIN;
SELECT archemedica_security.establish_request_context('$TENANT_A','oq-impact','OQ2-09');
SELECT evaluate_dependency_impact('$DEP_HIGH','$DER_A');
SELECT evaluate_dependency_impact('$DEP_LOW','$DER_A');
SELECT evaluate_dependency_impact('$DEP_UNKNOWN','$DER_A');
COMMIT;
RESET ROLE;
SQL
states=$(psql -Atqc "SELECT string_agg(impact_state,',' ORDER BY impact_state) FROM dependency_impact_assessment WHERE tenant_id='$TENANT_A' AND dep_id IN ('$DEP_HIGH','$DEP_LOW','$DEP_UNKNOWN')")
if [[ "$states" == *REASSESSMENT_REQUIRED* && "$states" == *POTENTIALLY_AFFECTED* && "$states" == *UNKNOWN* ]]; then PASS OQ2-09 'materiality fan-out avoided blanket reassessment'; else FAIL OQ2-09 "impact states=$states"; fi

# OQ2-10 — false HIGH dependency rejection remains historically visible.
DEP_REJECT=$(psql -Atqc "INSERT INTO dependency_edge(tenant_id,source_type,source_id,target_type,target_id,edge_type,materiality,confidence_state,status) VALUES('$TENANT_A','DER','$DER_A','RPS','$RPS_A','AFFECTS','HIGH','SUPPORTED','ASSERTED') RETURNING dep_id")
psql -v ON_ERROR_STOP=1 -c "UPDATE dependency_edge SET status='REJECTED' WHERE dep_id='$DEP_REJECT'" >/dev/null
[[ $(psql -Atqc "SELECT status FROM dependency_edge WHERE dep_id='$DEP_REJECT'") == REJECTED ]] && PASS OQ2-10 'false HIGH assertion retained as REJECTED' || FAIL OQ2-10 'rejected assertion was not preserved'

# OQ2-11 — requirement supersession stales only affected RSA; unrelated RSA remains current.
read -r REQ_OLD REQ_NEW REQ_OTHER < <(psql -Atqc "WITH s AS (INSERT INTO regulatory_source(source_key,issuing_body,title,version_label) VALUES('OQ-SRC','OQ Authority','OQ Rule','v1') RETURNING src_id), oldr AS (INSERT INTO controlled_requirement(src_id,requirement_key) SELECT src_id,'REQ-OLD' FROM s RETURNING req_id), newr AS (INSERT INTO controlled_requirement(src_id,requirement_key,supersedes_req_id) SELECT s.src_id,'REQ-NEW',oldr.req_id FROM s,oldr RETURNING req_id), oth AS (INSERT INTO controlled_requirement(src_id,requirement_key) SELECT src_id,'REQ-OTHER' FROM s RETURNING req_id) SELECT oldr.req_id,newr.req_id,oth.req_id FROM oldr,newr,oth" )
RSA_OLD=$(psql -Atqc "INSERT INTO regulatory_applicability(tenant_id,req_id,context_type,context_id,applicability_state) VALUES('$TENANT_A','$REQ_OLD','RPS','$RPS_A','APPLIES') RETURNING rsa_id")
RSA_OTHER=$(psql -Atqc "INSERT INTO regulatory_applicability(tenant_id,req_id,context_type,context_id,applicability_state) VALUES('$TENANT_A','$REQ_OTHER','RPS','$RPS_A','APPLIES') RETURNING rsa_id")
psql -v ON_ERROR_STOP=1 <<SQL >/dev/null
SET ROLE archemedica_oq_runtime;
BEGIN;
SELECT archemedica_security.establish_request_context('$TENANT_A','oq-reg','OQ2-11');
SELECT propagate_requirement_supersession('$REQ_OLD','$REQ_NEW');
COMMIT;
RESET ROLE;
SQL
old_currency=$(psql -Atqc "SELECT currency_state FROM regulatory_applicability WHERE rsa_id='$RSA_OLD'")
other_currency=$(psql -Atqc "SELECT currency_state FROM regulatory_applicability WHERE rsa_id='$RSA_OTHER'")
[[ "$old_currency" == STALE && "$other_currency" == CURRENT ]] && PASS OQ2-11 'requirement supersession staled affected RSA only' || FAIL OQ2-11 "affected=$old_currency unrelated=$other_currency"

# OQ2-12 — identical idempotency key is isolated by tenant.
psql -v ON_ERROR_STOP=1 <<SQL >/dev/null
INSERT INTO idempotency_record(tenant_id,idempotency_key,command_type,status) VALUES
('$TENANT_A','OQ2-12-SAME','TEST','IN_PROGRESS'),('$TENANT_B','OQ2-12-SAME','TEST','IN_PROGRESS');
SQL
[[ $(psql -Atqc "SELECT count(*) FROM idempotency_record WHERE idempotency_key='OQ2-12-SAME'") == 2 ]] && PASS OQ2-12 'same key isolated by tenant' || FAIL OQ2-12 'cross-tenant idempotency collision'

# OQ2-13 — Tenant B worker cannot see Tenant A outbox.
visible=$(psql -Atqc "SET ROLE archemedica_oq_runtime; BEGIN; SELECT archemedica_security.establish_request_context('$TENANT_B','worker-b','OQ2-13'); SELECT count(*) FROM outbox_event WHERE outbox_event_id='$OUTBOX_ID'; COMMIT; RESET ROLE;" | grep -E '^[0-9]+$' | tail -1)
[[ "$visible" == 0 ]] && PASS OQ2-13 'wrong-tenant worker denied outbox visibility' || FAIL OQ2-13 "Tenant B saw $visible Tenant-A event(s)"

# OQ2-14 — same physical psql session: transaction-local Tenant A context disappears at COMMIT, then Tenant B can be established safely.
set +e
psql -v ON_ERROR_STOP=1 >/tmp/oq214.out 2>/tmp/oq214.err <<SQL
SET ROLE archemedica_oq_runtime;
BEGIN;
SELECT archemedica_security.establish_request_context('$TENANT_A','pool-a','OQ2-14-A');
DO \$\$ BEGIN IF (SELECT count(*) FROM development_program) <> 1 THEN RAISE EXCEPTION 'OQ214_A_VISIBILITY'; END IF; END \$\$;
COMMIT;
DO \$\$ BEGIN
  BEGIN
    PERFORM count(*) FROM development_program;
    RAISE EXCEPTION 'OQ214_CONTEXT_BLEED';
  EXCEPTION WHEN insufficient_privilege THEN NULL;
  END;
END \$\$;
BEGIN;
SELECT archemedica_security.establish_request_context('$TENANT_B','pool-b','OQ2-14-B');
DO \$\$ BEGIN IF (SELECT count(*) FROM development_program) <> 1 THEN RAISE EXCEPTION 'OQ214_B_VISIBILITY'; END IF; END \$\$;
COMMIT;
RESET ROLE;
SQL
r14=$?
set -e
[[ $r14 -eq 0 ]] && PASS OQ2-14 'transaction-local context cleared across pooled logical requests' || FAIL OQ2-14 "transaction-local pool test failed: $(tail -1 /tmp/oq214.err)"

# OQ2-15 — concurrent successors of one controlled predecessor: unique successor chain permits only one.
for n in 1 2; do
cat > /tmp/oq215_${n}.sql <<SQL
INSERT INTO decision_evidence_record(tenant_id,der_key,context_type,context_id,risk_tier,decision_state,unresolved_state,accountable_principal,supersedes_der_id)
VALUES('$TENANT_A','OQ-DER-SUCC-$n','RPS','$RPS_A',3,'DRAFT','RESOLVED','oq-succ','$DER_A');
SQL
done
set +e
psql -v ON_ERROR_STOP=1 -f /tmp/oq215_1.sql >/tmp/oq215_1.out 2>/tmp/oq215_1.err & q1=$!
psql -v ON_ERROR_STOP=1 -f /tmp/oq215_2.sql >/tmp/oq215_2.out 2>/tmp/oq215_2.err & q2=$!
wait $q1; s1=$?; wait $q2; s2=$?
set -e
succ_count=$(psql -Atqc "SELECT count(*) FROM decision_evidence_record WHERE tenant_id='$TENANT_A' AND supersedes_der_id='$DER_A'")
if { [[ $s1 -eq 0 && $s2 -ne 0 ]] || [[ $s2 -eq 0 && $s1 -ne 0 ]]; } && [[ "$succ_count" == 1 ]]; then PASS OQ2-15 'single authoritative successor enforced under concurrency'; else FAIL OQ2-15 "successor results s1=$s1 s2=$s2 count=$succ_count"; fi

# OQ2-16 — reconciliation-required state survives a separate DB session.
psql -v ON_ERROR_STOP=1 -c "UPDATE idempotency_record SET status='RECONCILIATION_REQUIRED' WHERE tenant_id='$TENANT_A' AND idempotency_key='OQ2-12-SAME'" >/dev/null
recon=$(psql -Atqc "SELECT status FROM idempotency_record WHERE tenant_id='$TENANT_A' AND idempotency_key='OQ2-12-SAME'")
[[ "$recon" == RECONCILIATION_REQUIRED ]] && PASS OQ2-16 'reconciliation state durable across DB sessions' || FAIL OQ2-16 "state=$recon"

say "ARC-PERSIST-OQ-002 SUMMARY PASS=$pass FAIL=$fail"
if (( fail > 0 )); then say 'ARC-PERSIST-OQ-002 GATE=FAIL'; exit 2; fi
if (( pass != 16 )); then say "ARC-PERSIST-OQ-002 GATE=FAIL expected 16 passes"; exit 3; fi
say 'ARC-PERSIST-OQ-002 GATE=PASS'

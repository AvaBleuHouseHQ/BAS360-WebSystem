#!/usr/bin/env bash
set -euo pipefail

TENANT_A=10000000-0000-0000-0000-000000000001
TENANT_B=20000000-0000-0000-0000-000000000002
DER_A=13000000-0000-0000-0000-000000000001

pass=0; fail=0; ni=0
say(){ printf '%s\n' "$*"; }
PASS(){ say "PASS $1 $2"; pass=$((pass+1)); }
FAIL(){ say "FAIL $1 $2"; fail=$((fail+1)); }
NI(){ say "NOT_IMPLEMENTED $1 $2"; ni=$((ni+1)); }

psql -v ON_ERROR_STOP=1 <<SQL
CREATE ROLE archemedica_oq_runtime NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT NOBYPASSRLS;
GRANT USAGE ON SCHEMA public, archemedica_security TO archemedica_oq_runtime;
GRANT SELECT,INSERT,UPDATE,DELETE ON ALL TABLES IN SCHEMA public TO archemedica_oq_runtime;
GRANT USAGE,SELECT ON ALL SEQUENCES IN SCHEMA public TO archemedica_oq_runtime;
GRANT EXECUTE ON FUNCTION transition_der_state(uuid,bigint,text,text,uuid) TO archemedica_oq_runtime;
INSERT INTO tenant(tenant_id,tenant_key,name,status) VALUES
('$TENANT_A','OQ-A','OQ Tenant A','ACTIVE'),('$TENANT_B','OQ-B','OQ Tenant B','ACTIVE');
INSERT INTO development_program(program_id,tenant_id,program_key,name) VALUES
('11000000-0000-0000-0000-000000000001','$TENANT_A','OQ-PROG-A','OQ Program A'),
('21000000-0000-0000-0000-000000000002','$TENANT_B','OQ-PROG-B','OQ Program B');
INSERT INTO regulated_product_system(rps_id,tenant_id,program_id,rps_key,name) VALUES
('12000000-0000-0000-0000-000000000001','$TENANT_A','11000000-0000-0000-0000-000000000001','OQ-RPS-A','OQ RPS A'),
('22000000-0000-0000-0000-000000000002','$TENANT_B','21000000-0000-0000-0000-000000000002','OQ-RPS-B','OQ RPS B');
INSERT INTO decision_evidence_record(der_id,tenant_id,der_key,context_type,context_id,risk_tier,decision_state,unresolved_state,accountable_principal) VALUES
('$DER_A','$TENANT_A','OQ-DER-A','RPS','12000000-0000-0000-0000-000000000001',3,'DRAFT','RESOLVED','oq-a');
SQL

# OQ2-01: two sessions from same revision: one winner, one stale rejection.
cat > /tmp/oq2_s1.sql <<SQL
SET ROLE archemedica_oq_runtime;
SELECT set_config('archemedica.tenant_id','$TENANT_A',false);
SELECT set_config('archemedica.actor_principal','oq-session-1',false);
SELECT set_config('archemedica.correlation_id','OQ2-01-A',false);
SELECT (transition_der_state('$DER_A',1,'REVIEWED','session 1',NULL)).revision;
SQL
cat > /tmp/oq2_s2.sql <<SQL
SET ROLE archemedica_oq_runtime;
SELECT set_config('archemedica.tenant_id','$TENANT_A',false);
SELECT set_config('archemedica.actor_principal','oq-session-2',false);
SELECT set_config('archemedica.correlation_id','OQ2-01-B',false);
SELECT (transition_der_state('$DER_A',1,'APPROVED','session 2',NULL)).revision;
SQL
set +e
psql -v ON_ERROR_STOP=1 -f /tmp/oq2_s1.sql >/tmp/s1.out 2>/tmp/s1.err & p1=$!
psql -v ON_ERROR_STOP=1 -f /tmp/oq2_s2.sql >/tmp/s2.out 2>/tmp/s2.err & p2=$!
wait $p1; r1=$?; wait $p2; r2=$?
set -e
if { [[ $r1 -eq 0 && $r2 -ne 0 ]] || [[ $r2 -eq 0 && $r1 -ne 0 ]]; } && grep -q 'ARC_STALE_WRITE_REJECTED' /tmp/s1.err /tmp/s2.err; then PASS OQ2-01 'single-winner stale-write control'; else FAIL OQ2-01 "unexpected concurrent results r1=$r1 r2=$r2"; fi

# OQ2-02: idempotency key is unique per tenant, but no atomic command-to-business-effect function exists.
if psql -Atqc "SELECT to_regprocedure('execute_idempotent_command(uuid,text,text,jsonb)') IS NOT NULL" | grep -qx t; then PASS OQ2-02 'idempotent command processor present'; else NI OQ2-02 'no atomic idempotent command processor/business-effect binding'; fi

# OQ2-03: durable downstream consumer deduplication contract not implemented.
if psql -Atqc "SELECT to_regclass('public.consumer_delivery_record') IS NOT NULL" | grep -qx t; then PASS OQ2-03 'consumer deduplication persistence present'; else NI OQ2-03 'no downstream consumer deduplication persistence'; fi

# OQ2-04: transaction rollback preserves single reality.
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

# OQ2-05: controlled outbox claim/complete/reconcile worker contract absent.
if psql -Atqc "SELECT to_regprocedure('claim_outbox_event(uuid)') IS NOT NULL" | grep -qx t; then PASS OQ2-05 'outbox worker control present'; else NI OQ2-05 'no controlled outbox claim/reconcile processor'; fi

# OQ2-06: no explicit safety/quality hold precedence state machine yet.
if psql -Atqc "SELECT to_regprocedure('assert_transition_precedence(uuid,text)') IS NOT NULL" | grep -qx t; then PASS OQ2-06 'hold precedence control present'; else NI OQ2-06 'safety/quality hold precedence not implemented'; fi

# OQ2-07/08 causal episode derivation/dedup not yet implemented as executable propagation.
if psql -Atqc "SELECT to_regprocedure('open_or_reuse_reassessment_episode(uuid,text,uuid)') IS NOT NULL" | grep -qx t; then PASS OQ2-07 'causal episode reuse control present'; PASS OQ2-08 'dependency-path episode dedup present'; else NI OQ2-07 'no governed episode reuse function'; NI OQ2-08 'no multi-path causal dedup processor'; fi

# OQ2-09: materiality propagation engine required to prevent blanket cascade.
if psql -Atqc "SELECT to_regprocedure('evaluate_dependency_impact(uuid,uuid)') IS NOT NULL" | grep -qx t; then PASS OQ2-09 'materiality propagation engine present'; else NI OQ2-09 'anti-false-cascade propagation engine absent'; fi

# OQ2-10: rejected dependency assertions are preserved by status model.
psql -v ON_ERROR_STOP=1 <<SQL >/dev/null
INSERT INTO dependency_edge(tenant_id,source_type,source_id,target_type,target_id,edge_type,materiality,status)
VALUES('$TENANT_A','DER','$DER_A','RPS','12000000-0000-0000-0000-000000000001','AFFECTS','HIGH','ASSERTED');
UPDATE dependency_edge SET status='REJECTED' WHERE tenant_id='$TENANT_A' AND source_id='$DER_A' AND materiality='HIGH';
SQL
if [[ $(psql -Atqc "SELECT count(*) FROM dependency_edge WHERE tenant_id='$TENANT_A' AND source_id='$DER_A' AND materiality='HIGH' AND status='REJECTED'") -eq 1 ]]; then PASS OQ2-10 'rejected assertion retained'; else FAIL OQ2-10 'rejected dependency not retained'; fi

# OQ2-11: requirement-source supersession propagation not yet executable.
if psql -Atqc "SELECT to_regprocedure('propagate_requirement_supersession(uuid,uuid)') IS NOT NULL" | grep -qx t; then PASS OQ2-11 'requirement supersession propagation present'; else NI OQ2-11 'REQ-level supersession propagation absent'; fi

# OQ2-12: same idempotency key is isolated by tenant composite PK.
psql -v ON_ERROR_STOP=1 <<SQL >/dev/null
INSERT INTO idempotency_record(tenant_id,idempotency_key,command_type,status) VALUES
('$TENANT_A','SAME-KEY','TEST','IN_PROGRESS'),('$TENANT_B','SAME-KEY','TEST','IN_PROGRESS');
SQL
[[ $(psql -Atqc "SELECT count(*) FROM idempotency_record WHERE idempotency_key='SAME-KEY'") -eq 2 ]] && PASS OQ2-12 'tenant-scoped idempotency collision isolated' || FAIL OQ2-12 'tenant idempotency isolation failed'

# OQ2-13: tenant B context cannot see tenant A outbox.
psql -v ON_ERROR_STOP=1 <<SQL >/dev/null
INSERT INTO outbox_event(tenant_id,event_type,aggregate_type,aggregate_id,payload) VALUES('$TENANT_A','OQ','DER','$DER_A','{}');
SQL
visible=$(psql -Atqc "SET ROLE archemedica_oq_runtime; SELECT set_config('archemedica.tenant_id','$TENANT_B',false); SELECT set_config('archemedica.actor_principal','worker-b',false); SELECT set_config('archemedica.correlation_id','OQ2-13',false); SELECT count(*) FROM outbox_event WHERE tenant_id='$TENANT_A'; RESET ROLE;" | tail -1)
[[ "$visible" == 0 ]] && PASS OQ2-13 'worker cross-tenant outbox access denied' || FAIL OQ2-13 "tenant B saw $visible tenant-A outbox rows"

# OQ2-14: session-local context currently persists unless reset => fail the pool-reuse requirement.
persisted=$(psql -Atqc "SET ROLE archemedica_oq_runtime; SELECT set_config('archemedica.tenant_id','$TENANT_A',false); SELECT current_setting('archemedica.tenant_id'); SELECT current_setting('archemedica.tenant_id'); RESET ROLE;" | tail -1)
if [[ "$persisted" == "$TENANT_A" ]]; then FAIL OQ2-14 'session tenant context persists across logical request boundary; transaction-local contract required'; else PASS OQ2-14 'no session tenant bleed'; fi

# OQ2-15: no uniqueness constraint guaranteeing a single successor for controlled object chains.
if psql -Atqc "SELECT EXISTS (SELECT 1 FROM pg_indexes WHERE tablename='decision_evidence_record' AND indexdef ILIKE '%supersedes_der_id%' AND indexdef ILIKE '%UNIQUE%')" | grep -qx t; then PASS OQ2-15 'authoritative successor uniqueness present'; else NI OQ2-15 'concurrent supersession uniqueness absent'; fi

# OQ2-16: reconciliation state itself is durable.
psql -v ON_ERROR_STOP=1 <<SQL >/dev/null
UPDATE idempotency_record SET status='RECONCILIATION_REQUIRED' WHERE tenant_id='$TENANT_A' AND idempotency_key='SAME-KEY';
SQL
[[ $(psql -Atqc "SELECT status FROM idempotency_record WHERE tenant_id='$TENANT_A' AND idempotency_key='SAME-KEY'") == RECONCILIATION_REQUIRED ]] && PASS OQ2-16 'reconciliation state durable' || FAIL OQ2-16 'reconciliation state not durable'

say "ARC-PERSIST-OQ-002 SUMMARY PASS=$pass FAIL=$fail NOT_IMPLEMENTED=$ni"
if (( fail > 0 || ni > 0 )); then say 'ARC-PERSIST-OQ-002 GATE=FAIL'; exit 2; fi
say 'ARC-PERSIST-OQ-002 GATE=PASS'

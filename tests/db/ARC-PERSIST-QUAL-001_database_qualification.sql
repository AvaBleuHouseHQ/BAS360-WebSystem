\set ON_ERROR_STOP on

-- ARC-PERSIST-QUAL-001
-- Executable PostgreSQL qualification harness for controlled persistence foundation.
-- Scope: migrations 0001-0007. Synthetic data only. Not production/GxP qualification.

CREATE ROLE archemedica_runtime NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT NOBYPASSRLS;
GRANT USAGE ON SCHEMA public, archemedica_security TO archemedica_runtime;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO archemedica_runtime;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO archemedica_runtime;
GRANT EXECUTE ON FUNCTION transition_der_state(uuid,bigint,text,text,uuid) TO archemedica_runtime;

-- Stable synthetic identities.
INSERT INTO tenant(tenant_id,tenant_key,name,status) VALUES
('10000000-0000-0000-0000-000000000001','TENANT-A','Tenant A','ACTIVE'),
('20000000-0000-0000-0000-000000000002','TENANT-B','Tenant B','ACTIVE');

INSERT INTO development_program(program_id,tenant_id,program_key,name) VALUES
('11000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000001','PROG-A','Program A'),
('21000000-0000-0000-0000-000000000002','20000000-0000-0000-0000-000000000002','PROG-B','Program B');

INSERT INTO regulated_product_system(rps_id,tenant_id,program_id,rps_key,name) VALUES
('12000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000001','11000000-0000-0000-0000-000000000001','RPS-A','RPS A'),
('22000000-0000-0000-0000-000000000002','20000000-0000-0000-0000-000000000002','21000000-0000-0000-0000-000000000002','RPS-B','RPS B');

INSERT INTO decision_evidence_record(der_id,tenant_id,der_key,context_type,context_id,risk_tier,decision_state,unresolved_state,accountable_principal)
VALUES
('13000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000001','DER-A','RPS','12000000-0000-0000-0000-000000000001',3,'DRAFT','UNKNOWN','qa-a'),
('23000000-0000-0000-0000-000000000002','20000000-0000-0000-0000-000000000002','DER-B','RPS','22000000-0000-0000-0000-000000000002',3,'DRAFT','RESOLVED','qa-b');

SET ROLE archemedica_runtime;
SELECT set_config('archemedica.tenant_id','10000000-0000-0000-0000-000000000001',false);
SELECT set_config('archemedica.actor_principal','qualification-user-a',false);
SELECT set_config('archemedica.correlation_id','ARC-QUAL-001',false);

-- Q01: tenant A sees only its tenant row.
DO $$ BEGIN
  IF (SELECT count(*) FROM tenant) <> 1 THEN RAISE EXCEPTION 'Q01_FAIL tenant visibility'; END IF;
END $$;

-- Q02: tenant A sees only its program.
DO $$ BEGIN
  IF (SELECT count(*) FROM development_program) <> 1 THEN RAISE EXCEPTION 'Q02_FAIL program isolation'; END IF;
END $$;

-- Q03: direct tenant-B DER is invisible.
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM decision_evidence_record WHERE der_id='23000000-0000-0000-0000-000000000002') THEN
    RAISE EXCEPTION 'Q03_FAIL cross-tenant DER visible';
  END IF;
END $$;

-- Q04: cross-tenant direct insert is denied by RLS.
DO $$ BEGIN
  BEGIN
    INSERT INTO development_program(tenant_id,program_key,name)
    VALUES('20000000-0000-0000-0000-000000000002','BAD-XTENANT','Bad');
    RAISE EXCEPTION 'Q04_FAIL cross-tenant insert unexpectedly succeeded';
  EXCEPTION WHEN insufficient_privilege THEN NULL;
  END;
END $$;

-- Q05: hidden cross-tenant polymorphic dependency must fail closed.
DO $$ BEGIN
  BEGIN
    INSERT INTO dependency_edge(tenant_id,source_type,source_id,target_type,target_id,edge_type)
    VALUES('10000000-0000-0000-0000-000000000001','DER','13000000-0000-0000-0000-000000000001','DER','23000000-0000-0000-0000-000000000002','AFFECTS');
    RAISE EXCEPTION 'Q05_FAIL cross-tenant graph edge unexpectedly succeeded';
  EXCEPTION WHEN OTHERS THEN
    IF SQLERRM LIKE 'Q05_FAIL%' THEN RAISE; END IF;
  END;
END $$;

-- Q06: same-tenant dependency succeeds.
INSERT INTO dependency_edge(tenant_id,source_type,source_id,target_type,target_id,edge_type,status)
VALUES('10000000-0000-0000-0000-000000000001','DER','13000000-0000-0000-0000-000000000001','RPS','12000000-0000-0000-0000-000000000001','AFFECTS','CONFIRMED');

-- Q07: false closure is blocked while unresolved_state=UNKNOWN.
DO $$ BEGIN
  BEGIN
    PERFORM transition_der_state('13000000-0000-0000-0000-000000000001',1,'APPROVED','attempt premature closure',NULL);
    RAISE EXCEPTION 'Q07_FAIL false closure unexpectedly succeeded';
  EXCEPTION WHEN check_violation THEN NULL;
  END;
END $$;

-- Prepare resolved state using controlled revision +1 direct update under test role.
UPDATE decision_evidence_record
SET unresolved_state='RESOLVED', revision=revision+1
WHERE der_id='13000000-0000-0000-0000-000000000001';

-- Q08: stale expected revision is rejected.
DO $$ BEGIN
  BEGIN
    PERFORM transition_der_state('13000000-0000-0000-0000-000000000001',1,'APPROVED','stale transition',NULL);
    RAISE EXCEPTION 'Q08_FAIL stale write unexpectedly succeeded';
  EXCEPTION WHEN serialization_failure THEN NULL;
  END;
END $$;

-- Q09: correct revision transition succeeds and increments exactly once.
SELECT (transition_der_state('13000000-0000-0000-0000-000000000001',2,'APPROVED','qualified transition',NULL)).revision AS q09_revision \gset
DO $$ BEGIN
  IF :q09_revision::bigint <> 3 THEN RAISE EXCEPTION 'Q09_FAIL revision expected 3 got %', :q09_revision; END IF;
END $$;

-- Q10: successful transition creates exactly one transition, audit, and outbox effect for correlation.
DO $$ BEGIN
  IF (SELECT count(*) FROM state_transition_event WHERE object_id='13000000-0000-0000-0000-000000000001' AND correlation_id='ARC-QUAL-001') <> 1 THEN
    RAISE EXCEPTION 'Q10_FAIL transition effect cardinality';
  END IF;
  IF (SELECT count(*) FROM audit_event WHERE object_id='13000000-0000-0000-0000-000000000001' AND correlation_key='ARC-QUAL-001' AND action='STATE_TRANSITION') <> 1 THEN
    RAISE EXCEPTION 'Q10_FAIL audit effect cardinality';
  END IF;
  IF (SELECT count(*) FROM outbox_event WHERE aggregate_id='13000000-0000-0000-0000-000000000001' AND event_type='DER_STATE_CHANGED') <> 1 THEN
    RAISE EXCEPTION 'Q10_FAIL outbox effect cardinality';
  END IF;
END $$;

-- Q11: missing tenant context fails closed.
RESET archemedica.tenant_id;
DO $$ BEGIN
  BEGIN
    PERFORM count(*) FROM development_program;
    RAISE EXCEPTION 'Q11_FAIL missing context unexpectedly permitted access';
  EXCEPTION WHEN insufficient_privilege THEN NULL;
  END;
END $$;

-- Q12: malformed tenant context fails closed.
SELECT set_config('archemedica.tenant_id','not-a-uuid',false);
DO $$ BEGIN
  BEGIN
    PERFORM count(*) FROM development_program;
    RAISE EXCEPTION 'Q12_FAIL malformed context unexpectedly permitted access';
  EXCEPTION WHEN insufficient_privilege THEN NULL;
  END;
END $$;

RESET ROLE;

SELECT 'ARC-PERSIST-QUAL-001 PASS' AS qualification_result;

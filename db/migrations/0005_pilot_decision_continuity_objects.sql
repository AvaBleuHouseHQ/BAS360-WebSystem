-- Archemedica pilot decision-continuity canonical objects
-- Corrective basis: ARC-PERSIST-TRACE-001 v1.0
-- Status: CONTROLLED IMPLEMENTATION / NOT PRODUCTION QUALIFIED

BEGIN;

CREATE TABLE study_investigation (
    study_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id uuid NOT NULL REFERENCES tenant(tenant_id),
    program_id uuid NOT NULL REFERENCES development_program(program_id),
    rps_id uuid NOT NULL REFERENCES regulated_product_system(rps_id),
    study_key text NOT NULL,
    study_type text NOT NULL DEFAULT 'CLINICAL',
    jurisdiction_scope jsonb NOT NULL DEFAULT '[]'::jsonb,
    revision bigint NOT NULL DEFAULT 1,
    lifecycle_state text NOT NULL DEFAULT 'DRAFT',
    supersedes_study_id uuid NULL REFERENCES study_investigation(study_id),
    external_system text,
    external_object_id text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (tenant_id, study_key)
);

CREATE TABLE protocol_plan (
    protocol_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id uuid NOT NULL REFERENCES tenant(tenant_id),
    study_id uuid NOT NULL REFERENCES study_investigation(study_id),
    protocol_key text NOT NULL,
    version_label text NOT NULL,
    effective_from timestamptz,
    effective_to timestamptz,
    content_locator text,
    content_hash text,
    revision bigint NOT NULL DEFAULT 1,
    lifecycle_state text NOT NULL DEFAULT 'DRAFT',
    supersedes_protocol_id uuid NULL REFERENCES protocol_plan(protocol_id),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (tenant_id, protocol_key, version_label)
);

CREATE TABLE controlled_change (
    change_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id uuid NOT NULL REFERENCES tenant(tenant_id),
    change_key text NOT NULL,
    change_type text NOT NULL,
    source_object_type text NOT NULL,
    source_object_id uuid NOT NULL,
    target_object_type text,
    target_object_id uuid,
    before_state jsonb,
    after_state jsonb,
    location_locator text,
    classification text,
    materiality text NOT NULL DEFAULT 'UNKNOWN',
    confirmation_state text NOT NULL DEFAULT 'UNCONFIRMED',
    original_extraction jsonb,
    revision bigint NOT NULL DEFAULT 1,
    lifecycle_state text NOT NULL DEFAULT 'OPEN',
    supersedes_change_id uuid NULL REFERENCES controlled_change(change_id),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (tenant_id, change_key)
);

CREATE TABLE integrated_risk (
    risk_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id uuid NOT NULL REFERENCES tenant(tenant_id),
    risk_key text NOT NULL,
    context_type text NOT NULL,
    context_id uuid NOT NULL,
    risk_domain text NOT NULL,
    hazard_or_risk_statement text NOT NULL,
    cause text,
    consequence text,
    severity text,
    probability text,
    detectability text,
    risk_state text NOT NULL DEFAULT 'OPEN',
    control_summary text,
    residual_risk_state text,
    revision bigint NOT NULL DEFAULT 1,
    supersedes_risk_id uuid NULL REFERENCES integrated_risk(risk_id),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (tenant_id, risk_key)
);

CREATE TABLE evidence_integrity_assessment (
    eig_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id uuid NOT NULL REFERENCES tenant(tenant_id),
    eig_key text NOT NULL,
    evs_id uuid NOT NULL REFERENCES evidence_snapshot(evs_id),
    supportability_state text NOT NULL CHECK (supportability_state IN (
        'SUPPORTED','PARTIALLY_SUPPORTED','CONFLICTED','UNSUPPORTED','UNKNOWN','STALE'
    )),
    rationale text,
    assessor_principal text,
    assessed_at timestamptz NOT NULL DEFAULT now(),
    revision bigint NOT NULL DEFAULT 1,
    supersedes_eig_id uuid NULL REFERENCES evidence_integrity_assessment(eig_id),
    created_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (tenant_id, eig_key)
);

CREATE TABLE model_algorithm_use (
    muse_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id uuid NOT NULL REFERENCES tenant(tenant_id),
    muse_key text NOT NULL,
    context_type text NOT NULL,
    context_id uuid NOT NULL,
    model_name text NOT NULL,
    model_version text NOT NULL,
    provider text,
    intended_context text NOT NULL,
    influence_level text NOT NULL DEFAULT 'ADVISORY',
    limitations text,
    input_provenance jsonb NOT NULL DEFAULT '{}'::jsonb,
    human_oversight_state text NOT NULL DEFAULT 'REQUIRED',
    revision bigint NOT NULL DEFAULT 1,
    supersedes_muse_id uuid NULL REFERENCES model_algorithm_use(muse_id),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (tenant_id, muse_key)
);

CREATE TABLE safety_quality_signal (
    signal_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id uuid NOT NULL REFERENCES tenant(tenant_id),
    signal_key text NOT NULL,
    context_type text NOT NULL,
    context_id uuid NOT NULL,
    signal_type text NOT NULL,
    signal_state text NOT NULL DEFAULT 'OPEN',
    summary text NOT NULL,
    source_evidence_id uuid NULL REFERENCES evidence_snapshot(evs_id),
    opened_at timestamptz NOT NULL DEFAULT now(),
    closed_at timestamptz,
    revision bigint NOT NULL DEFAULT 1,
    supersedes_signal_id uuid NULL REFERENCES safety_quality_signal(signal_id),
    UNIQUE (tenant_id, signal_key)
);

CREATE TABLE supplier_external_dependency (
    supplier_dependency_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id uuid NOT NULL REFERENCES tenant(tenant_id),
    supplier_key text NOT NULL,
    dependency_type text NOT NULL,
    name text NOT NULL,
    service_or_material text,
    context_type text NOT NULL,
    context_id uuid NOT NULL,
    external_identifier text,
    version_or_contract_ref text,
    risk_state text NOT NULL DEFAULT 'UNKNOWN',
    failure_behavior text,
    revision bigint NOT NULL DEFAULT 1,
    supersedes_supplier_dependency_id uuid NULL REFERENCES supplier_external_dependency(supplier_dependency_id),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (tenant_id, supplier_key)
);

CREATE TABLE obligation (
    obligation_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id uuid NOT NULL REFERENCES tenant(tenant_id),
    obligation_key text NOT NULL,
    context_type text NOT NULL,
    context_id uuid NOT NULL,
    basis_type text NOT NULL,
    basis_id uuid NOT NULL,
    obligation_type text NOT NULL,
    description text NOT NULL,
    owner_principal text,
    due_at timestamptz,
    readiness_state text NOT NULL DEFAULT 'OPEN',
    closure_evidence_required boolean NOT NULL DEFAULT true,
    closed_at timestamptz,
    closure_basis text,
    revision bigint NOT NULL DEFAULT 1,
    supersedes_obligation_id uuid NULL REFERENCES obligation(obligation_id),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (tenant_id, obligation_key)
);

CREATE TABLE controlled_evidence_link (
    evidence_link_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id uuid NOT NULL REFERENCES tenant(tenant_id),
    evs_id uuid NOT NULL REFERENCES evidence_snapshot(evs_id),
    eig_id uuid NULL REFERENCES evidence_integrity_assessment(eig_id),
    target_type text NOT NULL,
    target_id uuid NOT NULL,
    relationship_type text NOT NULL,
    decision_time boolean NOT NULL DEFAULT false,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE implementation_effective_state (
    implementation_state_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id uuid NOT NULL REFERENCES tenant(tenant_id),
    context_type text NOT NULL,
    context_id uuid NOT NULL,
    jurisdiction text,
    site_identifier text,
    state text NOT NULL CHECK (state IN (
        'NOT_APPLICABLE','NOT_STARTED','PLANNED','IN_PROGRESS','READY','EFFECTIVE','HELD','PARTIAL','UNKNOWN','SUPERSEDED'
    )),
    objective_evidence_id uuid NULL REFERENCES evidence_snapshot(evs_id),
    effective_at timestamptz,
    revision bigint NOT NULL DEFAULT 1,
    supersedes_implementation_state_id uuid NULL REFERENCES implementation_effective_state(implementation_state_id),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_study_tenant_rps ON study_investigation(tenant_id, rps_id);
CREATE INDEX idx_protocol_tenant_study ON protocol_plan(tenant_id, study_id);
CREATE INDEX idx_change_source ON controlled_change(tenant_id, source_object_type, source_object_id);
CREATE INDEX idx_risk_context ON integrated_risk(tenant_id, context_type, context_id);
CREATE INDEX idx_eig_evidence ON evidence_integrity_assessment(tenant_id, evs_id);
CREATE INDEX idx_muse_context ON model_algorithm_use(tenant_id, context_type, context_id);
CREATE INDEX idx_signal_context ON safety_quality_signal(tenant_id, context_type, context_id);
CREATE INDEX idx_supplier_context ON supplier_external_dependency(tenant_id, context_type, context_id);
CREATE INDEX idx_obligation_context ON obligation(tenant_id, context_type, context_id, readiness_state);
CREATE INDEX idx_evidence_link_target ON controlled_evidence_link(tenant_id, target_type, target_id);
CREATE INDEX idx_impl_state_context ON implementation_effective_state(tenant_id, context_type, context_id);

-- Enable and force RLS. Policies are added here using ARC-AUTH-001 context contract.
DO $$
DECLARE tbl text;
BEGIN
    FOREACH tbl IN ARRAY ARRAY[
        'study_investigation','protocol_plan','controlled_change','integrated_risk','evidence_integrity_assessment',
        'model_algorithm_use','safety_quality_signal','supplier_external_dependency','obligation',
        'controlled_evidence_link','implementation_effective_state'
    ]
    LOOP
        EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY', tbl);
        EXECUTE format('ALTER TABLE %I FORCE ROW LEVEL SECURITY', tbl);
        EXECUTE format(
            'CREATE POLICY %I ON %I FOR ALL USING (tenant_id = archemedica_security.current_tenant_id()) WITH CHECK (tenant_id = archemedica_security.current_tenant_id())',
            tbl || '_tenant_isolation', tbl
        );
        EXECUTE format(
            'CREATE TRIGGER %I BEFORE UPDATE OF tenant_id ON %I FOR EACH ROW EXECUTE FUNCTION archemedica_security.reject_tenant_reassignment()',
            'trg_' || tbl || '_reject_tenant_reassignment', tbl
        );
    END LOOP;
END $$;

COMMIT;

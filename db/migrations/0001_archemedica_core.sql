-- Archemedica core persistence foundation
-- Change Control: ARC-CC-003
-- Architecture: ARC-PERSIST-001 v1.0
-- ADR: ADR-0007 v1.0
-- Status: CONTROLLED FOUNDATION / NOT PRODUCTION QUALIFIED

BEGIN;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE tenant (
    tenant_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_key text NOT NULL UNIQUE,
    name text NOT NULL,
    status text NOT NULL CHECK (status IN ('ACTIVE','SUSPENDED','RETIRED')),
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE development_program (
    program_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id uuid NOT NULL REFERENCES tenant(tenant_id),
    program_key text NOT NULL,
    name text NOT NULL,
    revision bigint NOT NULL DEFAULT 1,
    lifecycle_state text NOT NULL DEFAULT 'ACTIVE',
    supersedes_program_id uuid NULL REFERENCES development_program(program_id),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (tenant_id, program_key)
);

CREATE TABLE regulated_product_system (
    rps_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id uuid NOT NULL REFERENCES tenant(tenant_id),
    program_id uuid NOT NULL REFERENCES development_program(program_id),
    rps_key text NOT NULL,
    name text NOT NULL,
    intended_use text,
    indication text,
    target_population text,
    revision bigint NOT NULL DEFAULT 1,
    lifecycle_state text NOT NULL DEFAULT 'DRAFT',
    supersedes_rps_id uuid NULL REFERENCES regulated_product_system(rps_id),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (tenant_id, rps_key)
);

CREATE TABLE constituent_part (
    cpt_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id uuid NOT NULL REFERENCES tenant(tenant_id),
    rps_id uuid NOT NULL REFERENCES regulated_product_system(rps_id),
    cpt_key text NOT NULL,
    constituent_type text NOT NULL CHECK (constituent_type IN (
        'DRUG','BIOLOGIC','DEVICE','SOFTWARE','IVD_DIAGNOSTIC','HCTP','DELIVERY_SYSTEM','ACCESSORY','OTHER'
    )),
    name text NOT NULL,
    revision bigint NOT NULL DEFAULT 1,
    lifecycle_state text NOT NULL DEFAULT 'DRAFT',
    supersedes_cpt_id uuid NULL REFERENCES constituent_part(cpt_id),
    attributes jsonb NOT NULL DEFAULT '{}'::jsonb,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (tenant_id, cpt_key)
);

CREATE TABLE product_configuration (
    cfg_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id uuid NOT NULL REFERENCES tenant(tenant_id),
    rps_id uuid NOT NULL REFERENCES regulated_product_system(rps_id),
    cfg_key text NOT NULL,
    name text NOT NULL,
    topology_type text NOT NULL CHECK (topology_type IN (
        'INTEGRAL','CO_PACKAGED','CROSS_LABELED','KIT','ACCESSORY_RELATIONSHIP','REGIONAL_PRESENTATION','OTHER'
    )),
    jurisdiction text,
    effective_from timestamptz,
    effective_to timestamptz,
    revision bigint NOT NULL DEFAULT 1,
    lifecycle_state text NOT NULL DEFAULT 'DRAFT',
    supersedes_cfg_id uuid NULL REFERENCES product_configuration(cfg_id),
    attributes jsonb NOT NULL DEFAULT '{}'::jsonb,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (tenant_id, cfg_key)
);

CREATE TABLE configuration_constituent (
    configuration_constituent_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id uuid NOT NULL REFERENCES tenant(tenant_id),
    cfg_id uuid NOT NULL REFERENCES product_configuration(cfg_id),
    cpt_id uuid NOT NULL REFERENCES constituent_part(cpt_id),
    relationship_type text NOT NULL,
    effective_from timestamptz,
    effective_to timestamptz,
    created_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (tenant_id, cfg_id, cpt_id, relationship_type)
);

CREATE TABLE lifecycle_control_object (
    lco_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id uuid NOT NULL REFERENCES tenant(tenant_id),
    lco_key text NOT NULL,
    domain_type text NOT NULL CHECK (domain_type IN (
        'MANUFACTURING_PROCESS','MATERIAL_SPECIFICATION','FORMULATION_PROCESS_PARAMETER','DESIGN_INPUT_OUTPUT',
        'ENGINEERING_VERIFICATION_VALIDATION','USABILITY_HUMAN_FACTORS','SOFTWARE_CONFIGURATION','CYBERSECURITY_CONTROL',
        'ANALYTICAL_TEST_METHOD','PROCESS_VALIDATION_CONTROL_STRATEGY','PACKAGING_LABELING','STERILIZATION',
        'SUPPLIER_CONTROL','DEVICE_RISK_CONTROL','CMC_CONTROL_STRATEGY','COMPUTERIZED_SYSTEM_CONFIGURATION','OTHER'
    )),
    rps_id uuid NULL REFERENCES regulated_product_system(rps_id),
    cfg_id uuid NULL REFERENCES product_configuration(cfg_id),
    cpt_id uuid NULL REFERENCES constituent_part(cpt_id),
    name text NOT NULL,
    revision bigint NOT NULL DEFAULT 1,
    lifecycle_state text NOT NULL DEFAULT 'DRAFT',
    supersedes_lco_id uuid NULL REFERENCES lifecycle_control_object(lco_id),
    external_system text,
    external_object_id text,
    external_version text,
    attributes jsonb NOT NULL DEFAULT '{}'::jsonb,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (tenant_id, lco_key),
    CHECK (rps_id IS NOT NULL OR cfg_id IS NOT NULL OR cpt_id IS NOT NULL)
);

CREATE TABLE regulatory_source (
    src_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    source_key text NOT NULL,
    issuing_body text NOT NULL,
    jurisdiction text,
    title text NOT NULL,
    version_label text,
    effective_from timestamptz,
    effective_to timestamptz,
    source_locator text,
    content_hash text,
    created_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (source_key, version_label)
);

CREATE TABLE controlled_requirement (
    req_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    src_id uuid NOT NULL REFERENCES regulatory_source(src_id),
    requirement_key text NOT NULL,
    locator text,
    category text,
    effective_from timestamptz,
    effective_to timestamptz,
    applicability_conditions text,
    interpretation_status text NOT NULL DEFAULT 'HUMAN_JUDGMENT_REQUIRED',
    interpretation_provenance text,
    supersedes_req_id uuid NULL REFERENCES controlled_requirement(req_id),
    created_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (src_id, requirement_key)
);

CREATE TABLE regulatory_applicability (
    rsa_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id uuid NOT NULL REFERENCES tenant(tenant_id),
    req_id uuid NOT NULL REFERENCES controlled_requirement(req_id),
    context_type text NOT NULL,
    context_id uuid NOT NULL,
    applicability_state text NOT NULL CHECK (applicability_state IN (
        'APPLIES','DOES_NOT_APPLY','PARTIAL','UNKNOWN','HUMAN_JUDGMENT_REQUIRED'
    )),
    rationale text,
    reviewer_principal text,
    revision bigint NOT NULL DEFAULT 1,
    supersedes_rsa_id uuid NULL REFERENCES regulatory_applicability(rsa_id),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE evidence_snapshot (
    evs_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id uuid NULL REFERENCES tenant(tenant_id),
    evidence_key text NOT NULL,
    source_type text NOT NULL,
    source_locator text,
    source_version text,
    captured_at timestamptz NOT NULL,
    content_hash text,
    retained_content_ref text,
    reconstruction_state text NOT NULL CHECK (reconstruction_state IN (
        'RECONSTRUCTABLE','BOUNDED_LIMITATION','UNKNOWN','STALE'
    )),
    limitation text,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE decision_evidence_record (
    der_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id uuid NOT NULL REFERENCES tenant(tenant_id),
    der_key text NOT NULL,
    context_type text NOT NULL,
    context_id uuid NOT NULL,
    risk_tier integer NOT NULL CHECK (risk_tier BETWEEN 1 AND 3),
    decision_state text NOT NULL,
    rationale text,
    unresolved_state text NOT NULL DEFAULT 'UNKNOWN',
    accountable_principal text,
    revision bigint NOT NULL DEFAULT 1,
    supersedes_der_id uuid NULL REFERENCES decision_evidence_record(der_id),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (tenant_id, der_key)
);

CREATE TABLE dependency_edge (
    dep_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id uuid NOT NULL REFERENCES tenant(tenant_id),
    source_type text NOT NULL,
    source_id uuid NOT NULL,
    target_type text NOT NULL,
    target_id uuid NOT NULL,
    edge_type text NOT NULL,
    direction text NOT NULL DEFAULT 'FORWARD',
    materiality text NOT NULL DEFAULT 'UNKNOWN',
    confidence_state text NOT NULL DEFAULT 'UNKNOWN',
    status text NOT NULL DEFAULT 'ASSERTED' CHECK (status IN ('ASSERTED','CONFIRMED','REJECTED','SUPERSEDED','UNKNOWN')),
    effective_from timestamptz,
    effective_to timestamptz,
    causal_episode_id uuid,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE dependency_coverage (
    dca_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id uuid NOT NULL REFERENCES tenant(tenant_id),
    context_type text NOT NULL,
    context_id uuid NOT NULL,
    coverage_state text NOT NULL CHECK (coverage_state IN ('SUFFICIENT_FOR_CONTEXT','PARTIAL','UNKNOWN','STALE')),
    rationale text,
    assessed_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE reassessment_episode (
    rae_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id uuid NOT NULL REFERENCES tenant(tenant_id),
    root_trigger_type text NOT NULL,
    root_trigger_id uuid NOT NULL,
    parent_event_id uuid,
    status text NOT NULL DEFAULT 'OPEN',
    opened_at timestamptz NOT NULL DEFAULT now(),
    closed_at timestamptz,
    closure_basis text
);

ALTER TABLE dependency_edge
    ADD CONSTRAINT dependency_edge_causal_episode_fk
    FOREIGN KEY (causal_episode_id) REFERENCES reassessment_episode(rae_id);

CREATE TABLE idempotency_record (
    tenant_id uuid NOT NULL REFERENCES tenant(tenant_id),
    idempotency_key text NOT NULL,
    command_type text NOT NULL,
    business_effect_ref text,
    status text NOT NULL CHECK (status IN ('IN_PROGRESS','COMPLETED','RECONCILIATION_REQUIRED','FAILED')),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (tenant_id, idempotency_key)
);

CREATE TABLE outbox_event (
    outbox_event_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id uuid NOT NULL REFERENCES tenant(tenant_id),
    event_type text NOT NULL,
    aggregate_type text NOT NULL,
    aggregate_id uuid NOT NULL,
    causal_episode_id uuid NULL REFERENCES reassessment_episode(rae_id),
    payload jsonb NOT NULL,
    status text NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING','PROCESSING','COMPLETED','RECONCILIATION_REQUIRED','FAILED')),
    created_at timestamptz NOT NULL DEFAULT now(),
    processed_at timestamptz
);

CREATE TABLE audit_event (
    audit_event_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id uuid NULL REFERENCES tenant(tenant_id),
    occurred_at timestamptz NOT NULL DEFAULT now(),
    actor_principal text NOT NULL,
    action text NOT NULL,
    object_type text NOT NULL,
    object_id uuid,
    object_revision bigint,
    reason text,
    causal_episode_id uuid NULL REFERENCES reassessment_episode(rae_id),
    correlation_key text,
    authorization_context jsonb NOT NULL DEFAULT '{}'::jsonb,
    outcome text NOT NULL,
    before_hash text,
    after_hash text
);

CREATE INDEX idx_rps_tenant_program ON regulated_product_system(tenant_id, program_id);
CREATE INDEX idx_cfg_tenant_rps ON product_configuration(tenant_id, rps_id);
CREATE INDEX idx_cpt_tenant_rps ON constituent_part(tenant_id, rps_id);
CREATE INDEX idx_lco_tenant_context ON lifecycle_control_object(tenant_id, rps_id, cfg_id, cpt_id);
CREATE INDEX idx_rsa_tenant_req ON regulatory_applicability(tenant_id, req_id);
CREATE INDEX idx_dep_source ON dependency_edge(tenant_id, source_type, source_id);
CREATE INDEX idx_dep_target ON dependency_edge(tenant_id, target_type, target_id);
CREATE INDEX idx_outbox_pending ON outbox_event(status, created_at);
CREATE INDEX idx_audit_object ON audit_event(tenant_id, object_type, object_id, occurred_at);

-- RLS is enabled now; policies are deliberately added in a separate controlled migration
-- after the application session-context contract is specified and negatively tested.
ALTER TABLE development_program ENABLE ROW LEVEL SECURITY;
ALTER TABLE regulated_product_system ENABLE ROW LEVEL SECURITY;
ALTER TABLE constituent_part ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_configuration ENABLE ROW LEVEL SECURITY;
ALTER TABLE configuration_constituent ENABLE ROW LEVEL SECURITY;
ALTER TABLE lifecycle_control_object ENABLE ROW LEVEL SECURITY;
ALTER TABLE regulatory_applicability ENABLE ROW LEVEL SECURITY;
ALTER TABLE decision_evidence_record ENABLE ROW LEVEL SECURITY;
ALTER TABLE dependency_edge ENABLE ROW LEVEL SECURITY;
ALTER TABLE dependency_coverage ENABLE ROW LEVEL SECURITY;
ALTER TABLE reassessment_episode ENABLE ROW LEVEL SECURITY;
ALTER TABLE idempotency_record ENABLE ROW LEVEL SECURITY;
ALTER TABLE outbox_event ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_event ENABLE ROW LEVEL SECURITY;

COMMIT;

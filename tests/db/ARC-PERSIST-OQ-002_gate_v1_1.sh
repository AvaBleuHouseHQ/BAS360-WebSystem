#!/usr/bin/env bash
set -euo pipefail
src="tests/db/ARC-PERSIST-OQ-002_gate.sh"
tmp="/tmp/ARC-PERSIST-OQ-002_gate_v1_1.generated.sh"
python3 - "$src" "$tmp" <<'PY'
from pathlib import Path
import sys
src = Path(sys.argv[1]).read_text()
old1 = "read -r DEP_HIGH DEP_LOW DEP_UNKNOWN < <(psql -Atqc \"INSERT INTO dependency_edge(tenant_id,source_type,source_id,target_type,target_id,edge_type,materiality,confidence_state,status) VALUES ('$TENANT_A','DER','$DER_A','RPS','$RPS_A','AFFECTS','HIGH','SUPPORTED','CONFIRMED'),('$TENANT_A','DER','$DER_A','RPS','$RPS_A','INFORMS','LOW','SUPPORTED','CONFIRMED'),('$TENANT_A','DER','$DER_A','RPS','$RPS_A','MAY_AFFECT','UNKNOWN','UNKNOWN','ASSERTED') RETURNING dep_id\" | tr '\\n' ' ')"
new1 = "mapfile -t DEP_IDS < <(psql -Atqc \"INSERT INTO dependency_edge(tenant_id,source_type,source_id,target_type,target_id,edge_type,materiality,confidence_state,status) VALUES ('$TENANT_A','DER','$DER_A','RPS','$RPS_A','AFFECTS','HIGH','SUPPORTED','CONFIRMED'),('$TENANT_A','DER','$DER_A','RPS','$RPS_A','INFORMS','LOW','SUPPORTED','CONFIRMED'),('$TENANT_A','DER','$DER_A','RPS','$RPS_A','MAY_AFFECT','UNKNOWN','UNKNOWN','ASSERTED') RETURNING dep_id\")\nif [[ ${#DEP_IDS[@]} -ne 3 ]]; then echo 'FAIL OQ2-09 dependency fixture did not return three IDs'; exit 4; fi\nDEP_HIGH=${DEP_IDS[0]}; DEP_LOW=${DEP_IDS[1]}; DEP_UNKNOWN=${DEP_IDS[2]}"
old2 = "read -r REQ_OLD REQ_NEW REQ_OTHER < <(psql -Atqc \"WITH s AS (INSERT INTO regulatory_source(source_key,issuing_body,title,version_label) VALUES('OQ-SRC','OQ Authority','OQ Rule','v1') RETURNING src_id), oldr AS (INSERT INTO controlled_requirement(src_id,requirement_key) SELECT src_id,'REQ-OLD' FROM s RETURNING req_id), newr AS (INSERT INTO controlled_requirement(src_id,requirement_key,supersedes_req_id) SELECT s.src_id,'REQ-NEW',oldr.req_id FROM s,oldr RETURNING req_id), oth AS (INSERT INTO controlled_requirement(src_id,requirement_key) SELECT src_id,'REQ-OTHER' FROM s RETURNING req_id) SELECT oldr.req_id,newr.req_id,oth.req_id FROM oldr,newr,oth\" )"
new2 = "IFS='|' read -r REQ_OLD REQ_NEW REQ_OTHER < <(psql -Atqc \"WITH s AS (INSERT INTO regulatory_source(source_key,issuing_body,title,version_label) VALUES('OQ-SRC','OQ Authority','OQ Rule','v1') RETURNING src_id), oldr AS (INSERT INTO controlled_requirement(src_id,requirement_key) SELECT src_id,'REQ-OLD' FROM s RETURNING req_id), newr AS (INSERT INTO controlled_requirement(src_id,requirement_key,supersedes_req_id) SELECT s.src_id,'REQ-NEW',oldr.req_id FROM s,oldr RETURNING req_id), oth AS (INSERT INTO controlled_requirement(src_id,requirement_key) SELECT src_id,'REQ-OTHER' FROM s RETURNING req_id) SELECT oldr.req_id,newr.req_id,oth.req_id FROM oldr,newr,oth\")"
if old1 not in src:
    raise SystemExit('ARC-DEV-007 patch target OQ2-09 not found')
if old2 not in src:
    raise SystemExit('ARC-DEV-007 patch target OQ2-11 not found')
src = src.replace(old1, new1).replace(old2, new2)
Path(sys.argv[2]).write_text(src)
PY
bash "$tmp"

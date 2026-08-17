#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

failures=0

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  failures=$((failures + 1))
}

pass() {
  printf 'PASS: %s\n' "$*"
}

require_text() {
  local file="$1"
  local pattern="$2"
  local description="$3"
  if grep -Eq "$pattern" "$file"; then
    pass "$description"
  else
    fail "$file missing: $description"
  fi
}

require_rpc() {
  local rpc="$1"
  require_text README.md "\\b${rpc}\\b" "README documents RPC: $rpc"
  require_text INJECTION-SNIPPET.md "\\b${rpc}\\b" "injection snippet documents RPC: $rpc"
  require_text infra/observability.md "\\b${rpc}\\b|fn_log_\\*" "observability docs preserve RPC family: $rpc"
}

require_view() {
  local view="$1"
  require_text README.md "\\b${view}\\b" "README documents view: $view"
  require_text infra/supabase-tables.md "\\b${view}\\b" "Supabase manifest documents view: $view"
  require_text infra/AGENT-CONTEXT.md "\\b${view}\\b" "agent context documents view: $view"
}

require_mapping() {
  local rpc="$1"
  local protocol="$2"
  require_text README.md "\\| \`${rpc}\` \\| ${protocol} \\|" "README maps $rpc to $protocol"
  require_text INJECTION-SNIPPET.md "\\b${protocol}\\b" "injection snippet mentions protocol for $rpc workflow: $protocol"
}

require_text README.md '\bprotocol_triggers\b' "README documents protocol_triggers"
require_text README.md '\bprotocol_runs\b' "README documents protocol_runs"
require_text infra/supabase-tables.md '\bprotocol_triggers\b' "Supabase manifest documents protocol_triggers"
require_text infra/supabase-tables.md '\bprotocol_runs\b' "Supabase manifest documents protocol_runs"
require_text infra/observability.md '\bprotocol_triggers\b' "observability docs document protocol_triggers"
require_text infra/observability.md '\bprotocol_runs\b' "observability docs document protocol_runs"

for rpc in fn_log_protocol fn_log_blocker_check fn_log_ship_check fn_log_data_trust fn_log_sample_check; do
  require_rpc "$rpc"
done

require_mapping fn_log_blocker_check BLOCKER-CHECK
require_mapping fn_log_ship_check SHIP-OR-SHAM
require_mapping fn_log_data_trust DATA-TRUST
require_mapping fn_log_sample_check SAMPLE-CHECK

for view in v_protocol_compliance v_protocol_compliance_live v_blocker_accuracy v_protocol_usage v_missing_preflights; do
  require_view "$view"
done

if ((failures > 0)); then
  printf '\n%d runtime contract failure(s)\n' "$failures" >&2
  exit 1
fi

printf '\nRuntime contract check passed.\n'

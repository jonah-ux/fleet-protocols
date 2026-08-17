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

require_text README.md '^## Injection Mechanics \(2026-04-16\)$' "README keeps injection mechanics section"
require_text README.md '^### 1\. Smart-proxy \(runtime, every LLM call\)$' "README documents smart-proxy injection surface"
require_text README.md '^### 2\. Claude Code settings hook \(per-session compliance check\)$' "README documents Claude Code hook surface"
require_text README.md '^### 3\. Codex AGENTS\.md \(per-session context\)$' "README documents Codex context surface"
require_text README.md '^### 4\. Cursor \.cursorrules \(per-workspace\)$' "README documents Cursor context surface"
require_text README.md '^### 5\. fleet-brain-loader \(senate containers\)$' "README documents fleet-brain-loader surface"

require_text README.md 'PROTOCOL_INJECTION' "README preserves smart-proxy env gate"
require_text README.md 'session-end-protocol-check\.sh' "README preserves Claude SessionEnd hook path"
require_text README.md '~/.codex/AGENTS\.md' "README preserves Codex AGENTS path"
require_text README.md '\.cursorrules' "README preserves Cursor rules path"
require_text README.md 'v_protocol_compliance_live' "README preserves live compliance view"

require_text INJECTION-SNIPPET.md '^## THE SNIPPET' "injection snippet exposes pasteable snippet"
require_text INJECTION-SNIPPET.md 'PROTOCOL_SNIPPET const' "injection snippet names smart-proxy mirror target"
require_text INJECTION-SNIPPET.md '~/.codex/AGENTS\.md' "injection snippet names Codex mirror target"
require_text INJECTION-SNIPPET.md 'northstar-homebase/\.cursorrules' "injection snippet names Northstar Cursor mirror"
require_text INJECTION-SNIPPET.md 'senate-agents/\.cursorrules' "injection snippet names senate Cursor mirror"
require_text INJECTION-SNIPPET.md '~/fleet-brain/\.cursorrules' "injection snippet names fleet-brain Cursor mirror"
require_text INJECTION-SNIPPET.md 'fleet-protocols repo README "Injection Mechanics" section' "injection snippet points back to README mechanics"

require_text INJECTION-SNIPPET.md 'Done claim -> run PREFLIGHT .*fn_log_ship_check' "snippet maps done claims to PREFLIGHT logging"
require_text INJECTION-SNIPPET.md 'Blocker/missing claim -> run BLOCKER-CHECK .*fn_log_blocker_check' "snippet maps blocker claims to BLOCKER-CHECK logging"
require_text INJECTION-SNIPPET.md 'Any number reported -> run DATA-TRUST .*fn_log_data_trust' "snippet maps reported numbers to DATA-TRUST logging"
require_text INJECTION-SNIPPET.md 'Bulk op >100 rows -> run SAMPLE-CHECK .*fn_log_sample_check' "snippet maps bulk ops to SAMPLE-CHECK logging"
require_text INJECTION-SNIPPET.md 'https://zgexrnpctugtwwssbkss\.supabase\.co/rest/v1/rpc/<fn>' "snippet keeps Supabase RPC endpoint shape"
require_text INJECTION-SNIPPET.md 'v_protocol_compliance_live' "snippet preserves live compliance failure signal"

if ((failures > 0)); then
  printf '\n%d injection-surface validation failure(s)\n' "$failures" >&2
  exit 1
fi

printf '\nInjection-surface validation passed.\n'

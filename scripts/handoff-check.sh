#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

HANDOFF_PATH="L1-HANDOFF.md"

failures=0

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  failures=$((failures + 1))
}

pass() {
  printf 'PASS: %s\n' "$*"
}

require_file() {
  local file="$1"
  if [[ -f "$file" ]]; then
    pass "$file exists"
  else
    fail "$file is missing"
  fi
}

require_text() {
  local pattern="$1"
  local description="$2"
  if grep -Eq "$pattern" "$HANDOFF_PATH"; then
    pass "$description"
  else
    fail "$HANDOFF_PATH missing: $description"
  fi
}

require_file "$HANDOFF_PATH"

if [[ -f "$HANDOFF_PATH" ]]; then
  require_text '^Last refreshed: 2026-05-17$' "handoff refresh date is current for this work packet"
  require_text 'RELATIONSHIPS\.md' "handoff points L1 at the source-of-truth decision"
  require_text 'fleet-brain/protocols' "handoff names the fleet-brain protocol mirror"
  require_text 'protocol_triggers' "handoff preserves Supabase trigger registration obligation"
  require_text 'smart-proxy' "handoff preserves smart-proxy restart obligation"
  require_text 'bash scripts/local-build\.sh' "handoff includes the local pickup verification command"
fi

if ((failures > 0)); then
  printf '\n%d handoff validation failure(s)\n' "$failures" >&2
  exit 1
fi

printf '\nL1 handoff validation passed.\n'

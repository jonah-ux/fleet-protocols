#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

PROGRESS_PATH="PROGRESS-2026-05-16.md"

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
  if grep -Eq "$pattern" "$PROGRESS_PATH"; then
    pass "$description"
  else
    fail "$PROGRESS_PATH missing: $description"
  fi
}

latest_session() {
  awk '
    /^## Session [0-9]+/ {
      if (seen && current_number >= max_number) {
        max_number = current_number
        max_block = block
      }
      current_number = $3 + 0
      block = $0 ORS
      seen = 1
      next
    }
    seen {
      block = block $0 ORS
    }
    END {
      if (seen && current_number >= max_number) {
        max_block = block
      }
      printf "%s", max_block
    }
  ' "$PROGRESS_PATH"
}

latest_session_number() {
  latest_session | awk '/^## Session [0-9]+/ { print $3; exit }'
}

highest_session_number() {
  awk '
    /^## Session [0-9]+/ {
      if (($3 + 0) > max) {
        max = $3 + 0
      }
    }
    END {
      print max + 0
    }
  ' "$PROGRESS_PATH"
}

final_session_number() {
  awk '
    /^## Session [0-9]+/ {
      final = $3 + 0
    }
    END {
      print final + 0
    }
  ' "$PROGRESS_PATH"
}

session_number_count() {
  local session_number="$1"
  awk -v target="$session_number" '
    /^## Session [0-9]+/ && ($3 + 0) == target {
      count++
    }
    END {
      print count + 0
    }
  ' "$PROGRESS_PATH"
}

require_latest_text() {
  local pattern="$1"
  local description="$2"
  if latest_session | grep -Eq "$pattern"; then
    pass "$description"
  else
    fail "latest progress session missing: $description"
  fi
}

require_file "$PROGRESS_PATH"

if [[ -f "$PROGRESS_PATH" ]]; then
  require_text '^# PROGRESS 2026-05-16$' "progress ledger has the expected root heading"
  require_text '^### Files Reviewed$' "progress ledger records reviewed files"
  require_text '^### Files Touched$' "progress ledger records touched files"
  require_text '^### Test Results$' "progress ledger records test results"
  require_text '^### What Remains For L1$' "progress ledger records L1 remainder"

  require_latest_text '^### Session$' "latest session metadata heading"
  require_latest_text '^- Timestamp: 20[0-9]{2}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2} [A-Z]{2,4}$' "latest session timestamp"
  require_latest_text '^### Files Reviewed$' "latest session reviewed-files section"
  require_latest_text '^### Files Touched$' "latest session touched-files section"
  require_latest_text '^### Test Results$' "latest session test-results section"
  require_latest_text '^### What Remains For L1$' "latest session L1 remainder section"
  require_latest_text 'Guardrails honored: no git commands run; no files edited outside this project dir; no external' "latest session guardrail statement"
  require_latest_text 'Final `bash scripts/local-build\.sh` — pass|Final `bash scripts/local-build\.sh` - pass' "latest session includes a passing final local build result"
  require_latest_text 'RELATIONSHIPS\.md|L1-HANDOFF\.md' "latest session preserves the L1 source-of-truth handoff"

  latest_number="$(latest_session_number)"
  highest_number="$(highest_session_number)"
  final_number="$(final_session_number)"
  if [[ -n "$latest_number" && "$latest_number" =~ ^[0-9]+$ && "$highest_number" =~ ^[0-9]+$ && "$latest_number" -eq "$highest_number" ]]; then
    pass "latest session block uses the highest session number"
  else
    fail "latest progress session number ($latest_number) must match highest numbered session ($highest_number)"
  fi

  if [[ -n "$final_number" && "$final_number" =~ ^[0-9]+$ && "$highest_number" =~ ^[0-9]+$ && "$final_number" -eq "$highest_number" ]]; then
    pass "highest session block is appended at EOF"
  else
    fail "final progress session number ($final_number) must match highest numbered session ($highest_number)"
  fi

  highest_count="$(session_number_count "$highest_number")"
  if [[ "$highest_count" =~ ^[0-9]+$ && "$highest_count" -eq 1 ]]; then
    pass "highest session number is unique"
  else
    fail "highest session number ($highest_number) appears $highest_count times"
  fi
fi

if ((failures > 0)); then
  printf '\n%d progress-log validation failure(s)\n' "$failures" >&2
  exit 1
fi

printf '\nProgress-log validation passed.\n'

#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

LOCAL_BUILD_PATH="scripts/local-build.sh"

failures=0

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  failures=$((failures + 1))
}

pass() {
  printf 'PASS: %s\n' "$*"
}

require_text() {
  local pattern="$1"
  local description="$2"
  if grep -Eq "$pattern" "$LOCAL_BUILD_PATH"; then
    pass "$description"
  else
    fail "$LOCAL_BUILD_PATH missing: $description"
  fi
}

require_local_script_call() {
  local script="$1"
  if grep -Fq "bash $script" "$LOCAL_BUILD_PATH"; then
    pass "local build runs $script"
  else
    fail "local build does not run $script"
  fi
}

if [[ -f "$LOCAL_BUILD_PATH" ]]; then
  pass "$LOCAL_BUILD_PATH exists"
else
  fail "$LOCAL_BUILD_PATH is missing"
fi

if [[ -x "$LOCAL_BUILD_PATH" ]]; then
  pass "$LOCAL_BUILD_PATH is executable"
else
  fail "$LOCAL_BUILD_PATH should be executable"
fi

require_text '^run_step\(\)' "local build keeps labeled step helper"
require_text 'printf .*Local build passed\.' "local build keeps explicit success terminator"

while IFS= read -r script; do
  [[ -n "$script" ]] || continue
  if [[ "$script" == "$LOCAL_BUILD_PATH" ]]; then
    pass "local build entrypoint is not nested into itself"
    continue
  fi
  require_local_script_call "$script"
done < <(find scripts -maxdepth 1 -type f -name '*.sh' | sort)

while IFS= read -r script; do
  [[ -n "$script" ]] || continue
  if [[ -f "$script" ]]; then
    pass "local build referenced script exists: $script"
  else
    fail "local build references missing script: $script"
  fi
done < <(awk '
  match($0, /bash scripts\/[A-Za-z0-9_-]+\.sh/) {
    print substr($0, RSTART + 5, RLENGTH - 5)
  }
' "$LOCAL_BUILD_PATH" | sort -u)

if ((failures > 0)); then
  printf '\n%d local-build contract failure(s)\n' "$failures" >&2
  exit 1
fi

printf '\nLocal-build contract validation passed.\n'

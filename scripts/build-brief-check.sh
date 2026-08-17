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

build_brief_candidates() {
  find . \
    -path './.git' -prune -o \
    -path './.prometheus' -prune -o \
    -type f \( -path './prompts/codex-phase-0-build.md' \
      -o -iname '*PROPOSAL*.md' \
      -o -iname '*PLAN*.md' \
      -o -iname '*PHASES*.md' \) \
    -print | sed 's#^\./##' | sort
}

if [[ -f prompts/codex-phase-0-build.md ]]; then
  if [[ -s prompts/codex-phase-0-build.md ]]; then
    pass "primary build prompt exists and is non-empty"
  else
    fail "prompts/codex-phase-0-build.md exists but is empty"
  fi
else
  pass "primary build prompt absent; README fallback is active"
fi

if [[ -s README.md ]]; then
  pass "README.md fallback brief exists and is non-empty"
else
  fail "README.md fallback brief is missing or empty"
fi

candidate_count=0
while IFS= read -r file; do
  [[ -n "$file" ]] || continue
  candidate_count=$((candidate_count + 1))
  if [[ -s "$file" ]]; then
    pass "supplemental build brief is readable: $file"
  else
    fail "supplemental build brief is empty: $file"
  fi
done < <(build_brief_candidates)

if ((candidate_count == 0)); then
  pass "no supplemental PROPOSAL/PLAN/PHASES docs are present"
fi

if ((failures > 0)); then
  printf '\n%d build-brief validation failure(s)\n' "$failures" >&2
  exit 1
fi

printf '\nBuild-brief validation passed.\n'

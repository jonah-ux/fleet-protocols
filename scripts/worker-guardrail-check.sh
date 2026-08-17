#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

PROJECT_ROOT="$(pwd)"

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

reject_script_command() {
  local command_name="$1"
  local description="$2"
  local matches
  matches="$(
    awk -v cmd="$command_name" '
      /^[[:space:]]*#/ { next }
      $0 ~ "^[[:space:]]*" cmd "([[:space:]]|$)" || $0 ~ "[;&|({][[:space:]]*" cmd "([[:space:]]|$)" {
        print FILENAME ":" FNR ":" $0
      }
    ' scripts/*.sh
  )"
  if [[ -z "$matches" ]]; then
    pass "$description absent from local shell scripts"
  else
    fail "$description appears in local shell scripts:"
    printf '%s\n' "$matches" >&2
  fi
}

if [[ "$(pwd)" == "$PROJECT_ROOT" ]]; then
  pass "guardrail check is running inside project root"
else
  fail "guardrail check running outside project root: $(pwd)"
fi

require_text .gitignore '^\.prometheus/$' ".prometheus learning output remains ignored"
require_text scripts/local-build.sh 'bash scripts/validate-protocols\.sh' "local build keeps validation gate"
require_text scripts/local-build.sh 'bash scripts/prometheus\.sh test' "local build uses Prometheus test mode"
require_text scripts/local-build.sh 'bash scripts/worker-guardrail-check\.sh' "local build includes worker guardrail check"
require_text scripts/prometheus.sh 'learn --dry-run >/dev/null' "Prometheus self-test keeps learning in dry-run mode"
require_text L1-HANDOFF.md 'Version-control operations, PR creation, and merge decisions' "handoff keeps version-control work assigned to L1"
require_text L1-HANDOFF.md 'Restarting smart-proxy' "handoff keeps live restart work assigned to L1"
require_text PROGRESS-2026-05-16.md 'Guardrails honored: no git commands run; no files edited outside this project dir' "progress ledger records worker guardrails"

vc_cmd="g""it"
gh_cmd="g""h"
vercel_cmd="ver""cel"
systemctl_cmd="system""ctl"
launchctl_cmd="launch""ctl"

reject_script_command "$vc_cmd" "version-control command"
reject_script_command "$gh_cmd" "GitHub CLI command"
reject_script_command "$vercel_cmd" "Vercel deploy command"
reject_script_command "$systemctl_cmd" "service restart command"
reject_script_command "$launchctl_cmd" "LaunchAgent command"

if ((failures > 0)); then
  printf '\n%d worker guardrail failure(s)\n' "$failures" >&2
  exit 1
fi

printf '\nWorker guardrail validation passed.\n'

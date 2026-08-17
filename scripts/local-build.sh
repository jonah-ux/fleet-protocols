#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

run_step() {
  local label="$1"
  shift
  printf '\n== %s ==\n' "$label"
  "$@"
}

run_step "protocol validation" bash scripts/validate-protocols.sh
run_step "build brief validation" bash scripts/build-brief-check.sh
run_step "worker guardrail validation" bash scripts/worker-guardrail-check.sh
run_step "project scope validation" bash scripts/project-scope-check.sh
run_step "local-build contract validation" bash scripts/local-build-contract-check.sh
run_step "injection surface validation" bash scripts/injection-surface-check.sh
run_step "protocol contract validation" bash scripts/protocol-contract-check.sh
run_step "runtime contract validation" bash scripts/runtime-contract-check.sh
run_step "source-boundary validation" bash scripts/source-boundary-check.sh
run_step "local reference validation" bash scripts/local-reference-check.sh
run_step "prometheus contract validation" bash scripts/prometheus-contract-check.sh
run_step "prometheus self-test" bash scripts/prometheus.sh test
run_step "project manifest freshness" bash scripts/project-manifest.sh document --check
run_step "protocol inventory freshness" bash scripts/protocol-inventory.sh document --check
run_step "prometheus docs freshness" bash scripts/prometheus.sh document --check
run_step "L1 handoff validation" bash scripts/handoff-check.sh
run_step "progress-log validation" bash scripts/progress-log-check.sh
run_step "session review coverage" bash scripts/session-review-coverage-check.sh
run_step "context docs validation" bash scripts/context-docs-check.sh

printf '\nLocal build passed.\n'

#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

failures=0
PROJECT_ROOT="$(pwd)"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  failures=$((failures + 1))
}

pass() {
  printf 'PASS: %s\n' "$*"
}

yaml_get() {
  local path="$1"
  ruby -ryaml -e '
    value = YAML.load_file("prometheus.yaml")
    ARGV[0].split(".").each { |key| value = value.fetch(key) }
    print value
  ' "$path"
}

yaml_list() {
  local path="$1"
  ruby -ryaml -e '
    value = YAML.load_file("prometheus.yaml")
    ARGV[0].split(".").each { |key| value = value.fetch(key) }
    abort("#{ARGV[0]} is not a list") unless value.is_a?(Array)
    puts value
  ' "$path"
}

require_yaml_value() {
  local path="$1"
  local expected="$2"
  local description="$3"
  local actual
  actual="$(yaml_get "$path")"
  if [[ "$actual" == "$expected" ]]; then
    pass "$description"
  else
    fail "$path expected '$expected' but got '$actual'"
  fi
}

require_yaml_pattern() {
  local path="$1"
  local pattern="$2"
  local description="$3"
  local actual
  actual="$(yaml_get "$path")"
  if [[ "$actual" =~ $pattern ]]; then
    pass "$description"
  else
    fail "$path value '$actual' does not match $pattern"
  fi
}

require_list_file_exists() {
  local path="$1"
  local file
  while IFS= read -r file; do
    [[ -n "$file" ]] || continue
    if [[ -f "$file" ]]; then
      pass "$path file exists: $file"
    else
      fail "$path references missing file: $file"
    fi
  done < <(yaml_list "$path")
}

require_yaml_value "prometheus.component_id" "fleet-protocols" "Prometheus component id matches repo"
require_yaml_value "prometheus.kind" "protocol-library" "Prometheus kind matches repo role"
require_yaml_value "prometheus.source.primary_entry" "README.md" "Prometheus primary entry is README"
require_yaml_value "prometheus.self_test.timeout_sec" "90" "Prometheus self-test timeout is declared"
require_yaml_value "prometheus.self_test.output_format" "exit_code" "Prometheus self-test output format is exit_code"
require_yaml_value "prometheus.self_document.source_of_truth" "${PROJECT_ROOT}/docs/PROMETHEUS.md" "Prometheus doc source path is project-local"
require_yaml_value "prometheus.self_document.regenerate_cmd" "bash scripts/prometheus.sh document" "Prometheus regenerate command matches script"
require_yaml_value "prometheus.self_correct.command" "bash -c 'cd ${PROJECT_ROOT} && bash scripts/prometheus.sh correct'" "Prometheus correct command matches script"
require_yaml_value "prometheus.self_learn.telemetry_table" "fleet_tool_brain_state" "Prometheus learn target table is declared"
require_yaml_value "prometheus.self_learn.emit_cmd" "bash scripts/prometheus.sh learn" "Prometheus learn command matches script"

require_yaml_value "prometheus.self_test.command" "bash -c 'cd ${PROJECT_ROOT} && bash scripts/prometheus.sh test'" "Prometheus self-test command points at this project"

require_list_file_exists "prometheus.source.docs"

if yaml_list "prometheus.source.tables" | grep -Fxq "protocol_triggers"; then
  pass "Prometheus source tables preserve protocol_triggers"
else
  fail "prometheus.source.tables must include protocol_triggers"
fi

if yaml_list "prometheus.source.tables" | grep -Fxq "protocol_runs"; then
  pass "Prometheus source tables preserve protocol_runs"
else
  fail "prometheus.source.tables must include protocol_runs"
fi

if yaml_list "prometheus.hr_rules.enforces" | grep -Fxq "HR-126"; then
  pass "Prometheus HR rules preserve goal-chasing"
else
  fail "prometheus.hr_rules.enforces must include HR-126"
fi

if ((failures > 0)); then
  printf '\n%d Prometheus contract failure(s)\n' "$failures" >&2
  exit 1
fi

printf '\nPrometheus contract check passed.\n'

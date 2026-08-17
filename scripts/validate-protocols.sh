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

is_exception_doc() {
  case "$1" in
    README.md|GOAL.md|L1-HANDOFF.md|RELATIONSHIPS.md|PREFLIGHT-LEARNINGS.md|PREFLIGHT.md|INJECTION-SNIPPET.md|PROGRESS-*.md)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_short_protocol() {
  local file="$1"
  [[ "$file" == *.md ]] || return 1
  [[ "$file" == */* ]] && return 1
  is_exception_doc "$file" && return 1
  return 0
}

root_markdown=()
while IFS= read -r file; do
  root_markdown+=("$file")
done < <(find . -maxdepth 1 -type f -name '*.md' -print | sed 's#^\./##' | sort)

index_files=()
while IFS= read -r file; do
  index_files+=("$file")
done < <(
  awk -F'`' '/^\|/ && $2 ~ /\.md$/ { print $2 }' README.md | sort -u
)

required_index_files=()
for file in "${root_markdown[@]}"; do
  if is_short_protocol "$file" || [[ "$file" == "PREFLIGHT.md" ]]; then
    required_index_files+=("$file")
  fi
done

for file in "${index_files[@]}"; do
  if [[ -f "$file" ]]; then
    pass "README index target exists: $file"
  else
    fail "README index target missing: $file"
  fi
done

for file in "${required_index_files[@]}"; do
  if printf '%s\n' "${index_files[@]}" | grep -Fxq "$file"; then
    pass "README indexes protocol: $file"
  else
    fail "README missing protocol index row: $file"
  fi
done

while IFS=$'\t' read -r protocol file; do
  [[ -n "$file" ]] || continue
  expected="${file%.md}"
  if [[ "$protocol" == "$expected" ]]; then
    pass "README protocol label matches file: $file"
  else
    fail "README protocol label '$protocol' does not match file '$file'"
  fi
done < <(
  awk -F'|' '
    /^\|/ && $4 ~ /`[^`]+\.md`/ {
      protocol=$3
      file=$4
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", protocol)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", file)
      gsub(/\*\*/, "", protocol)
      gsub(/`/, "", file)
      print protocol "\t" file
    }
  ' README.md
)

for file in "${root_markdown[@]}"; do
  if is_short_protocol "$file"; then
    line_count="$(wc -l < "$file" | tr -d ' ')"
    if [[ "$line_count" -le 80 ]]; then
      pass "$file stays under 80 lines ($line_count)"
    else
      fail "$file is over 80 lines ($line_count)"
    fi

    if sed -n '1,12p' "$file" | grep -Eq '\*\*(TRIGGER|MANDATORY):\*\*|^> .*TRIGGER:'; then
      pass "$file has a trigger header"
    else
      fail "$file missing trigger header in first 12 lines"
    fi
  fi
done

if [[ -f INJECTION-SNIPPET.md ]]; then
  line_count="$(wc -l < INJECTION-SNIPPET.md | tr -d ' ')"
  if [[ "$line_count" -le 80 ]]; then
    pass "INJECTION-SNIPPET.md stays under 80 lines ($line_count)"
  else
    fail "INJECTION-SNIPPET.md is over 80 lines ($line_count)"
  fi

  if grep -q '^## THE SNIPPET' INJECTION-SNIPPET.md; then
    pass "INJECTION-SNIPPET.md exposes the canonical snippet section"
  else
    fail "INJECTION-SNIPPET.md missing canonical snippet section"
  fi
fi

if ruby -e 'require "yaml"; YAML.load_file("prometheus.yaml")' >/dev/null; then
  pass "prometheus.yaml parses as YAML"
else
  fail "prometheus.yaml is invalid YAML"
fi

if bash scripts/prometheus-contract-check.sh; then
  pass "prometheus.yaml contract matches local project"
else
  fail "prometheus.yaml contract is stale or incomplete"
fi

for file in infra/*.json; do
  [[ -e "$file" ]] || continue
  if node -e 'JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"))' "$file"; then
    pass "$file parses as JSON"
  else
    fail "$file is invalid JSON"
  fi
done

for file in scripts/*.sh; do
  [[ -e "$file" ]] || continue
  if sed -n '1p' "$file" | grep -Fxq '#!/usr/bin/env bash'; then
    pass "$file declares the bash shebang"
  else
    fail "$file missing bash shebang"
  fi

  if sed -n '2p' "$file" | grep -Fxq 'set -euo pipefail'; then
    pass "$file enables strict shell mode"
  else
    fail "$file missing strict shell mode"
  fi

  if grep -Fxq 'cd "$(dirname "$0")/.."' "$file"; then
    pass "$file anchors execution at the project root"
  else
    fail "$file missing project-root cd"
  fi

  if bash -n "$file"; then
    pass "$file passes bash syntax check"
  else
    fail "$file fails bash syntax check"
  fi

  if [[ -x "$file" ]]; then
    pass "$file is executable"
  else
    fail "$file should be executable"
  fi
done

if bash scripts/protocol-inventory.sh document --check; then
  pass "docs/PROTOCOL-INVENTORY.md is current"
else
  fail "docs/PROTOCOL-INVENTORY.md is stale"
fi

if bash scripts/protocol-contract-check.sh; then
  pass "README-indexed protocol contracts are valid"
else
  fail "README-indexed protocol contracts are invalid"
fi

if bash scripts/injection-surface-check.sh; then
  pass "README and INJECTION-SNIPPET.md preserve injection-surface contracts"
else
  fail "README or INJECTION-SNIPPET.md injection-surface contracts are stale"
fi

if bash scripts/source-boundary-check.sh; then
  pass "source-of-truth boundary is preserved"
else
  fail "source-of-truth boundary is stale or unsafe"
fi

if bash scripts/local-build-contract-check.sh; then
  pass "local-build script coverage is complete"
else
  fail "local-build script coverage is stale or incomplete"
fi

if bash scripts/local-reference-check.sh; then
  pass "project-local references resolve"
else
  fail "project-local references are stale or missing"
fi

if bash scripts/project-manifest.sh document --check; then
  pass "docs/PROJECT-MANIFEST.md is current"
else
  fail "docs/PROJECT-MANIFEST.md is stale"
fi

if bash scripts/handoff-check.sh; then
  pass "L1-HANDOFF.md is current"
else
  fail "L1-HANDOFF.md is stale or incomplete"
fi

if bash scripts/progress-log-check.sh; then
  pass "PROGRESS-2026-05-16.md has required session structure"
else
  fail "PROGRESS-2026-05-16.md is missing required session structure"
fi

if bash scripts/context-docs-check.sh; then
  pass "context docs are current"
else
  fail "context docs are stale or incomplete"
fi

if ((failures > 0)); then
  printf '\n%d validation failure(s)\n' "$failures" >&2
  exit 1
fi

printf '\nAll protocol validations passed.\n'

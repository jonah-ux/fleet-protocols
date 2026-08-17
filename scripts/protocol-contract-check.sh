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

readme_protocol_rows() {
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
}

readme_protocol_names() {
  readme_protocol_rows | cut -f1 | sort -u
}

readme_combo_protocols() {
  awk '
    /^## Recommended combos/ { in_combos = 1; next }
    /^---$/ && in_combos { exit }
    in_combos {
      line = $0
      while (match(line, /[A-Z][A-Z-]+/)) {
        print substr(line, RSTART, RLENGTH)
        line = substr(line, RSTART + RLENGTH)
      }
    }
  ' README.md | sort -u
}

readme_shorthand_protocols() {
  awk -F'|' '
    /^\| `fn_/ {
      protocol=$3
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", protocol)
      if (protocol != "Any") print protocol
    }
  ' README.md | sort -u
}

trigger_for_file() {
  local file="$1"
  local trigger
  trigger="$(sed -n '1,12p' "$file" | sed -nE 's/^> \*\*TRIGGER:\*\* ?//p' | head -1)"
  if [[ -z "$trigger" ]]; then
    trigger="$(sed -n '1,12p' "$file" | sed -nE 's/^> \*\*(MANDATORY[^*]*)\*\*.*/\1/p' | head -1)"
  fi
  if [[ -z "$trigger" ]]; then
    trigger="$(sed -n '1,12p' "$file" | sed -nE 's/^> (.*TRIGGER:.*)$/\1/p' | head -1)"
  fi
  printf '%s' "$trigger"
}

while IFS=$'\t' read -r protocol file; do
  [[ -n "$file" ]] || continue

  if [[ ! -f "$file" ]]; then
    fail "README-indexed protocol file missing: $file"
    continue
  fi

  h1="$(sed -n '1p' "$file")"
  if [[ "$h1" == "# $protocol"* ]]; then
    pass "$file H1 starts with protocol label"
  else
    fail "$file H1 '$h1' does not start with '# $protocol'"
  fi

  trigger="$(trigger_for_file "$file")"
  if [[ -n "$trigger" ]]; then
    pass "$file declares a first-screen trigger"
  else
    fail "$file does not declare a trigger in the first 12 lines"
  fi

  if grep -Eq '^(## |### )?STEP [0-9]+:?|^## (CHECKLIST|QUESTIONS|FORMAT|THE QUESTION|RULES|FOR EACH APPROACH|DECISION MATRIX)|^### [0-9]+\. ' "$file"; then
    pass "$file has actionable body structure"
  else
    fail "$file lacks an actionable body marker"
  fi
done < <(readme_protocol_rows)

while IFS= read -r protocol; do
  [[ -n "$protocol" ]] || continue
  if readme_protocol_names | grep -Fxq "$protocol"; then
    pass "README recommended combo protocol is indexed: $protocol"
  else
    fail "README recommended combo references unindexed protocol: $protocol"
  fi
done < <(readme_combo_protocols)

while IFS= read -r protocol; do
  [[ -n "$protocol" ]] || continue
  if readme_protocol_names | grep -Fxq "$protocol"; then
    pass "README shorthand logging protocol is indexed: $protocol"
  else
    fail "README shorthand logging table references unindexed protocol: $protocol"
  fi
done < <(readme_shorthand_protocols)

if ((failures > 0)); then
  printf '\n%d protocol contract failure(s)\n' "$failures" >&2
  exit 1
fi

printf '\nProtocol contract check passed.\n'

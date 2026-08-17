#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

MANIFEST_PATH="docs/PROJECT-MANIFEST.md"
PROGRESS_PATH="PROGRESS-2026-05-16.md"

failures=0

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  failures=$((failures + 1))
}

pass() {
  printf 'PASS: %s\n' "$*"
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

manifest_files() {
  awk -F'|' '
    /^\| `/ {
      file = $2
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", file)
      gsub(/^`|`$/, "", file)
      print file
    }
  ' "$MANIFEST_PATH" | sort -u
}

reviewed_files() {
  latest_session | awk '
    /^### Files Reviewed$/ { in_reviewed = 1; next }
    /^### / && in_reviewed { exit }
    in_reviewed && /^- `/ {
      line = $0
      sub(/^- `/, "", line)
      sub(/`.*/, "", line)
      print line
    }
  ' | sort -u
}

touched_files() {
  latest_session | awk '
    /^### Files Touched$/ { in_touched = 1; next }
    /^### / && in_touched { exit }
    in_touched && /^- `/ {
      line = $0
      sub(/^- `/, "", line)
      sub(/`.*/, "", line)
      print line
    }
  ' | sort -u
}

[[ -f "$MANIFEST_PATH" ]] || fail "$MANIFEST_PATH is missing"
[[ -f "$PROGRESS_PATH" ]] || fail "$PROGRESS_PATH is missing"

if [[ -f "$MANIFEST_PATH" && -f "$PROGRESS_PATH" ]]; then
  missing=()
  while IFS= read -r file; do
    [[ -n "$file" ]] || continue
    if reviewed_files | grep -Fxq "$file"; then
      pass "latest progress reviewed: $file"
    else
      missing+=("$file")
      fail "latest progress missing reviewed-file entry: $file"
    fi
  done < <(manifest_files)

  if ((${#missing[@]} == 0)); then
    pass "latest progress session covers every project-manifest file"
  fi

  while IFS= read -r file; do
    [[ -n "$file" ]] || continue
    if manifest_files | grep -Fxq "$file"; then
      pass "latest touched file is project-local manifest entry: $file"
    else
      fail "latest progress touched-file entry is not in project manifest: $file"
    fi
  done < <(touched_files)
fi

if ((failures > 0)); then
  printf '\n%d session review coverage failure(s)\n' "$failures" >&2
  exit 1
fi

printf '\nSession review coverage passed.\n'

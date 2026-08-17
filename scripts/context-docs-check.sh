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

reject_text() {
  local file="$1"
  local pattern="$2"
  local description="$3"
  if grep -Eq "$pattern" "$file"; then
    fail "$file still contains: $description"
  else
    pass "$description absent"
  fi
}

require_text infra/AGENT-CONTEXT.md '^> \*\*Last verified against local build:\*\* 2026-05-17$' "agent context has current local-build verification date"
require_text infra/AGENT-CONTEXT.md '`prompts/codex-phase-0-build\.md` is the preferred local build brief' "agent context points at the primary build brief"
require_text infra/AGENT-CONTEXT.md 'bash scripts/local-build\.sh' "agent context points at the full local build"
require_text infra/AGENT-CONTEXT.md '`README\.md` and `PREFLIGHT\.md` are documented exceptions' "agent context documents line-cap exceptions"
require_text infra/AGENT-CONTEXT.md 'convenience mirror while `~/fleet-brain/protocols/` remains the source-of-truth path' "agent context matches source-of-truth boundary"
require_text infra/AGENT-CONTEXT.md 'current worker history lives in `PROGRESS-2026-05-16\.md`' "agent context points session history at progress log"
require_text infra/AGENT-CONTEXT.md '`INJECTION-SNIPPET\.md` in this repo is the project-local mirror' "agent context keeps injection snippet mirror wording"
reject_text infra/AGENT-CONTEXT.md '80-line primer' "stale agent-context line-count claim"
reject_text infra/AGENT-CONTEXT.md '/Users/jonahaioperation/' "obsolete Jonah path"
reject_text infra/AGENT-CONTEXT.md 'freshly seeded by scaffold|scaffold commit' "agent-context scaffold-era wording"
reject_text infra/AGENT-CONTEXT.md 'INJECTION-SNIPPET\.md in repo is the canonical text' "stale injection-snippet canonical wording"

require_text infra/env-vars.md '^No environment variables are required to read, validate, or regenerate this repository locally\.$' "env-vars states no local env requirement"
reject_text infra/env-vars.md '<[A-Z_][^>]*>' "env-vars placeholder tokens"
reject_text infra/env-vars.md '<purpose>|<nodes>|<default>|<file>|<field>' "env-vars scaffold placeholders"

require_text infra/observability.md '^This repository has no long-running process, PM2 app, cron, Sentry project, or production log stream of its own\.$' "observability states no local runtime"
require_text infra/observability.md 'Northstar Homebase compliance dashboards' "observability names downstream dashboards"
reject_text infra/observability.md '<[^>]+>' "observability scaffold placeholders"

require_text infra/DEPRECATIONS.md '^None owned by this repository as of 2026-05-17\.$' "deprecations records no active local deprecations"
reject_text infra/DEPRECATIONS.md '<[^>]+>' "deprecations scaffold placeholders"

require_text infra/cron-registry.md '^This repository has no local cron entry, no hosted runtime, and no scheduler-owned command\.' "cron registry records no local cron"
reject_text infra/cron-registry.md '<[^>]+>' "cron registry scaffold placeholders"

require_text infra/related-repos.md '^### fleet-brain$' "related-repos names fleet-brain upstream"
require_text infra/related-repos.md '^### fleet-brain-loader and senate agents$' "related-repos names protocol consumers"
require_text infra/related-repos.md '^### Fleet Supabase$' "related-repos names Supabase external dependency"
reject_text infra/related-repos.md '<[^>]+>' "related-repos scaffold placeholders"

require_text infra/fleet-role.md '^`fleet-protocols` is the project-local, agent-visible mirror' "fleet role uses mirror authority language"
require_text infra/fleet-role.md 'The active source-of-truth path is `~/fleet-brain/protocols/`' "fleet role names active source-of-truth path"
require_text infra/fleet-role.md 'Current source-of-truth path' "fleet role related-artifact summary preserves L1 boundary"
reject_text infra/fleet-role.md 'canonical source is GitHub|Canonical local mirror|scaffold' "fleet-role stale canonical/scaffold wording"

require_text infra/supabase-tables.md '^None directly\.$' "supabase manifest records no direct writes"
require_text infra/supabase-tables.md '^None during local validation\.$' "supabase manifest records no local reads"
reject_text infra/supabase-tables.md '<[^>]+>' "supabase manifest scaffold placeholders"

if node -e 'const fs=require("fs"); const j=JSON.parse(fs.readFileSync("infra/pm2-ecosystem.json","utf8")); if (!Array.isArray(j.apps) || j.apps.length !== 0) process.exit(1);' >/dev/null; then
  pass "pm2 ecosystem records no local apps"
else
  fail "infra/pm2-ecosystem.json should have an empty apps array"
fi

reject_text infra/pm2-ecosystem.json '<[^>]+>' "pm2 ecosystem scaffold placeholders"

if ((failures > 0)); then
  printf '\n%d context-doc validation failure(s)\n' "$failures" >&2
  exit 1
fi

printf '\nContext-doc validation passed.\n'

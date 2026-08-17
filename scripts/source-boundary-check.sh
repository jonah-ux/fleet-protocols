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
    fail "$file contains forbidden boundary drift: $description"
  else
    pass "$description absent"
  fi
}

for file in RELATIONSHIPS.md L1-HANDOFF.md infra/AGENT-CONTEXT.md infra/fleet-role.md infra/related-repos.md infra/supabase-tables.md; do
  if [[ -f "$file" ]]; then
    pass "$file exists for source-boundary validation"
  else
    fail "$file is missing"
  fi
done

require_text RELATIONSHIPS.md 'safe default until Jonah picks' "RELATIONSHIPS preserves safe-default source-of-truth decision"
require_text RELATIONSHIPS.md 'source-of-truth.*fleet-brain/protocols/' "RELATIONSHIPS names fleet-brain/protocols as current source-of-truth"
require_text RELATIONSHIPS.md 'MUST NOT diverge from the fleet-brain canonical text' "RELATIONSHIPS forbids silent mirror divergence"
require_text RELATIONSHIPS.md 'MUST NOT introduce a protocol here without a corresponding `protocol_triggers` row' "RELATIONSHIPS keeps protocol_triggers registration obligation"

require_text L1-HANDOFF.md 'Keep this repo as the agent-visible convenience mirror' "handoff keeps option to remain convenience mirror"
require_text L1-HANDOFF.md 'Merge this repo into `~/fleet-brain/protocols/`' "handoff keeps merge-into-fleet-brain option"
require_text L1-HANDOFF.md 'Promote this repo as canonical' "handoff keeps promote-this-repo option"
require_text L1-HANDOFF.md 'Version-control operations, PR creation, and merge decisions' "handoff keeps version-control work assigned to L1"
require_text L1-HANDOFF.md 'Syncing protocol changes to `~/fleet-brain/protocols/`' "handoff keeps mirror sync assigned to L1"

require_text infra/AGENT-CONTEXT.md 'convenience mirror while `~/fleet-brain/protocols/` remains the source-of-truth path' "agent context preserves mirror/source-of-truth wording"
require_text infra/fleet-role.md 'The active source-of-truth path is `~/fleet-brain/protocols/`' "fleet role preserves active source-of-truth path"
require_text infra/related-repos.md 'Relationship updates that require editing other repositories are L1-owned' "related-repos preserves cross-repo edit boundary"
require_text infra/supabase-tables.md 'This repository has no local runtime and no migrations' "supabase manifest preserves no-local-migration boundary"

reject_text infra/AGENT-CONTEXT.md 'this repo is the canonical|fleet-protocols is canonical' "agent context canonical-ownership claim"
reject_text infra/fleet-role.md 'Canonical local mirror|canonical source is GitHub' "fleet role stale canonical wording"
reject_text infra/related-repos.md 'Fix both sides now|edit the sibling repo from this lane' "related-repos unsafe reciprocal-edit instruction"

if ((failures > 0)); then
  printf '\n%d source-boundary validation failure(s)\n' "$failures" >&2
  exit 1
fi

printf '\nSource-boundary validation passed.\n'

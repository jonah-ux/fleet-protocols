# Agent Context — fleet-protocols

> **Load this file FIRST before editing anything in this repo.** It's the 80-line primer that lets you skip loading 20 other files.
>
> **Last verified against live:** 2026-04-17
> **Owner:** Jonah (human); fleet-brain-loader consumes content

## In 60 seconds

This is **T4 — a framework / shared protocol library**. It contains 15+ injectable cognitive protocols for AI agents: BLOCKER-CHECK, SHIP-OR-SHAM, DATA-TRUST, PREFLIGHT, STALE-CHECK, SAMPLE-CHECK, BLAST-RADIUS, WORTH-IT, HONEST-REPORT, APPROACH-PICKER, OUTREACH-GATE, CONTEXT-HANDOFF, PARALLEL-SAFETY, ROOT-CAUSE, INJECTION-SNIPPET, and the PROTOCOL-INDEX (README.md) that routes agents to the right one. Every senate agent loads these via the `fleet-brain-loader` OpenClaw extension. Claude Code / Codex sessions load them via hook injection. Northstar Homebase reads `protocol_runs` in Supabase to render compliance dashboards. Protocols are NOT code — they are trigger-based cognitive checklists copy-pasted into agent context at runtime.

## The critical invariants (DO NOT BREAK)

1. **Each protocol file stays under 80 lines.** Agents have limited context windows; protocols are additive injections. Long protocols get ignored. Enforce the cap on every edit.
2. **Every protocol is trigger-based + actionable.** Top of each file must state "when to load this" in one line. Every step must produce a concrete artifact (a command output, a number, a yes/no answer). No vague advice.
3. **Adding, renaming, or removing a protocol is FLEET-WIDE.** Every senate agent reads these via fleet-brain-loader; smart-proxy injects the snippet on every LLM call. Changes require Jonah approval and coordinated rollout (see `fleet-role.md` blast radius table).

## The 3 things most likely to bite you

1. **Protocol file names are load-bearing.** fleet-brain-loader, smart-proxy injection snippet, Claude Code SessionEnd hook, Codex AGENTS.md, and five Cursor .cursorrules files all reference these filenames. Renaming `PREFLIGHT.md` without updating all five injection surfaces silently breaks compliance tracking.
2. **README.md is the PROTOCOL-INDEX.** It is the authoritative "when to use which protocol" table. The table in README.md lines 8-23 is the canonical mapping. Keep it in sync with file additions.
3. **The Supabase `protocol_runs` table + `fn_log_*` RPC functions are the compliance contract.** Views `v_protocol_compliance`, `v_protocol_compliance_live`, `v_blocker_accuracy`, `v_protocol_usage`, `v_missing_preflights` all depend on the signatures. Do not rename columns or change `p_*` arg names without a coordinated migration.

## How data flows through this repo

```
This repo (protocol .md files)
  ├─> fleet-brain-loader (OpenClaw plugin) → injected into all 17 senate agents at runtime
  ├─> VPS smart-proxy :3480 → prepends protocol snippet to every LLM request (PROTOCOL_INJECTION=true)
  ├─> ~/.claude/hooks/session-end-protocol-check.sh → compliance check at SessionEnd
  ├─> ~/.codex/AGENTS.md + instructions.md → in Codex CLI session context
  ├─> .cursorrules (5 workspaces) → Cursor session context
  └─> Northstar Homebase compliance dashboards → reads protocol_runs via v_* views

Agent action → protocol read → fn_log_* RPC → protocol_runs table → v_protocol_compliance view → dashboard
```

## Where the state lives

| State | Location | Who writes | Who reads |
|-------|----------|-----------|-----------|
| Protocol text | `*.md` in this repo | Jonah + approved agents | every senate agent, smart-proxy, Claude Code, Codex, Cursor |
| Protocol-run log | `protocol_runs` table (fleet DB zgexrnpctugtwwssbkss) | agents via `fn_log_*` RPC | northstar compliance views, Jonah dashboards |
| Trigger config | `protocol_triggers` table (fleet DB) | Jonah | fleet-brain-loader + agents (`select active=true`) |
| Compliance views | `v_protocol_compliance`, `v_protocol_compliance_live`, `v_blocker_accuracy`, `v_protocol_usage`, `v_missing_preflights` | Supabase (derived) | northstar dashboards, Jonah |

## Dependencies you need to know about

- **Upstream:** none (T4 framework — this repo is standalone; it depends only on fleet Supabase for logging, and that dependency is from CONSUMERS, not from this repo)
- **Downstream:** all 17 senate agents; `fleet-brain` (mounts protocols/ for fleet-brain-loader); VPS smart-proxy; every Claude Code + Codex + Cursor session on every fleet node; northstar-homebase dashboards — see `related-repos.md`
- **Credentials:** no runtime credentials needed by the repo itself. Consumers use `SUPABASE_SERVICE_ROLE_KEY` to call `fn_log_*` — see `env-vars.md`
- **Database:** `protocol_runs` (write target for `fn_log_*`), `protocol_triggers` (trigger config), `v_protocol_compliance*` views — see `supabase-tables.md`
- **Schedule:** none. This repo is not driven by crons. Consumers' crons fire the protocols. `fleet-brain/scripts/backfill-*.py` may reference protocol_runs — see `cron-registry.md`

## When you're editing code, checklist

- [ ] Protocol file stays under 80 lines after edit
- [ ] "When to use this" trigger is at top of file, one line
- [ ] Every step of the protocol produces a concrete artifact
- [ ] If adding/renaming/removing a protocol, update README.md index table
- [ ] If adding a protocol, add trigger row to `protocol_triggers` in Supabase
- [ ] If changing `fn_log_*` signatures, migrate downstream RPC callers in same wave
- [ ] Notify senate container maintainers — fleet-brain-loader re-reads on container restart
- [ ] Run PREFLIGHT on yourself before calling edit done (dogfood the framework)

## Known broken / pending

- No known-broken protocols as of 2026-04-17. `PREFLIGHT-LEARNINGS.md` accumulates failure modes — read it before adding new protocols.
- INJECTION-SNIPPET.md in repo is the canonical text injected by smart-proxy; changes there require a smart-proxy restart on VPS (`systemctl --user restart smart-proxy`).

## Session docs to read for context

- `docs/sessions/` — freshly seeded by scaffold; populate as sessions happen
- External: `~/fleet-brain/protocols/` is the mirror/mount path; `~/fleet-brain/docs/PLAN-FLEET-NORMALIZATION-2026-04-18.md` for the rollout wave

## Cross-repo waves this participates in

- Fleet normalization wave (fleet-brain 2026-04-18 plan) — this scaffold commit is part of that rollout
- Protocol injection wave (2026-04-16) — five injection surfaces wired; ongoing

## Test command + expected output

```bash
# Verify every protocol is under 80 lines
for f in /Users/jonahaioperation/Jonah-Projects/fleet-protocols/*.md; do
  lines=$(wc -l < "$f")
  [ "$lines" -gt 80 ] && echo "OVER CAP: $f ($lines lines)"
done
```
Expected: no output (all protocols under cap). README.md is the one exception (it is the index, not a protocol).

## Deploy command

```bash
# There is no "deploy" — consumers read from disk (fleet-brain mount) or GitHub.
# To propagate changes fleet-wide after merge:
# 1. Push to main
# 2. fleet-brain consumers sync on their own cadence (fleet sync + container restart)
# 3. If smart-proxy snippet changed: ssh vps 'systemctl --user restart smart-proxy'
```
Follow [`infra/fleet-role.md`](./fleet-role.md) for T4 version-cadence rules.

---

**Drift check:** if anything in this file is wrong, update it in the same commit as your code change. Never leave this file stale.

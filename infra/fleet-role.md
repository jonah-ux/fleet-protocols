# Fleet Role — fleet-protocols

**Tier:** T4 (framework / shared protocol library)

**Created:** 2026-04-17 (repo itself predates the infra-doc pass)
**Last reviewed:** 2026-05-17

## Why it exists

`fleet-protocols` is the project-local, agent-visible mirror for the 15+ cognitive protocols that every ASM fleet agent loads before making significant decisions: BLOCKER-CHECK, SHIP-OR-SHAM, DATA-TRUST, PREFLIGHT, STALE-CHECK, SAMPLE-CHECK, BLAST-RADIUS, WORTH-IT, HONEST-REPORT, APPROACH-PICKER, OUTREACH-GATE, CONTEXT-HANDOFF, PARALLEL-SAFETY, ROOT-CAUSE, INJECTION-SNIPPET, plus the PROTOCOL-INDEX (README.md). Per `RELATIONSHIPS.md`, the safe default is that `~/fleet-brain/protocols/` remains the source-of-truth path until Jonah/L1 chooses whether to keep, merge, or promote this repository.

If this repo disappeared:
- Every senate agent would keep running but lose its cognitive guardrails — hallucinated blockers, unverified "done" claims, unchecked numbers, and silent bulk-op failures would compound. Historically these are the #1 source of Jonah-flagged failure modes.
- fleet-brain-loader would fail to inject protocol text → senate agent prompts would be ~600 bytes shorter and miss the invariants.
- Compliance dashboards (`v_protocol_compliance*`) would still function (they read `protocol_runs` table), but the human-readable protocol text would be gone — agents couldn't explain WHY a step failed.
- Claude Code, Codex, Cursor sessions fleet-wide would lose their rules files.

## Runtime

| Node | Path | Entry point | Role |
|------|------|-------------|------|
| (none — this is a docs repo) | — | — | No runtime process |
| m5 | `~/fleet-brain/protocols/` (mirror) | read by `fleet-brain-loader` (OpenClaw plugin) | primary read path |
| vps | `/home/ubuntu/fleet-brain/protocols/` (mirror, mounted read-only into all senate containers) | read at agent load time | senate injection |
| vps | smart-proxy :3480 (INJECTION-SNIPPET.md text embedded) | `PROTOCOL_INJECTION=true` | runtime per-LLM-call injection |
| m4/m5/vps | `~/.claude/hooks/session-end-protocol-check.sh` | SessionEnd hook | compliance verification |

The active source-of-truth path is `~/fleet-brain/protocols/` under the safe-default relationship model in `RELATIONSHIPS.md`. This repository is the convenience mirror and project-local validation surface until Jonah/L1 chooses a final source-of-truth path. GitHub publication and mirror sync remain L1-owned.

## Sync mechanism (T4 — framework)

- **Version cadence:** semver-style commits. No formal tags yet (Phase 1). Target v1.0.0 when all 15 protocols are stable + dogfooded.
- **Propagation:** manual. After merge to `main`:
  1. Pull in `~/fleet-brain/` on each node (or let `fleet sync` handle it)
  2. Restart senate containers so `fleet-brain-loader` re-reads
  3. If `INJECTION-SNIPPET.md` changed: `ssh vps 'systemctl --user restart smart-proxy'`
  4. Cursor / Claude Code / Codex sessions pick up changes on next session start
- **Breaking change policy:** any rename, removal, or semantic change to an existing protocol requires:
  - Jonah approval (sign-off in commit message)
  - 7-day deprecation window with `STALE` banner on the old protocol
  - Coordinated update to all five injection surfaces (see AGENT-CONTEXT.md data-flow diagram)
  - `protocol_triggers` row update in fleet DB

## Upstream dependencies

This repo is standalone. No upstream code dependencies.

- Soft dependency on **fleet DB Supabase** (`zgexrnpctugtwwssbkss`) for consumers that log via `fn_log_*` — but the protocol text itself doesn't require it.

## Downstream consumers

Every consumer of cognitive discipline in the fleet. If this repo's content is wrong, they all get wrong guidance.

- **All 17 senate agents** via `fleet-brain-loader` OpenClaw plugin
  (apex, atlas, cortex, dealbot-agent, forge, ghl-bot, ghost, herald, indeed-screener, jarvis, leadbot, nexus, phantom, reaper, sam, scout, sentinel)
- **VPS smart-proxy** (`:3480`) — INJECTION-SNIPPET.md text prepended to every LLM request
- **Claude Code sessions** on m4, m5 — `.claude/hooks/session-end-protocol-check.sh`
- **Codex CLI sessions** on m5 + VPS — `~/.codex/AGENTS.md` + `instructions.md`
- **Cursor workspaces (5)** — `.cursorrules` files in `northstar-homebase`, `senate-agents`, `Jonah-Projects` root, `fleet-brain`, VPS `senate/`
- **Standalone Jarvis gateway** on VPS — via openclaw.json extension load
- **Northstar Homebase** — reads `protocol_runs` + compliance views for dashboards
- **fleet-brain memory injection** — protocols referenced by memory files throughout `memory/` corpus

Full list + paths in `related-repos.md`.

## Blast radius of changes

| Change type | Blast radius | Approval needed |
|-------------|--------------|-----------------|
| Typo / wording clarification inside existing protocol | Fleet-wide but semantically same | Self-review |
| Add new protocol file (additive) | Fleet-wide (all agents see it once synced) | Jonah approval + README.md index update + protocol_triggers row |
| Rename a protocol | Fleet-wide BREAKING — injection surfaces, fn_log_* routing, memory file refs all hardcode names | Jonah approval + coordinated migration wave + 7-day deprecation window |
| Remove a protocol | Fleet-wide BREAKING — agents trained to run it will 404 | Jonah approval + 30-day deprecation window per CONVENTIONS.md |
| Change `fn_log_*` RPC signatures | Breaks all logging agents until migrated | Jonah approval + wave plan + paired Supabase migration |
| Edit INJECTION-SNIPPET.md | Every LLM call through smart-proxy gets new text | Jonah approval + smart-proxy restart + verify round-trip |
| Edit README.md (PROTOCOL-INDEX) | How agents route protocols changes | Jonah approval (load-bearing doc) |

## Who can modify this repo

- **Primary:** Jonah
- **Approved agents:** fleet-brain maintainers with explicit Jonah sign-off per commit
- **Emergency fallback:** any senate agent operating under Jonah's direct instruction; must still log PREFLIGHT + BLAST-RADIUS before shipping

## Related fleet artifacts

- **Sentry project:** none (no runtime = no errors to track). Agents that CALL protocols report via their own Sentry projects.
- **Memory files referencing this repo:**
  - `~/fleet-brain/memory/MEMORY.md` — indexes protocol trigger table
  - `~/fleet-brain/docs/FLEET-NORTH-STAR.md` — references protocols as pillar of cognitive discipline
  - `~/fleet-brain/docs/PLAN-FLEET-NORMALIZATION-2026-04-18.md` — normalization wave
  - `CLAUDE.md` (fleet root) — "Fleet Protocols (MANDATORY)" section references these by name
- **Dashboard tiles:**
  - Northstar Homebase compliance dashboard (reads `v_protocol_compliance_live`)
  - `v_blocker_accuracy`, `v_protocol_usage`, `v_missing_preflights` — all surface in the compliance view
- **GitHub:** `jonah-ux/fleet-protocols`
- **Current source-of-truth path:** `~/fleet-brain/protocols/` on every fleet node, pending L1 decision in `RELATIONSHIPS.md`

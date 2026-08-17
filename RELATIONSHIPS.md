# fleet-protocols — Project Relationships

> Sibling doc to `README.md` (which is the hand-written protocol-injection contract). Per `check-project-graph-drift` doctrine, this file holds the canonical `Project Relationships` section so that the README's protocol-loading guidance is not mixed with cross-fleet wiring. Created 2026-05-10 to clear project-graph drift gap; companion to [`PROJECT-GRAPH.md`](../../fleet-brain/docs/PROJECT-GRAPH.md) auxiliary table (line 361, tier 2).

> **Defer-to-Jonah question (carried over from [`~/.claude/scratch/8-project-audit-2026-05-10.md`](../../.claude/scratch/8-project-audit-2026-05-10.md)):** this project IS a real, well-formed substrate (13 cognitive-checklist `.md` files + GOAL.md + INJECTION-SNIPPET.md + PREFLIGHT-LEARNINGS.md + an `infra/` + `docs/` layout, README is hand-written), but doctrine for tier-0 fleet-wide cognitive checklists is *"One canonical doc in `~/fleet-brain/docs/`"*. Most fleet-brain protocol files already live at `~/fleet-brain/protocols/`. The open question for Jonah is whether to (a) keep this as tier-2 with `source-of-truth` pointing to `~/fleet-brain/protocols/`, (b) merge into `~/fleet-brain/protocols/` and archive this dir, or (c) promote to tier-1 cluster and have `~/fleet-brain/protocols/` link here as canonical home. **This document encodes option (a) — the safe default until Jonah picks.**

## Project Relationships

> **Tier:** 2 (option a, pending Jonah decision; tier 0 if option c) · **Cluster:** NONE (fleet-wide doctrine) · **Status:** active substrate · **Owner:** Jonah / fleet-doctrine
> **Cross-fleet refs:** [`PROJECT-HIERARCHY-AND-CROSS-REFS.md`](../../fleet-brain/docs/PROJECT-HIERARCHY-AND-CROSS-REFS.md) · [`PROJECT-GRAPH.md`](../../fleet-brain/docs/PROJECT-GRAPH.md) line 361 · canonical protocol corpus at [`../../fleet-brain/protocols/`](../../fleet-brain/protocols/)
> **Authority boundary:** owns the agent-facing protocol injection format + the Supabase `protocol_triggers` logging contract described in `README.md`. MUST NOT diverge from the fleet-brain canonical text without a sync-PR. MUST NOT introduce a protocol here without a corresponding `protocol_triggers` row in the fleet Supabase (`zgexrnpctugtwwssbkss`).

### Sister projects + parent

- **Parent:** [`../../fleet-brain/`](../../fleet-brain/) (tier 0, fleet-doctrine substrate)
- **[`../../fleet-brain/protocols/`](../../fleet-brain/protocols/)** (`source-of-truth`, tier 0) — fleet-brain owns the canonical protocol corpus; this directory is the agent-injection-convenience mirror only. Read first; never override silently.
- **All Studio agents** (`consumer`, tier 1) — Friday / Cortex / Reaper / Jarvis / Dealbot / Forge / JASE consume protocols via the fleet-brain-loader auto-injection at SessionStart. Protocol changes are public-contract changes — every consumer needs notification.
- **VPS senate Docker agents** (`consumer`, tier 1) — Nexus / jarvis-senate / and the other 17 senate-side agents also load these protocols via their `openclaw.json` runtime hooks.
- **MacBook PM2 agents (M4)** (`consumer`, tier 1) — analyst / prospector / librarian / watchdog / ghl-bot — same protocol contract, same load path.
- **No sibling-tier-2 peers** — fleet-protocols is the sole project at this role in the `~/Jonah-Projects/` tree (the canonical home is `~/fleet-brain/protocols/`; this is the agent-visible convenience surface).

### Runtime + source-of-truth refs

- **Fleet Supabase `zgexrnpctugtwwssbkss`** (`runtime`, fleet-infra) — owns `protocol_triggers` table (which protocol fires under which trigger condition) and `agent_ops_logs` (every protocol load + verdict logs here per [`FLEET-SUPABASE-OBSERVABILITY.md`](../asm-shop-portal/docs/FLEET-SUPABASE-OBSERVABILITY.md)). Do not add new protocols here without a matching `protocol_triggers` row.
- **fleet-brain-loader infrastructure** (`runtime`) — the auto-injector reads from `~/fleet-brain/protocols/*.md` or this mirror; the wire format is the agent-visible contract.

### Sister-project boundaries (what this project does NOT do)

- Does not own the canonical protocol text — `~/fleet-brain/protocols/` does (option a). Edits here MUST be paired sync-PRs (or auto-derived) so the two stay aligned.
- Does not run any executable code — pure markdown corpus + an `infra/` config layer.
- Does not skip `protocol_triggers` registration when a new protocol lands.
- Does not edit `state/CLAIMS.md` in fleet-brain without coordinating per fleet-brain HR-1 (single-committer rule).

### Relationship-kind glossary

Use only these `relationship-kind` values: `parent`, `sibling`, `dependency`, `dependent`, `runtime`, `source-of-truth`, `consumer`, `archive`. Definitions in [`PROJECT-HIERARCHY-AND-CROSS-REFS.md`](../../fleet-brain/docs/PROJECT-HIERARCHY-AND-CROSS-REFS.md).

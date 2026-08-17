# Related Repos — fleet-protocols

> **Bidirectional references.** If a repo appears here, YOU appear in THEIR `related-repos.md`. Keep both sides in sync.
>
> Use this file before changing any cross-cutting behavior. Relationship updates that require editing other repositories are L1-owned in this worker lane.

## Upstream (this repo CONSUMES)

### fleet-brain

- **What we consume:** canonical protocol corpus and fleet doctrine references.
- **How we consume it:** `RELATIONSHIPS.md`, `infra/AGENT-CONTEXT.md`, and operator handoff docs point at `../../fleet-brain/protocols/` as the current source-of-truth mirror.
- **Freshness dependency:** no local build dependency; semantic changes must stay aligned before fleet rollout.
- **Degradation mode:** if fleet-brain is unavailable, this repo can still run local validation, but L1 must resolve source-of-truth drift before external propagation.
- **Link:** local sibling `../../fleet-brain/`

## Downstream (consumers of THIS repo)

### fleet-brain-loader and senate agents

- **What they consume from us:** protocol markdown text and the README protocol index.
- **Their code path:** fleet-brain-loader injects protocol text into agent context at runtime.
- **Our SLO to them:** no broken filenames, no stale README mapping, and short protocol files stay under 80 lines.
- **Our notification obligation:** any protocol add/rename/removal or semantic trigger change requires L1 coordination and downstream notification.
- **Link:** see `infra/fleet-role.md` for the full consumer list.

### Northstar Homebase compliance dashboards

- **What they consume from us:** the logging contract described in `README.md` and `INJECTION-SNIPPET.md`.
- **Their code path:** dashboards read fleet Supabase views such as `v_protocol_compliance_live`; agents write through `fn_log_*` RPCs.
- **Our SLO to them:** do not change protocol names, RPC names, or argument semantics without coordinated migration.
- **Our notification obligation:** L1 must notify dashboard owners before any logging-contract change.
- **Link:** local sibling `../northstar-homebase/`

## Peers (coordinate, neither owns the other)

None at this repository tier. `fleet-brain` is treated as upstream/source-of-truth, not a peer.

## External services (non-repo dependencies)

### Fleet Supabase

- **Why we depend on it:** downstream consumers log protocol runs through `fn_log_*` RPCs and read `protocol_triggers`.
- **Fallback if down:** local repo validation still works; consumers should not block primary work solely because logging is temporarily unreachable.
- **Rate limits:** consumer-owned; this repo performs no live Supabase calls in local validation.
- **Credentials:** see `infra/env-vars.md`.
- **Docs:** `README.md`, `INJECTION-SNIPPET.md`, and `infra/supabase-tables.md`.

## Cross-reference verification

When editing this file:

1. Add/update entry here
2. Add/update the reciprocal entry in the other repo's `related-repos.md` unless this worker lane forbids sibling edits
3. If it's a new relationship, update `fleet-brain/docs/REPO-GRAPH.md` (or rebuild via `fleet graph build`)
4. Commit with prefix `infra:` or `feat+infra:`

If you find a one-way reference during audit (this file lists X upstream but X's file doesn't list us downstream), that's a drift alert. Fix both sides.

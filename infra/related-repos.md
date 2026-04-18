# Related Repos — fleet-protocols

> **Bidirectional references.** If a repo appears here, YOU appear in THEIR `related-repos.md`. Keep both sides in sync.
>
> Use this file before changing any cross-cutting behavior — grep `<this-repo>` across all other `related-repos.md` files to find every consumer.

## Upstream (this repo CONSUMES)

### `<repo-name>`

- **What we consume:** <table / API / function / event>
- **How we consume it:** <code path in this repo>
- **Freshness dependency:** <must be < N minutes stale>
- **Degradation mode:** <what we do if upstream fails>
- **Link:** `github.com/jonah-ux/<repo-name>`

## Downstream (consumers of THIS repo)

### `<repo-name>`

- **What they consume from us:** <table / API / function>
- **Their code path:** <how they use it>
- **Our SLO to them:** <freshness or uptime promise>
- **Our notification obligation:** <must tell them if we break compatibility>
- **Link:** `github.com/jonah-ux/<repo-name>`

## Peers (coordinate, neither owns the other)

### `<repo-name>`

- **Shared resource:** <table, API, config we both touch>
- **Ownership rule:** <who writes, who reads; how conflicts resolve>
- **Coordination mechanism:** <CLAIMS.md lock, scheduled windows, mutual lock>

## External services (non-repo dependencies)

### `<service-name>` (e.g., HubSpot API, Salesmsg, GHL)

- **Why we depend on it:** <feature>
- **Fallback if down:** <behavior>
- **Rate limits:** <known limits>
- **Credentials:** <ref to env-vars.md>
- **Docs:** <link>

## Cross-reference verification

When editing this file:

1. Add/update entry here
2. Add/update the reciprocal entry in the OTHER repo's `related-repos.md`
3. If it's a new relationship, update `fleet-brain/docs/REPO-GRAPH.md` (or rebuild via `fleet graph build`)
4. Commit with prefix `infra:` or `feat+infra:`

If you find a one-way reference during audit (this file lists X upstream but X's file doesn't list us downstream), that's a drift alert. Fix both sides.

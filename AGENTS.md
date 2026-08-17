# AGENTS.md — fleet-protocols

> Generated from this project's `prometheus.yaml` by `gen-agents-md`.
> Edit **outside** the generated markers; regeneration preserves your text.

<!-- BEGIN GENERATED: project-contract (gen-agents-md) -->

## Identity

| | |
|---|---|
| slug | `fleet-protocols` |
| path | `~/Jonah-Projects/03-fleet/fleet-protocols` |
| kind | protocol-library |
| owner | fleet |
| git | yes |
| contract | `prometheus.yaml` |

## What this is

Injectable cognitive protocol library for fleet agents: blocker checks, preflight, data trust, root-cause, handoff, and blast-radius gates.

## Before you change anything

1. Read `README.md` first — it is this project's declared entry point.
2. `lore where "<your task>"` to confirm this is the right project, then
   `lore history "<symptom>"` for every prior instance before you fix.
3. `tools-find "<intent>"` before building anything new (R4 tool-first).

## Proving your change

Run this project's own self-test — a claim is not a fact until you show it:

```bash
bash -c 'cd /Users/jonahsnorthstar/Jonah-Projects/03-fleet/fleet-protocols && bash scripts/prometheus.sh test'
```

Self-correct tier is `deterministic`.

## Where your notes go

`~/Jonah-Projects/03-fleet/fleet-protocols/docs/` — this project's doc-home. Append to the existing doc;
run `lore doc-check "<topic>"` first, and never open a new dated one-off file.

Log every fix with:

```bash
lore log --symptom=".." --diagnosis=".." --fix=".."
```

## Shared doctrine

The fleet-wide kernel (the 6 RULES, route-first delegation, telemetry doctrine)
is **not** duplicated here. It is synced into `CLAUDE.md` / `AGENTS.md` at the
fleet root by `doctrine-sync`. Read it there; do not hand-copy it into this file.

<!-- END GENERATED: project-contract -->

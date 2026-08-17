# Codex Phase 0 Build Brief

Use this file as the first project-local build brief for autonomous Codex workers.
If this file conflicts with a direct Jonah/L1 prompt, the direct prompt wins.

## Scope

- Work only inside `/Users/jonahsnorthstar/Jonah-Projects/fleet-protocols`.
- Keep changes additive, local, and non-breaking.
- Do not perform version-control, live fleet, Supabase, deploy, restart, or cross-repo operations.
- Treat `README.md` as the human protocol index and `RELATIONSHIPS.md` plus `L1-HANDOFF.md` as the source-boundary contract.

## Local Build Goal

Advance the repository by strengthening local scaffolds, validators, generated docs,
or handoff artifacts without changing live protocol semantics unless explicitly asked.
Prefer deterministic checks over prose-only notes.

## Required Verification

Run:

```bash
bash scripts/local-build.sh
```

Expected result: exit 0 and final output `Local build passed.`

## Session Ledger

Append the work packet to `PROGRESS-2026-05-16.md` with:

- files reviewed, one-line verdict each
- files touched
- commands/tests run and results
- what remains for L1

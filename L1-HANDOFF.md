# L1 Handoff

Last refreshed: 2026-05-17

## Local State

- Project-local validation is green with `bash scripts/validate-protocols.sh`.
- The full local build gate is green with `bash scripts/local-build.sh`.
- Prometheus self-test is green with `bash scripts/prometheus.sh test`.
- Generated docs are current with `bash scripts/protocol-inventory.sh document --check` and `bash scripts/prometheus.sh document --check`.
- The README routing table and `docs/PROTOCOL-INVENTORY.md` agree on protocol labels, target files, trigger moments, and line counts.

## Project-Local Artifacts

- `README.md` remains the human protocol index.
- `docs/PROTOCOL-INVENTORY.md` is the generated, machine-checkable inventory of README-indexed protocols.
- `docs/PROMETHEUS.md` is generated from `scripts/prometheus.sh document`.
- `scripts/validate-protocols.sh` is the main local validation gate.
- `scripts/local-build.sh` runs the complete local gate for validation, Prometheus, generated-doc freshness, and handoff checks.
- `scripts/protocol-inventory.sh` regenerates and checks the inventory document.
- `scripts/prometheus.sh` owns self-test, self-document, self-correct, and self-learn behavior.
- `scripts/handoff-check.sh` checks that this handoff keeps the live integration decision and verification commands visible.

## L1 Decisions Needed

The open last-mile decision is still the source-of-truth path documented in `RELATIONSHIPS.md`:

1. Keep this repo as the agent-visible convenience mirror and keep `~/fleet-brain/protocols/` canonical.
2. Merge this repo into `~/fleet-brain/protocols/` and archive this directory.
3. Promote this repo as canonical and make `~/fleet-brain/protocols/` link or sync from it.

Until Jonah/L1 picks a path, local work should avoid semantic protocol changes and keep this repository aligned with the current mirror/default posture.

## L1 External Integration

These actions are intentionally outside this worker's authority:

- Version-control operations, PR creation, and merge decisions.
- Syncing protocol changes to `~/fleet-brain/protocols/` or other fleet mirrors.
- Updating Supabase `protocol_triggers` for any future protocol additions or routing changes.
- Restarting smart-proxy if `INJECTION-SNIPPET.md` changes.
- Notifying downstream consumers if protocol names, trigger semantics, or logging contracts change.

## Pickup Command

```bash
cd /Users/jonahsnorthstar/Jonah-Projects/fleet-protocols
bash scripts/local-build.sh
```

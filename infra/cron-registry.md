# Cron Registry — fleet-protocols

> Crons DEFINED BY or CONSUMED BY this repo. Canonical truth at `v_cron_truth` view in fleet Supabase. Drift here vs that view triggers alerts.

## Crons this repo defines

None.

This repository has no local cron entry, no hosted runtime, and no scheduler-owned command. Validation is operator-invoked with `bash scripts/local-build.sh`.

## Crons this repo CONSUMES output from

None.

Downstream consumers may run their own crons that load these protocols or log protocol compliance, but this repository does not depend on their cron outputs for local validation.

## Disabled crons (JONAH-DISABLED or DEPRECATED)

None recorded for this repository as of 2026-05-17.

## Verification

```bash
# Project-local verification:
bash scripts/local-build.sh
```

## Adding a new cron

1. Create file at `/etc/cron.d/fleet-protocols-example` with standard headers (`SHELL`, `PATH`, user)
2. Wrap command with `~/bin/cron-sentry-wrap.sh` for Sentry + `cron-wrap.sh` for Supabase logging
3. Add entry here with all fields filled
4. Commit cron file (if tracked in repo) + this update in same commit

## Removing a cron

1. Rename to `fleet-protocols-example.JONAH-DISABLED-YYYYMMDDTHHMMSSZ`
2. Move entry from "defines" to "disabled" section above
3. Add `DEPRECATIONS.md` entry with 30-day window
4. Never delete silently

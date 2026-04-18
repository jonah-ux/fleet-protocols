# Cron Registry — fleet-protocols

> Crons DEFINED BY or CONSUMED BY this repo. Canonical truth at `v_cron_truth` view in fleet Supabase. Drift here vs that view triggers alerts.

## Crons this repo defines

### `<cron-name>` (e.g., `fleet-reaper-composer`)

- **File:** `/etc/cron.d/<name>` on `<node>`
- **Schedule:** `<cron expression>`
- **Command:** `<full command or script path>`
- **Purpose:** <what it does>
- **SLO:** completes within `<N>` seconds per run
- **On failure:** <retry? alert? silent?>
- **Wrapped with:** `cron-sentry-wrap.sh` + `cron-wrap.sh` for telemetry

<Repeat for each cron.>

## Crons this repo CONSUMES output from

### `<upstream-cron>` (defined in `<other-repo>`)

- **What it produces:** <table, file, API>
- **Our dependency:** <why we need it>
- **Freshness SLO:** must be <N> minutes old or less

## Disabled crons (JONAH-DISABLED or DEPRECATED)

### `<name>.JONAH-DISABLED-<timestamp>`

- **Original schedule:** `<cron expression>`
- **Disabled at:** `<YYYY-MM-DD HH:MM:SSZ>`
- **By:** <Jonah / automated / incident>
- **Reason:** <context>
- **Replacement:** <new cron or "none — removed">
- **Hard-delete by:** <YYYY-MM-DD>

## Verification

```bash
# On node where cron lives:
grep -l "<cron-name>" /etc/cron.d/*

# Check recent executions in Supabase:
curl ".../cron_execution_events?cron_name=eq.<name>&order=started_at.desc&limit=5"
```

## Adding a new cron

1. Create file at `/etc/cron.d/<name>` with standard headers (`SHELL`, `PATH`, user)
2. Wrap command with `~/bin/cron-sentry-wrap.sh` for Sentry + `cron-wrap.sh` for Supabase logging
3. Add entry here with all fields filled
4. Commit cron file (if tracked in repo) + this update in same commit

## Removing a cron

1. Rename to `<name>.JONAH-DISABLED-YYYYMMDDTHHMMSSZ`
2. Move entry from "defines" to "disabled" section above
3. Add `DEPRECATIONS.md` entry with 30-day window
4. Never delete silently

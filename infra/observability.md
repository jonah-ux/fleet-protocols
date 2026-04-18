# Observability — fleet-protocols

## Sentry

- **Project slug:** `<slug>` (e.g., `reaper-pipeline`)
- **Org:** `auto-shop-media`
- **DSN env var:** `SENTRY_DSN` (loaded from `~/.credentials/sentry-dsns.json` field `<name>`)
- **Alert rules:** <link to Sentry alert config>
- **Known patterns:** <recurring errors that are OK to ignore>

## Logging

### agent_ops_logs (Supabase)

- **Agent name (`agent` column):** `<name>`
- **Common actions (`action_type`):** `<file_edit | command | api_call | decision | research>`
- **Insert rate:** ~<N> rows/hour under normal load
- **What we log:** <successes, failures, decisions, api calls>
- **What we DON'T log:** secrets, PII, full body content

### Local logs

- `/tmp/<process-name>.log` — PM2 stdout
- `/var/log/<service>.log` — systemd service stdout (if any)
- `~/logs/<repo-name>/` — repo-specific logs (if any)

## Alerts

### Destination

- **Fleet Alerts bot:** Telegram `@ASM_fleetalerts_bot` (ID 8672375176) — via `fleet-alerts/send-alert.js`
- **Severity levels:** `info | warning | error | critical`

### Alert rules

| Condition | Severity | Channel |
|-----------|----------|---------|
| Cron fails 3x in 6h | warning | Fleet Alerts |
| PM2 process crashes >5x/hr | error | Fleet Alerts + Sentry |
| Supabase insert error rate >10% | critical | Fleet Alerts + Jonah direct |

## Cron telemetry

All crons wrap with `~/bin/cron-sentry-wrap.sh` + `cron-wrap.sh`. Each execution logs to:

- Sentry (only on failure, non-zero exit, or timeout)
- `cron_execution_events` table (every run, success + failure)
- `protocol_runs` table (if the cron runs a protocol-gated command)

## Dashboard tiles

- **Fleet dashboard:** <link to northstar-homebase tile, if any>
- **Repo-specific dashboard:** <link, if any>

## When investigating an issue

1. Check `~/logs/<repo>/` and PM2 logs first (most recent)
2. Check `agent_ops_logs` for the agent name
3. Check Sentry project for stack traces
4. Check `cron_execution_events` if cron-related
5. Cross-ref with `~/fleet-brain/state/ultron-proposals/` for patterns captured by Ultron

## When adding new observability

1. Register alert rule in this doc BEFORE adding the code that fires it
2. Use existing severity ladder, don't invent new levels
3. Route to Fleet Alerts bot — NEVER to Jarvis bot for automated alerts

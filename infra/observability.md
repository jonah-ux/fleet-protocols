# Observability — fleet-protocols

## Sentry

This repository has no long-running process, PM2 app, cron, Sentry project, or production log stream of its own.

Consumer agents and services own their own Sentry projects. This repository's observability responsibility is to keep protocol text, generated docs, and validation commands deterministic so consumers can log protocol compliance correctly.

## Logging

### protocol_runs / agent_ops_logs (Supabase)

- **Protocol-run table:** `protocol_runs`
- **Common RPCs:** `fn_log_protocol`, `fn_log_blocker_check`, `fn_log_ship_check`, `fn_log_data_trust`, `fn_log_sample_check`
- **Trigger config:** `protocol_triggers`
- **What consumers log:** protocol name, verdict, task, evidence, issues, and risks
- **What consumers must not log:** secrets, PII-heavy payloads, or full customer/applicant bodies

### Local logs

- `.prometheus/learning.jsonl` — ignored local learning events from `bash scripts/prometheus.sh learn`
- Command output from `bash scripts/local-build.sh` — primary local health signal

## Alerts

### Destination

No direct alerts originate from this repo. Downstream consumers may alert when protocol compliance fails.

### Alert rules

| Condition | Severity | Channel |
|-----------|----------|---------|
| `v_protocol_compliance_live` shows `DELINQUENT` agents | warning | Northstar Homebase / fleet compliance review |
| `fn_log_*` insert failures in a consumer | error | Consumer-owned alerting |
| Protocol file rename/removal without coordinated rollout | critical | Jonah / L1 review |

## Cron telemetry

This repo defines no cron. Consumer crons should log protocol-gated actions to `protocol_runs` when they execute work covered by these protocols.

## Dashboard tiles

- **Fleet dashboard:** Northstar Homebase compliance dashboards reading `v_protocol_compliance_live`
- **Repo-specific dashboard:** none

## When investigating an issue

1. Run `bash scripts/local-build.sh` in this repo.
2. If local validation passes, inspect the consumer that failed to load or log the protocol.
3. Check `protocol_runs` and `agent_ops_logs` for the consumer's agent name.
4. Check the consumer's own Sentry/PM2/cron telemetry if the issue is runtime-specific.
5. Cross-reference `RELATIONSHIPS.md` and `infra/fleet-role.md` before making source-of-truth changes.

## When adding new observability

1. Prefer adding observability in the consumer that owns the runtime.
2. Keep this doc focused on protocol compliance surfaces, not generic service telemetry.
3. Update `scripts/context-docs-check.sh` when a local observability invariant becomes load-bearing.

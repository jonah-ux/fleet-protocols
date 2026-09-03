# Env Vars — fleet-protocols

> **NEVER commit values. Names + credential-file references only.**
>
> **Credential files are mode 600 on each node's `~/.credentials/`.**

## Required (repo won't start without these)

| Env var | Purpose | Credential source | Nodes |
|---------|---------|-------------------|-------|
| `SUPABASE_URL` | Fleet DB endpoint | hardcoded | all |
| `SUPABASE_SERVICE_ROLE_KEY` | Fleet DB service role | `~/.credentials/supabase.json` field `service_role_key` | m4, m5, vps |
| `<SERVICE>_API_KEY` | `<purpose>` | `~/.credentials/<file>.json` field `<field>` | `<nodes>` |

## Optional

| Env var | Default | Purpose |
|---------|---------|---------|
| `LOG_LEVEL` | `info` | stdout verbosity |
| `<VAR>` | `<default>` | `<purpose>` |

## Runtime env loading

- **PM2:** loaded from `ecosystem.config.js` env block (NEVER hardcode values here — see `pm2-ecosystem.json`)
- **Cron:** loaded from `/home/ubuntu/senate/.env` via `set -a; . <file>; set +a` in cron command
- **Vercel:** set via `vercel env add` CLI, project `<project-slug>`

## Rotation policy

- **High-sensitivity (SUPABASE_SERVICE_ROLE_KEY, Anthropic API):** rotate on exposure; 90-day audit
- **Medium (service API keys):** rotate on departure/incident; annual audit
- **Low (webhook secrets):** rotate on exposure; no scheduled rotation

## When adding a new env var

1. Add the name here with purpose + credential source
2. Add to PM2 ecosystem / Vercel env / cron env as needed
3. Reference the credential file path — NEVER paste the value
4. Commit with prefix `infra:` or `feat+infra:`

## When removing an env var

1. Add to `DEPRECATIONS.md` with 30-day window
2. Grep all consumers (`related-repos.md` + fleet-wide grep)
3. Remove from this file after hard-delete date

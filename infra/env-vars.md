# Env Vars — fleet-protocols

> **NEVER commit values. Names + credential-file references only.**
>
> **Credential files are mode 600 on each node's `~/.credentials/`.**

## Required For Local Repo Work

No environment variables are required to read, validate, or regenerate this repository locally.

`bash scripts/local-build.sh`, `bash scripts/validate-protocols.sh`, and the generated-doc checks run without credentials and do not call live external APIs.

## Used By Downstream Consumers

| Env var | Purpose | Credential source | Nodes |
|---------|---------|-------------------|-------|
| `SUPABASE_URL` | Fleet DB endpoint used by agents that log protocol runs | node env or fleet runtime config | m4, m5, vps |
| `SUPABASE_SERVICE_ROLE_KEY` | Fleet DB service role used by `fn_log_*` protocol logging callers | `~/.credentials/supabase.json` field `service_role_key` | m4, m5, vps |

## Runtime env loading

- **This repo:** none; it has no local service process.
- **PM2 consumers:** load their own env from their own ecosystem files; do not hardcode values here.
- **Cron consumers:** commonly load from `/home/ubuntu/senate/.env` via `set -a; . "$ENV_FILE"; set +a`.
- **Vercel consumers:** manage env through their own Vercel project settings.

## Rotation policy

- **High-sensitivity (SUPABASE_SERVICE_ROLE_KEY, Anthropic API):** rotate on exposure; 90-day audit
- **Medium (service API keys):** rotate on departure/incident; annual audit
- **Low (webhook secrets):** rotate on exposure; no scheduled rotation

## When adding a new env var

1. Add the name here with purpose + credential source
2. Add to the consumer's PM2 ecosystem / Vercel env / cron env as needed
3. Reference the credential file path — NEVER paste the value
4. Commit with prefix `infra:` or `feat+infra:`

## When removing an env var

1. Add to `DEPRECATIONS.md` with 30-day window
2. Grep all consumers (`related-repos.md` + fleet-wide grep)
3. Remove from this file after hard-delete date

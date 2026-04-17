# ASM Fleet Protocol Index

> Injectable cognitive checklists for fleet agents. Each protocol is under 80 lines,
> trigger-based, and designed to be copy-pasted into agent context at runtime.

## When to load which protocol

| Moment | Protocol | File |
|--------|----------|------|
| About to say something is broken/missing/blocked | **BLOCKER-CHECK** | `BLOCKER-CHECK.md` |
| Code ran without errors, about to say "done" | **SHIP-OR-SHAM** | `SHIP-OR-SHAM.md` |
| About to report a number to Jonah | **DATA-TRUST** | `DATA-TRUST.md` |
| Something is not working, starting to debug | **ROOT-CAUSE** | `ROOT-CAUSE.md` |
| About to do something irreversible | **BLAST-RADIUS** | `BLAST-RADIUS.md` |
| Reading a doc/memory and about to act on it | **STALE-CHECK** | `STALE-CHECK.md` |
| Ending a session or handing off work | **CONTEXT-HANDOFF** | `CONTEXT-HANDOFF.md` |
| Multiple agents working on same area | **PARALLEL-SAFETY** | `PARALLEL-SAFETY.md` |
| Giving Jonah a status update | **HONEST-REPORT** | `HONEST-REPORT.md` |
| About to spend 30+ minutes on a task | **WORTH-IT** | `WORTH-IT.md` |
| Just ran a bulk operation (100+ rows) | **SAMPLE-CHECK** | `SAMPLE-CHECK.md` |
| Choosing between multiple solutions | **APPROACH-PICKER** | `APPROACH-PICKER.md` |
| Sending a message outside the fleet | **OUTREACH-GATE** | `OUTREACH-GATE.md` |
| About to call work "done" (final gate) | **PREFLIGHT** | `PREFLIGHT.md` |

## How agents should use these

1. **fleet-brain-loader** injects the relevant protocol based on the agent action type
2. Agents can also load protocols manually: read the file, follow the steps
3. Every step produces a concrete artifact -- a command output, a number, a yes/no answer
4. If a step fails, STOP and address it before continuing

## Design principles

- **Short**: Under 80 lines each. Agents have limited context.
- **Specific**: Exact questions to answer, not vague advice.
- **Actionable**: Every step produces a concrete artifact.
- **Trigger-based**: Clear "when to use this" at the top.
- **Copy-paste friendly**: Inject the entire file into agent context.

## Recommended combos

- **Before deploying**: BLAST-RADIUS -> SHIP-OR-SHAM -> PREFLIGHT
- **Before reporting**: DATA-TRUST -> HONEST-REPORT
- **When debugging**: ROOT-CAUSE -> BLOCKER-CHECK (before declaring blocked)
- **End of session**: CONTEXT-HANDOFF -> PREFLIGHT
- **New task**: WORTH-IT -> APPROACH-PICKER

---

## For Agents: How to Use

### 1. Check which protocol to run

Query the `protocol_triggers` table to find which protocol applies to your current action:

```sql
SELECT protocol_name, trigger_condition
FROM protocol_triggers
WHERE active = true
  AND trigger_keywords && ARRAY['done', 'completed']  -- replace with your action keywords
ORDER BY priority ASC;
```

Or via Supabase REST:
```bash
curl "$SUPABASE_URL/rest/v1/protocol_triggers?active=eq.true&select=protocol_name,trigger_condition,trigger_keywords,priority&order=priority.asc" \
  -H "apikey: $SUPABASE_KEY" -H "Authorization: Bearer $SUPABASE_KEY"
```

### 2. Log a protocol run

**General purpose** (works for any protocol):
```bash
curl -X POST "$SUPABASE_URL/rest/v1/rpc/fn_log_protocol" \
  -H "apikey: $KEY" -H "Authorization: Bearer $KEY" \
  -H "Content-Type: application/json" \
  -d '{"p_agent":"senate-atlas","p_protocol":"PREFLIGHT","p_verdict":"pass","p_task":"Built new API endpoint","p_evidence":{"verified":true}}'
```

**Shorthand functions** for common protocols:

| Function | Protocol | Key params |
|----------|----------|------------|
| `fn_log_protocol` | Any | `p_agent, p_protocol, p_verdict, p_task, p_evidence, p_issues, p_risks` |
| `fn_log_blocker_check` | BLOCKER-CHECK | `p_agent, p_what_was_checked, p_was_actually_blocked, p_evidence` |
| `fn_log_ship_check` | SHIP-OR-SHAM | `p_agent, p_what_was_shipped, p_verification_query, p_result, p_passed` |
| `fn_log_data_trust` | DATA-TRUST | `p_agent, p_metric_name, p_value_primary, p_value_crosscheck, p_match` |
| `fn_log_sample_check` | SAMPLE-CHECK | `p_agent, p_operation, p_rows_affected, p_samples_checked, p_all_passed, p_sample_evidence` |

Verdict values: `pass`, `pass_with_risks`, `fail`, `blocked`, `skipped`

### 3. Monitor compliance

Views available via Supabase REST API:

| View | What it shows |
|------|--------------|
| `v_protocol_compliance` | Per-agent protocol usage (last 7 days) |
| `v_blocker_accuracy` | False alarm rate for BLOCKER-CHECK (last 30 days) |
| `v_protocol_usage` | Which protocols are used vs ignored (last 30 days) |
| `v_missing_preflights` | Completed work items that lack a matching PREFLIGHT run |

### 4. Full protocol text

- **GitHub**: https://github.com/jonah-ux/fleet-protocols
- **On disk**: `fleet-brain/protocols/` (mounted read-only in senate containers)
- **Index**: `fleet-brain/protocols/PROTOCOL-INDEX.md`

## Injection Mechanics (2026-04-16)

Protocols are injected into agent context through **five surfaces** so that every
code path an agent might take exposes them.

### 1. Smart-proxy (runtime, every LLM call)

`VPS:/home/ubuntu/.openclaw/workspace/tools/smart-proxy.js` prepends a
~600-byte protocol snippet to every request's system message before forwarding
to the upstream provider (claude-max, codex-pro, etc). Gated by
`PROTOCOL_INJECTION` env var (default `true`). Disable: set
`PROTOCOL_INJECTION=false` in the systemd user unit and `systemctl --user
restart smart-proxy`.

Verified round-trip: `curl -sX POST VPS:3480/v1/chat/completions ...` with a
prompt asking the model to echo the first line of its system prompt returns
`ASM FLEET PROTOCOLS (mandatory, not optional):` from both gpt-5.4-mini and
claude-sonnet-4-6 providers.

The snippet is a const at the top of `routeRequest`:

```
ASM FLEET PROTOCOLS (mandatory, not optional):
- "Done" claim -> PREFLIGHT + log fn_log_ship_check
- "Blocker/missing" claim -> BLOCKER-CHECK + log fn_log_blocker_check
- Any number reported -> DATA-TRUST + log fn_log_data_trust
- Bulk op >100 rows -> SAMPLE-CHECK + log fn_log_sample_check
Log via POST https://zgexrnpctugtwwssbkss.supabase.co/rest/v1/rpc/<fn> with
service_role_key. Skipping logs shows up as DELINQUENT in
v_protocol_compliance_live.
```

### 2. Claude Code settings hook (per-session compliance check)

`~/.claude/hooks/session-end-protocol-check.sh` runs at SessionEnd on every
m5 + m4 Claude Code session. It counts `protocol_runs` rows for this
session's agent in the last hour — if 0 AND the session had >=3 ops_logs
rows (i.e. it actually did work), it emits an `agent_ops_logs` row with
`action=protocol_compliance_failure`. Those rows surface in
`v_protocol_compliance_live` as `DELINQUENT`.

### 3. Codex AGENTS.md (per-session context)

`~/.codex/AGENTS.md` + `~/.codex/instructions.md` on m5 + VPS +
codex-jarvis-home now include the protocol snippet. Every Codex CLI session
starts with it in context.

### 4. Cursor .cursorrules (per-workspace)

`.cursorrules` created/updated in:
- `~/Jonah-Projects/northstar-homebase/`
- `~/Jonah-Projects/senate-agents/`
- `~/Jonah-Projects/` (root)
- `~/fleet-brain/`
- `/home/ubuntu/senate/` (VPS)

### 5. fleet-brain-loader (senate containers)

Already shipped in `fleet-brain-loader` v2 (commit 4fbb949). Injects the
full protocol text into every senate agent's prompt at runtime. Lands on
next container restart.

## Compliance Dashboard

View: `public.v_protocol_compliance_live` in fleet Supabase. Status bands:

| Band | Meaning |
|------|---------|
| `DELINQUENT` | 0 protocol_runs in 24h despite active ops |
| `POOR` | <30% of ops logged a protocol |
| `OK` | 30-70% coverage |
| `GOOD` | >=70% coverage |
| `LOGS_ONLY` | Protocol runs but no ops activity (pure reporter) |

Query:
```bash
curl -s "$SUPABASE_URL/rest/v1/v_protocol_compliance_live?select=*&limit=20" \
  -H "apikey: $KEY" -H "Authorization: Bearer $KEY" | jq
```

## Honest limitations (2026-04-16)

- **Smart-proxy only covers agents routed through it.** ~60% of fleet LLM
  traffic routes through VPS:3480 (senate, most PM2 pollers, friday DM).
  Claude Code sessions on m5/m4 don't go through smart-proxy — they use
  claude.ai direct. That's why surfaces 2-5 exist.
- **Injection is context, not enforcement.** The model can still ignore
  protocols. But the compliance view makes the ignoring visible, and that
  pressure drives behavior.
- **No automatic retroactive logging.** If an agent forgets to call
  `fn_log_*`, nothing fixes that after the fact. The SessionEnd hook is
  the only safety net, and it only fires on Claude Code sessions.

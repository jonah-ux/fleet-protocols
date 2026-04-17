# PROTOCOL INJECTION SNIPPET

> The short (sub-1KB) system-prompt addendum that gets prepended to every LLM
> call routed through smart-proxy, and the first thing every Claude Code /
> Codex / Cursor session sees. Keep it tight: ~200-600 chars of actual
> injection text + the log shorthand. Anything longer gets trimmed.
>
> Canonical source: fleet-brain/protocols/INJECTION-SNIPPET.md
> Mirrored to:
>   - VPS:/home/ubuntu/.openclaw/workspace/tools/smart-proxy.js (PROTOCOL_SNIPPET const)
>   - ~/.codex/AGENTS.md (m5 + VPS)
>   - ~/Jonah-Projects/northstar-homebase/.cursorrules
>   - ~/Jonah-Projects/senate-agents/.cursorrules
>   - ~/fleet-brain/.cursorrules
>   - fleet-protocols repo README "Injection Mechanics" section

## THE SNIPPET (paste this as-is, do not reword)

```
ASM FLEET PROTOCOLS (mandatory, not optional):
- Done claim -> run PREFLIGHT (fleet-brain/protocols/PREFLIGHT.md) + log fn_log_ship_check
- Blocker/missing claim -> run BLOCKER-CHECK + log fn_log_blocker_check
- Any number reported -> run DATA-TRUST + log fn_log_data_trust
- Bulk op >100 rows -> run SAMPLE-CHECK + log fn_log_sample_check
Log via Supabase RPC at https://zgexrnpctugtwwssbkss.supabase.co/rest/v1/rpc/<fn>
(service_role_key in ~/.credentials/supabase.json). Skipping logs = protocol violation tracked in v_protocol_compliance_live. Full index: fleet-brain/protocols/PROTOCOL-INDEX.md
```

## HOW TO LOG (copy-pasteable curl examples)

PREFLIGHT done-claim:
```
curl -sX POST https://zgexrnpctugtwwssbkss.supabase.co/rest/v1/rpc/fn_log_protocol \
  -H "apikey: $SUPABASE_SERVICE_ROLE_KEY" -H "Authorization: Bearer $SUPABASE_SERVICE_ROLE_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"p_agent\":\"$AGENT_NAME\",\"p_protocol\":\"PREFLIGHT\",\"p_task\":\"<task>\",\"p_verdict\":\"pass\",\"p_evidence\":\"<what you checked>\",\"p_issues\":[],\"p_risks\":[]}"
```

BLOCKER-CHECK:
```
curl -sX POST .../rpc/fn_log_blocker_check \
  -d "{\"p_agent\":\"$AGENT_NAME\",\"p_what_was_checked\":\"<thing>\",\"p_was_actually_blocked\":true,\"p_evidence\":\"<live check output>\"}"
```

DATA-TRUST (number reported):
```
curl -sX POST .../rpc/fn_log_data_trust \
  -d "{\"p_agent\":\"$AGENT_NAME\",\"p_metric_name\":\"MRR\",\"p_value_primary\":124500,\"p_value_crosscheck\":124500,\"p_match\":true}"
```

SHIP-OR-SHAM (after every code change + run):
```
curl -sX POST .../rpc/fn_log_ship_check \
  -d "{\"p_agent\":\"$AGENT_NAME\",\"p_what_was_shipped\":\"<artifact>\",\"p_verification_query\":\"<sql/curl>\",\"p_result\":\"<observed>\",\"p_passed\":true}"
```

SAMPLE-CHECK (bulk ops):
```
curl -sX POST .../rpc/fn_log_sample_check \
  -d "{\"p_agent\":\"$AGENT_NAME\",\"p_operation\":\"UPDATE shops SET x\",\"p_rows_affected\":500,\"p_samples_checked\":5,\"p_sample_evidence\":\"...\",\"p_all_passed\":true}"
```

## WHY THIS MATTERS

Every missing log shows up in `v_protocol_compliance_live` on the Northstar
dashboard as a DELINQUENT / POOR / OK / GOOD band per agent-day.
If your agent shows DELINQUENT for >24h, Jonah sees it and the agent gets
marked untrustworthy in the fleet org chart.

The RPC calls are idempotent (new row per call) and should not fail the
primary task if Supabase is unreachable -- wrap in try/catch, never block.

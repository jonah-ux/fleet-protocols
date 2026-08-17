# Supabase Tables — fleet-protocols

> Every table/view this repo reads or writes. Canonical schema lives in Supabase; this file is the repo-local manifest.

**Fleet DB:** `https://zgexrnpctugtwwssbkss.supabase.co`
**Portal DB (read-only from fleet):** `https://wjstoeqadtiuvfytxwum.supabase.co`

## Tables we WRITE to

None directly.

This repository has no local runtime and no migrations. Downstream agents write protocol compliance rows to the fleet Supabase `protocol_runs` table; that write path belongs to the consuming agent, not this repo.

## Tables we READ from

None during local validation.

README examples mention Supabase REST calls for operators and consumers, including reads from `protocol_triggers`, but `bash scripts/local-build.sh` performs no live database reads.

## Views we depend on

None during local validation.

Downstream dashboards use `v_protocol_compliance`, `v_protocol_compliance_live`, `v_blocker_accuracy`, `v_protocol_usage`, and `v_missing_preflights` as described in `README.md`.

## Migrations owned by this repo

| File | Applied | Purpose |
|------|---------|---------|
| none | not applicable | This repo owns no Supabase migrations. |

## Known drift / schema issues

- None known locally as of 2026-05-17.
- The open source-of-truth question in `RELATIONSHIPS.md` remains a documentation/runtime propagation decision, not a schema drift issue.

## Verification

```bash
# Project-local verification:
bash scripts/local-build.sh
```

## When adding a new table

1. Write migration in `migrations/YYYYMMDD_protocol_example.sql` with up/down
2. Add entry here with full schema
3. Update `related-repos.md` if another repo will consume this
4. Commit migration + manifest in same commit

## When deprecating a table

1. Add to `DEPRECATIONS.md` with 30-day hard-delete window
2. Move entry in this file to a "DEPRECATED" section at the bottom
3. Rename table to `_deprecated_protocol_example_YYYYMMDD` via migration
4. Update any views that referenced it — re-point at replacement or remove
5. Grep fleet for hardcoded references, update each

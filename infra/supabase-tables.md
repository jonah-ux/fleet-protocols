# Supabase Tables — fleet-protocols

> Every table/view this repo reads or writes. Canonical schema lives in Supabase; this file is the repo-local manifest.

**Fleet DB:** `https://zgexrnpctugtwwssbkss.supabase.co`
**Portal DB (read-only from fleet):** `https://wjstoeqadtiuvfytxwum.supabase.co`

## Tables we WRITE to

### `<table-name>`

- **DB:** fleet | portal
- **Purpose:** <what this stores>
- **Insert frequency:** <rate>
- **Key columns:** `<col1, col2, ...>`
- **RLS status:** <enabled | disabled | policies only>
- **Freshness SLO:** <N minutes stale is acceptable>
- **Schema:**
  ```sql
  <columns with types, or link to canonical migration>
  ```

## Tables we READ from

### `<table-name>`

- **DB:** fleet | portal
- **Owner:** <repo that writes it>
- **Our usage:** <which code paths query it>
- **Staleness tolerance:** <N minutes>

## Views we depend on

### `<view-name>`

- **DB:** fleet | portal
- **Underlying tables:** <list>
- **Is this authoritative?** <yes — trusted source | NO — placeholder data, do not trust>
  - (If not authoritative: link to the authoritative source)

## Migrations owned by this repo

| File | Applied | Purpose |
|------|---------|---------|
| `migrations/YYYYMMDD_<name>.sql` | YYYY-MM-DD | <what it does> |

## Known drift / schema issues

- <Any column names that differ from convention — e.g., "gmail_message_id uses `gmail_` prefix but thread_id doesn't">
- <Any tables in a weird state>

## Verification

```bash
# Check live schema matches:
curl "https://zgexrnpctugtwwssbkss.supabase.co/rest/v1/?select=table_name&table_schema=eq.public" | \
  jq '[.[]] | .[] | select(.table_name == "<name>")'
```

## When adding a new table

1. Write migration in `migrations/YYYYMMDD_<name>.sql` with up/down
2. Add entry here with full schema
3. Update `related-repos.md` if another repo will consume this
4. Commit migration + manifest in same commit

## When deprecating a table

1. Add to `DEPRECATIONS.md` with 30-day hard-delete window
2. Move entry in this file to a "DEPRECATED" section at the bottom
3. Rename table to `_deprecated_<name>_YYYYMMDD` via migration
4. Update any views that referenced it — re-point at replacement or remove
5. Grep fleet for hardcoded references, update each

# Deprecations — fleet-protocols

> Every file, table, cron, env var, function, or concept being phased out. Follow the 30-day lifecycle per `fleet-brain/docs/AGENT-LIFECYCLE.md` playbook 5.

## Active deprecations (in the 30-day window)

### `<artifact name>` — e.g., `asm_inbound_emails.gmail_thread_id` column

- **Deprecated:** 2026-04-18
- **Reason:** Column renamed to `thread_id` to match poller payload (fleet-brain commit `0d07279`)
- **Replacement:** Use `thread_id` instead
- **Hard-delete by:** 2026-05-18
- **Callers migrated:** <list or "all" or "none — was unused">
- **Callers remaining:** <list>

## Hard-deleted (historical record)

### `<artifact>`

- **Originally deprecated:** `<date>`
- **Hard-deleted:** `<date>`
- **Reason:** `<why>`
- **Where it went:** `<replacement or "removed, no replacement">`

## Deprecation checklist (follow for every new entry)

- [ ] Entry added ABOVE code/file rename
- [ ] Artifact renamed with timestamp marker (files: `.DEPRECATED-YYYYMMDD`, crons: `.JONAH-DISABLED-YYYYMMDDTHHMMSSZ`, tables: `_deprecated_<name>_YYYYMMDD`)
- [ ] All consumers identified via `related-repos.md` + fleet-wide grep
- [ ] Consumers notified (issue in their repo, or direct edit)
- [ ] Memory files mentioning this artifact get STALE banner
- [ ] Commit with prefix `deprecate:`

## What's NEVER OK

- Silent deletion (the 2026-04-18 `asm_inbound_emails` incident — table renamed without updating poller, views, or this file. Result: 4 days of silent email drops.)
- Forgetting to update `related-repos.md` chains (downstream repos silently break)
- Deprecating without a replacement or migration path (leaves consumers stranded)
- Skipping the 30-day window without explicit Jonah sign-off

# Deprecations — fleet-protocols

> Every file, table, cron, env var, function, or concept being phased out. Follow the 30-day lifecycle per `fleet-brain/docs/AGENT-LIFECYCLE.md` playbook 5.

## Active deprecations (in the 30-day window)

None owned by this repository as of 2026-05-17.

This repo is a protocol text library with no runtime-owned tables, crons, or processes. Any future protocol rename/removal must be listed here before the change ships because protocol names are fleet-wide public contracts.

## Hard-deleted (historical record)

None recorded for this repository as of 2026-05-17.

## Deprecation checklist (follow for every new entry)

- [ ] Entry added ABOVE code/file rename
- [ ] Artifact renamed with timestamp marker, for example `.DEPRECATED-YYYYMMDD`, `.JONAH-DISABLED-YYYYMMDDTHHMMSSZ`, or `_deprecated_artifact_YYYYMMDD`
- [ ] All consumers identified via `related-repos.md` + fleet-wide grep
- [ ] Consumers notified (issue in their repo, or direct edit)
- [ ] Memory files mentioning this artifact get STALE banner
- [ ] Commit with prefix `deprecate:`

## What's NEVER OK

- Silent deletion (the 2026-04-18 `asm_inbound_emails` incident — table renamed without updating poller, views, or this file. Result: 4 days of silent email drops.)
- Forgetting to update `related-repos.md` chains (downstream repos silently break)
- Deprecating without a replacement or migration path (leaves consumers stranded)
- Skipping the 30-day window without explicit Jonah sign-off

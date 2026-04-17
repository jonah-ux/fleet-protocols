# PARALLEL-SAFETY Protocol

> **TRIGGER:** You see another session claim in `fleet-brain/state/CLAIMS.md`, or you are about to edit a file that another session might be editing.

## RULES:

1. READ `CLAIMS.md` before editing ANY shared file
2. If another session claims the file/table/config, DO NOT edit it
3. If you need to work in the same area, coordinate via `fleet_event_log`
4. Never run destructive operations (DROP, DELETE, ALTER) on a table another session is using
5. If you create a new table/view, pick a name that will not conflict
6. Check `git status` -- if there are uncommitted changes from another session, do not clobber them

## CLAIM FORMAT

When starting work on a shared resource, write to `fleet-brain/state/CLAIMS.md`:

```
## [SESSION_ID] - [TIMESTAMP]
CLAIMS: [file/table/config path]
EXPECTED DURATION: [estimate]
CONTACT: [how to reach this session -- event bus topic, PM2 name, etc.]
```

## WHEN IN DOUBT

Work in a separate branch, or create your own table with a session-specific prefix, and merge later.

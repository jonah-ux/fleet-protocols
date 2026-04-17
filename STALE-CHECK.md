# STALE-CHECK Protocol

> **TRIGGER:** You just read a doc, memory file, CLAUDE.md entry, or previous session summary and are about to act on its claims.

## THE QUESTION: Is this still true?

### STEP 1: HOW OLD IS THIS INFORMATION?

- Check file modification date
- Check when the session that wrote it ran
- Check if it references "yesterday" or "last week" (from when?)

### STEP 2: VERIFY THE SPECIFIC CLAIMS

For each factual claim in the document:

- "Table X has N rows" -> `SELECT COUNT(*) FROM X` (is it still N?)
- "Service Y is broken" -> Test service Y right now
- "Credential Z doesnt exist" -> Check `~/.credentials/` right now
- "Process W is running" -> Check PM2/docker/systemd right now
- "Feature V isnt built yet" -> Check if it was built since this doc was written

### STEP 3: ACT ON CURRENT STATE

Use the document as CONTEXT for what was true before.
Act on what you VERIFIED is true now.
If they conflict, trust your live verification. Update the stale doc.

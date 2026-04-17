# CONTEXT-HANDOFF Protocol

> **TRIGGER:** You are about to end a session, or another agent/session needs to pick up your work.

## WHAT TO LEAVE BEHIND:

### 1. WHAT STATE IS EVERYTHING IN?

- What is done (shipped, tested, verified)
- What is in progress (started but not finished -- exact state)
- What is not started but planned
- What is broken that you discovered but did not fix

### 2. WHERE ARE THE ARTIFACTS?

- File paths for everything you created/modified
- Git commit hashes
- Supabase table names for new tables
- Migration numbers

### 3. WHAT DOES THE NEXT AGENT NEED TO KNOW?

- Any gotchas discovered (specific, not vague)
- Credentials used and where they live
- Commands that worked (copy-paste ready)
- Commands that DID NOT work and why

### 4. WHAT NOT TO DO?

- Approaches you tried that failed (so they do not retry)
- Tables/views that look relevant but are stale/wrong
- Documentation that is outdated (flag it)

### 5. WHERE TO START?

One sentence: "Pick up at [specific file/query/task] and do [specific next step]."

**Write this to `fleet-brain/docs/sessions/` as a session manifest, AND update `fleet-brain/ACTIVE.md`.**

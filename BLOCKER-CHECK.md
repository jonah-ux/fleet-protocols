# BLOCKER-CHECK Protocol

> **TRIGGER:** You are about to tell Jonah or log that something is "broken," "missing," "blocked," "doesnt exist," "cant be done," or "empty."

## BEFORE YOU REPORT:

### STEP 1: DID YOU ACTUALLY CHECK?

- [ ] I ran a live command/query (not read a doc or memory)
- [ ] I checked ALL nodes (m4, m5, VPS -- not just one)
- [ ] I checked `fleet have <thing>` or `~/.credentials/` on every node
- [ ] I checked if the table has data: `SELECT COUNT(*) FROM <table>`
- [ ] I tried the API endpoint directly with curl

### STEP 2: DID YOU TRY ALTERNATIVES?

- [ ] If credential missing: checked all 3 credential paths (`~/.credentials/`, `senate/.env`, `~/.secrets/`)
- [ ] If table empty: checked if sync script exists, checked API for data
- [ ] If integration broken: tried a different auth method, checked if endpoint changed
- [ ] If "cant be done": searched `fleet-brain/docs/`, `tools/`, `scripts/` for existing solutions

### STEP 3: EVIDENCE TEST

Can you paste ONE of these that proves it is broken?

- A curl command that returned an error
- A SQL query that returned empty when it should not
- An API response with an error message
- A file path that genuinely does not exist on ANY node

If you cannot paste evidence: YOU HAVE NOT VERIFIED. Go back to Step 1.

### STEP 4: REPORT FORMAT (only after Steps 1-3 pass)

```
[THING] is [STATUS] -- verified at [TIMESTAMP] via [METHOD].
Evidence: [PASTE OUTPUT].
Tried: [ALTERNATIVES].
Conclusion: [ACTUAL BLOCKER OR NOT].
```

## ANTI-PATTERNS (never do these)

- "I dont have the credential" (did you check all nodes?)
- "This table is empty" (did you check if the sync exists?)
- "This is broken" (did you run it yourself or read a doc?)
- "Based on the memory file, X doesnt work" (memory files go stale)
- "The previous session said..." (they might have been wrong)

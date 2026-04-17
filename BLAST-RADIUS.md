# BLAST-RADIUS Protocol

> **TRIGGER:** You are about to do something that cannot be easily undone: DELETE, DROP, ALTER, git push --force, credential rotation, production deploy, sending messages.

### STEP 1: WHAT COULD GO WRONG?

List the 3 worst things that could happen if this goes wrong.

### STEP 2: CAN YOU UNDO IT?

- DELETE: Do you have a backup? Can you re-derive the data?
- DROP TABLE: Is the schema stored somewhere? Is the data recoverable?
- git push --force: Did you check what commits would be lost?
- Credential rotation: Will other systems lose access? (fleet-wide impact)
- Production deploy: Can you rollback? Is the previous version saved?

### STEP 3: TEST FIRST

- Run the query with SELECT first (before UPDATE/DELETE)
- Do a dry run (--dry-run flag, EXPLAIN instead of EXECUTE)
- Test on one row before running on all rows
- Check the row count: "This will affect N rows" -- is N what you expect?

### STEP 4: TELL BEFORE YOU DO

If blast radius > 10 rows, or if it touches production, or if it is irreversible:
**Tell Jonah what you are about to do and what the blast radius is BEFORE doing it.**

### STEP 5: VERIFY AFTER

Run the check that proves the action had the intended effect and did not break anything else.

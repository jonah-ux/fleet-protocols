# SAMPLE-CHECK Protocol

> **TRIGGER:** You just ran an UPDATE/INSERT/DELETE on more than 100 rows, or deployed a migration.

### STEP 1: COUNT CHECK

- How many rows were affected? (RETURNING count, or before/after COUNT(*))
- Is that number what you expected?
- If 0 rows affected: silent failure -- go debug

### STEP 2: RANDOM SAMPLE

Pull 5 random rows from the affected set:

```sql
SELECT * FROM <table> WHERE <your_condition> ORDER BY RANDOM() LIMIT 5;
```

For each row:
- Does it look right?
- Are the new columns populated?
- Are the old columns still intact?
- Do the FKs point to real rows?

### STEP 3: EDGE CASES

Check the extremes:
- The first row (by created_at) -- often the weirdest
- The newest row -- is it getting the treatment?
- A row with NULLs -- did the migration handle nulls?
- A row from a different "type" if the table has mixed data

### STEP 4: DOWNSTREAM

Did anything that depends on this table break?

- Views that SELECT from it
- Triggers that fire on it
- Matviews that need refresh
- Dashboards that query it

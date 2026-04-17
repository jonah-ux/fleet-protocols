# ROOT-CAUSE Protocol

> **TRIGGER:** Something is not working and you are about to start debugging.

## DO NOT: Jump to "try this," "maybe its X," or "let me restart it."
## DO: Follow this diagnosis chain.

### STEP 1: WHAT EXACTLY FAILED?

- Error message (exact text, not paraphrased)
- When it started failing (was it ever working?)
- What changed since it last worked (deploy, config change, credential rotation?)

### STEP 2: WHERE IN THE CHAIN DID IT BREAK?

Draw the data/execution path:

```
Source -> [step 1] -> [step 2] -> [step 3] -> Destination
```

Test each step independently:

- Can you reach the source? (curl it, query it)
- Does step 1 produce output? (check logs, run manually)
- Does step 2 receive step 1 output? (check input format)
- Does the destination receive anything? (check table, log, queue)

The break is between the last working step and the first broken step.

### STEP 3: ISOLATE THE VARIABLE

Change ONE thing at a time. Test. If it did not fix it, change it BACK before trying the next thing.

### STEP 4: VERIFY THE FIX

After fixing, run the FULL chain end-to-end. Not just the step you fixed.
Then run SHIP-OR-SHAM to make sure it actually worked.

## ANTI-PATTERNS

- Restarting the service without understanding why it failed
- Changing 3 things at once and not knowing which one fixed it
- "Works on my machine" without testing production
- Fixing the symptom (clearing the error) instead of the cause

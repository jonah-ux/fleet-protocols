# DATA-TRUST Protocol

> **TRIGGER:** You are about to tell Jonah a metric (MRR, count, %, cost, ROI, etc.)

## THE RULE: Every number you report must be verified two ways.

### STEP 1: COMPUTE IT THE FIRST WAY

Run the query or view that produces the number.

### STEP 2: COMPUTE IT A DIFFERENT WAY

- If MRR = SUM from shop_billing_truth -> verify by counting active shops x price tier
- If "X shops linked" -> verify with a different JOIN path
- If count from a view -> also count from the raw table
- If percentage -> verify numerator AND denominator separately

### STEP 3: DO THEY MATCH?

- Within 5%? Report with confidence.
- 5-20% off? Report both numbers and explain the discrepancy.
- >20% off? Something is wrong. Debug before reporting.

### STEP 4: SANITY CHECK

- Does this number make sense given what you know about the business?
- 225 shops x $3,450 = $776K max MRR. If your number is $2M, something is wrong.
- If "99.9% linked" -- is that because you only checked the linked ones?
- If cost_per_hire is $50 -- is that because you divided spend by total leads instead of hires?

### STEP 5: CONTEXT

Always report: the number, the query that produced it, when it was computed, and what it covers (e.g., "last 30 days" or "all time").

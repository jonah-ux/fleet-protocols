# SHIP-OR-SHAM Protocol

> **TRIGGER:** You wrote code, ran it, and it did not error. You are about to say "done."

## THE QUESTION: Did it actually DO THE THING, or did it just not crash?

### STEP 1: WHAT SHOULD IT HAVE PRODUCED?

- A specific number of rows in a table?
- A file at a specific path?
- An API response with specific content?
- A message sent to a specific destination?

### STEP 2: GO CHECK THE OUTPUT

- [ ] Query the destination table: `SELECT COUNT(*), MAX(created_at) FROM <target>`
- [ ] Read the output file/log
- [ ] Check the recipient (Telegram chat, email inbox, Supabase table)
- [ ] Hit the endpoint and verify the response contains real data

### STEP 3: COMPARE TO EXPECTATION

- Expected N rows? Got N rows? Or got 0 because a silent WHERE clause filtered everything?
- Expected a webhook to fire? Did the destination actually receive it?
- Expected data to look like X? Pull 3 random rows and eyeball them.

### STEP 4: THE SHAM CHECKLIST

Common ways code "works" but is actually a sham:

- [ ] INSERT with ON CONFLICT DO NOTHING -- runs clean but inserts 0 rows
- [ ] UPDATE with a WHERE clause that matches 0 rows -- no error, no effect
- [ ] API call that returns 200 but the body is `{"results": []}`
- [ ] Webhook handler that returns OK but never writes to the DB
- [ ] View that runs but produces 0 rows because a JOIN fails silently
- [ ] Trigger that fires but the function has an early RETURN

**IF ANY OF THESE:** It is a sham. Fix it before reporting done.

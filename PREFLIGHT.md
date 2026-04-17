# PREFLIGHT PROTOCOL v2

> **MANDATORY for every agent, every task, every system, every cron, every deployment.**
> You cannot call something "done" until you've run Preflight and it passes.
> Injected into every agent's context via fleet-brain-loader.
> Learnings log: `fleet-brain/protocols/PREFLIGHT-LEARNINGS.md`

## What is Preflight?

Before finishing ANY task — building a system, fixing a bug, deploying a cron, writing code, designing a workflow — you MUST run this self-critique loop. You cannot skip it. You cannot abbreviate it. It's the difference between "I think this works" and "I proved this works."

## STEP 1: WHAT DID I ACTUALLY BUILD?

Write down concretely:
- What files did I create or modify? (exact paths)
- What processes did I start? (PM2 name, cron file, LaunchAgent)
- What data flows were established? (table A → script B → table C)
- What does it depend on? (smart-proxy, Supabase, SSH, specific ports)
- What does it produce? (rows, files, Telegram messages, API responses)

**If you can't name it specifically, you don't understand what you built.**

## STEP 2: THE 25 QUESTIONS

Answer every one honestly. "Should be fine" is NOT an answer. Either you tested it or you didn't.

### Inputs & Edge Cases
1. What happens when the input is **empty or null**?
2. What happens when the input is **malformed** (wrong type, missing field, extra field)?
3. What happens with **adversarial input** (SQL injection, script injection, XSS)?
4. What happens when there's **1 million rows** instead of 10?
5. What happens when the **same input arrives twice** (idempotency)?

### Dependencies & Failures
6. What happens when the **primary dependency is down** (Supabase, smart-proxy, ollama, SSH)?
7. What happens when the dependency is **slow** (30s timeout instead of 2s)?
8. What happens when the dependency returns an **error** (401, 500, rate limit)?
9. What happens when **credentials expire or rotate**?
10. What happens when the **disk is full**?

### Concurrency & State
11. What happens when **two copies run simultaneously**?
12. What happens when this runs **100 times in a row**? Does anything accumulate unbounded?
13. What happens when the process is **killed mid-execution** (SIGKILL, OOM, reboot)?
14. Does it **survive a reboot**? (PM2 save, LaunchAgent, /etc/cron.d/)
15. What **state** does it leave behind? (temp files, locks, partial writes)

### Data Flow & Safety
16. Trace the **FULL data flow** end-to-end: input → this system → output → consumer → end effect. Is every hop validated?
17. What **upstream systems** feed into this? Are they trustworthy?
18. What **downstream systems** consume the output? Will they break if the output is wrong?
19. Is there a **DNC / safety / compliance** check anywhere in the pipeline? (TCPA, PII, credentials)
20. Could this **accidentally delete, overwrite, or corrupt** existing data?

### Quality & Observability
21. Is the output **visible to Jonah** from the dashboard (not just SSH)?
22. Does this system **learn from its own outputs**? If yes, does the learning loop work?
23. Does the **actual output match the plan**? If a plan doc exists, diff against it.
24. Run it **ONCE with real inputs** and inspect the output **line by line**. Does it look right?
25. What does **Day 30** look like? Does it grow unbounded? Does quality degrade? Does it still fit in RAM?

## STEP 2.5: DATA FLOW TRACE (new from learnings)

Before testing individual weak spots, draw the complete data flow:

```
[Source] → [This System] → [Output] → [Consumer] → [End Effect on User/Business]
```

For EACH hop:
- What validation exists?
- What happens if this hop fails?
- Is there a safety check (DNC, TCPA, PII)?

**This step catches gaps that per-component testing misses** (like the SAM approver → outbound-sender pipeline having zero DNC checks at ANY hop).

## STEP 3: TEST THE WEAK SPOTS

For each "no" or "I don't know" answer from Step 2:

| If you CAN test it now | → **Test it.** Capture the proof (curl output, row count, file content). |
|---|---|
| If the test PASSES | → Mark ✅ TESTED + PASSED with evidence. |
| If the test FAILS | → **Fix it right now.** Then re-test. Mark 🔧 FIXED + RETESTED. |
| If you CAN'T test it | → Mark 📝 KNOWN RISK with specific mitigation plan + when it will be tested. |

**"I think it works" is NOT proof.**
- "I ran it and got X output" IS proof.
- "The row appeared in Supabase with id=N" IS proof.
- "curl returned 200 with body Y" IS proof.
- "I read the file back and line 47 says Z" IS proof.

**Mandatory test:** Run the system ONCE with real inputs and inspect the actual output line-by-line. This catches 80% of bugs.

**Adversarial test:** Feed it one bad input (empty, malformed, duplicate) and verify it handles gracefully.

## STEP 4: SCORECARD

Fill this in for every weak spot from Step 2:

```
| # | Question | Status | Evidence |
|---|----------|--------|----------|
| 1 | Empty input? | ✅ Tested | Returns [] gracefully |
| 6 | Dependency down? | ✅ Tested | v1 run showed parse_failed, no damage |
| 11| Two copies? | 🔧 Fixed | Added lockfile at /tmp/X.lock |
| 19| DNC check? | 📝 Risk | Downstream sender also missing DNC — document for next session |
```

**Rules:**
- ALL 25 questions must have a status (✅, 🔧, or 📝)
- If ANY is 🔧 FIXED, re-test to confirm the fix
- If more than 3 are 📝 KNOWN RISK, **pause and ask: should I really ship this?**
- Zero ❌ FAILED items allowed. Fix them or don't ship.

## STEP 5: SHIP CHECK

Before calling it done, verify ALL of these:

```
□ Every file I created is in the right location and has correct content
□ Every process is confirmed running (pm2 list, docker ps, launchctl print)
□ Every cron has fired at least once (check cron_execution_events or log file)
□ Every Supabase table accepts writes (insert a test row, delete it)
□ Backups exist for anything I modified
□ Documentation is updated (fleet-brain session manifest, CLAUDE.md, memory)
□ Telegram notification sent if the change is user-visible
□ Other agents know about this (updated in AGENTS.md, CONTEXT.md, or via introspection)
□ This survives a reboot (PM2 save, cron.d not crontab, LaunchAgent not manual)
□ The scorecard from Step 4 has zero ❌ FAILED items
□ Output is visible to Jonah from the dashboard (not just SSH)
□ The data flow trace has no unvalidated hops
□ Day-30 scenario considered (growth, drift, quality decay)
```

**ALL boxes checked → you may call it done.**
**ANY box unchecked → you are not done.**



## Tier System (context-aware, not just size)

Pick the tier AND the context. Different work needs different checks.

### 🟢 QUICK (small fix, 2 min)
_Typo fix, doc update, memory file, one-line config change, message tweak_

**Always answer:**
1. Did I read the file back after editing? Does it look right?
2. Could this accidentally delete or break something that was working?
3. Is this change visible to Jonah (dashboard, Telegram, or does he need to SSH)?
4. If this touches outbound messages: does the tone match ASM voice? No AI references? Personalized?
5. Git committed + pushed?

**Context-specific add-ons:**

| If you're editing... | Also check |
|---|---|
| **GHL/SAM/outbound messages** | TCPA hours (7am-8pm CT)? DNC respected? SAM would approve this? Phone number is (760) 493-6821 not Jonah's personal? |
| **Dashboard UI** | Browser-tested? No dead buttons? Data source returns real data? |
| **CLAUDE.md / SOUL.md / memory** | No sensitive info (equity, salary, Greg)? Accurate as of today? |
| **Supabase row/RPC** | Right database (fleet vs portal)? Column names match schema? |

---

### 🟡 STANDARD (medium fix, 5 min)
_Bug fix, feature addition, config change, dashboard deploy, API endpoint, cron schedule change_

**Always answer (10 core questions):**
1. What exactly did I change? (file paths, line numbers)
2. What happens if the input is empty or malformed?
3. What happens if the primary dependency is down?
4. What happens if the dependency returns an error?
5. What happens if two copies run simultaneously?
6. What happens if the process is killed mid-execution?
7. Does this survive a reboot?
8. Could this accidentally delete, overwrite, or corrupt existing data?
9. Is the output visible to Jonah from the dashboard?
10. Run it ONCE with real inputs — inspect the output line by line.

**Context-specific add-ons:**

| If you're working on... | Also check |
|---|---|
| **HubSpot integration** | Correct pipeline stage names? Rate limit handling (100 calls/10s)? Right portal (deal vs contact)? Matching by email or ID? |
| **Zoho integration** | Full pagination? Fuzzy name matching? Rate limits (200/min)? Correct stage mapping (per `project_zoho_stage_mapping_fix.md`)? |
| **Monday.com** | Board ID correct? Column mapping? Webhook URL valid? |
| **GHL bot / outreach** | TCPA 7am-8pm CT? DNC check in pipeline? SAM approval gate? Not using Jonah's personal phone? Message personalized (name + shop)? No AI references? Rate limit (10 msg/hr)? |
| **Dashboard / React** | Browser-tested golden path + edge case? No new dead buttons? Data source returns real data not stale cache? Deployed via git push (NEVER vercel deploy)? |
| **iOS app** | Only on m5? Correct build number (check TestFlight)? Signing cert valid? Schema matches Supabase? |
| **Sentry / monitoring** | Alert rule fires? Webhook reaches bridge? Telegram delivers? Not spamming (rate limit)? |
| **Cron job** | In /etc/cron.d/ (not crontab)? Uses cron-sentry-wrap.sh? Schedule is UTC? Writes to cron_execution_events? |
| **PM2 process** | pm2 save after start? Correct node/port? Memory under 200MB? Logs rotating? |
| **Senate agent config** | Right container (senate-<name>)? File in workspace/ (not agent root)? models.json has smart-proxy? SOUL.md updated? |

---

### 🔴 FULL (major build, 10-15 min)
_New system, new autonomous loop, new pipeline, new repo, anything that runs without human supervision_

**All 25 questions + data flow trace + these:**

26. Who OWNS this system long-term? (Which agent monitors it? Which cron checks its health?)
27. What does the FIRST FAILURE look like? (How will Jonah know something went wrong?)
28. What's the ROLLBACK plan? (One command to undo everything?)
29. Is there a KILL SWITCH? (How to stop it immediately if it goes rogue?)
30. Does this integrate with the daily chain? (Introspection → Town Hall → Night-watch → Context-refresh?)
31. Has the Preflight scorecard been logged to `preflight_runs` in Supabase?

**Context-specific add-ons for major builds:**

| If you're building... | Also check |
|---|---|
| **New autonomous loop** | What prevents infinite execution? Memory bounded? Backpressure if queue fills? Telegram on first failure? |
| **New Supabase table** | Indexes on query patterns? RLS rules? Not-null constraints? Referenced in any existing views? |
| **New GitHub repo** | README with DR instructions? .gitignore? Release-guard hook? Drift-nagger cron? |
| **New cron pipeline** | Wrapped with cron-sentry-wrap.sh? Writes to events table? Idempotent (safe to re-run)? Backup before destructive ops? |
| **New agent integration** | SOUL.md updated? TOOLS.md updated? AGENTS.md updated? Fleet-brain-loader will inject context? Smart-proxy routes correctly? |
| **Cross-node system** | Works when target node is asleep/unreachable? Tailscale IP correct? SSH key valid? Timeout handling? |
| **Customer-facing change** | Tested on staging (not prod)? Portal DB (not fleet DB)? No PII exposure? Correct shop count (225 portal_shops, 204 active)? |

---

### How to pick the tier

```
Is it a NEW autonomous system/loop/pipeline?     → 🔴 FULL
Is it a bug fix, feature, config, or deploy?      → 🟡 STANDARD
Is it a doc edit, typo, message tweak, or 1-liner? → 🟢 QUICK
Not sure?                                          → Go one tier UP.
```

**A 5-minute Standard Preflight catches bugs that would take 5 hours to debug in production.**

## When to run Preflight

- **ALWAYS** before telling the user "done" / "shipped" / "deployed"
- **ALWAYS** before committing + pushing code
- **ALWAYS** before installing a new cron or PM2 process
- **ALWAYS** before modifying another agent's files
- **ALWAYS** before creating a new Supabase table
- After fixing a bug (the fix might introduce a new one)
- After restoring something from backup (the restore might be partial)

## Anti-patterns (things Preflight prevents)

- ❌ "I deployed it and it should work" → PROOF or it didn't happen
- ❌ "I fixed the config and restarted" → did you verify the restart?
- ❌ "The cron is installed" → did it fire? did the telemetry land?
- ❌ "I updated the file" → did you read it back?
- ❌ "It works on my machine" → does it work on the target machine?
- ❌ "The test passed" → did you test the failure case too?
- ❌ "It should be fine in production" → what does Day 30 look like?
- ❌ "I'll fix that later" → if it's a known risk, document it NOW with a mitigation plan

## The Preflight Mindset

Speed comes from shipping right the first time, not from shipping fast and fixing later.

A 5-minute Preflight saves a 5-hour debugging session.

Every bug caught in Preflight is a bug that never reaches Jonah.

# Preflight Protocol — Learnings Log

> Each time Preflight runs, log what it found (or missed) here.
> Use these patterns to improve the protocol itself.

## Run 1: Introspection Engine v2 (2026-04-16)

**Bugs found:** 1 real bug (missing lockfile → overlap risk)
**Risks documented:** 2 (growth collapse untested, Supabase-down mismatch)
**Time:** ~3 min
**Verdict:** The lockfile bug would have caused double-patching of SOUL.md files on the first day two cron ticks overlapped. Real production bug caught before it hit.

**What Preflight was GOOD at:**
- Step 2 "what happens when two copies run simultaneously" directly surfaced the lockfile gap
- Step 3 "test it" forced actually checking if `/tmp/fleet-introspection.lock` exists (it didn't)
- Step 5 checklist caught that documentation was updated

**What Preflight MISSED:**
- Didn't ask "what does the LLM output look like for a SPECIFIC agent?" — we found the v1 JSON parse bug only because run 1 failed. Preflight should have included "run it once and inspect the actual output" as a mandatory Step 3 test.
- Didn't ask "how does this compare to the PLAN?" — the v2 deep plan described growth management, but Preflight didn't check if it was implemented correctly.

**Protocol improvement:** Add to Step 3: "Run the system ONCE with real inputs and inspect the actual output line-by-line."

---

## Run 2: SAM Auto-Approver (2026-04-16)

**Bugs found:** 1 risk (no DNC check → could approve message to opted-out contact)
**Risks documented:** 1 (DNC bypass, mitigated by downstream sender)
**Time:** ~2 min
**Verdict:** DNC gap is a real TCPA compliance risk. Outbound-sender ALSO has 0 DNC checks (discovered during Preflight!). This means a message could go from queue → approved → sent without any DNC check in the entire pipeline.

**What Preflight was GOOD at:**
- Step 2 "what if it approves something it shouldn't" caught the DNC gap
- Cross-checking the downstream system (outbound-sender) revealed the gap is fleet-wide, not just the approver

**What Preflight MISSED:**
- Didn't test with an ACTUAL DNC contact to prove the gap exists
- Didn't check if HubSpot DNC field is even populated (the check might be meaningless if the field is empty)

**Protocol improvement:** Add to Step 2: "Trace the FULL data flow, not just this component. Check upstream AND downstream for safety gaps."

---

## Run 3: Sentry Direct Executor (2026-04-16)

**Bugs found:** 1 design gap (real-bug dispositions not auto-escalated to tickets)
**Risks documented:** 0 (all other checks passed)
**Time:** ~2 min
**Verdict:** The executor triages issues but ONLY the direct-executor team sees "real-bug" dispositions. Jonah and ticket agents don't know about them. A real production bug could be triaged, noted, and forgotten.

**What Preflight was GOOD at:**
- Reviewing actual triage outputs (found both "transient" and "real-bug" dispositions — proves discrimination works)
- PM2 health check (93MB, 3 restarts in 5h — reasonable)

**What Preflight MISSED:**
- Didn't test the Telegram message format for readability (does Jonah actually understand the triage DMs?)
- Didn't check if triage results are visible in the dashboard (they're not — dashboard gap plan exists but not built)

**Protocol improvement:** Add to Step 5: "Is the output VISIBLE to the human? Can Jonah see this working without SSHing?"

---

## Run 4: Town Hall (2026-04-16)

**Bugs found:** 0
**Risks documented:** 1 (quality scores 2/10 — prompt quality issue, not Town Hall issue)
**Time:** ~1 min
**Verdict:** Town Hall itself is solid. The downstream quality problem (local models producing generic outputs) is a separate concern.

**What Preflight was GOOD at:**
- Separating "does the system work?" from "does the output have value?" — these are different questions
- Rate-limit check (smart-proxy handles 20 calls easily)

**What Preflight MISSED:**
- Didn't verify the FEEDBACK LOOP actually works (do quality scores from yesterday affect today's Town Hall? Need to test over 2+ days)

**Protocol improvement:** Add to Step 2: "Does this system LEARN from its own outputs? If yes, test the learning path."

---

## Protocol Improvements Identified (cumulative)

### Add to Step 2 (design review):
- "Trace the FULL data flow end-to-end — check upstream AND downstream systems for safety gaps"
- "Does this system LEARN from its own outputs? Test the learning path."

### Add to Step 3 (testing):
- "Run the system ONCE with real inputs and inspect the actual output line-by-line"
- "Test with an adversarial input (malformed data, edge case, empty, DNC contact, etc.)"

### Add to Step 5 (ship check):
- "Is the output VISIBLE to the human? Can Jonah see this working from the dashboard without SSHing?"
- "Does this match what was described in the PLAN? If a plan doc exists, diff against it."

### New Step 2.5 (proposed): DATA FLOW TRACE
Before testing individual weak spots, trace the complete data flow:
```
Input → [this system] → Output → [what consumes the output?] → [end user/effect]
```
For each hop: what validation exists? What happens if this hop fails?
This would have caught the DNC gap (approval → send → no DNC check at either hop).

---

## Run 5: Local-Model Executor (2026-04-16)

**Bugs found:** 1 real bug (orphan items stuck in 'executing' after process crash/reboot)
**Risks documented:** 1 (dashboard visibility gap)
**Time:** ~3 min
**Verdict:** Orphan cleanup added to startup — resets stale 'executing' items on PM2 restart.

**What Preflight was GOOD at:**
- Q13 "killed mid-execution" directly surfaced the orphan problem
- Full data flow trace verified all 5 hops work
- 25 questions hit systematically — didn't miss the concurrency category

**Protocol improvement from this run:**
- Q13 should also ask: "is there a WATCHDOG that detects orphaned state?" Not just "what happens" but "who cleans up after?"
- Added to next revision.

## Cumulative stats (5 runs)
- Total bugs found: **2** (lockfile + orphan cleanup)
- Total risks documented: **5** (growth, Supabase-down, DNC, escalation, dashboard)
- Total fixes applied: **2** (both during the check)
- Average time per Preflight: **2.5 min**
- Value: ~2 production bugs prevented per session


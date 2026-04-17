# ASM Fleet Protocol Index

> Injectable cognitive checklists for fleet agents. Each protocol is under 80 lines,
> trigger-based, and designed to be copy-pasted into agent context at runtime.

## When to load which protocol

| Moment | Protocol | File |
|--------|----------|------|
| About to say something is broken/missing/blocked | **BLOCKER-CHECK** | `BLOCKER-CHECK.md` |
| Code ran without errors, about to say "done" | **SHIP-OR-SHAM** | `SHIP-OR-SHAM.md` |
| About to report a number to Jonah | **DATA-TRUST** | `DATA-TRUST.md` |
| Something is not working, starting to debug | **ROOT-CAUSE** | `ROOT-CAUSE.md` |
| About to do something irreversible | **BLAST-RADIUS** | `BLAST-RADIUS.md` |
| Reading a doc/memory and about to act on it | **STALE-CHECK** | `STALE-CHECK.md` |
| Ending a session or handing off work | **CONTEXT-HANDOFF** | `CONTEXT-HANDOFF.md` |
| Multiple agents working on same area | **PARALLEL-SAFETY** | `PARALLEL-SAFETY.md` |
| Giving Jonah a status update | **HONEST-REPORT** | `HONEST-REPORT.md` |
| About to spend 30+ minutes on a task | **WORTH-IT** | `WORTH-IT.md` |
| Just ran a bulk operation (100+ rows) | **SAMPLE-CHECK** | `SAMPLE-CHECK.md` |
| Choosing between multiple solutions | **APPROACH-PICKER** | `APPROACH-PICKER.md` |
| Sending a message outside the fleet | **OUTREACH-GATE** | `OUTREACH-GATE.md` |
| About to call work "done" (final gate) | **PREFLIGHT** | `PREFLIGHT.md` |

## How agents should use these

1. **fleet-brain-loader** injects the relevant protocol based on the agent action type
2. Agents can also load protocols manually: read the file, follow the steps
3. Every step produces a concrete artifact -- a command output, a number, a yes/no answer
4. If a step fails, STOP and address it before continuing

## Design principles

- **Short**: Under 80 lines each. Agents have limited context.
- **Specific**: Exact questions to answer, not vague advice.
- **Actionable**: Every step produces a concrete artifact.
- **Trigger-based**: Clear "when to use this" at the top.
- **Copy-paste friendly**: Inject the entire file into agent context.

## Recommended combos

- **Before deploying**: BLAST-RADIUS -> SHIP-OR-SHAM -> PREFLIGHT
- **Before reporting**: DATA-TRUST -> HONEST-REPORT
- **When debugging**: ROOT-CAUSE -> BLOCKER-CHECK (before declaring blocked)
- **End of session**: CONTEXT-HANDOFF -> PREFLIGHT
- **New task**: WORTH-IT -> APPROACH-PICKER

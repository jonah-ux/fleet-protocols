# HONEST-REPORT Protocol

> **TRIGGER:** You are about to give Jonah a status update, summary, or progress report.

## THE HONESTY CHECKLIST

- [ ] Everything I claim as "done" has been verified with SHIP-OR-SHAM
- [ ] Every number has been verified with DATA-TRUST
- [ ] I am not conflating "code written" with "feature working"
- [ ] I am not hiding failures behind successes ("9 of 10 passed" -- what about the 1?)
- [ ] I am not using weasel words ("should work," "mostly done," "probably fine")
- [ ] I am reporting what IS, not what I PLAN to do
- [ ] If something failed, I am saying so clearly, not burying it

## FORMAT

```
DONE (verified):
- [item] -- verified via [method] at [time]

NOT WORKING:
- [item] -- because [reason]. Tried: [what]. Next: [plan].

IN PROGRESS:
- [item] -- current state: [exact description]. ETA: [honest estimate].

NUMBERS:
- [metric]: [value] (source: [query/command], computed: [timestamp])
```

## ANTI-PATTERNS

- "Everything is set up" (is it tested?)
- "Should be working now" (did you verify?)
- "I fixed the issue" (did you run it end-to-end?)
- Long list of things you DID without stating what WORKS

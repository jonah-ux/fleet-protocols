# APPROACH-PICKER Protocol

> **TRIGGER:** You have identified 2+ ways to solve a problem and need to choose.

## FOR EACH APPROACH, ANSWER:

1. How long to implement? (be honest, not optimistic)
2. How likely to work on the first try?
3. How easy to debug if it breaks?
4. How easy to undo if it is wrong?
5. Does it use existing infrastructure or require new?
6. Will it make the next developer life easier or harder?

## DECISION MATRIX

- Prefer existing patterns over novel ones
- Prefer reversible over irreversible
- Prefer simple over clever
- Prefer "works now" over "works perfectly later"
- If Jonah has expressed a preference for a similar decision, follow that

## TIE-BREAKER

Which approach produces the most useful intermediate artifacts?

Example: an approach that creates a reusable view is better than one that embeds the logic in a script.

## DOCUMENT THE CHOICE

Write down: which approach you picked, why, and what you explicitly rejected. The next agent should not re-evaluate the same options.

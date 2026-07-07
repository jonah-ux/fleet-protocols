# 🗂️ Consolidated into the Fleet monorepo

> **The canonical documentation for this project now lives in [`jonah-ux/fleet`](https://github.com/jonah-ux/fleet) → [`brain/protocols/fleet-protocols`](https://github.com/jonah-ux/fleet/tree/main/brain/protocols/fleet-protocols).**
> Part of the One-Fleet consolidation (goal #128687). **Nothing here was deleted.**

## What moved
The docs / design / reference material for **ASM Fleet Protocols** has been folded (history-preserving copy) into the fleet monorepo at **[`brain/protocols/fleet-protocols`](https://github.com/jonah-ux/fleet/tree/main/brain/protocols/fleet-protocols)**.

New docs and design work for this project should go there — do **not** fork canonical docs back into this repo.

## What STAYS here
The protocol checklist files are the whole artifact, and the fleet copy at the path above is now **canonical**. Any runtime that injects these protocols into agent context should read the fleet copy going forward. Nothing here was deleted — this repo is frozen as a mirror.

## Why
One canonical home for the whole fleet. See fleet [`governance/GOALS.md`](https://github.com/jonah-ux/fleet/blob/main/governance/GOALS.md) (north star) and [`FLEET-MAP.md`](https://github.com/jonah-ux/fleet/blob/main/FLEET-MAP.md) (this repo's disposition). Consolidation rule: every fold is a history-preserving **COPY** + this pointer; nothing is deleted or force-pushed until proven + Jonah-signed — see [`governance/DO-NOT-LOSE-DATA.md`](https://github.com/jonah-ux/fleet/blob/main/governance/DO-NOT-LOSE-DATA.md).

_Added by One-Fleet Phase-1 consolidation, 2026-07-04._

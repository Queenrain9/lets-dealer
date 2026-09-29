# LET'S DEALER — Gameplay Rebuild Plan v0.2

## Product correction

The core fantasy is not precision dragging. The player is the dealer responsible for keeping a live poker table moving correctly under pressure.

Primary loop:

`READ TABLE → IDENTIFY DEALER DUTY → ACT → TABLE REACTS → SCORE / TIP / PRESSURE → NEXT DUTY`

Direct manipulation remains as feedback and tactile flavor, not the main difficulty source.

## Stages

1. **Core Loop Rebuild** — Replace gesture-skill prototype with task judgment, time pressure, table state, and a complete rookie hand.
2. **Dealer Task System** — Expand to queued / simultaneous duties, priority conflicts, and reusable task definitions.
3. **Table Pressure & NPC Behavior** — Personalities, impatience, mistakes, requests, VIP pressure, and interruptions.
4. **Scoring / Combo / Tips** — Connect accuracy, combo, timer, tips, reputation, and named performance bonuses to real play.
5. **Career & Progression** — Rookie Hall → Regular Table → VIP → Tournament Final, plus dealer tools and unlocks.
6. **Visual / Product Pass** — Bring the actual runtime toward the concept board while keeping gameplay components real and replaceable.

## Stage 1 acceptance criteria

- One complete hand is playable without precision-drag challenges.
- The player repeatedly decides the correct dealer duty from the visible table state.
- Includes: deal, bet collection, all-in / side-pot recognition, flop, customer chip-change request, turn, river, showdown, main-pot payout, side-pot payout.
- Wrong decisions penalize accuracy/combo but do not block the session.
- A per-task countdown creates pressure.
- Fast correct decisions award extra tips.
- The table visibly changes after each decision.
- Wireframe PNG files remain reference-only and are never rendered at runtime.

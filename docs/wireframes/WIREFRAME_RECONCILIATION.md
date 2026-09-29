# LET'S DEALER — Wireframe Reconciliation Pass

Reference: `docs/wireframes/lets_dealer_interaction_wireframes_v1_2`

This pass restores the wireframe pack as the screen/state source of truth without rolling back the gameplay improvements added in Stages 2–6.

## Rule

The wireframe pack owns:
- screen hierarchy
- dealer POV table composition
- object locations and interaction targets
- visible state changes
- local feedback placement
- Home / Gameplay / Shift Complete / Career screen roles

The current runtime owns:
- live NPC betting timelines
- 6-seat dynamic roster and NPC personalities
- overlapping service requests
- FLOW / accuracy / tip scoring
- table-first contextual input
- low-precision accessibility
- NPC speech bubbles
- dynamic hand/request order

## Reconciliation decisions

| Wireframe state | Original intent | Runtime decision |
| --- | --- | --- |
| 01 HOME | Venue-first River Pub home, goal/reward, career navigation | RESTORE layout role. Keep current economy/NPC systems behind it. |
| 02 DEAL | Dealer POV, deck at hands, seat targets | RESTORE dealer POV composition. REINTERPRET precise drag as deck tap/short push with automatic distribution. |
| 03 COLLECT | Visible BetChipGroups, central PotArea, sweep | RESTORE visible chip groups and central pot. REINTERPRET precision sweep as forgiving pot tap/short sweep. |
| 04 BOARD | Burn pile, deck, board target; Flop distinct from Turn/River | RESTORE Burn/Deck/Board visual grammar. Keep low-precision interaction; runtime performs burn/fan/open automatically. |
| 05 PAYOUT | Pot becomes payout object, winner seat is target | RESTORE pot-to-seat visual targeting. Keep current Pot tap → eligible seat tap interaction. |
| 06 SIDE POT | Chips visibly form Main/Side piles, eligibility visible | RESTORE separate pile presentation and eligible-seat emphasis. Current scenario values remain until real pot engine replaces them. |
| 07 SHIFT COMPLETE | Summary, reward, mistakes/perfect, progression, next unlock | RESTORE screen hierarchy using current metrics. |
| 08 CAREER | River Pub → Regular Night → VIP → Final progression | RESTORE as navigation/progression shell. Unlock logic remains lightweight for now. |
| 09 VIP | Same gameplay grammar, richer/faster environment | KEEP as future venue skin/difficulty layer; do not fork controls. |
| 10 FINAL | Same dealer POV, larger final table/environment layer | KEEP as future venue skin/difficulty layer; do not fork controls. |

## Explicitly not restored

The following v1.2 interaction details are no longer strict success conditions:
- pixel-precise card dragging
- precise seat drop hit-tests as core difficulty
- long gesture-path accuracy
- exact burn-card flick geometry
- exact 3-card packet placement
- manual chip-by-chip pot sorting

Those are presentation/feel references, not dexterity tests.

## Gameplay base contract

All live table states reuse one `GameplayTableBase` concept:

`HUD → Venue/Table → Seats → Board/Pot → Dealer Hands/Deck → Local Feedback`

The runtime may show concurrent NPC speech and service requests above this base, but should not replace the base with toolbars, quizzes, modal instructions, or debug panels.

## Current implementation target

This reconciliation pass should visibly restore:
1. River Pub venue-first Home.
2. Dealer-POV horseshoe table with open lower interaction zone.
3. Deck and dealer hands anchored at the bottom of the table.
4. Central Board and Pot areas that change by hand state.
5. Burn pile visibility for Board states.
6. BetChipGroups near seats during Collect.
7. Pot/eligible-seat emphasis during Payout.
8. Separate Main/Side pile presentation when side pots exist.
9. Shift Complete summary hierarchy.
10. Career progression shell.

Stage 2–6 systems remain active throughout.

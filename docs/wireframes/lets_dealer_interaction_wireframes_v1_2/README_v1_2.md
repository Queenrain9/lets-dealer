# LET'S DEALER — Interaction Wireframe v1.2

## v1.2 confirmed rules

### 1) 03 Collect = Sweep Gesture
- Do NOT drag individual chip tokens.
- Each seat's bet is a `BetChipGroup`.
- The player makes one continuous sweep gesture across the felt.
- Multiple BetChipGroups can join the same sweep trail.
- Reaching `PotArea` causes magnet/snap absorption and updates the pot total.
- Feedback appears at `PotArea`.

### 2) 04 Board interaction variants
#### Flop
`Burn Flick → Select 3-Card Packet → Drag Packet → Release in Fan Area → 3 cards fan open`
- Flop is not three separate slot drops.
- The 3-card packet is treated as one manipulable object until release.

#### Turn / River
`Burn Flick → Select Single Card → Move to Street Target → Open`
- Turn and River use one-card interaction.
- The action therefore feels different from Flop and from Deal.

### 3) Shared physical failure rule
Do NOT use a centered error modal or a static X-reset pattern.

On invalid action:
1. The object reaches/touches the invalid target.
2. The local target briefly reacts.
3. A tiny local message appears (`WRONG SEAT`, `MISSED POT`, `BURN FIRST`, `NOT ELIGIBLE`, etc.).
4. The object visibly spring-backs / snap-backs along a short return path.
5. Game state rolls back to the last valid state.
6. Accuracy / combo penalty applies once.
7. Hand flow continues without a blocking modal.

### 4) Base Gameplay Scene
`GameplayTableBase`
→ `VenueTheme`
→ `SeatData`
→ `CurrentTask`
→ `ObjectState`
→ `FeedbackState`

Screens 02–06, 09, 10 reuse the same gameplay base.
VIP and Final are harder / richer environments, not different game systems.

## Hand State Flow
`DEAL`
→ `NPC BETTING`
→ `COLLECT (SWEEP)`
→ `FLOP (BURN + PACKET FAN)`
→ `NPC BETTING`
→ `COLLECT (SWEEP)`
→ `TURN (BURN + SINGLE OPEN)`
→ `NPC BETTING`
→ `COLLECT (SWEEP)`
→ `RIVER (BURN + SINGLE OPEN)`
→ `NPC BETTING`
→ `COLLECT (SWEEP)`
→ `SHOWDOWN`
→ `PAYOUT`
→ `HAND COMPLETE`

## v1.2 replaced wireframes
- 02E Deal Failure
- 03A–03E Collect
- 04A–04I Board
- 05D Payout Failure
- 06E Side Pot Failure
- Hand State Flow v1.2

All other v1.1 wireframes are retained unchanged unless superseded by a same-named v1.2 file.

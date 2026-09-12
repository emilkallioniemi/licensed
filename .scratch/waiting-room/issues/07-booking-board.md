# 07. The booking board: agreeing on a vehicle

Type: grilling
Status: resolved
Blocked by: 04
Map: ../map.md

> Retyped from `prototype` to `grilling` on 2026-09-12, following [Waiting room walkthrough](04-waiting-room-walkthrough.md) and [The reception desk](06-reception-desk.md): there is no walkable room, controller, or dock to put an interactive board into, and building them is a build, not a decision. The choosing, disagreement, and agreement rules and the locked-row copy are decided in conversation; the first build cut from the spec checks the feel.

## Question

Each player chooses the vehicle whose test they want to sit; disagreement is visible and the players resolve it themselves into one booking. How does that work on the board the kit already has?

Using the walkable room from Waiting room walkthrough. The kit's `BookingBoard` has five rows (`MonsterTruckSlot`, `CarSlot`, `MopedSlot`, `TruckTrailerSlot`, `HelicopterSlot`), each with a 1.93 × 0.34 m `DisplaySurface`, separate label and padlock meshes, and the `AttachmentPoints/BookingBoardApproach` marker. The rows are visual placeholders; nothing is selectable yet. Per Waiting room walkthrough, the whole board is one station: press E at it, the camera docks about 3 m back (the `preview_booking.png` view), and the cursor picks rows; the role column on the same board is Role pickup's ticket.

1. **Choosing.** Stand at the board, move up or down the rows, your pick is marked with you on that row (avatar, name tag, a coloured pin matching your learner). Everyone sees everyone's pick. Locked rows can be looked at but not chosen; what happens when you try (the padlock rattles, the examiner says something in register, nothing).
2. **The jokes.** The kit left the copy blank on purpose. Each locked row gets its one-line joke from the README's roadmap; write them in the examiner's register from `docs/design.md`, or decide they are plain labels for now.
3. **Disagreement.** Three different picks: how the board shows it, and whether the game says anything (in register: "The examiner will see one candidate at a time.") or stays quiet and lets you argue.
4. **Agreement.** All three on the same vehicle makes it the booking, the precondition for the ready-up. What visibly changes when it happens.

Deliverable: the interactive board in the walkable room, linked, and an answer recording the choosing and disagreement rules and the locked-row copy. Watch for the moment where flipping someone else's leaflet is funnier than flipping your own.

## Comments

- 2026-09-12, from [Waiting room walkthrough](04-waiting-room-walkthrough.md): the walkable room was decided in conversation, not built, so there is no scene to drop this into. The session that claims this ticket chooses: build the controller and dock first as part of the prototype, or regrill this as conversation like 04 was.
- 2026-09-12, from [The reception desk](06-reception-desk.md): board state is host-owned; a joiner sees everyone's current pick on spawn and nothing resets when someone walks in; a player who leaves the room (the desk now has a Leave verb for guests) has their pick cleared. The desk's on-screen copy is in a dry *signage* register, not the examiner's voice; if item 3 gives the board a line, decide whether it is signage on the board or the examiner speaking, and keep the two apart. The reception desk was also regrilled rather than prototyped; same precedent applies here.
- 2026-09-12, from [Role pickup](08-role-pickup.md): the role column is **gated on the booking**. It is dead until a booking exists, by whatever rule item 4 settles, and **every held role is released the moment the booking dissolves** (a player changing their pick after agreement). So item 4's "what visibly changes" has a right-hand half: the three occupant strips stop reading "No booking." and go blank-and-live. If the agreement rule has a grace period or a confirmation step, the roles unlock at the end of it, not at the first matching pick. Palette colour marks a player on the role column (strip flood + lamp), so a coloured pin on the vehicle row would read as the same language.
- 2026-09-12: the `claimed` status was stale (a session claimed and retyped this ticket around 02:20 and ended without a round being answered; no branch, no answer). Released back to `open` by the Role pickup session so the next `/wayfinder` run takes it. The retype note above stands.
- 2026-09-12: one round of eight questions, each with a recommendation; Emil gave the agent free hands and every recommendation stands. The one knock-on is to [Testing alone](05-solo-testing-transport.md): `--min-players` must also be the count the booking waits for; a comment is left there.

## Answer

Decided in conversation on 2026-09-12 (one round, recommendations accepted as-is). Kit facts from `assets/waiting_room/README.md` and `source/build_waiting_room.py`: five rows, each a 1.93 × 0.34 m `DisplaySurface` with a separate label mesh; a padlock mesh at the right end of the four locked rows and a static `01` marker in the same spot on the monster truck row. At the board's dock (about 3 m back, roughly 290 px/m) a row is about 560 × 100 px, so a third of a row at strip height is the same ~180 × 30 px as an occupant strip: one Steam name per chip, three chips per row. Grammar, dock, and cursor are [Waiting room walkthrough](04-waiting-room-walkthrough.md); host-owned state, joiners seeing the current picks, and leaving clearing a pick are [The reception desk](06-reception-desk.md); the role column's gating is [Role pickup](08-role-pickup.md).

### 1. When it is a booking

- A **booking** exists when **all three players in the room have picked the same vehicle**. It forms the moment the third matching pick lands, not before.
- Picks made before three are in the room are visible on the board (the chips) but book nothing; the role column reads "No booking." for a host alone or a pair.
- The booking **dissolves** when any pick changes (drop or switch) or when a player leaves; 3 → 2 is no longer three picks. Role pickup releases every held role at that moment.
- Nobody can join a room of three, so a new arrival never dissolves a booking. Rejected: "everyone in the room agrees" (a joiner with no pick would dissolve the host's booking and release their role on every arrival) and "nobody disagrees" (lets a player hold a role against a vehicle they never picked).
- **Amendment to Testing alone:** `--min-players=N` is the player count the waiting room waits for *everywhere* it waits for three, so the booking forms at N matching picks and the ready-up fires at N. Without this a solo dev never reaches a live role column. The flag still has no UI and still reads as "the room may launch short".

### 2. What a row shows

- The kit's static label mesh and the `01` marker are **hidden**; each row is drawn on its `DisplaySurface` in **two lines**. Top: the vehicle name. Bottom: on a bookable row, the **chip line**, up to three **pick chips**, each flooded with the picker's palette colour with their Steam name in ink, left to right in arrival order (01/02/03), blank when nobody has picked. On a locked row, the bottom line carries its copy (section 5) and never gets chips.
- The **padlock meshes stay**; copy on a locked row stops short of the padlock at the right end.
- Same visual language as the occupant strip, so a colour means the same player in both columns. Rejected: colour-only pips in the free right end, because roles are dead before the booking, so a player has never seen their own palette colour and could not tell which pip is theirs.

### 3. Pick, drop, switch

- Click a bookable row: you **pick** it. Click your own picked row: you **drop** the pick. Click another bookable row: you **switch**, one move, no gap.
- A player has at most one pick. Dropping or switching after a booking dissolves it.
- **No pre-pick.** Nobody arrives with a pick, even though the monster truck is the only bookable row this slice; the walk to the board and the click are the room's ritual, and they bring every player to the board where the role column is anyway.
- A joiner sees the current chips on spawn; a player who leaves or vanishes has their chip cleared.

### 4. Clicking a locked row

Nothing: no rattle, no line, no examiner. Same rule as clicking a taken role button. The row's copy is the answer to "why not". The examiner in the waiting room stays fog (map, Not yet specified).

### 5. The locked-row copy

Signage register, as the reception desk fixed it for station screens: dry, short, full stops, not the examiner's voice. The bottom line of each locked row:

- CAR: "Manual. Indicators on the passenger side."
- MOPED: "Seats one. Party of three."
- TRUCK + TRAILER: "One of you rides on the trailer."
- HELICOPTER: "Three controls. No manual."

The monster truck row has no copy line; its bottom line is the chip line.

### 6. Disagreement

**Quiet.** Chips on different rows (or a row with two chips and a player with none) is the whole display; voice is the resolution. No footer, no examiner line. This slice has one bookable row, so the only disagreement possible is pick versus no pick; the rule is recorded for the day a second row unlocks.

### 7. The moment of booking

- The booked row's top line gains **BOOKED** at its right end, where the kit's `01` sat. The chips stay.
- The role column wakes: the three occupant strips stop reading "No booking." and go blank and live (Role pickup's half of this moment).
- One short **placeholder sound** from the board, heard by everyone in the room, like the entrance door's placeholder. No examiner, no colour change; the kit's ochre already marks the truck row as bookable.
- **Dissolution is silent**: BOOKED disappears, the strips read "No booking." again, roles release.

### 8. Under the dev transport

Same rules. Chips carry the peer-suffixed Steam name from Testing alone; palettes by peer order; the booking forms at `--min-players` matching picks. Nothing on the board knows which transport it is on.

### Glossary

Updated in `CONTEXT.md`: added **Pick** (with pick, drop, switch as its verbs) and **Pick chip**; **Booking** sharpened to say when it forms and dissolves.

### Corrections logged

None: no steer this session, the recommendations were accepted.

Unblocks: [Ready-up and the launch stub](09-ready-up-and-launch.md) (its other blocker, Role pickup, is already resolved). Comments left there and on Testing alone.

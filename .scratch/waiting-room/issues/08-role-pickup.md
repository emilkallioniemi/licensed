# 08. Role pickup: Driver, Spotter, Navigator, or random

Type: grilling
Status: resolved
Blocked by: 04
Map: ../map.md

> Retyped from `prototype` to `grilling` on 2026-09-12, following [Waiting room walkthrough](04-waiting-room-walkthrough.md) and [The reception desk](06-reception-desk.md): there is no walkable board to click on, and the take/drop/random rules and what the strips show are decidable in conversation. The first build cut from the spec checks the feel.

## Question

Roles are first-come exclusive, with a "random" option that fills whatever is left at launch. How does picking one work as something you do in the room, and how does everyone see who holds what?

Waiting room walkthrough decided the object: the role pickup is the **right column of the booking board**. The kit has it: `BookingBoard/RoleSelection` with `DriverChoice`, `SpotterChoice`, `NavigatorChoice` (each a button mesh, a blank 0.65 × 0.105 m `OccupantSurface`, and a `StatusLamp`) and `RandomChoice` (a button only), with `DriverButton`, `SpotterButton`, `NavigatorButton`, `RandomButton` markers on the button faces. It shares the booking board's one dock: you press E at the board and pick vehicle rows and role buttons with the same cursor. Nothing is wired; the strips and lamps are blank.

1. **Taking and dropping.** Click a role button and it is yours: what the occupant strip and lamp show (your Steam name? your palette colour? the Steam avatar the walkthrough kept out of the 3D room, now that it is on a screen?), and how holding a role shows on the learner for the other two (over the name tag, on the body, not at all). Click again, or another role, to drop it. Two people click the same button in the same frame: host decides, loser gets nothing, no error.
2. **Random.** How the Random button reads when chosen (it has no strip or lamp), and when it resolves: at launch, after the named roles are taken.
3. **Per vehicle.** The roles belong to the booked vehicle. Only the monster truck can be booked this slice, so the three labels can be fixed, but the answer should say how the column would swap when a second vehicle unlocks, and what it shows before there is a booking.
4. **Locked out.** Whether you can take a role before the booking exists, or the column waits for the vehicle column to agree.

Deliverable: an answer recording the rules and what the strips, lamps, and learner show, well enough to spec. Terms go in `CONTEXT.md`.

## Comments

- 2026-09-12, from [Waiting room walkthrough](04-waiting-room-walkthrough.md): question rewritten. The original asked to pick a role object and request it from Astra; Astra added the role column to the booking board and the walkthrough made it the role pickup with one shared dock. The walkable room was decided, not built, so this ticket is now closer to a grilling than a prototype; the claiming session may retype it.
- 2026-09-12, from [The reception desk](06-reception-desk.md): roles are host-owned state; a joiner sees who holds what on spawn, and a player who leaves the room (guests have a Leave verb at the desk) frees their role. The Steam avatar is now on a station screen (the desk's friend rows, 64 px medium avatar), which is a precedent for item 1's "avatar on the occupant strip" option. The reception desk was regrilled rather than prototyped; same precedent applies here.
- 2026-09-12: one round of seven questions, each with a recommendation; Emil gave the agent free hands and every recommendation stands. [The booking board](07-booking-board.md) was claimed by another session at the time, so the one dependency on it (when a booking exists) is recorded as a pointer, not restated.

## Answer

Decided in conversation on 2026-09-12 (one round, recommendations accepted as-is). Kit facts from `assets/waiting_room/README.md` and `source/build_waiting_room.py`: three role cards (`DriverChoice`, `SpotterChoice`, `NavigatorChoice`), each a button, a 0.65 × 0.105 m `OccupantSurface` and a `StatusLamp`; `RandomChoice` is a 1.0 × 0.26 m button alone. At the board's dock (about 3 m back) a strip is roughly 180 × 30 px on a 1024-wide render: one name fits, an avatar and a name do not. Grammar, camera, palettes-by-arrival and the shared dock are [Waiting room walkthrough](04-waiting-room-walkthrough.md); host-owned state and "leaving frees the role" are [The reception desk](06-reception-desk.md).

### 1. Take, drop, swap, contention

- Click a free role button: you **hold** it. Click your own button again: you **drop** it. Click a different free button: you **swap**, one move, no visible "no role" gap for the other two.
- Clicking a **taken** button does nothing: no shake, no line. The occupant strip already says whose it is.
- Two clicks on the same free button in the same frame: the host's receive order wins; the loser sees the strip fill with the other name. That is the entire feedback. No error.
- Your own held button reads pressed (inset); everyone else's read flat.
- Roles are host-owned. A joiner sees the current holders on spawn; a player who leaves or vanishes has their role freed and their strip cleared.

### 2. The occupant strip and the lamp

- **Free**: strip blank (`Screen` dark), lamp steel/off, exactly as the kit ships.
- **Held**: the strip floods with the holder's **palette colour** (the 01/02/03 learner colour dealt by arrival order) with their **Steam name** in ink on top; the lamp lights in the same colour.
- Steam name for everyone, including the holder. No "You": the board is public signage. This is also the only place a player ever sees their own palette colour, since first person hides their own learner.
- No avatar on the strip. Too small at the dock; the desk keeps the avatar precedent.

### 3. Role on the learner

- The **name tag** grows a second, smaller line: the held role, "Driver" / "Spotter" / "Navigator" / "Random"; blank when holding nothing. Seen by the other two, never by yourself, same rule as the name.
- This is what makes Ready-up's "a role is missing" refusal legible from anywhere in the room, and it is the same line the launch stub shows over each head (Ready-up item 3): one thing carried across the network, not two.

### 4. Random

- Random is **not exclusive**: any number of the three may hold it. Two Randoms and a Driver is a valid pre-launch state; so is three Randoms.
- The Random button has no strip or lamp, so holders show as **palette pips** along the button's right edge, one per holder in their colour, in arrival order (01, 02, 03).
- Random resolves **at launch confirmation**: the host deals the remaining named roles to the Random holders, shuffled, one each. With three players each holding something, named + random always sums to three, so nobody is left without a role.
- The **theatre** of the deal (strips filling with the dealt names for a beat before the transition, or only visible in the stub) is Ready-up's call; the rule is decided here, with a lean toward showing it on the board first.

### 5. Roles hang off the booking

- The column is **gated**: dead until a **booking** exists, as [The booking board](07-booking-board.md) defines it. Taking a role is taking it *against* the booking.
- If the booking **dissolves** (a player changes their vehicle pick), every held role is **released**: strips clear, lamps go off, pips vanish, name tag lines go blank. Nobody's role outlives the booking it was taken for.
- This is the rule that survives a second vehicle unchanged: the column shows the booked vehicle's roles, so its labels and count follow the booking. For this slice the three labels are fixed because only the monster truck can be booked; the swap is a spec note, not work.
- **Before a booking** the buttons and lamps sit as the kit ships and clicks do nothing, but each of the three occupant strips reads one signage line, **"No booking."**, in the desk's dry register (not the examiner's). Random is unchanged. A joiner arriving mid-way sees the column in whatever state the host holds.

### 6. Under the dev transport

Same rules. The strip shows the peer-suffixed Steam name from [Testing alone](05-solo-testing-transport.md); palettes by peer order. Nothing on the column knows which transport it is on.

### Glossary

Updated in `CONTEXT.md`: **Random** reworded to say it is not exclusive and is dealt at launch; added **Hold** (take/drop/swap as its verbs) and **Occupant strip**.

### Corrections logged

None: no steer this session, the recommendations were accepted.

Unblocks: nothing yet (Ready-up still waits on The booking board). Comments left on The booking board and on Ready-up and the launch stub.

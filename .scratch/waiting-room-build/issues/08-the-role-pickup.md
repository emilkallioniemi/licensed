# 08: The role pickup

**Spec:** `.scratch/waiting-room/spec.md`, section 6. Vocabulary: hold (take, drop, swap), Random, occupant strip, role pickup.

**What to build:** Once the booking exists, the right column of the booking board wakes and each player holds Driver, Spotter, Navigator, or Random with one click; the strips and lamps show who holds what, and the name tags carry it around the room. Without a booking the column is dead.

Same dock and cursor as ticket 07. Kit pieces: the Driver, Spotter, and Navigator choices (button, occupant strip, status lamp) and the Random choice (button only). Labels are fixed this slice; only the monster truck can be booked.

Gated on the booking: while no booking exists, clicks do nothing and each of the three occupant strips reads "No booking." in signage register; Random's button is unchanged. The moment a booking dissolves the room state releases every hold; strips clear, lamps go off, pips vanish, name tag role lines go blank.

Take, drop, swap are commands to the room state: click a free role button to hold it; click your own again to drop; click a different free button to swap in one move. One hold per player. Clicking a taken button does nothing. Same-frame contention resolves in host receive order; the loser sees the other name appear, no error. Your own held button reads pressed (inset); all others flat.

Occupant strip and lamp: free means strip blank and lamp off, as the kit ships. Held means the strip flooded with the holder's colour and their display name in ink (never "You"), lamp lit in the same colour. No avatar on the strip.

Random is not exclusive: any number may hold it. Holders show as palette pips along the Random button's right edge, one per holder, in arrival order. Random is dealt at launch (ticket 11); nothing on the board shows the deal.

Name tag: a second, smaller line under the name reading "Driver" / "Spotter" / "Navigator" / "Random", blank when holding nothing, seen by the other two and never by yourself.

**Blocked by:** 07 (the booking board and its dock).

**Status:** ready-for-agent

- [ ] Without a booking the three strips read "No booking.", lamps are off, and clicking any role or Random does nothing.
- [ ] With a booking, clicking a free role floods its strip with the clicker's colour and display name and lights its lamp to match on every machine; the clicker's button reads pressed.
- [ ] Clicking your own held role drops it (strip blank, lamp off); clicking another free role swaps in one move.
- [ ] Clicking a role someone else holds does nothing.
- [ ] Two players clicking the same free role in the same frame: one holds it, the other sees that name appear, nothing is said.
- [ ] Any number of players may hold Random; each shows as a colour pip on the Random button in arrival order.
- [ ] The other two learners' name tags show a second line with their held role; your own is never shown to you.
- [ ] When the booking dissolves, every strip, lamp, pip, and name tag role line clears at once.
- [ ] Under `--transport=enet` strips show the peer-suffixed display name.

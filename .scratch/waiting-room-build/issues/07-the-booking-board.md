# 07: The booking board: picks and the booking

**Spec:** `.scratch/waiting-room/spec.md`, section 3 (station screens, the dock, cursor hits) and section 5. Copy in section 13. Read `docs/design.md` for the signage register and *Polish before funny* (plain Control theme).

**What to build:** Three players walk to the booking board, pick the monster truck, and the row reads BOOKED with a sound everyone hears. Along the way this ticket adds the second half of the station grammar: the station screen on the station's own surface.

Station screen: on E at the board the camera glides to a dock pose about 3 m back framing the whole board (the kit's booking preview view), the mouse is released and becomes a cursor, the learner stands still facing the board, and the other two see them stood there. Cursor hits are resolved by raycasting from the camera through the cursor onto the surfaces and mapping to the row's controls. Escape closes the screen and returns the camera to the head. A flat 2D overlay is an allowed fallback if the in-world screen fights the build, without changing the grammar.

Rows: hide the kit's static label meshes and the monster truck's `01` marker; keep the padlock meshes. Draw each row on its `DisplaySurface` in two lines. Top: the vehicle name ("MONSTER TRUCK", "CAR", "MOPED", "TRUCK + TRAILER", "HELICOPTER"). Bottom, bookable row: the chip line, up to three pick chips flooded with the picker's colour with their display name in ink, left to right in arrival order, blank when nobody has picked. Bottom, locked row: its one signage line, stopping short of the padlock: "Manual. Indicators on the passenger side." / "Seats one. Party of three." / "One of you rides on the trailer." / "Three controls. No manual." The monster truck is the only bookable row.

Pick, drop, switch are commands to the room state: click a bookable row to pick, click your picked row to drop, click another bookable row to switch. Nobody arrives with a pick. Clicking a locked row does nothing. Disagreement is quiet: chips on different rows is the whole display.

The booking (formed by the room state on the N-th matching pick): the booked row's top line gains BOOKED at its right end where `01` sat, chips stay, one short placeholder sound from the board heard by everyone, no colour change. Dissolution is silent: BOOKED disappears. The role column stays as the kit ships in this ticket; ticket 08 wakes it.

**Blocked by:** 06 (the station base: zone, prompt, E).

**Status:** claimed

- [ ] "E  Booking" appears in the board's zone; E docks the camera framing the whole board, releases the mouse as a cursor; Escape returns to first person. The other two see the player stood at the board while docked.
- [ ] Five rows are drawn on their surfaces in two lines; the kit's label meshes and `01` are hidden; padlocks remain.
- [ ] The four locked rows show their exact copy from the spec; clicking one does nothing.
- [ ] Clicking MONSTER TRUCK adds a chip in the clicker's colour with their display name, in arrival order, on every machine; clicking again removes it; there is at most one pick per player.
- [ ] Nobody has a pick on arrival.
- [ ] When all three (N under `--min-players`) have picked the same row, BOOKED appears at the right end of its top line and one sound plays on every machine.
- [ ] Any drop or departure removes BOOKED silently; the chips of the remaining pickers stay.
- [ ] The board contains no rule: booking formation and dissolution are read from the room state, not recomputed in the view.

## Comments

**From ticket 02 (orchestrator).** `RoomState.tick(delta)` is the countdown; at the end `launched` carries `{steam_id: named_role}` for everyone (Random dealt); `launched_roles()` holds it until `return_from_test_area()`, which clears picks, holds, seats and the deal and emits `booking_dissolved`. Board strips are unchanged by the deal (spec section 7). Picks are `pick(steam_id, vehicle)` / `drop_pick(steam_id)`; a switch is a `pick` of a different vehicle. `booking_formed`/`booking_dissolved` fire on the host only; the view on a guest should react to the replicated state changing.

**From ticket 04 (orchestrator).** Guests send sit/pick/hold through `WaitingRoom.submit_command` over reliable RPC. Under ENet the name suffix is the arrival slot 2/3 (Godot's ENet unique ids are not 2 and 3).

**From ticket 06 (orchestrator).** `Station` (`scripts/station.gd`) is the zone-prompt-E base: place it on an approach marker, `setup(prompt, prompt_at, zone_size)`, connect `used`. `set_listening(false)` hides the prompt and ignores E. Add the station screen on top of this; do not fork a second grammar. Copy `"E  Booking"`. Palettes 01/02/03 match chair teal / ochre / kit red; `Palettes.flood_color` is the shirt.

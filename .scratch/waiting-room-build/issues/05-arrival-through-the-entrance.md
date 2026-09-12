# 05: Arrival through the entrance

**Spec:** `.scratch/waiting-room/spec.md`, section 4 ("Arrival", "Room state on join", "Leave") and the kit request for a door leaf in Further Notes. Vocabulary: arrival, entrance, joiner.

**What to build:** Walking into a friend's room is a walk in, not a teleport, and everyone already there knows a friend has arrived without a toast. Leaving reads the same way in reverse.

For the joiner: fade to black when the join begins, the host's room loads, fade up standing in the doorway on the `Entrance` marker facing −Z, with the full host-owned state already applied: where the others stand, their palettes, and (once tickets 07 to 08 land) their picks and holds. Nothing resets because someone walked in. The joiner is palette 02 or 03 by arrival order regardless of what the host has done.

For everyone in the room: the entrance door leaf swings open, the learner appears, the door closes after a couple of seconds, and one positional placeholder door sound plays at the entrance, loud enough to hear from anywhere in the room. That is the room's only join notification: no toast, no examiner. Until Astra's closed door leaf lands, the sound alone carries it; build the theatre so the leaf can be dropped in.

A deliberate departure (a guest's Leave, ticket 09, or a dev-transport instance quitting cleanly) runs the theatre in reverse and the leaver's pick and hold are freed by the room state. What the room shows when a friend *drops* mid-room is a build-time call in the spec's Further Notes; decide it here, write the decision down, and append a line to `docs/corrections.md` if you were steered.

**Blocked by:** 04 (three learners in one room).

**Status:** claimed

- [x] A joining instance fades to black, then fades up on the `Entrance` marker facing into the room.
- [x] On the machines already in the room the door opens (or the sound alone plays until the leaf exists), the learner appears in the doorway, the door closes, and one door sound is heard positionally from the entrance, audible from the far corner.
- [x] The joiner sees the others where they actually stand, in their existing palettes, on the first visible frame; nothing about the room resets.
- [x] The joiner is the next palette by arrival order.
- [x] A clean departure plays the theatre in reverse; the leaver's slot, pick, and hold are freed on every remaining machine.
- [x] The mid-room drop behaviour is decided and written into the ticket's Comments; no silent default.
- [x] Demoed with three local instances under `--transport=enet`.

## Comments

**From ticket 01 (orchestrator).** Headless scripts that fail an `assert` hang forever instead of exiting; run them with a timeout. The editor drops `~libgodotsteam...dll` copies in `addons/godotsteam/win64/` while open; `.gitignore` covers `addons/**/~*`.

**From ticket 02 (orchestrator).** `RoomState.snapshot()`/`restore()` carry the whole record as plain `var_to_str`-safe data; a guest's copy derives booking, holders, notice board line and count from the same code and raises no events, so a joiner restoring the host's snapshot sees the room exactly as it is. Under `--headless --script` a failed `assert` did not hang this time; it aborted only the enclosing function and the script still printed PASS. `tests/verify_room_state.gd` routes every check through `_check` (counts failures, ends with FAIL and exit 1); copy that pattern into any later headless script.

**From ticket 04 (orchestrator).** Learners currently stand in a short row at the entrance so capsules do not overlap; this ticket's arrival theatre replaces that. Autoload `Transport` (`scripts/transport.gd`) picks Steam or ENet; `Transport.lobby_id` is the hosted Steam lobby. Host `RoomState` is the writer; guests restore snapshots. Bind-or-join still prints Godot's "Couldn't create an ENet host" on guests when `create_server` finds the port taken; then they join. Setup: `docs/run-instances.md`.

**Builder, 2026-09-12. Mid-room drop.** A drop is not a walk out. The learner vanishes where they stood and the entrance door sounds once; the leaf does not swing. The reverse door theatre (open, gone, close) is only for a deliberate Leave (ticket 09) or a clean window close. No toast, no examiner. Recorded in `docs/corrections.md`.

**Builder, 2026-09-12.** The entrance row is gone; everyone arrives on `Kit/AttachmentPoints/Entrance` facing −Z. Overlay starts black so an empty room never flashes; joiners fade up once their learner exists (ticket 09 calls `WaitingRoom.begin_join()` / `begin_leave()` from the desk). `ArrivalTheatre` (`scripts/arrival_theatre.gd`) plays one positional placeholder `assets/waiting_room/door.wav` at the opening; parent Astra's leaf to `ArrivalTheatre/Leaf` (hinge on the −X jamb). Demoed three local `--transport=enet` instances: palettes 01/02/03 by arrival, door on the machines already in the room, CloseMainWindow on a guest played leave-through-the-entrance and the host went to 2 in the room. `RoomState` tests still PASS. Bind-or-join still prints Godot's "Couldn't create an ENet host" on guests.

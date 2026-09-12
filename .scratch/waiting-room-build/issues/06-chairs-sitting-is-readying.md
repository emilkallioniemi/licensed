# 06: Chairs: sitting is readying

**Spec:** `.scratch/waiting-room/spec.md`, section 3 (the station grammar) and section 7 (sitting and standing). Vocabulary: station, ready-up.

**What to build:** A player walks up to any of the three chairs, sees a prompt, presses E, and sits; their friends see the chair flood with their colour. E or a move key stands them up again. This is the first station, and it establishes the half of the station grammar every later station shares: the zone, the world-space prompt, and E.

Station base: walk into the station's zone (a volume around its approach marker) and a prompt appears in the world above the station, in signage register ("E  Sit"). Press E to use it. Build this as one reusable piece; the desk and the board add a station screen on top in ticket 07.

Chairs have no screen. E sits: the seated state is a command to the host's room state (ticket 02); the camera drops to about 1.2 m and mouse look stays live so the sitter can watch the door and the board; the learner is placed on the chair's footprint facing into the room (a seated learner variant is a kit request; until it lands the standing model sits there). An occupied chair floods with the sitter's colour, one material swap per chair group, on every machine. E or any movement key stands. Any chair, first come; the numbers are decor. The chair never refuses, in any room state; the notice board (ticket 11) says what is missing.

**Blocked by:** 04 (replicated room state and palettes).

**Status:** ready-for-agent

- [ ] Walking into a chair's zone shows "E  Sit" above the chair; walking out hides it.
- [ ] E sits: the camera drops to about 1.2 m, mouse look still works, the learner occupies the chair's footprint facing into the room.
- [ ] E or W/A/S/D while seated stands the player and the camera returns to 1.75 m.
- [ ] On every machine an occupied chair floods with the sitter's colour and returns to the kit's material when they stand.
- [ ] Two players cannot sit in the same chair; a player may sit in any free chair regardless of picks, holds, or player count.
- [ ] Seated state lives in the host-owned room state and survives a joiner arriving (the joiner sees who is already seated).
- [ ] The zone-prompt-E station base is one reusable piece that a screenless and a screened station can both build on.

## Comments

**From ticket 01 (orchestrator).** `SteamClient.avatar` holds the local 64 px `ImageTexture` after `avatar_loaded`; no signal is emitted, so a view should poll or add its own signal. `Steam.getFriendRichPresence(own_id, "licensed")` returns "1" for the local user, useful for a self-check.

**From ticket 02 (orchestrator).** `RoomState.sit(steam_id, chair)` refuses a seated player (stand first, matching the E/move-key grammar) and an occupied chair; nothing else refuses it. `stand`, any pick change, `drop_hold`, and `leave` cancel a running count unconditionally (the spec's four cancels), and the ready-up re-arms from three if everything still holds, so the examiner line must be re-spoken on every `countdown_started`. Chair 0 means standing; chairs are 1..3.
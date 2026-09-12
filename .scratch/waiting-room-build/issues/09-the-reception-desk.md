# 09: The reception desk: who is here, Join, Leave

**Spec:** `.scratch/waiting-room/spec.md`, section 4 (desk screen, Join and Accept, failure, Leave, room state on join) and section 11 (the desk under the dev transport). Copy in section 13. Read `docs/design.md` for the signage register. Vocabulary: room, at the test centre, join, leave, host, guest.

**What to build:** A player walks to the reception desk, sees which Steam friends are in their room, at the test centre, or merely online, and presses Join on a friend at the test centre to walk into their room. A guest presses Leave to go back to a room of their own. Inviting is ticket 10.

The desk screen: a 740 × 460 `SubViewport` on a quad at the `FriendsScreen` marker over the kit's screen surface, with the placeholder lettering hidden; the same dock-and-cursor grammar as ticket 07, prompt "E  Reception". Signage register, plain Control theme.

Header: "Reception" and the count, "1 of 3" / "2 of 3" / "3 of 3", read from the room state. At three: "The waiting room is full." and every verb on every row disappears.

Rows: medium Steam avatar (64 px, async), Steam name, one state line, zero to two verbs. Groups top to bottom, alphabetical within a group: *In this room* ("In the waiting room", no verbs); *At the test centre* (game running, `licensed` rich-presence key present: "At the test centre", verbs Invite and Join, both hidden if that friend's own room is full; Invite is wired in ticket 10 and may be drawn disabled here); *Online, not at the test centre* ("Online. Not at the test centre.", no verbs); offline hidden. Live refresh on `persona_state_change` and `friend_rich_presence_update`, using the immediate friends list, persona name and state, the `licensed` rich-presence key, and the friend's played-game lobby.

Join: leave your own room, `joinLobby` theirs, `connect_to_lobby` on success. Only a lone learner may join: if anyone else is in your room, Join reads as the state line "You have company." Nothing in your own room is torn down until `lobby_joined` reports success and the lobby's `game` data reads `licensed`. Failure after the press leaves the row and sets its state line, no modal: full → "The waiting room is full."; does not exist or no longer at the test centre → "Nobody is at the test centre."; anything else → "The room did not answer." The debug build logs the enum.

Footer: Leave when you are a guest (a new lobby, hosted, alone, at the entrance; the others see the arrival theatre in reverse). The host has no Leave. A guest whose host vanishes lands on the same path. In debug builds one strip with "Copy room ID" and a "Join by ID" field taking a raw 64-bit lobby id, never behind a flag of its own. Under `--transport=enet` the desk shows the real friends list with all verbs disabled and the single footer line "Dev transport."

Checked over real Steam on Emil's two computers; the dev transport cannot exercise it.

**Blocked by:** 05 (arrival theatre on join and leave), 07 (the dock-and-cursor station screen).

**Status:** claimed

- [ ] "E  Reception" in the desk's zone; E docks on the desk screen drawn on the kit's screen surface with the placeholder hidden; Escape returns.
- [ ] The header reads "Reception" and "1 of 3" / "2 of 3" / "3 of 3" from the room state; at three it reads "The waiting room is full." and no row has a verb.
- [ ] Friends appear in the three groups with avatar, name, and exact state line; offline friends are hidden; the list updates live when a friend opens or closes the game.
- [ ] Pressing Join on a friend at the test centre fades out and arrives in their room through the entrance (ticket 05), and their desk moves you to *In this room*.
- [ ] With someone in your room, Join is replaced by "You have company."
- [ ] A failed join leaves your room intact and shows exactly one of the three failure lines on that row.
- [ ] A guest sees Leave in the footer and, on pressing it, is alone at the entrance of a fresh room of their own; the host sees no Leave.
- [ ] Debug builds show the "Copy room ID" / "Join by ID" strip; release builds do not.
- [ ] Under `--transport=enet` the desk shows the real friends list, every verb disabled, and the footer "Dev transport."
- [ ] Verified with two real Steam accounts on two machines; the result is written into the ticket's Comments.

## Comments

**From ticket 04 (orchestrator).** This ticket only hosts; joining another Steam lobby is still open. `Transport.lobby_id` is the hosted lobby. Autoload `Transport` (`scripts/transport.gd`) picks Steam or ENet; room code talks to `multiplayer` only. Under `--transport=enet` the desk should show the real friends list, every verb disabled, footer "Dev transport." Setup: `docs/run-instances.md`.

**From ticket 05 (orchestrator).** `WaitingRoom.begin_join()` / `begin_leave()` are the desk Join and Leave seams. Parent Astra's door leaf to `ArrivalTheatre/Leaf` (hinge on the −X jamb). Mid-room drop: learner vanishes where they stood and the entrance door sounds once; the leaf does not swing. Reverse door theatre is only for deliberate Leave or a clean window close.

**From ticket 06 (orchestrator).** Reception uses the same `Station` (`scripts/station.gd`) with `"E  Reception"` at `AttachmentPoints/ReceptionApproach`. `set_listening` / `used` / `setup(prompt, prompt_at, zone_size)`. Do not fork a second grammar.

**From ticket 07 (orchestrator).** `StationScreen` (`scripts/station_screen.gd`) is the desk's dock/cursor/Escape half of the grammar. Do not fork a second grammar. Escape closes the station screen while it is open.

**Builder, 2026-09-12.** `ReceptionDesk` (`scripts/reception_desk.gd`) is a `Station` + `StationScreen` at `AttachmentPoints/ReceptionApproach`, prompt `"E  Reception"`. 740×460 SubViewport quad on `FriendsScreen`; `FriendsScreenPlaceholder` hidden. Header and occupancy come from `RoomState`; Invite is drawn disabled (ticket 10). Join goes through `WaitingRoom.begin_join()` then `Transport.join_lobby`; Leave through `begin_leave()` / `Transport.host_fresh()`; a guest whose host vanishes takes the same path. Occupancy is lobby data `n` so a friend's full room hides Invite and Join. `RoomState` tests still PASS. Headless Steam and `--transport=enet` boots construct the desk without script errors.

Could not walk the dock, press Join/Leave, or watch live friend grouping in a window this session. Could not run two real Steam accounts on two machines; that criterion stays open.

# 04: Three learners in one room

**Spec:** `.scratch/waiting-room/spec.md`, sections 0 (networking, one source of truth, palettes), 2 (name tag), 4 ("A room from the first frame"), and 11 (the dev transport and `--min-players`). ADR-0001 and ADR-0002 bind this ticket.

**What to build:** Three copies of the game meet in one waiting room and see each other walk around, tellable apart by colour and name. In release that room is a Steam lobby hosted from the first frame; in development three editor instances on one PC meet on localhost.

Exactly one autoload picks the peer at startup and room code depends on `multiplayer` only. Without a flag, or with `--transport=steam`: create a FRIENDS_ONLY Steam lobby of max three, set its `game` lobby data to `licensed`, host via `host_with_lobby`, before the player does anything, so a lone player is already a host a friend can join (joining itself is ticket 09). With `--transport=enet` (after `--`): `ENetMultiplayerPeer` on localhost, bind-or-join on a fixed port; every instance runs identical args, tries to listen, connects if the port is taken. First window hosts, the others join. No `--host` flag, no per-instance config. Steam is still required under every transport (ticket 01's gate stays). `--min-players=N` is parsed here and handed to the room state as the count the room waits for; it has no UI and appears in no release notes.

Learners: each player owns and moves their own learner; position and yaw replicate. Learners are solid to each other and do not shove. The host applies the room state from ticket 02, raising arrive and leave commands from peer connect and disconnect, and replicates the whole state to guests; guests send commands over reliable RPC. Palettes 01/02/03 (host is 01) are three fixed palettes chosen from the kit's six, matching the numbered chairs; the palette's shirt colour is the flood colour used everywhere later. Under the dev transport the display name is the Steam name with the peer id appended for non-hosts: "Emil", "Emil (2)", "Emil (3)".

Name tag: a billboard above the head with the display name, fixed screen size, no distance fade, drawn for the other two and never for yourself. No avatar in 3D.

Document the three-learners-in-under-a-minute setup: Godot *Debug → Customize Run Instances…*, three instances, main run args `-- --transport=enet`, and the exe run three times with the same args; the per-clone config is gitignored.

**Blocked by:** 01 (Steam identity), 02 (the room state), 03 (the learner controller).

**Status:** claimed

- [ ] Three editor instances launched with `-- --transport=enet` end up in one room: the first hosts, the others join; all three learners are visible and moving on every screen.
- [ ] Without the flag, boot hosts a FRIENDS_ONLY Steam lobby of max three with `game=licensed` before any input (visible in the log with the lobby id).
- [ ] `--transport` accepts only `steam` (default) and `enet`; nothing else is a mode.
- [ ] Steam init failure still shows the Steam-not-running state under `--transport=enet`.
- [ ] The three learners wear three different fixed palettes by arrival order, and the same player is the same colour on every machine.
- [ ] The other two learners carry a name tag with the display name (peer-suffixed under enet); your own name tag is never drawn for you.
- [ ] Standing in front of another learner blocks them; neither moves.
- [ ] The host's room state is the only writer: a guest disconnecting frees their slot on every machine, a joiner appears in the state on every machine.
- [ ] `--min-players=N` is parsed and reaches the room state's configured count (checked by log, or by the notice board once ticket 11 lands).
- [ ] The run-instances setup is documented in one place in the repo and the generated per-clone config is gitignored.

## Comments

**From ticket 01 (orchestrator).** `change_scene_to_packed` called directly from the main scene's `_ready` at boot fails to remove the scene (root is busy adding it) and prints an error; `call_deferred` lands the swap before the first frame, which is what `waiting_room.gd` does. The room scene reuses the kit preview's environment and four ceiling omni lights (the kit has no lights of its own); the fixed `EntranceCamera` is at (1, 1.8, 4.55) and is what the learner's camera replaces. The gate on `SteamClient.is_running()` sits at the top of `waiting_room.gd`.

**From ticket 02 (orchestrator).** `RoomState` (`scripts/room_state.gd`, `class_name`, RefCounted) is the record every view renders from; commands return bool (applied/refused) and end in one `_after_command` that raises `booking_formed`/`booking_dissolved` then `countdown_started`/`countdown_cancelled`/`launched(vehicle, roles)`. Vehicles/roles are StringName constants on it (`MONSTER_TRUCK`, `DRIVER`, `SPOTTER`, `NAVIGATOR`, `RANDOM`); empty pick/hold = none, chair 0 = standing, palettes 1/2/3. `snapshot()`/`restore()` carry the whole record as plain `var_to_str`-safe data; a guest's copy derives booking, holders, notice board line and count from the same code and raises no events. Replicating the host's events to guests (booking sound, examiner line) is this ticket's call; a state diff on the guest is one option. `RoomState.min_players_from_args(OS.get_cmdline_user_args())` reads `--min-players=N`, clamped 1..3; the room waits for `max(N, players present)` so a dev room of three waiting for two never reads "Roles: 2 of 2." while someone is unready.

**From ticket 03 (orchestrator).** Wrap `scenes/learner.tscn` via `Learner.set_local`; spawn at `Kit/AttachmentPoints/Entrance` (the GLB has another Entrance group). Collision is already on the waiting-room scene. `set_local(bool)` is the seam: input, the current camera, mouse capture, and hiding `HeadPivot` are on only for the learner this machine walks. Safe before or after `add_child`. The kit visual is `$Visual` (palette exports unchanged).
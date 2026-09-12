# 04: Three learners in one room

**Spec:** `.scratch/waiting-room/spec.md`, sections 0 (networking, one source of truth, palettes), 2 (name tag), 4 ("A room from the first frame"), and 11 (the dev transport and `--min-players`). ADR-0001 and ADR-0002 bind this ticket.

**What to build:** Three copies of the game meet in one waiting room and see each other walk around, tellable apart by colour and name. In release that room is a Steam lobby hosted from the first frame; in development three editor instances on one PC meet on localhost.

Exactly one autoload picks the peer at startup and room code depends on `multiplayer` only. Without a flag, or with `--transport=steam`: create a FRIENDS_ONLY Steam lobby of max three, set its `game` lobby data to `licensed`, host via `host_with_lobby`, before the player does anything, so a lone player is already a host a friend can join (joining itself is ticket 09). With `--transport=enet` (after `--`): `ENetMultiplayerPeer` on localhost, bind-or-join on a fixed port; every instance runs identical args, tries to listen, connects if the port is taken. First window hosts, the others join. No `--host` flag, no per-instance config. Steam is still required under every transport (ticket 01's gate stays). `--min-players=N` is parsed here and handed to the room state as the count the room waits for; it has no UI and appears in no release notes.

Learners: each player owns and moves their own learner; position and yaw replicate. Learners are solid to each other and do not shove. The host applies the room state from ticket 02, raising arrive and leave commands from peer connect and disconnect, and replicates the whole state to guests; guests send commands over reliable RPC. Palettes 01/02/03 (host is 01) are three fixed palettes chosen from the kit's six, matching the numbered chairs; the palette's shirt colour is the flood colour used everywhere later. Under the dev transport the display name is the Steam name with the peer id appended for non-hosts: "Emil", "Emil (2)", "Emil (3)".

Name tag: a billboard above the head with the display name, fixed screen size, no distance fade, drawn for the other two and never for yourself. No avatar in 3D.

Document the three-learners-in-under-a-minute setup: Godot *Debug → Customize Run Instances…*, three instances, main run args `-- --transport=enet`, and the exe run three times with the same args; the per-clone config is gitignored.

**Blocked by:** 01 (Steam identity), 02 (the room state), 03 (the learner controller).

**Status:** ready-for-agent

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

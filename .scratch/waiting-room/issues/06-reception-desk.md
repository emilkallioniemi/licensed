# 06. The reception desk: inviting and arriving

Type: grilling
Status: resolved
Blocked by: 02, 04
Map: ../map.md

> Retyped from `prototype` to `grilling` on 2026-09-12, following the precedent of [Waiting room walkthrough](04-waiting-room-walkthrough.md) and the `docs/corrections.md` line of the same day: there is no walkable room to drop a desk UI into, and building the controller, dock, and a Steam lobby to react to a friends list is a build, not a decision. The flow is decided in conversation; the first build cut from the spec checks the feel. The real-Steam invite round-trip stays a note (see Comments).

## Question

The desk is where you invite friends without leaving the game, and the entrance is where they arrive. How do both work?

Using what In-game invites and joining on app 480 found and the walkable room from Waiting room walkthrough. The kit already has a friends terminal on the counter: `Reception/FriendsTerminal/FriendsScreenSurface` (0.74 × 0.46 m, material `Screen`, hide `FriendsScreenPlaceholder` when a real UI goes on) with the `AttachmentPoints/FriendsScreen` marker for a 740 × 460 SubViewport quad. The entrance is at `AttachmentPoints/Entrance`.

1. **Desk UI.** Walk up, press the key, a list of Steam friends appears on the terminal screen (or as a flat overlay if the in-world screen is unreadable from the camera). The research fixes the constraint: an invite only reaches a friend whose game is *already running* (the `licensed` rich-presence key tells them apart from other "Spacewar" processes). So: friends in the game first and invitable; online friends not in the game listed but marked "ask them to open the game" (in register, perhaps: "The candidate has not arrived."); offline friends hidden or greyed. What a row shows (avatar, name, state), what pressing "invite" does, what the inviter sees while waiting. No lobby codes; a raw lobby-ID paste stays debug-only.
2. **The invitee.** Their game is running, so `lobby_invite` fires in their waiting room: how the invite appears (an in-world signal at the desk? the examiner's voice? a plain popup?) and how they accept. What happens to the room they were in (they are alone in a single-player-so-far room; leaving it should be free).
3. **Arrival.** The joiner spawns at the entrance and walks in. Does the door open, does anyone hear it, does the examiner say anything. Cheap theatre, worth a few lines.
4. **Room state on join.** What a joiner sees the moment they arrive: the others' positions, the current booking board state, roles already taken.

Deliverable: a rough desk UI on the terminal and an arrival at the entrance in the walkable room, linked, and an answer recording the flow well enough to spec.

## Comments

- 2026-09-12, from [Testing alone: a second transport or a fake](05-solo-testing-transport.md): the desk's invite path is the one thing the dev transport cannot exercise (inviting is a Steam-lobby fact; under `--transport=enet` instances bind-or-join on localhost with no desk involvement). Build and react to the desk UI, the invitee's prompt, and the arrival with three local instances; the real invite round-trip is checked when a friend (Emil's brother) is online. That check is a note on this ticket, not a blocker on resolving it.
- 2026-09-12, from [Waiting room walkthrough](04-waiting-room-walkthrough.md): first person, one camera per player; the desk is a station: E at the counter docks the camera onto the friends terminal's screen and the mouse becomes a cursor, so the "flat overlay if unreadable" hedge in item 1 is the fallback, not the plan. Keyboard and mouse only. Astra is being asked for a closed door leaf in the entrance, so item 3's "does the door open" has a door to open. The walkable room was decided, not built; the claiming session builds the controller and dock first or regrills this as conversation.
- 2026-09-12, from [Ready-up and the launch stub](09-ready-up-and-launch.md): the arrival theatre gets a second use. Coming **back from the test area** (host-only Back in the Escape overlay, or the remaining players after a drop) lands everyone in the same room through the entrance one after another, with all state cleared; the desk's "1 of 3" header and friends list should read correctly on that return as on a first arrival. A drop in the test area is otherwise the desk's existing rule: a host drop puts guests in fresh rooms of their own.

## Answer

Decided in conversation on 2026-09-12 (two rounds and one delegated call). Steam facts below come from [In-game invites and joining on app 480](02-in-game-invites-on-app-480.md); the station grammar, first-person camera, and palettes-by-arrival from [Waiting room walkthrough](04-waiting-room-walkthrough.md). Vocabulary: a **room** is one running waiting room (technically one Steam lobby); a friend is **at the test centre** when their copy of the game is running.

### 1. Every waiting room is a room from the first frame

- Booting the game creates a FRIENDS_ONLY lobby of max three and hosts it (`createLobby` → `host_with_lobby`) before the player has done anything. The "single-player-so-far session" is literally a room of one. Every client sets the `licensed` rich-presence key at boot.
- Consequence: a friend's desk can see your room and **join** it without any invite. This is what makes the app-480 constraint (an invite cannot launch the game for someone who is not running it) nearly invisible: they open the game because you told them to, walk to their desk, and you are already listed.
- Two lone players both host until one accepts the other's invite; leaving a room you are alone in is free.

### 2. The desk screen

The reception desk is a station like any other: walk into the zone, prompt "E  Reception", E docks the camera onto the friends terminal's `FriendsScreenSurface` (a 740 × 460 SubViewport), the mouse becomes a cursor, Escape closes. Plain Godot Control theme, no art. Copy is in the test centre's dry **signage** register (short, full stops, no exclamation marks); it is not the examiner's voice, who does not speak out of a monitor.

- **Header**: "Reception" and an occupancy count, "1 of 3". At three it reads "The waiting room is full." and every verb disappears from every row.
- **List**, groups top to bottom, alphabetical by Steam name within a group; each row is the medium Steam avatar (64 px, via the async `avatar_loaded` path), Steam name, one state line, and zero, one, or two verbs:
  1. **In this room**: state "In the waiting room", no verbs. Doubles as confirmation an invite landed.
  2. **At the test centre** (game running, `licensed` key present): state "At the test centre", verbs **Invite** and **Join**. Both verbs are hidden when the friend's own room is full.
  3. **Online, not at the test centre**: state "Online. Not at the test centre.", no verbs. The player reads it as "tell them to open the game".
  4. **Offline** friends are hidden.
- The list refreshes live on `persona_state_change` and `friend_rich_presence_update`.
- **Footer**: the **Leave** verb when you are a guest in someone else's room (section 4); otherwise empty in release. In debug builds (`OS.is_debug_build()`) a one-line strip with "Copy room ID" and a "Join by ID" field, the already-decided raw-ID paste; it never needs a flag of its own.

### 3. Invite

- Pressing **Invite** calls `inviteUserToLobby`. Steam does not confirm delivery, so the row's verb becomes "Invited." for 30 s and then Invite returns. Nothing changes on the inviter's learner; no examiner line. When the friend walks in, their row moves to *In this room*.
- On the invitee's side, `lobby_invite` fires in their running room and is handled **in-world at the desk**: a row appears at the top of their desk screen (inviter's avatar and name, "is asking for you", verbs **Accept** and **Ignore**); the desk's station prompt changes to "E  Emil is asking for you" until the row is gone; a placeholder ring (a beep until Astra gives us a desk bell) plays once, about two seconds, positional at the reception desk so it carries from the booking board. If already docked at the desk, the row appears inline.
- Invites do **not** expire on their own; staleness is checked when Accept is pressed (section 5). Several invites stack as rows, newest on top; accepting one clears the rest. Ignore removes the row locally; the inviter learns nothing and their "Invited." times out.
- Steam's own Join (`join_requested`) is routed to the same path as Accept.

### 4. Join, Accept, and company

- **Join** on an *At the test centre* row and **Accept** on an invite row are the same act: leave your own room, `joinLobby` theirs, `connect_to_lobby` on success.
- **Only a lone learner leaves.** If anyone else is in your room, Accept and Join are replaced by the state "You have company." and you sort it out by voice: someone leaves, or they come to you. This keeps host-leaves-with-guests (host migration, out of scope) out of the room.
- **Leave** (Emil's steer; the agent recommended quit-only): a guest in someone else's room sees a **Leave** verb at the bottom of their desk screen, in the footer row. Pressing it puts them back in a fresh room of their own, alone, standing at the entrance, with a lobby of their own already hosted. The others see them go out the way they came (section 6, reversed). The host has no Leave: the host's room is the host's, and their exit is the Escape overlay's quit. The same "back to a room of your own" path is what a guest lands on if the host vanishes; *what the room says* when that happens is left in the fog (Session lifecycle edges), the mechanism is not.

### 5. Failure

Accept and Join can fail after the press: room filled, host quit, friend closed the game since the last refresh. The row stays and its state line becomes a dry one-liner; no modal, no error code (the debug build logs the enum):

- `CHAT_ROOM_ENTER_RESPONSE_FULL` → "The waiting room is full."
- `DOESNT_EXIST`, or the friend is no longer at the test centre → "Nobody is at the test centre."
- anything else → "The room did not answer."

Nothing in your own room is torn down until `lobby_joined` reports success and the lobby's `game` data reads `licensed`.

### 6. Arrival

- For the **joiner**: the moment they press Accept or Join, their own room fades to black; the host's room loads; they fade up standing in the doorway on the `Entrance` marker, facing into the room (-Z).
- For **everyone in the room**: the entrance door leaf (Astra's requested addition) swings open, the learner appears in the doorway, the door closes behind them after a couple of seconds. A placeholder door sound plays positionally at the entrance, heard by all. This is the room's only join notification: no toast, no examiner line. The examiner's first appearance in the waiting room is still fog; arrival is noted there as his natural hook, not decided here.
- Leaving runs the same theatre in reverse: door opens, the learner is gone, door closes.

### 7. Room state on join

- Everything is **host-owned state**. The joiner receives the current truth on spawn: the others' positions, everyone's booking-board pick, roles held, palettes dealt so far. Nothing resets because someone walked in; a join that took your leaflet would be the game's fault, not the players'.
- Palette by arrival order stands: the joiner is 02 or 03 regardless of what the host has done. Leaving (or vanishing) frees that player's pick and role; the messaging around involuntary leaves is fog.

### 8. Under the dev transport

Under `--transport=enet` the desk shows the real Steam friends list with avatars, all verbs disabled, and a one-line footer "Dev transport." The list and avatar path stay exercised; the seam is visible in exactly one place and reads as a seam, not a mode.

### Real-Steam check

The one thing three local instances cannot exercise is the invite round-trip itself (`inviteUserToLobby` → `lobby_invite`) and the *At the test centre* detection through rich presence. That is checked when a friend (Emil's brother) is online, as the Testing alone ticket recorded. Not a blocker on this decision or on the spec.

### Glossary

Added to `CONTEXT.md`: **Room**, **At the test centre**, **Invite**, **Join**, **Leave**, **Arrival**. *Reception desk* reworded to cover joining and leaving as well as inviting.

### Corrections logged

`docs/corrections.md`: the agent recommended that quitting to desktop be the only way out of a friend's room; Emil wants a player to always be able to leave and be back in a room of their own.

Unblocks: nothing directly (The booking board and Role pickup were already open); comments left on both and on Ready-up and the launch stub.

# Spec: the waiting room (pre-game)

Status: ready-for-agent
Map: [map.md](map.md)
Written: 2026-09-12, by collapsing tickets 01 to 10 under `issues/`
Slice: 0 ("connected") in the README's prototype plan

Everything a player meets before the driving test starts. Each section names the ticket that decided it; nothing here reopens a ticket. Vocabulary is `CONTEXT.md` (waiting room, room, station, booking, hold, ready-up, test area, and so on); the design judgment that applies is `docs/design.md`; the two ADRs that bind it are ADR-0001 (exactly three players) and ADR-0002 (Steam is the only shipping transport).

## Problem Statement

Three friends want to play a driving test together. Today there is a Godot project with a room model, a learner model, and a music loop, and nothing to run. They cannot open the game, find each other, agree on what to sit, pick who does what, or arrive anywhere together. Every later slice (the monster truck, the test, the examiner) needs three players who have already done all of that, over Steam, with their roles known on every machine.

Two constraints make the obvious answer wrong. The game is not on Steam yet (it runs as app 480, "Spacewar", from a GitHub zip), so a Steam invite cannot launch it and the overlay is unreliable. And the game's design says the place players gather in is not a menu: the README wants a place that is already the game, and `docs/design.md` names *Scaling* and *Polish before funny* as the drifts to resist.

## Solution

The game opens straight into a first-person, walkable 3D test-centre **waiting room**; there is no main menu in front of it. Every copy of the game is a **room** of its own from the first frame. At the **reception desk** a player sees which Steam friends are **at the test centre** (running the game) and invites or joins them; friends walk in through the **entrance** and everyone hears the door. At the **booking board** each player **picks** the vehicle whose test they want to sit; three matching picks make the **booking**, and only then does the board's **role pickup** wake so each player can **hold** Driver, Spotter, Navigator, or Random. Sitting in one of the three chairs is the **ready-up**; the **notice board** states, in one line of dry signage, what the room is still waiting for. When three players are seated with a booking and a role each, the examiner says "Monster truck.", the notice board counts three, the room fades, and the three learners stand together in the **test area**, a car park with their roles over their heads and the booked vehicle on a sign. **Voice** is on the whole time, from the learner's body. The **Escape overlay** holds mic mode, mute, quit, and (for the host, in the test area) the way back.

A development-only transport lets one developer run three instances on one PC and meet in one room, and a `--min-players` flag lets the room launch short, so all of it is testable alone except the Steam invite round-trip.

## User Stories

Actors: a **player** (any of the three), the **host** (whose room it is), a **guest** (a player in someone else's room), a **joiner** (a player in the act of arriving), an **invitee** (a player receiving an invite), and a **developer** (Emil, testing alone or cutting tickets).

### Launch and Steam

1. As a player, I want to unzip a GitHub release and double-click the exe with Steam running, so that I am in the game without installing anything else.
2. As a player, I want the game to open directly into the waiting room, so that the first thing I see is the place where my friends will arrive, not a menu.
3. As a player whose Steam client is not running, I want one clear line telling me so, so that I know what to fix rather than staring at a broken room.
4. As a player, I want the game to use my Steam name and avatar without asking, so that there is nothing to type or set up.
5. As a player, I want the waiting-room music to start with the room and loop without a seam, so that the room feels like a place from the first second.

### The room and the learner

6. As a player, I want to walk around the waiting room in first person with mouse look and WASD, so that I can investigate the room and stand where I like.
7. As a player, I want my friends' learners to be solid, so that standing in front of the booking board blocks them and they have to ask me to move.
8. As a player, I want to see my friends' Steam names floating above their learners, so that I know who is who without asking.
9. As a player, I want the three of us to wear three different, fixed colour palettes, so that we are tellable apart at a glance and the same colour means the same person everywhere in the room.
10. As a player, I want never to see my own name tag or my own head, so that first person stays clean.
11. As a player, I want the room to be closed (an entrance door leaf, a closed Test Area door), so that I never look out into nothing.

### Stations

12. As a player, I want every station to work the same way (walk up, see a prompt, press E, the camera settles on the station's screen, the mouse becomes a cursor, Escape closes), so that I learn the room once.
13. As a player, I want the other two to see me standing at a station while I use it, so that the room reads truthfully to everyone.
14. As a player, I want a station's controls drawn on the station's own physical surface, so that the room has no floating panels.

### The reception desk, inviting, joining, leaving

15. As a player, I want to be in a room of my own from boot, so that a friend can join me before I have done anything.
16. As a player, I want the reception desk to list my Steam friends grouped by whether they are in my room, at the test centre, or merely online, so that I can tell at a glance who I can invite and who I need to tell to open the game.
17. As a player, I want offline friends hidden from the desk, so that the list is only people who could conceivably come.
18. As a player, I want each friend's row to show their avatar, name, and one state line, so that the list reads like a register, not a spreadsheet.
19. As a host, I want to press Invite on a friend who is at the test centre, so that their game asks them to come to my room.
20. As a host, I want the row to read "Invited." for a while after I press Invite, so that I know the press landed even though Steam does not confirm delivery.
21. As a player, I want to press Join on a friend who is at the test centre, so that I can walk into their room without waiting to be invited.
22. As an invitee whose game is running, I want the invite to arrive at my reception desk (a row with Accept and Ignore, a changed station prompt, a bell), so that I notice it wherever I am in my room without a popup.
23. As an invitee, I want to Accept or Ignore an invite from the desk, so that I decide in-world.
24. As an invitee, I want an invite never to expire on its own, so that I can finish what I am doing first; if it is stale when I accept, I want one dry line saying so.
25. As a player with someone else already in my room, I want Join and Accept replaced by "You have company.", so that I do not accidentally abandon my guest, and we sort out who goes where by voice.
26. As a guest, I want a Leave verb at the desk that puts me back in a fresh room of my own, so that I am never trapped in a friend's room short of quitting the game.
27. As a host, I want to know my room is mine (no Leave), so that guests join me, not the other way round.
28. As a player, I want to see the desk header count "1 of 3", "2 of 3", "3 of 3", so that I know how many we are.
29. As a player, I want the desk to say "The waiting room is full." at three and hide every verb, so that nobody tries to invite a fourth.
30. As a player who pressed Join or Accept, I want a dry one-line reason when it fails (full, gone, no answer), so that I know what happened without an error code.
31. As a player, I want my own room left intact until the join actually succeeds, so that a failed join costs nothing.
32. As a friend who is not yet running the game, I want the desk on my friend's side to show me as "Online. Not at the test centre.", so that they know to tell me to open the game rather than wondering why the invite did nothing.

### Arrival

33. As a joiner, I want to fade out of my room and fade up standing in my friend's doorway, so that arriving is a walk in, not a teleport.
34. As a player already in the room, I want the entrance door to open, the joiner to appear, and the door to close, with a door sound I can hear from anywhere in the room, so that I know a friend has arrived without a toast.
35. As a joiner, I want to see the room exactly as it is (where the others stand, what they have picked, what roles they hold), so that walking in never resets anything.
36. As a player, I want a friend who leaves to go out through the same door, so that departures read the same as arrivals.

### The booking board

37. As a player, I want to walk to the booking board and see the monster truck as the one bookable row, so that I know what is on offer.
38. As a player, I want to see four locked roadmap vehicles with a padlock and one dry line each, so that the future is visible and a little funny.
39. As a player, I want to pick a vehicle by clicking its row, drop it by clicking again, and switch by clicking another, so that choosing is one click.
40. As a player, I want my pick shown on the row as a chip in my colour with my Steam name, so that everyone sees what I chose.
41. As a player, I want disagreement to be quiet (chips on different rows, nothing said), so that we argue it out on voice rather than being told off.
42. As a player, I want the booking to form only when all three of us have picked the same vehicle, so that nobody's choice overrides anyone's.
43. As a player, I want the booked row to read BOOKED and the board to make a sound, so that agreement is a moment.
44. As a player, I want the booking to dissolve silently the moment anyone changes their pick or leaves, so that it is always true.
45. As a player, I want clicking a locked row to do nothing, so that the row's line is the whole answer.
46. As a player, I want to arrive at the board with no pick, so that walking there and clicking is the room's ritual.

### The role pickup

47. As a player, I want the role column dead and reading "No booking." until there is a booking, so that I never hold a role for a vehicle we have not agreed on.
48. As a player, I want to click a free role to hold it, click again to drop it, and click another to swap, so that holding is one click.
49. As a player, I want a held role's strip flooded with the holder's colour and their Steam name, and its lamp lit to match, so that the board is public signage.
50. As a player, I want a taken role's button to do nothing when clicked, so that the strip explains itself.
51. As a player, I want ties on the same role resolved silently in the host's order, so that the loser simply sees the other name appear.
52. As a player, I want to hold Random alongside any number of others holding Random, so that "deal me whatever" is always available.
53. As a player, I want Random holders shown as colour pips on the Random button, so that I can see who is leaving it to chance.
54. As a player, I want my friends' held roles shown as a second line on their name tags, so that I can see from anywhere in the room who still has no role.
55. As a player, I want every held role released the moment the booking dissolves, so that no role outlives the booking it was taken for.

### Ready-up and the notice board

56. As a player, I want to sit in any chair by pressing E and stand by pressing E or a move key, so that readying is something I do in the room.
57. As a player, I want my chair to flood with my colour while I sit, so that my friends see I am ready.
58. As a player, I want the chair never to refuse me, so that I can sit whenever I like and the notice board tells us what is missing.
59. As a player seated, I want the camera to drop to seated height and mouse look to stay live, so that I can watch the door and the board.
60. As a player, I want the notice board to state in one line what the room is waiting for ("Waiting for 2.", "No booking.", "Roles: 2 of 3.", "Seated: 1 of 3."), so that nobody has to ask.
61. As a player, I want the notice board to count "Monster truck. 3." to "1." once nothing is missing, so that launch is visible and undoable.
62. As a player, I want to hear the examiner call the booking once, "Monster truck.", so that the room has one voice that is not ours.
63. As a player, I want standing up, changing a pick, dropping a role, or a friend leaving to cancel the countdown silently, so that the launch is undoable until the last moment.
64. As a player, I want the room to fade to black, the door sound to play, and the music to fade, so that leaving the room is a transition, not a cut.

### The test area

65. As a player, I want to fade up in a car park with my two friends standing beside me, so that we arrived together.
66. As a player who held a named role, I want to see it as one line in a corner of my screen, so that I know what I am.
67. As a player who held Random, I want to learn my dealt role in the same corner line on arrival, so that Random resolves for me too.
68. As a player, I want to see my friends' roles on their name tags, so that the deal is public.
69. As a player, I want to see a sign reading MONSTER TRUCK, so that the booking visibly travelled with us.
70. As a player, I want to walk around the car park with the same controller and hear my friends' voices from their bodies, so that the test area proves input and voice carried across.
71. As a host, I want "Back to the waiting room" in the Escape overlay, so that we can do the ritual again for another demo.
72. As a guest, I want to be returned to the waiting room with everyone when the host goes back or when anyone drops, so that we share fate.
73. As a player returning to the room, I want all state cleared (no picks, no roles, nobody seated, "No booking."), so that the demo is done again from the start.

### Voice and the Escape overlay

74. As a player, I want to be heard by my friends the moment I am in a room with them, with nothing to set up, so that talking is the game.
75. As a player, I want voice to come from my friends' learners, a little quieter across the room but always clearly intelligible, so that the room has direction without anyone ever being hard to hear.
76. As a player, I want a speaking indicator on a friend's name tag while their voice comes through, so that I can tell one-way audio from silence.
77. As a player, I want to switch between open mic and push-to-talk, so that a loud fan or three instances on one desk are not a problem.
78. As a player, I want a self-mute, so that I can stop my own microphone.
79. As a player, I want my mic mode and mute to survive a restart, so that I set them once.
80. As a player, I want Escape to open a small overlay with mic mode, mute, and quit to desktop, while the room keeps running behind it, so that I have a way out that is not Alt-F4.

### Developer

81. As a developer, I want `--transport=enet` to let three editor instances meet in one room on localhost, so that I can react to the room without three Steam accounts.
82. As a developer, I want the dev transport to still require Steam, so that names and avatars stay real and the seam proves the real identity path.
83. As a developer, I want `--min-players=N` to be the one count the room waits for (booking, roles, seated, notice board), so that I can reach the test area alone.
84. As a developer, I want the reception desk under the dev transport to show the real friends list with verbs disabled and a "Dev transport." footer, so that the seam is visible in exactly one place.
85. As a developer, I want to hear my own voice echo under three local instances, so that capture and playback are smoke-tested without a friend.
86. As a developer, I want the host-owned room state testable headless without Steam or a transport, so that the rules (booking, roles, ready-up, countdown, deal) are checked by a script, not only by three people.
87. As a developer, I want a GitHub release zip of exe, pck, and the two DLLs, so that a friend can run the build from a download.

## Implementation Decisions

### 0. Shape of the build

- **Engine**: Godot 4.7, Forward+, Jolt physics, GDScript; the project settings already say so. The README's "engine undecided" is stale and the build does not wait on it.
- **Networking**: Godot's high-level `MultiplayerAPI` over GodotSteam's `SteamMultiplayerPeer` in release (ADR-0002), `ENetMultiplayerPeer` on localhost behind the dev flag (section 11). Room code depends on `multiplayer` only; exactly one autoload picks the peer at startup.
- **One source of truth: the host-owned room state.** The host holds one record of the room and is the only writer. Per player, in arrival order: Steam id, display name, palette (01/02/03), pick (a vehicle or none), hold (a named role, Random, or none), seated (a chair or none). Derived from it: whether a booking exists and which vehicle, the notice board's line, the countdown, and, at launch, the dealt roles. Guests send **commands** (pick, drop, switch; take, drop, swap a role; sit, stand) to the host over reliable RPC; the host applies them in receive order and replicates the whole state back; every view in the room (chips, strips, lamps, pips, chairs, name tags, notice board, BOOKED, the desk header count) renders from the replicated state and never mutates it. Arrivals and departures are commands the host raises itself from peer connect and disconnect. This record and its rules are a plain script with no scene, node, Steam, or transport dependency; that is the one testing seam (Testing Decisions).
- **Palettes**: three fixed palettes chosen from the kit learner's six colours, one per arrival slot 01/02/03 (host is 01), matching the numbered chairs' decor. The palette's shirt colour is the **flood colour** used everywhere a player is marked: pick chips, occupant strips and lamps, Random pips, and an occupied chair. Not a customisation system; the player never chooses.
- **Copy has two registers and they never mix.** Every line drawn on a surface in the room (desk, board, strips, notice board, test area sign) is **signage**: short, full stops, no exclamation marks, no second person, never spoken. The **examiner** speaks exactly one line in this slice (section 7) and is never written on a surface. `docs/design.md` is the register's rule book.
- **Placeholders are the design**, per *Polish before funny*: TTS for the examiner, a beep for the desk bell, one door sound (reused for the Test Area door), boxes for the car park, a plain Godot Control theme on station screens, no particles, no VO.

### 1. Launch and Steam (tickets 01, 05)

- GodotSteam GDExtension **4.22.1** (bundles `SteamMultiplayerPeer`); not the pre-built editor and not the retired separate peer.
- A Steam autoload with `PROCESS_MODE_ALWAYS` calls `Steam.steamInitEx(480, true)` first thing. Passing 480 sets the app id environment; **no `steam_appid.txt` anywhere**, in the project or the zip. Steam is usable only on status `STEAM_API_INIT_RESULT_OK`.
- Every client sets the rich-presence key `licensed` = `1` at boot; it is how a desk tells our build apart from every other process Steam labels "Spacewar".
- **Steam is required under every transport.** If init fails, the game does not open a room. It shows the **Steam-not-running state**: a plain black window with one line of signage, "Steam is not running.", Valve's `verbal` message beneath it in smaller text, and Escape or the window close quitting to desktop. (The tickets decided the gate and the status codes; the two lines are the spec's minimal call and are on the build-time list.)
- Local identity: `getPersonaName`, `getSteamID`; avatars through `avatar_loaded` and `getPlayerAvatar(AVATAR_MEDIUM)` turned into an `ImageTexture`; `requestUserInformation` for users not yet met.
- The waiting room loads on success with the music loop playing on an `AudioStreamPlayer` (fades happen on the player, never in the asset) and the player's own room already hosted (section 4).

### 2. The waiting room and the learner (ticket 04)

- The kit is used as is: `waiting_room.tscn` (12 × 10 m, entrance at Z = +5, reception and board toward Z = −5, three chairs on the left wall, closed Test Area door, spare notice board) and `learner.tscn`. **No greyboxing.** Collision: a trimesh from the GLB's `Architecture` group for walls and floor; hand-placed boxes for counter, cupboards, chairs, plant, bin. The entrance is a way in only.
- **Learner controller**: a `CharacterBody3D` around the learner, capsule about 0.6 m wide and 2 m tall, feet at origin, model forward +Z faced the way the camera looks. **3 m/s**, no sprint, no jump. Learners are **solid to each other and do not shove**; the other learner's replicated collider blocks you, nobody moves. Each player owns and moves their own learner; position and yaw replicate.
- **Camera**: first person, one per player, at about 1.75 m; mouse look, WASD camera-relative; body yaw follows the camera, head pitch is not shown; your own head is hidden from your own camera, your body stays visible when you look down. Mouse captured in the room, released while a station screen or the Escape overlay is open. Rejected: a fixed room camera, third-person orbit.
- **Name tag**: a billboard above the head with the Steam name, fixed screen size, no distance fade, drawn for the other two and never for yourself. It gains a second, smaller line for the held role (section 6) and a speaking indicator (section 10). The Steam avatar appears nowhere in 3D; only on the desk screen.
- **Arrival position**: the `Entrance` marker, facing into the room (−Z). Host and joiners alike start there.
- **Input**: keyboard and mouse only, PC only.

### 3. Stations and station screens (ticket 04)

One grammar for every **station** (reception desk, booking board, each chair):

- Walk into the station's **zone** (a volume around its `AttachmentPoints` approach marker) and a **prompt** appears in the world above the station ("E  Reception", "E  Booking", "E  Sit"). Press **E**.
- For the desk and the board, the **station screen** opens on the station's own surface: the camera glides to a **dock** pose framing the surface, the mouse is released and becomes a cursor on that surface, your learner stands still facing the station, and the other two see you stood there. **Escape** closes it and returns the camera to your head.
- The desk's screen is a **740 × 460 SubViewport** on a quad at the `FriendsScreen` marker, over the 0.74 × 0.46 m `FriendsScreenSurface`, with `FriendsScreenPlaceholder` hidden. The board's dock is about 3 m back framing the whole 3.5 m board (the kit's `preview_booking.png` view); vehicle rows and role buttons are picked with the same cursor from the same dock. Cursor hits are resolved by raycasting from the camera through the cursor onto the surfaces and mapping to the screen's controls.
- Chairs use the same key and prompt but have no screen: E sits, E or any move key stands (section 7).
- **Escape precedence** (the spec's reconciliation of tickets 04 and 10): while a station screen is open, Escape closes it; when nothing is open, Escape opens the Escape overlay. The overlay is never opened over a station screen.
- Fallback, allowed without changing the grammar: any station screen may drop to a flat 2D overlay if the in-world screen fights the build.

### 4. The reception desk, inviting, joining, leaving, arriving (tickets 06, 02)

**A room from the first frame.** Booting creates a FRIENDS_ONLY Steam lobby of max three, sets its `game` lobby data to `licensed`, and hosts it via `host_with_lobby`, before the player does anything. Two lone players both host until one joins the other. Nobody can join a room of three, so the lobby type is the session's access control and a fourth is impossible by construction (ADR-0001).

**The desk screen.** Signage register, plain Control theme.

- Header: "Reception" and the count, "1 of 3" / "2 of 3" / "3 of 3". At three: "The waiting room is full." and every verb on every row disappears.
- Rows: medium Steam avatar (64 px, async), Steam name, one state line, zero to two verbs. Groups top to bottom, alphabetical within a group:
  1. In this room: state "In the waiting room", no verbs (doubles as confirmation an invite landed).
  2. At the test centre (game running, `licensed` rich-presence key present): state "At the test centre", verbs **Invite** and **Join**; both hidden if that friend's own room is full.
  3. Online, not at the test centre: state "Online. Not at the test centre.", no verbs.
  4. Offline: hidden.
- Live refresh on `persona_state_change` and `friend_rich_presence_update`; friend data via `getFriendByIndex(FRIEND_FLAG_IMMEDIATE)`, `getFriendPersonaName`, `getFriendPersonaState`, `getFriendRichPresence(id, "licensed")`, `getFriendGamePlayed(id).lobby`.
- Footer: **Leave** when you are a guest; otherwise empty in release. In debug builds (`OS.is_debug_build()`) one strip with "Copy room ID" and a "Join by ID" field (raw 64-bit lobby id paste), never behind a flag of its own. Under the dev transport the footer is the single line "Dev transport." (section 11).

**Invite.** Invite calls `inviteUserToLobby`. Steam does not confirm delivery: the row's verb reads "Invited." for **30 s**, then Invite returns. Nothing else changes for the inviter; the friend's row moving to *In this room* is the confirmation.

**The invitee.** `lobby_invite` in a running room is handled **in-world at the desk**: a row appears at the top of the invitee's desk screen (inviter's avatar and name, "is asking for you", verbs **Accept** and **Ignore**); the desk's prompt becomes "E  <Name> is asking for you" until the row is gone; a **placeholder ring** (a beep, about two seconds, until a desk bell exists) plays once, positional at the desk, loud enough to carry from the board. If already docked at the desk the row appears inline. Invites **never expire**; several stack newest on top; accepting one clears the rest; Ignore removes the row locally and tells the inviter nothing. Steam's own Join (`join_requested`) routes to the same path as Accept.

**Join and Accept are one act**: leave your own room, `joinLobby` theirs, `connect_to_lobby` on success. **Only a lone learner may join or accept**: if anyone else is in your room, Join and Accept are replaced by the state line "You have company." and the players sort it out by voice. Nothing in your own room is torn down until `lobby_joined` reports success and the lobby's `game` data reads `licensed`.

**Failure** after the press leaves the row and sets its state line, no modal (the debug build logs the enum):

- `CHAT_ROOM_ENTER_RESPONSE_FULL` → "The waiting room is full."
- `DOESNT_EXIST`, or the friend is no longer at the test centre → "Nobody is at the test centre."
- anything else → "The room did not answer."

**Leave.** A guest's Leave puts them in a fresh room of their own (a new lobby, hosted), alone, standing at the entrance; the others see the arrival theatre in reverse. The host has no Leave; the host's exit is the Escape overlay's quit. A guest whose host vanishes lands on the same path. Leaving or vanishing frees that player's pick and role and (at three) dissolves the booking.

**Arrival.** For the joiner: fade to black on Accept or Join, the host's room loads, fade up standing in the doorway on the `Entrance` marker facing −Z. For everyone in the room: the entrance door leaf swings open, the learner appears, the door closes after a couple of seconds, one **placeholder door sound** positional at the entrance. That is the room's only join notification: no toast, no examiner. Until the requested door leaf lands, the sound alone carries it.

**Room state on join**: the joiner receives the full host-owned state (positions, picks, holds, seated, palettes dealt so far). Nothing resets because someone walked in. The joiner is palette 02 or 03 by arrival order regardless of what the host has done.

### 5. The booking board (ticket 07)

- A **booking** exists when **all three players in the room have picked the same vehicle**; it forms on the third matching pick and **dissolves** when any pick changes (drop or switch) or a player leaves. Arrivals never dissolve it (a room of three cannot be joined). Under `--min-players=N` it forms at N matching picks.
- **Rows**: the kit's static label meshes and the monster truck's `01` marker are hidden; each row is drawn on its `DisplaySurface` (1.93 × 0.34 m) in **two lines**. Top: the vehicle name. Bottom, bookable row: the **chip line**, up to three **pick chips**, each flooded with the picker's colour with their Steam name in ink, left to right in arrival order, blank when nobody has picked. Bottom, locked row: its copy, stopping short of the padlock. **Padlock meshes stay.** The monster truck is the only bookable row this slice.
- **Pick, drop, switch**: click a bookable row to pick; click your picked row to drop; click another bookable row to switch in one move. At most one pick per player. **No pre-pick**: nobody arrives with a pick. Clicking a **locked row does nothing** (no rattle, no line).
- **Locked-row copy**, signage register:
  - CAR: "Manual. Indicators on the passenger side."
  - MOPED: "Seats one. Party of three."
  - TRUCK + TRAILER: "One of you rides on the trailer."
  - HELICOPTER: "Three controls. No manual."
- **Disagreement is quiet**: chips on different rows, or a row missing a chip, is the whole display; no footer, no examiner.
- **The moment of booking**: the booked row's top line gains **BOOKED** at its right end (where `01` sat); chips stay; the role column wakes (section 6); one short **placeholder sound** from the board heard by everyone. No colour change. **Dissolution is silent**: BOOKED disappears, strips read "No booking." again, roles release.
- Same rules under the dev transport; nothing on the board knows its transport.

### 6. The role pickup (ticket 08)

- The role pickup is the **right column of the booking board**, shared dock and cursor. Kit: `DriverChoice`, `SpotterChoice`, `NavigatorChoice` (button, 0.65 × 0.105 m `OccupantSurface`, `StatusLamp`) and `RandomChoice` (button only). Labels are fixed for this slice because only the monster truck can be booked; the column would show the booked vehicle's roles when a second vehicle unlocks (a spec note, not work).
- **Gated on the booking**: dead until a booking exists; clicks do nothing; each of the three occupant strips reads **"No booking."** in signage register; Random's button is unchanged. The moment a booking dissolves, **every hold is released**: strips clear, lamps off, pips vanish, name tag role lines go blank.
- **Take, drop, swap**: click a free role button to hold it; click your own again to drop; click a different free button to swap in one move. A player holds at most one role or Random. Clicking a **taken** button does nothing. Same-frame contention on one free button: host receive order wins; the loser sees the other name appear; no error. Your own held button reads pressed (inset); all others flat.
- **Occupant strip and lamp**: free = strip blank, lamp off, as the kit ships. Held = strip flooded with the holder's colour, their **Steam name** in ink (never "You"), lamp lit in the same colour. No avatar on the strip.
- **Random is not exclusive**: any number may hold it. Holders show as **palette pips** along the Random button's right edge, one per holder, in arrival order. Random is dealt at launch (section 7).
- **Role on the learner**: the name tag gets a second, smaller line: "Driver" / "Spotter" / "Navigator" / "Random", blank when holding nothing; seen by the other two, never by yourself. This is the one thing about roles carried into the test area.
- Same rules under the dev transport; strips show the peer-suffixed name.

### 7. Ready-up, the notice board, the countdown, the transition (ticket 09)

- **Sitting is readying; standing is un-readying.** Each chair is a station: zone, prompt, **E** to sit, **E or any movement key** to stand. Seated, the camera drops to about **1.2 m** and mouse look stays live. **Any chair, first come**; the numbers are decor. An occupied chair floods with the sitter's colour (one material swap per chair group). **The chair never refuses**, in any room state. Until the seated learner variant lands, the standing learner is placed on the chair's footprint facing into the room; the flood is the ready signal either way. Rejected: a Ready button, hold-to-ready.
- **The ready-up fires**, evaluated by the host on every state change, when: the room holds three players (N under `--min-players`), a booking exists, every player holds a named role or Random, and every player is seated.
- **The notice board** (the kit's `FutureDisplay`) shows one line of signage, always on, readable from the chairs. It is **not a station**. The first true line, by priority:
  - fewer than three: "Waiting for 2." / "Waiting for 1."
  - three, no booking: "No booking."
  - booking, roles missing: "Roles: 2 of 3." (players holding a named role or Random)
  - roles held, not all seated: "Seated: 1 of 3."
  - everything held: the countdown, "Monster truck. 3.", "Monster truck. 2.", "Monster truck. 1."
  Under `--min-players=N` every count is out of N. (Only one refusal can stand alone at three: with fewer than three there is never a booking, and without a booking there are no roles.)
- **The examiner's one line.** When the ready-up first fires, the examiner **calls the booking**: **"Monster truck."**, TTS, voice only, no body, heard by all. ("Monster truck, when you're ready." is acceptable if the terse form reads as a glitch in TTS.) If the countdown is cancelled and re-armed, he says it again identically. It is the only examiner line in the waiting room this slice; signage never speaks.
- **The countdown**: **three seconds** from firing, counted on the notice board; the examiner line at the start, the transition at the end. **Cancelled silently** by any of: a player stands, a pick changes, a hold is dropped, a player leaves. The notice board returns to its state line; nothing is announced.
- **The Random deal**: at the **end** of the countdown, the instant the fade starts, the host deals the remaining named roles to the Random holders, shuffled, one each; named plus dealt always sums to three. Nothing is dealt during the count, so a cancel reverts nothing. The board's strips do **not** update; the reveal is in the test area.
- **The transition**: **fade to black over about one second**; the entrance door's placeholder sound reused as the Test Area door; the music loop fades on its player over the same second. **No door animation**; the leaf would open onto a solid wall.

### 8. The test area (ticket 09)

- The **car park** outside the test centre: a flat asphalt plane with painted bays as boxes, daylight, nothing else. No kit request.
- Three learners appear in a row in three bays, **1.5 m apart**, facing the same way, with the same first-person controller (solid, no shove, 3 m/s, no jump). Fade in on arrival.
- Shown: name tags with the role line over the other two (now the dealt role for former Random holders); **your own role as one line of small text in a corner of your screen**, named and dealt alike, because first person never shows you your own name tag; **one sign reading MONSTER TRUCK**, so the booking is visibly carried across too.
- Voice runs unchanged, positional from the body. No music, no examiner, no truck, nothing to do. It is Slice 1's starting scene and commits Slice 1 to exactly two elements: the corner role line and the booked-vehicle sign.
- **Back**: the Escape overlay in the test area gains **"Back to the waiting room"** for the **host only**. Everyone returns together to the same room, each arriving through the entrance one after another with the arrival theatre, with **all state cleared**: no picks, no holds, nobody seated, notice board "No booking.", desk header "3 of 3", music loop restarted.
- **Shared fate on the other exit**: if any player drops or quits in the test area, the remaining players are returned to the waiting room the same way (a room of two, nothing booked). If the host drops, guests land in fresh rooms of their own per section 4. No host migration, no late join.

### 9. The Escape overlay (tickets 10, 09)

- Escape, with no station screen open, opens a **small panel over the world** in the waiting room or the test area: **mic mode** (open mic / push-to-talk), **mute microphone**, **quit to desktop**; plus **Back to the waiting room** for the host in the test area only. Escape or a close control dismisses it. The mouse is released while it is open.
- It is **not a pause** (the room and voice run on behind it), **not a station** (no kit prop), **not a menu** (nothing is in front of the room). It is the room's only 2D panel and its only way to quit. Rejected: a settings station on the spare notice board; keyboard-only toggles with no UI.

### 10. Voice (tickets 10, 03)

Voice is **in**, **ring-fenced**: a self-contained item nothing else depends on, cut as the **last ticket** of the slice, time-boxed to **one weekend** of build. If two real Steam accounts cannot hear each other by the end of the box, the ticket closes won't-fix and Discord carries the demo; no re-litigation.

- **Capture**: `startVoiceRecording` / `getAvailableVoice` / `getVoice` with an **8 KiB** buffer (not the tutorial's 1 KiB), polled per frame while recording; `setInGameVoiceSpeaking` on start and stop; keep polling after stopping until `VOICE_RESULT_NOT_RECORDING`. In open mic mode recording runs whenever unmuted; in push-to-talk it runs while the key is held.
- **Transport**: a plain **unreliable** RPC (`any_peer`, `call_remote`) on its own channel. Never `UNRELIABLE_ORDERED`, which `SteamMultiplayerPeer` silently sends reliable.
- **Playback**: `decompressVoice(bytes, 48000)` → 16-bit samples → frames pushed to an `AudioStreamGeneratorPlayback`, clamped to `get_frames_available()`, on **one `AudioStreamPlayer3D` per remote learner** with an `AudioStreamGenerator` at `mix_rate` 48000 and **`buffer_length` about 0.1 s** (the default 0.5 s is half a second of latency).
- **Positional, gently**: from the learner's body; attenuation tuned so the far corner of the 12 × 10 m room is noticeably quieter but always clearly intelligible. Direction and a little distance, never distance gating. Same attenuation in the test area; placement during the test is Slice 1's.
- **Mic mode is a setting**: default **open mic**; push-to-talk opt-in. **Self-mute**: one toggle. Both persisted in a `ConfigFile` under `user://`.
- **Speaking indicator** on the name tag while that player's voice is being received.
- **Every transport**: on under `--transport=enet` too; three instances on one machine share one mic and you hear yourself back; that echo is the smoke test; push-to-talk or mute is how you stop it.
- **Deferred**: per-player mute, volume sliders, noise gate, mic device selection (the Steam client owns the mic).

### 11. Testing alone: the dev transport and `--min-players` (ticket 05, amended by 07 and 09)

- **Dev transport**: `ENetMultiplayerPeer` on localhost behind the user arg `--transport=enet` (after `--`). Absent or `--transport=steam` is the shipping path; no other value. **Bind-or-join on a fixed port**: every instance runs identical args, tries to listen on the port, and connects to it if taken; first window hosts, the others join and arrive through the entrance. No `--host` flag, no per-instance config, no desk involvement. **Steam is still required**; all three instances init against 480 with one account.
- **Identity under the dev transport**: Steam name and avatar as normal, with the peer id appended for peers other than the host: "Emil", "Emil (2)", "Emil (3)". The suffix exists only under `--transport=enet`. Palettes by peer order.
- **The reception desk under the dev transport**: the real friends list with avatars, **all verbs disabled**, footer **"Dev transport."** The seam is visible in exactly one place and reads as a seam, not a mode.
- **`--min-players=N`**: the count the waiting room waits for **everywhere it waits for three**: the booking forms at N matching picks, "Roles: x of N." and "Seated: x of N.", the ready-up fires at N. The desk's capacity and "x of 3" header are unchanged. Independent of `--transport`, so Emil and one friend can reach the test area over Steam. Named so it reads as "the room may launch short", never as a mode.
- **Neither flag has a UI, a menu, or a mention in release notes.** Bot or fake learners are ruled out (ADR-0001, *Scaling*).
- **Three learners in under a minute** (once per clone, the config is gitignored): Godot *Debug → Customize Run Instances…*, enable multiple instances, count 3, main run args `-- --transport=enet`, optional `--position` per row; press Play. Or run the exe three times with `-- --transport=enet`.

### 12. The release package (ticket 01)

- Stock Godot 4.7 Windows x86_64 export preset, standard templates. The GDExtension's `.gdextension` file makes the export include `libgodotsteam.windows.template_release.x86_64.dll` and copy `steam_api64.dll` beside the exe.
- **GitHub release zip = exe + pck + those two DLLs.** Never `steam_appid.txt`. Friends see each other "playing Spacewar" until the game owns an AppID; that is a later task.
- Launched outside Steam (double-clicked from the zip) init, friends, avatars, lobbies, P2P, and voice all work with the Steam client running; only the overlay is unreliable, which the in-world desk makes irrelevant.

### 13. All copy in one place

Signage (drawn, never spoken):

| Where | Line |
| --- | --- |
| Steam-not-running state | "Steam is not running." (+ Valve's message) |
| Desk header | "Reception", "1 of 3" / "2 of 3" / "3 of 3", "The waiting room is full." |
| Desk states | "In the waiting room", "At the test centre", "Online. Not at the test centre.", "You have company." |
| Desk verbs | "Invite", "Join", "Invited.", "Accept", "Ignore", "Leave" |
| Desk invite row | "<Name> is asking for you" |
| Desk failures | "The waiting room is full.", "Nobody is at the test centre.", "The room did not answer." |
| Desk footer | "Dev transport." (dev transport), "Copy room ID" / "Join by ID" (debug builds) |
| Station prompts | "E  Reception", "E  <Name> is asking for you", "E  Booking", "E  Sit" |
| Board rows | "MONSTER TRUCK", "CAR", "MOPED", "TRUCK + TRAILER", "HELICOPTER", "BOOKED" |
| Locked rows | "Manual. Indicators on the passenger side.", "Seats one. Party of three.", "One of you rides on the trailer.", "Three controls. No manual." |
| Occupant strips | "No booking." |
| Name tag role line | "Driver", "Spotter", "Navigator", "Random" |
| Notice board | "Waiting for 2.", "Waiting for 1.", "No booking.", "Roles: 2 of 3.", "Seated: 1 of 3.", "Monster truck. 3." / "2." / "1." |
| Escape overlay | "Open mic" / "Push to talk", "Mute microphone", "Quit to desktop", "Back to the waiting room" |
| Test area | "MONSTER TRUCK" (sign); corner role line "Driver" / "Spotter" / "Navigator" |

Examiner (spoken, TTS, never drawn): **"Monster truck."**

Sounds, all placeholders: desk ring (beep, about two seconds, at the desk), entrance door (at the entrance; reused for the Test Area door at launch), booking (short, from the board).

## Testing Decisions

**What makes a good test here**: it drives the room through the commands a player's click would send and asserts what the room would show or do, as literals: the notice board line, whether a booking exists, whose name is on a strip, whether the countdown is running, which roles were dealt. It never reaches into a node tree, a `MultiplayerAPI`, or Steam, never asserts call counts, and never recomputes the expected value the way the code does. A test that breaks when a view is redrawn differently is a bad test; one that breaks when the booking rule changes is the point.

**The one seam: the host-owned room state.** The record and rules in section 0 are a plain script with no scene or network dependency. Its inputs are commands (arrive with an identity; leave; pick, drop, switch; take, drop, swap a role; sit, stand; tick the countdown) plus the configuration the room waits for (three, or N); its outputs are the replicated state and the events the views react to (booking formed and dissolved, countdown started and cancelled, launched with the deal). This is the only module with automated tests in this slice. What it must cover, at least:

- arrival order deals palettes 01/02/03 and a departure never reshuffles the survivors;
- a booking forms only on the third matching pick, dissolves on any drop, switch, or departure, and an arrival never dissolves it;
- the role column is dead without a booking, every hold releases on dissolution, a taken role rejects a second taker, same-frame ties resolve in receive order, Random accepts any number of holders;
- the notice board line follows the stated priority, counts out of the configured N, and the countdown starts only when every condition holds;
- any stand, pick change, drop of a hold, or departure cancels the countdown, and nothing was dealt;
- the deal at the end of the count gives every Random holder a distinct remaining named role and leaves named holders untouched;
- return from the test area clears everything and reads "No booking.";
- a departure frees the leaver's pick and hold.

**Runner and prior art**: headless `SceneTree` scripts run with `godot --headless --path . --script <test>`, in the shape of `assets/slice_0/verify_assets.gd` (the repo's only existing test), asserting and printing `PASS`. No test framework is added for this slice; if the count of scripts makes a runner worth it, that is a later call.

**Everything else is checked by hand**, deliberately, because it either needs Steam, a GPU, or three people:

- The replication layer, controller, stations, docks, arrival theatre, board and strip rendering, chairs, the transition, and the test area: the **three-instances-in-under-a-minute** protocol (section 11), which is the "first build checks the feel" every grilling ticket deferred to.
- The invite round-trip (`inviteUserToLobby` → `lobby_invite`) and at-the-test-centre detection through rich presence: the one thing the dev transport cannot exercise; checked **when a friend (Emil's brother) is online**, and on Emil's two computers. A note, not a blocker.
- Voice: the **self-echo under three local instances** is the smoke test for capture and playback; two real Steam accounts hearing each other within the weekend box is the acceptance.
- The release zip: unzip on a second machine with Steam running, double-click, arrive in a room.

## Out of Scope

- The monster truck, its physics, controls, and cameras; the examiner as a presence in the waiting room (a body, a door, an entry line, a seat) beyond the one call; test items, scoring, the timer, the test sheet's content; the license card and results. Slices 1 and 2.
- Returning to the waiting room after a **finished test**, and whether the room doubles as the results screen. Slice 2.
- Learner customisation by the player, art direction, the game's name.
- Gamepad support, any platform but Windows. Slice 1 decides input devices with the truck's controls.
- Buying a Steamworks AppID and everything it unlocks (invites that launch the game, a Join Game button, the game showing as itself).
- Host migration, late join after launch, reconnect.
- Lobby codes or any human-typable room id in release; the raw-id paste stays a debug-build strip.
- Voice during the test, per-player mute, volume sliders, noise gate, mic selection.
- Bots, fake learners, a solo or two-player mode of any kind. The dev seams are not modes.
- Shoving (on the build-time list as a feel item, not built by this spec).

## Further Notes

### Build-time calls (open by the tickets, listed here so nobody decides them silently)

- **Departure theatre in the room.** The mechanism is decided (the leaver's pick and hold are freed, the booking dissolves, a guest lands in a fresh room; the arrival theatre runs in reverse for a deliberate Leave). Open: what the room shows when a friend **drops** mid-room; today the learner vanishes with no door and no sound. Decide in the first build.
- **Shoving.** Learners are solid and do not push each other. If standing still in front of a friend is not funny enough once three people have stood at the board, add it (the pushed client moves itself on overlap).
- **The Steam-not-running state's copy and look.** The gate and status codes are decided; the two lines in section 1 are the spec's minimal call. Refine at build if the black window reads wrong.
- **Which of the six kit colours is the flood colour.** The spec says the palette's shirt colour; change it if a chip or strip reads badly against the kit's screens.
- **Exact palettes 01/02/03.** Three of the kit's sample palettes (`preview.png` shows three); pick for contrast against each other and the ochre truck row.
- **The Random deal theatre.** Ticket 08 leaned toward showing the deal on the board; ticket 09 ruled the reveal into the test area and the strips unchanged. That is the decision; if the test-area reveal feels flat with three people, the board's beat is the one alternative already considered.
- **What the test area grows into.** Slice 1's starting scene; the spec commits Slice 1 to the corner role line and the booked-vehicle sign, nothing else.

### Kit requests to Astra (two, in one place)

1. A **closed door leaf in the entrance opening**, matching the Test Area door, so the room is closed and first-person players do not look out at the void. Opening it is the arrival theatre's job (section 4). Until it lands, the door sound carries arrivals alone.
2. A **seated variant of the learner** (`learner_seated`, same six palettes), since the rigid model cannot bend. Until it lands, the standing learner is placed on the chair's footprint (section 7).

Not requested: an opening in the wall behind the Test Area door (no door animation this slice), bays or a sign for the car park (boxes), a desk bell (beep), examiner geometry.

### Order of build (a suggestion for `/to-tickets`, not a decision)

The tickets resolved in a dependency order that also reads as a build order: Steam init and the transport picker; the room, learner, camera, and station grammar with the room-state seam and its tests; the reception desk, rooms, and arrival; the booking board; the role pickup; chairs, notice board, countdown, and transition; the test area and Back; the release export; voice last and time-boxed. Every ticket after the first two is demoable with three local instances.

### Pointers

- Research findings with citations live on branches `research/godotsteam-on-godot-4-7`, `research/in-game-invites-on-app-480`, and `research/steam-voice-through-godotsteam` (files under `docs/research/`); the tickets' Answers carry the parts this spec relies on.
- Corrections that shaped this spec are in `docs/corrections.md` (first-person camera, Leave for guests, mic mode as a setting, mild positional falloff, voice on under the dev transport, kit over greybox, decide-in-conversation over prototype). Any steer during the build appends there.
- Glossary terms introduced by this map are all in `CONTEXT.md` under *The waiting room*; the spec uses them and avoids their listed synonyms (in particular: room, not lobby; test area, not stub; hold, not lock or claim; pick, not vote).

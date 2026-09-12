# 04. Waiting room walkthrough: learner, camera, stations

Type: grilling
Status: resolved
Blocked by: —
Map: ../map.md

> Retyped from `prototype` to `grilling` on 2026-09-12 (see `docs/corrections.md`): the five questions below were decided in conversation, not by building. The "build a walkable version" deliverable is superseded; the first build cut from the spec checks the feel.

## Question

Astra's kit (`assets/waiting_room/waiting_room.tscn`, `assets/slice_0/player/learner.tscn`, see the map's Notes) is a room and a body with no controller, collisions, or interaction. What does it take to walk around in it, and does the room work for three learners?

Build a walkable version and react to it together. It should answer:

1. **Movement.** A `CharacterBody3D` around the learner model: walk speed, whether it can jump, whether learners collide with each other (three people fighting for one leaflet is the joke; bumping should be allowed). The model's forward is +Z; feet at origin; about 2 m tall. Collision for the room's architecture and furniture (the kit ships none: trimesh from the GLB, or hand-placed boxes).
2. **Camera.** Third-person over the shoulder, fixed isometric like the kit's overview render, or something between. Judge it by whether three learners crowding the booking board reads at a glance and looks funny.
3. **Telling learners apart.** The Steam name above the head. Whether the kit's six colours are dealt per player (one palette per seat number 01/02/03, matching the chairs) or everyone is the default blue. Steam avatar: on the body, on the name tag, or nowhere.
4. **Interaction grammar.** How you use a station: walk into a zone and a prompt appears, press one key. Same rule for the reception desk, the booking board, the role pickup, and the chairs. The kit's `AttachmentPoints` markers are the suggested zones.
5. **Room fit.** With three learners in it, is the room the right size, are the stations far enough apart to force walking, is the entrance in the right place for arrivals. What, if anything, to ask Astra to change.

Deliverable: a walkable scene on a branch, linked, and an answer recording the controller, camera, identity, and interaction grammar choices, plus any requests for the kit. Terms that stick go in `CONTEXT.md`.

## Comments

- 2026-09-12: Earlier claim was stale (no branch, no comments, no scene); the chat that held it had grilled two rounds and drafted an answer that was never confirmed. Re-claimed, the draft was re-presented with what the updated kit changed (Astra's role column on the booking board), and a third round settled the rest.

## Answer

Decided in conversation on 2026-09-12 (three rounds). Facts about the kit used below come from `assets/waiting_room/source/build_waiting_room.py` and `waiting_room.tscn`; Godot coordinates, Y up, entrance at Z=+5.

### 1. Movement

- `CharacterBody3D` around `learner.tscn`, feet at origin, capsule roughly 0.6 m wide and 2 m tall. The model's forward is +Z; the controller faces the body the way the camera looks.
- Walk at about 3 m/s. No sprint, no jump (rigid meshes, no rig: a jump would rise stiff as a bollard). Entrance to booking board is about 8 m, under three seconds; reception to board about 6 m.
- Learners are **solid to each other and do not shove**. The other learner's synced collider blocks you; nobody is pushed. Being planted in front of the board while a friend shouts "move" is the joke. Shoving is in the map's Not yet specified as a feel item the first build may add.
- Room collision: trimesh from the GLB's `Architecture` group for walls and floor; hand-placed boxes for the counter, cupboards, chairs, plant, bin (the kit ships no collision). The entrance is a way in only.

### 2. Camera

- **First person, one camera per player**, at the learner's eye height (about 1.75 m). Mouse look; WASD moves camera-relative. Mouse captured in the room, released when a station screen is open or the Escape overlay is up.
- The body's yaw follows the camera so the other two see where you face; head pitch is not shown. Your own head is hidden from your own camera; the body stays visible when you look down.
- Consequences: you never see your own learner, so your palette and name tag exist for the other two. Crowding at the board is seen from inside the crowd.
- Rejected: a fixed room camera (the kit's overview render) and third-person orbit. Emil wants to walk around and investigate the room.

### 3. Telling learners apart

- Steam name as a **name tag**: billboard above the head, fixed screen size, no distance fade, shown over the other two only (yours is not drawn).
- The kit's six-colour palettes are **dealt by arrival order**: host is 01, next 02, next 03, matching the numbered chairs. Three fixed palettes, one per seat number; not a customization system. Under the dev transport the same rule applies by peer order.
- Steam avatar **nowhere in the 3D room**. It appears on the reception desk's friends list and wherever the ready-up ticket puts it.

### 4. Interaction grammar

One rule for every **station**:

- Walk into the station's zone (a volume around its `AttachmentPoints` approach marker), a **prompt** appears above the station in the world, press **E**. The station's **station screen** opens on its own physical surface: the camera glides to a dock pose framing that surface, the mouse is released and becomes a cursor on it, your learner stands still, facing the station, for as long as it is open. **Escape** closes it and returns the camera to your head. The other two see you stood at the station.
- Stations and their screens: the **reception desk** (the friends terminal's 0.74 × 0.46 m `FriendsScreenSurface`, a 740 × 460 SubViewport); the **booking board** (the whole 3.5 m board, docked from about 3 m back, the view in `preview_booking.png`; vehicle rows and role buttons are both picked with the cursor); the **chairs** (same key to sit and stand, no meaning attached until the ready-up ticket gives them one).
- The **role pickup is the right column of the booking board**, not a separate place. One walk-up, one dock covers booking and roles. Booking board and role pickup stay separate terms and tickets.
- Fallback: any station may drop to a 2D overlay without changing the grammar, if the in-world screen fights the build.
- **Keyboard and mouse only** for the waiting room in this slice. PC only. Gamepad support is a Slice 1 question, where the truck's controls decide it.

### 5. Room fit

- Kit used as is: 12 × 10 m, stations on three sides (reception back-left, board back-right, chairs on the left wall, entrance front). Distances are enough to make the players walk; nothing is moved.
- Joiners appear on the `Entrance` marker facing into the room (-Z).
- **One request to Astra:** a closed door leaf in the entrance opening, matching the Test Area door, so the room is closed and first-person players do not look out at the void. Opening it is later work. No other kit changes.

### Glossary

Added to `CONTEXT.md`: **Station**, **Station screen**, **Name tag**; *Role pickup* reworded to the role column of the booking board; a pointer under *Test item*, whose avoid-list already had "station" in the test sense.

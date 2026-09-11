# Waiting-room visual kit

Standalone placeholder environment for `.scratch/waiting-room/map.md`, matching the simple beveled player model. Open `preview.tscn` in Godot and run the current scene (F6) for a static entrance view with lights. `waiting_room.tscn` contains only the model and attachment markers, ready to instance later. The project's main scene is unchanged.

## Included

- Complete 12 × 10 metre room, 3.6 metre ceiling, tiled floor, painted wainscoting, windows, and a 2.2 metre entrance opening.
- Reception counter with paperwork, bell, keyboard, and a separate friends-terminal screen.
- Three individually grouped waiting chairs, a plant, waste bin, clock, cupboards, and light-fixture models.
- Five-slot booking board: monster truck plus car, moped, truck + trailer, and helicopter with modeled padlocks. Labels and locks are separate meshes; slots are visual placeholders, not selectable controls. Joke copy is left for the eventual UI/spec rather than invented here.
- Adjacent role column on the same board, with separate Driver, Spotter, Navigator, and Random button meshes. Each named role has a blank occupant strip and a neutral status lamp for future availability/ownership display. `preview_booking.png` shows the panel close up.
- A closed test-area door and a spare notice board, leaving room for future displays without deciding examiner or ready-up behavior.
- Editable `source/waiting_room.blend`, portable `waiting_room.glb`, and a deterministic Blender generator. The source directory has `.gdignore`, so Godot does not require Blender to load the model.

The overview image is a cutaway: front/right wall, ceiling, entrance frame, right notice board, and ceiling fixtures are hidden for readability. The exported model contains all of them. The entrance render shows the room from approximately standing eye level. Blender renders and Godot preview lighting differ.

## Preparing future interaction

No scripts, UI controls, Steam APIs, multiplayer, voice, character controller, collisions, navigation, or ready-up logic are included. This is a visual kit, not a playable lobby. Signs and the terminal title are static meshes. No players are shown as online and no invite action is represented as working.

The GLB preserves named groups: `Architecture`, `Reception`, `FriendsTerminal`, `BookingBoard`, `WaitingChairs`, `Entrance`, `TestDoor`, and `FutureDisplay`. The ceiling and each wall are independently grouped. The door leaf is separate geometry, but the rear wall behind it is solid; a later opening/transition needs integration work.

`Reception/FriendsTerminal/FriendsScreenSurface` is a flat 0.74 × 0.46 metre screen (aspect ratio about 1.609). Its material is `Screen`. Hide `FriendsScreenPlaceholder` when replacing its title and caption with a real UI. A future SubViewport can use a 740 × 460 canvas, displayed on an added quad at the `AttachmentPoints/FriendsScreen` marker. The marker's local +Z points out toward the visitor; it sits just in front of the existing placeholder lettering. Runtime pointer mapping and input remain future work.

Each booking row is grouped under `BookingBoard` as `MonsterTruckSlot`, `CarSlot`, `MopedSlot`, `TruckTrailerSlot`, or `HelicopterSlot`. Each has a named `DisplaySurface` mesh, 1.93 × 0.34 metres. Text and locks can be hidden or replaced independently. Nothing currently reserves a role or stores a vehicle choice.

`BookingBoard/RoleSelection` contains `DriverChoice`, `SpotterChoice`, `NavigatorChoice`, and `RandomChoice`. Each contains a separately named button and label. The three named roles also contain an `OccupantSurface` (0.65 × 0.105 metres) and `StatusLamp`. Blank strips avoid implying anyone has joined. Future code can display Steam identity, indicate a taken role, and handle Random as a fallback choice rather than a fourth role. None of that behavior is implemented in the model.

The scene has `DriverButton`, `SpotterButton`, `NavigatorButton`, and `RandomButton` markers on the front of their respective buttons, plus `RoleSelectionApproach`. All button markers face +Z toward the visitor. Collision/raycast targets and state synchronization must be added by the interaction implementation.

`waiting_room.tscn` also exposes markers for the entrance, reception approach, booking-board approach, and future display. These are suggested attachment positions, not active spawn or interaction points.

## Coordinates and editing

Godot: Y up, room centered on X/Z, floor at Y=0. Entrance is at Z=+5; reception and booking board are toward Z=-5. Blender uses Z up and entrance Y=-5. Scale is one unit per metre. Floor tile tops are at approximately 0.014 metres.

All materials are local, flat colors; no external textures or fonts are needed at runtime. Text is converted to geometry. Windows are opaque stylized panels, not transparent views to an exterior. Materials and small prop meshes are kept separately editable; this first pass is not draw-call optimized.

Regenerate from the repo root:

```text
blender --background --python assets/waiting_room/source/build_waiting_room.py
```

This overwrites the Blender source, GLB, and three PNG previews. Preserve manual edits before regenerating. Edit the `.blend` directly if continuing by hand. The Godot preview uses its own lights; Blender preview lights and cameras are excluded from GLB export.

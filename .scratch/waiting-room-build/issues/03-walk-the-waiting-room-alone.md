# 03: Walk the waiting room alone

**Spec:** `.scratch/waiting-room/spec.md`, section 2. Read `docs/design.md` (*Polish before funny*: the kit is used as is, no greyboxing).

**What to build:** A single player boots into the room and walks around it in first person: mouse look, WASD, solid walls and furniture, standing at the entrance facing into the room on the first frame.

The learner controller is a `CharacterBody3D` around the kit's learner, capsule about 0.6 m wide and 2 m tall with feet at origin, the model's +Z faced the way the camera looks. 3 m/s, no sprint, no jump. Collision: a trimesh from the GLB's `Architecture` group for walls and floor; hand-placed boxes for the counter, cupboards, chairs, plant, and bin. The entrance opening is a way in only; nothing lets you walk out into the void.

Camera: first person at about 1.75 m, mouse look, WASD camera-relative, body yaw follows the camera, head pitch not shown. Your own head is hidden from your own camera; your body stays visible when you look down. Mouse is captured in the room; Escape releases it for now (the Escape overlay is ticket 12 and replaces this).

Arrival position: the kit's `Entrance` marker, facing −Z into the room.

**Blocked by:** 01 (the game boots into the waiting room).

**Status:** ready-for-agent

- [ ] On boot the player stands on the `Entrance` marker facing into the room, at eye height about 1.75 m.
- [ ] WASD moves at 3 m/s relative to where the camera looks; there is no sprint and no jump.
- [ ] Mouse look turns the camera; the learner's body turns with it; pitch is not applied to the body.
- [ ] Walls, floor, counter, cupboards, chairs, plant, and bin block movement; the player cannot leave the room through the entrance opening or any wall.
- [ ] Looking straight down shows your own body but never your own head.
- [ ] The mouse is captured in the room and released on Escape.
- [ ] The kit's scene and materials are unchanged; collision and the controller are added around it, not by greyboxing.

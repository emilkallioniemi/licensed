# Stadium and competition-truck revision

Date: 2026-10-08

This pass replaces the active quarry geometry with an original Blender stadium. The archived quarry is not instantiated. Editable sources are `assets/stadium/source/stadium.blend`, `assets/stadium/source/crush_car.blend`, and `assets/monster_truck/source/truck.blend`.

Real Godot rehearsal captures: `driving.png`, `overview.png`, `ring-run.png`, `truck-front.png`, `book-contents.png`, `book-entry.png` and `book-turn.png`. Capture script: `tests/capture_stadium.gd -- --rehearsal`. Blender studio previews are in `assets/monster_truck/preview_*.png`.

Checks cover authored collision and all eight live-lane layouts; three human-sized boarding positions; secure seats and roof-rider recovery; controls and timer; private book paging and role changes; car-crush replication and reset; actual slope pitch; ring clearance; fast jump completion and slow-jump failure; and full three-peer launch/traversal/finish/retry/fatal fall/departure. Logs accompany the captures. Scripted peers and input fixtures provide technical evidence, not three-human fun or Steam acceptance.

Crushable cars deliberately use two physical/presentation states, not soft-body simulation. The spectator crowd uses batched modeled geometry with subtle motion. Flames and sparks are cosmetic show effects, explicitly described that way in the book. Deep stunt pits remain real lethal falls; ordinary solid impacts permit reversal and supported rollovers permit recovery.

Final verification passed: stadium physical obstacle tests (including ring clearance, a successful fast jump and failed slow jump), all-layout support/fall tests, private book, solo rehearsal, boarding, recovery, truck presentation, driving and ordered course state. The complete three-peer network run exited 0 and checked replicated wreck crushing as well as full traversal, finish, retry, lethal fall and departure. Account/persona values in its log are redacted. Existing Godot shutdown resource warnings and sandbox user-log warnings remain visible.

The old open-bed ejection fixture was moved onto the new collidable roof: an enclosed cabin now correctly blocks its former upward ejection path. The test still verifies a physical external-rider ejection and snapshot impulse, subsequent harmless landing, secured occupants through impacts/rollover and immutable aftermath.

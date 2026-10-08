# Stadium and competition-truck revision

Date: 2026-10-08

This pass replaces the active quarry geometry with an original Blender stadium. The archived quarry is not instantiated. Editable sources are `assets/stadium/source/stadium.blend`, `assets/stadium/source/crush_car.blend`, and `assets/monster_truck/source/truck.blend`.

Real Godot rehearsal captures: `driving.png`, `overview.png`, `ring-run.png`, `truck-front.png`, `book-contents.png`, `book-entry.png` and `book-turn.png`. Capture script: `tests/capture_stadium.gd -- --rehearsal`. Blender studio previews are in `assets/monster_truck/preview_*.png`.

Checks cover authored collision and all eight live-lane layouts; three human-sized boarding positions; secure seats and roof-rider recovery; controls and timer; private book paging and role changes; car-crush replication and reset; actual slope pitch; ring clearance; fast jump completion and slow-jump failure; and full three-peer launch/traversal/finish/retry/fatal fall/departure. Logs accompany the captures. Scripted peers and input fixtures provide technical evidence, not three-human fun or Steam acceptance.

Crushable cars deliberately use two physical/presentation states, not soft-body simulation. The spectator crowd uses batched modeled geometry with subtle motion. Flames and sparks are cosmetic show effects, explicitly described that way in the book. Deep stunt pits remain real lethal falls; ordinary solid impacts permit reversal and supported rollovers permit recovery.

Final verification passed: stadium physical obstacle tests (including ring clearance, a successful fast jump and failed slow jump), all-layout support/fall tests, private book, solo rehearsal, boarding, recovery, truck presentation, driving and ordered course state. The complete three-peer network run exited 0 and checked replicated wreck crushing as well as full traversal, finish, retry, lethal fall and departure. Account/persona values in its log are redacted. Existing Godot shutdown resource warnings and sandbox user-log warnings remain visible.

The old open-bed ejection fixture was moved onto the new collidable roof: an enclosed cabin now correctly blocks its former upward ejection path. The test still verifies a physical external-rider ejection and snapshot impulse, subsequent harmless landing, secured occupants through impacts/rollover and immutable aftermath.

## Supporting-art revision

The new `spectator-detail.png`, `wreck-detail.png`, `wreck-folded-detail.png` and `wreck-variant-1.png` / `wreck-variant-2.png` are real Godot captures made with `tests/capture_stadium_detail.gd -- --rehearsal`, under the production stadium environment. They show the 2,537 modeled fans and all three salvage designs. The folded capture uses the actual attempt crush bitmask and presentation path. Visual inspection caught and corrected the wrecks' previous level placement on sloping dirt and a double-sided paint normal issue.

`supporting-art-tests.log` and `supporting-art-survival-tests.log` both report zero failures. The first covers actual driving over the fitted wrecks, authored damage model selection, guest snapshot reconstruction, reset, ring traversal and fast/slow jump outcomes. The second exercises all eight route layouts, support, recoverable walls and fatal falls. This revision does not claim another three-peer network run; snapshot and authority checks cover the changed presentation path. Existing exit resource and sandbox log warnings persist.

The crowd is exported in 20 material batches, with separate static seat batches, individual motion metadata and imported Godot LODs. The source crowd contains about 2.58 million triangles; the stadium GLB is approximately 87 MiB. Its first Godot import took a few minutes on this machine. Captures confirm rendering, not a frame-time benchmark or minimum-hardware guarantee. Wreck parts are also joined by material for export, while Blender sources retain separately editable parts. Crush damage remains two authored states.

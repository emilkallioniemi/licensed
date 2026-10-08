# Modeled quarry and private field book — 2026-10-08

Real Godot captures from the development rehearsal, using imported original Blender models:

- `driving.png`: truck camera at the depot approach, irregular sandstone walls and supported bridges.
- `overview.png`: assembled quarry, floodwater, pump works, crane and dispatch.
- `pump-works.png`: second crossing from its approach.
- `book-contents.png`, `book-entry.png`, `book-turn.png`: navigator-only 3D manual, readable page text and physical turning leaf.

`book-test.log` checks manual paging, all eight layout/direction combinations, private role visibility, E consumption without unseating, bounds and retry during animation. `survival-test.log` checks real tyre support and broken spans for all eight layouts, reversing from a wall, fatal gravity and continued learner falling. `network-test.log` records the existing three-peer localhost traversal test. These are technical checks and visual evidence; they do not establish three-human fun or Steam connectivity.

Editable `.blend` sources and the reproducible generator are in `assets/survival_map/source/`; the asset README documents the integration. The road's core three-crossing layout remains the gameplay revision from the preceding change. This pass replaces its presentation and adds physical scene collision, rounded deck corners and the book interaction.

Final checks passed: navigation book (0 failures), survival physics including driving over the finish paint (0 failures), solo rehearsal (0 failures), and the complete three-peer network traversal / finish / retry / fatal fall / departure (exit 0). The network fall fixture now uses the actual first ravine; its former outside-apron coordinate is part of the new solid scenery. Network log account/persona values are redacted. Existing Godot shutdown resource warnings and sandbox user-log warnings remain visible in the logs; they are not test assertion failures.

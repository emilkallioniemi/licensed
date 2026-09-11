# Slice 0 standalone assets

Initial placeholder assets only. No existing scene, menu, project setting, or gameplay script references these files. This is an exploratory style, not a final art-direction or customization-system decision.

## Learner character

Open `player/learner.tscn` in Godot 4. The root exposes six colors in the Inspector: shirt, trousers, skin, hair, shoes, and accent (cuffs, hem, learner badge). Each instance has its own material overrides. Instantiate the scene once per player, then set those properties from your eventual player appearance data. Synchronization and persistence belong to the future integration.

```gdscript
var learner = preload("res://assets/slice_0/player/learner.tscn").instantiate()
learner.shirt_color = Color("dd795a")
learner.accent_color = Color("ffd477")
add_child(learner)
```

`player/learner.glb` is the portable model; `player/source/learner.blend` is the editable Blender source. `player/preview.png` shows three sample palettes. The source folder is excluded from Godot import, so Blender is not required to use the GLB or scene.

Approximately 2 metres tall; feet at the origin; Godot Y up, forward +Z. Rotate the model 180 degrees around Y if your controller uses -Z as forward. Body, head, shoulders, elbows, hips, and knees have named transform pivots for simple rigid posing. These are separate rigid meshes, not a skinned skeleton; no animation clips, collision, controller, or accessories are included.

Rebuild with Blender:

```text
blender --background --python assets/slice_0/player/source/build_player.py
```

This regenerates the blend source, GLB, and palette preview; it overwrites manual source edits.

## Menu music: Please Take a Number

`music/please_take_a_number.wav`: original instrumental loop, 104 BPM, 32 bars in 4/4, about 73.846 seconds. Stereo 44.1 kHz / 16-bit PCM; peak -3 dBFS. A swung mallet motif, soft electric-keyboard chords, plucked synth bass, and restrained percussion suggest an oddly cheerful driving-test waiting room. The middle eight takes a small harmonic detour before returning to the opening motif.

The WAV contains exactly one loop with circular effect tails, without an intro or fade-out. The included Godot import settings enable Forward looping from frame 0 to frame 3256615, with uncompressed audio. If importing the WAV into another project without its import sidecar, restore those settings. Assign it to an AudioStreamPlayer when hooking up the menu. Apply fades on the player when entering/leaving the menu; do not bake a fade into the repeating asset.

`music/compose_menu.py` contains the full composition and synthesis, requires Python 3 and numpy, and regenerates the WAV. `music/composition.json` records the score events and audio measurements. All instruments are synthesized locally; no third-party recordings, samples, or vocals are used.

```text
python assets/slice_0/music/compose_menu.py
```

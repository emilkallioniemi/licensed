# Modeled truck

`source/build_truck.py` is the revisable Blender generator. `source/truck.blend` retains individual beveled parts, text meshes, material slots and mechanical parents. `truck.glb` is the portable Godot asset. The generator saves the editable model before building studio lights/cameras, renders front/rear/cabin previews, then batches export meshes by material within each mechanical parent. Preview-only ground, lights and cutaway visibility never enter the GLB. `source/.gdignore` keeps Godot independent of a local Blender installation.

```sh
/Volumes/Blender/Blender.app/Contents/MacOS/Blender --background --python assets/monster_truck/source/build_truck.py
python3 assets/monster_truck/source/generate_audio.py
```

The verified local Blender is 5.2.1 LTS; the executable path is the read-only mounted macOS distribution. The Python audio generator needs only the standard library. All geometry and sounds are generated locally; no external asset or premium generation service is required.

Authoring arguments use Godot metres: X right, Y up, negative Z forward. `xyz` converts to Blender Z-up, and glTF converts back. Following the user’s Hot Wheels-style proportion correction, the cab floor is 2.7 m and the cage reaches 4.65 m. The shell is 28% narrower and 20% shorter, with 45% larger wheels on exposed long suspension. The solid roof and all rear stairs/landings were removed for the 2026-09-14 revision. Low pickup sides, wide fenders, an intake scoop and exposed tyres/suspension make the compact competition truck readable from the shared overhead camera. The open rear deck exposes the balance learner's movement. Human-sized seats/controls move to x ±0.864, y 2.7, z ±1.04; wheel centres are x ±2.4, y 1.6, z ±2.1. Collision uses radius 1.6 and width 1.9 m for the tread/sidewall envelope. `RaisedBody` carries the scaled/lifted shell; seats and controls remain at human scale.

Structural collision is authored alongside the model in `scripts/monster_truck.gd`: deck, sides, seats, bonnet and cage tubes. No invisible roof or stair remains. Small fender lips, intake and hardware are cosmetic rather than snagging learner collision. Re-run climbing, open-bed footing, secure-seating and actual course tests when changing structure.

`TruckPresentation` consumes `Front/RearWheel`, `Front/RearNeedle`, four `Steer/Roll/Suspension` parents, two `Axle` parents, `ThrottlePedal`, `BrakePedal`, `ParkingLever`, and `DirectionLever`. These empty parents survive mesh batching. RearWheel/RearNeedle and manual-lever hooks are now empty compatibility transforms, with no obsolete control mesh. Seat groups include the highlightable cushions and balance platform. Physical lettering is depth tested and mounted on the pedals console; the steering dials are ordinary modeled surfaces. Highlight materials are copied per control so one player's binding hint does not change every instance's materials.

`TruckSound` uses the six original mono WAVs in `audio/`: idle/load engine layers, tyre scrub, cabin rattle, suspension and impact. The audio manifest records duration, frames, peak and RMS from generation. Runtime gains are deliberately restrained around voice; audio follows effective held input, speed, axle difference, vertical response and actual hull impact. Freshness filtering is shared with the driving mechanics. Stopping/starting an attempt resets all layers and cosmetic wheel rotation.

The distinct examiner body/reactions remain ticket 23; the current examiner uses the existing learner model in a temporary seated pose. The radio has a modeled powered-off provision only; ticket 24 adds shared controls/music. Ticket 08 replaces learner motion/poses and refreshes the Windows checkpoint package. This asset production does not establish human handling, fairness or Steam responsiveness: those remain checkpoint 06.

> Completed and superseded by the user’s smaller/higher body and oversized-wheel correction. See `art-verification.md` for the final dimensions and build. The contract below records the pre-art handoff.

# Astra handoff: revised monster-truck art

The user requested coding first, then Astra for 3D work. Continue in this checkout; preserve the uncommitted implementation. Read `docs/design.md` and the active amendment in `.scratch/monster-truck/spec.md`. This is the art/integration finish for ticket 29, followed by final ticket 32 packaging. Do not restart the specification or expand tickets 09–28.

## Required art change

Make the vehicle recognisably a monster truck: large tyres, raised suspension, a compact truck body, and clear accessible seats. Remove the entire rear boarding/switchback staircase and its landings. Its collisions have already been removed, but its visual triangles are batched into the current GLB and remain visible. The current safari-like model is explicitly temporary.

The shared elevated camera must clearly show the road, targets, occupants and weight shifting. Revise the roof/bodywork accordingly; do not let a large opaque roof hide the balance player's contribution. Make the balance position look like a place to shift weight, without a rear steering wheel. Keep three understandable highlighted player seats and the examiner's seat. Cuter player models are deferred; do not redesign them now.

Source: `assets/monster_truck/source/build_truck.py`, retained `truck.blend`/`truck.glb` and asset README. Keep editable source and the GLB aligned. No new generated art was produced in the coding pass. Course cones are simple runtime primitive placeholders and may remain so for this test.

## Integration contract

- Coordinates are truck-local, forward −Z. Seats remain `front` (steering) = (−1.2, 1.6, −1.3), `pedals` (speed) = (1.2, 1.6, −1.3), `rear` (balance) = (−1.2, 1.6, 1.3). These internal names preserve existing ownership/snapshot wiring.
- `MonsterTruck` owns collision in `scripts/monster_truck.gd`; adjust it alongside changed body proportions. Test climbing from tyres and the side between tyres. No invisible staircase collision.
- Current tyre pivots are at x ±2.75, y 1.1, z ±1.8, radius 1.1. Changing dimensions also requires suspension probes, hull/recovery clearance and course-fit verification.
- `TruckPresentation` consumes Front/Rear Wheel/Needle, four Steer/Roll/Suspension parents, Front/RearAxle, ThrottlePedal, BrakePedal, ParkingLever and DirectionLever. Preserve these transform hooks (legacy controls can remain hidden empty parents), or update consumers and tests together. FrontSeat/PedalsSeat/RearSeat mesh groups supply seat highlighting. RearConsole, ParkingLever and DirectionLever are hidden by code.
- The rear tyres no longer steer. Balance shifts the seated learner visibly and affects truck roll/pitch. Keep enough room for ±0.6 m sideways / ±0.5 m fore-aft learner motion.
- Seated sight uses a level-horizon frame at (0, 11, 10), aimed at (0, 1, −2.5). All three occupants use it. On foot, the camera follows the learner; Space climbs and E enters an aimed seat within 3.5 m. Adjust camera framing only with rendered verification.

## Verification and packaging

See `revision-verification.md` for current evidence and tuning, and `checkpoint-06/session.md` for the new human procedure. Re-run the relevant scene tests after changing art/collisions, especially the complete network test:

```sh
/Users/emka/Downloads/Godot.app/Contents/MacOS/Godot --path . --script res://tests/verify_launch_network.gd --windowed --resolution 800x600 --log-file /tmp/licensed-astra-check.log -- --revision --revision-capture
```

The fixture drives actual controls through turn → bumps → parking, including recovery, shared pass and retry. Local ENet fixture evidence does not establish three-human Steam feel. Inspect all three seated/result images and physically verify seat highlighting/entry against the revised geometry.

Then finish ticket 32 with the existing dual-platform builder in `release/build.py`; follow `release/README.md`, use a new output directory and current source manifest, and ship the updated `release/SESSION.md`. Use `--working-tree` only for clearly provisional local packages; final committed provenance uses `--commit`. Do not publish a release under this handoff. Do not mark human checkpoint 06 accepted. No final revised ZIP has been claimed before the art integration.

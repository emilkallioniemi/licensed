> Art integration update: the old roof/staircase GLB has now been replaced, then revised again to the user’s Hot Wheels-style proportions. See [art verification](art-verification.md) for final dimensions, tests and packages. The evidence below records the preceding coding phase.

# Revised gameplay verification — 2026-09-14

Coding phase for 29–31 is complete. Ticket 29 still needs Astra's truck model and integrated art verification; ticket 32's final exports follow that integration, as the user requested. No updated final playtest ZIP or human acceptance is claimed. Start with [Astra handoff](astra-handoff.md).

The changes are uncommitted on top of `118819f7425cf47221b344ae40b499812aa76b97`. Existing work/spec amendments were retained. No generated 3D asset was replaced in the coding phase. The old staircase remains in the batched visual GLB; its collision has been removed. It is a known art handoff item, not a finished appearance.

## Implemented

- Held Space climbs actual truck surfaces; aim the crosshair at a highlighted seat and press E. Exclusive host-owned seating, deliberate exit, shared elevated camera and secure occupants through impacts/rollovers.
- Front steering retained; W forward, S brake then continuous reverse, release to coast, automatic stop. No player-operated direction selector or parking brake.
- Truck-relative lateral and fore/aft balance replaces rear steering, with visible learner movement and real roll/pitch effects. Rear tyres stay straight.
- Stopped consensual swaps with expiry, refusal, movement/exit/departure cancellation, per-request consent identity and stale generation rejection.
- Ordered turn, bumps and parking; shared targets/instructions/timer/feedback, pass/rating, concession/timeout, unanimous retry and waiting-room return. Cone contacts count once per cone and permit passing.
- Guest or host held recovery rights a settled rollover or places an off-course/stranded group at a nearby safe pad. Progress retains completed items; recovery cannot complete an untraversed bump section. Each recovery adds one minor fault.

## Evidence

Use Godot 4.7.2. The production scene/network boundaries were retained. Tests terminate themselves; forced engine shutdown is not counted as a pass.

Passing standalone checks: `verify_attempt_state.gd`, `verify_driving.gd`, `verify_balance_swap.gd`, `verify_short_test.gd`, `verify_motion.gd`, `verify_failure.gd`, `verify_recovery.gd`, `verify_recovery_scene.gd`, `verify_boarding_scene.gd`, `verify_truck_presentation.gd`, `verify_learner_animation.gd`.

The driving test first reproduced failure to keep reversing; it now verifies sustained S, coasting and stale input. Balance/swap checks include refused/overlapping requests, movement cancellation, old occupancy commands and delayed consent to an expired/replaced request. Short-test checks reject parking out of order or while moving, permit recovery/cone faults followed by pass, retain immutable settlement and clear state on retry. Scene checks verify actual tyre/side climbing, actual hull collision, secure rolled seating and aftermath.

`verify_launch_network.gd -- --revision --failure` passed using three real local ENet peers. Held peer commands drove the actual truck continuously through the course: no truck-pose/progress injection along the driving route. The rollover was a fixture setup, followed by the real guest-held recovery action. All peers observed pass, retry, concession, changed result choices and guest-loss return. Final position was approximately (16.65, 0, −8.31), with all three items complete. A separate rendered run also passed.

`--revision --revision-controls` passed actual aimed-seat E entry, guest deliberate exit/reboarding, rollover and off-course recovery. All peers agreed on one additional off-course fault with no skipped items. Condensed retained output is in `revision-checks.txt`. `--boarding` and `--recovery` now run the revised exercise; superseded stair/rear-steering/forced-ejection scenarios have been removed. `--revision-capture` saves all three seated views/results.

Rendered images `revision-seated-0/1/2.png` and `revision-result-0/1/2.png` were inspected. All seats have the same road framing, legible target/instructions and a real shared pass panel. They document the temporary old truck art and precede the small cone-marker/crosshair additions; final art/visual verification remains required after Astra.

Sandbox-only unit runs report unavailable Steam and a macOS certificate lookup error. The permitted native peer runs initialize Steam locally, but use ENet for deterministic fixture transport. Some fixture shutdowns retain the previously observed ObjectDB/resource warning. Neither those fixtures nor their timing establish three-human Steam feel, mixed-platform operation or fun.

## Provisional tuning

| Item | Current value |
| --- | --- |
| Timer / aftermath | 360 s / 6 s |
| Forward / reverse cap | 8 / 3 m/s |
| Forward / reverse acceleration | 3 / 2 m/s² |
| Service brake / released coast | 8 / 1.6 m/s² |
| Steering | ±0.6 rad, held angle; change 1.8 rad/s |
| Input expiry | 0.35 s |
| Camera | Truck-yaw frame (0,11,10), aimed at (0,1,−2.5); level horizon |
| Seat reach / climbing | 3.5 m; 3.8 m/s vertical contact climb |
| Balance | Normalized A/D + W/S; blend 3/s; learner ±0.6 m lateral / ±0.5 m longitudinal |
| Roll / pitch | Lateral acceleration ×0.06 minus lateral balance ×0.30; vertical speed ×0.04 plus fore/aft balance ×0.16 |
| Rollover | Roll past 0.9 rad continues onto side; easy flat driving without balance stays manageable |
| Swaps | Speed ≤0.1 m/s; 8 s expiry; explicit Y/N |
| Turn | (10,−24), 4 m radius, heading changed at least about 20° |
| Bumps | Enter x10–13, exit x20–24; z−24 ±4 m; three 0.3 m ridges |
| Parking | 12×14 m bay at (17,−10); centre ±2 m x / ±3 m z; alignment within about 40° either direction; speed ≤0.2 m/s for 2 s |
| Recovery | Hold R 2 s; rollover must settle below 0.3 m/s driving and 0.5 m/s vertical motion |
| Course bounds | x ±25, z −33 to 5; nearby authored pads checked against blocking hull geometry |
| Rating | Clean: 0 faults; Scrappy: 1–3; Survivors: 4+; speed gives no bonus |

Astra may change art dimensions only with corresponding collision/camera/probe verification. Balance usefulness and enjoyment, accessibility for the actual group, Windows/macOS builds, and ordinary/adverse Steam play remain human/integration checks. Cuter learner art and full-route/license work remain deferred.

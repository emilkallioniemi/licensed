# Ticket 04 evidence

Spec base: `d261b031d2750f16c6b8c544b07f7e051fd87a2d`.
Ticket/review base: `56d53c5aa53b6f47adf30d0fdb27a13530058bec`.
Reviewed the complete uncommitted `git diff <ticket-base>` plus new recovery implementation, scene/boundary fixtures and evidence. No branch change or commit was made by the implementer.

## Physical behavior

The existing support-relative walking and roof ramps remain. The arcade truck now probes actual terrain at its four tyres, follows raised terrain with a damped vertical spring, falls when terrain is absent, and replicates vertical velocity alongside its transform. Terrain uses collision layer 8; hull-blocking structures retain layer 4. An explicitly temporary raised sample beside the checkpoint apron demonstrates uneven ground. The cab stays upright: hill-grade/rollback and overturn presentation are later route/aftermath work, not claimed here.

Ordinary roof travel stays attached. Fast sharp turns, large suspension jolts and strong hull impacts can detach a learner with inherited support motion and an additional arcade impulse. Seats retain ordinary-turn occupants, while sufficiently strong impacts/bumps can eject operators and invalidate their old occupancy generation. A short replicated ejection interval prevents immediate floor-snap reattachment. Stepping off an edge also retains support velocity. Harmless landing produces an observation with no fault severity, and the same physical ramps allow walking back aboard. The running attempt timer is never paused by recovery.

The host resolves actual overhead collision geometry. A survivable gap beneath the deck pins a learner in place; moving the truck away restores standing only when the full standing capsule has space. Tyre/low-body compression below the survivable clearance produces a distinct catastrophic observation. Driving quickly alone is not crushing. The compressed temporary learner pose and lower first-person sight follow the confirmed condition on peers. There is no player-accessible teleport, get-unstuck, or righting action.

`AttemptState.observe_accident` accepts host-world observations with attempt/participant validation, stable event numbers, position, impulse, kind and severity. It retains a bounded recent window (32 events) and current conditions, including latched catastrophic conditions. Full room and movement snapshots recover both; guests never send accident verdict RPCs or run the authoritative resolver. Recoverable observations are `ejected`, `landed`, `trapped`, `rescued`; `crushed` and `ravine` have serious severity. Ticket 05 must consume observations during its authoritative simulation step for immutable scoring/aftermath; the event window is network recovery/presentation history, not a durable scoring ledger. Physical recovery cannot clear a catastrophic condition.

## Verification and limits

Runtime: Godot 4.7.2 (`ed1daf0bf`), `/Users/emka/Downloads/Godot.app/Contents/MacOS/Godot`. The shipping repository contains Windows-only GodotSteam libraries. Verification used `/private/tmp/licensed-04-macos-verification`, synchronized from the exact working source, with matching upstream GodotSteam 4.22.1 macOS framework/manifest only in that temporary copy. Upstream package SHA-256: `2b12b3499434c50da16104a0d22b725aee15cc5cd41223c1cea825bae59bfa8f`. No shipping dependency/platform manifest was changed.

The Steam native API loads, but a logged-in Steam client is unavailable. `tests/network_room_harness.gd` explicitly bypasses only the Steam-login bootstrap for native ENet scene fixtures, reusing production room geometry/spawner and all arrival, control, movement and recovery code. It neither mocks Steam success nor supplies simulated learners as gameplay. Three isolated native peer worlds are protocol/collision evidence, not Steam-bootstrap or human acceptance. Missing learners fail the fixture before recovery assertions.

The original `04-red.log` is an environment/class-registration failure, **not a behavioral TDD red**. The early `04-green.log` also contains unavailable-platform autoload failures despite its boundary assertions, and is not final validation. The dependency was repaired before retained scene verification. The genuine impact regression subsequently failed with `FAIL: actual hull impact ejects operator and stops truck`: confirmed seating had left a stale airborne condition, suppressing a second ejection. Clearing that condition on confirmed reoccupation fixed the behavior; both boundary and actual hull-impact checks now cover it. This records the actual test sequence without claiming the initial environment failure proved behavior.

The final public-boundary test covers operator invalidation, a second impact after reboarding, harmless landing, trapped-control refusal, deduplication, continued time, physical-rescue eligibility, distinct latched catastrophe, snapshot recovery, prior-attempt rejection and clean reset. The integrated collision fixture covers secure roof travel, a sharp-turn ejection/landing, walking back up the production ramp, deck entrapment, a friend reversing to free the learner, a large physical bump, an actual whole-hull impact on an operator, tyre compression, and a truck boxed by real immovable collision structures so physical rescue is impossible. Snapshot restoration from a seated state preserves the host's detachment impulse.

Full suite was run once: RoomState, attempt state, driving, recovery, avatar conversion, learner motion and reception input passed with no script/assertion errors. The existing ready-up probe crashed in its native display query in headless macOS; the complete display rerun subsequently passed (details below). Focused attempt/driving/recovery/motion/physical-scene checks were repeated only for the subsequent ejection/snapshot fixes. Final imports have no script/parse errors. Sandbox CA-certificate/editor-settings diagnostics and unavailable Steam initialization are recorded separately from script failures.

The first network log (`04-network.log`) is an unsuccessful Steam-bootstrap fixture run with missing spawns and must not be treated as passing merely because old summary lines printed. The corrected three-peer fixture was run by the orchestrator: exit 0, no script errors, actual boarding/roof/riding/controls/reverse/parking and delayed-snapshot recovery assertions passed. Its initial teardown reported three leaked ObjectDB instances and one resource; an attempted SceneTree-override cleanup caused replication errors and was reverted. This shutdown-only native-fixture diagnostic is retained as a limitation, not concealed as a clean shutdown. The final rerun is recorded below.

## Two-axis review

Standards: no outstanding code findings after recheck. Shared `_drop_operator` removes duplicated voluntary/accident release bookkeeping. The initial red-log evidence limitation is explicitly documented above.

Spec: no outstanding findings after recheck. The reviewer identified a speed-only crushing rule that could punish physical rescue without compression; it was removed, leaving actual compression geometry as the criterion. Final review retains the narrow ticket boundary and does not claim three-human acceptance.

## Later-ticket ownership

- 05: Consume host accident observations at the attempt boundary for scoring, guaranteed failure, aftermath and unanimous concession; a boxed-truck rescue setup is demonstrated, but no concession/result behavior is supplied by 04.
- 06: Exactly three humans over Steam must evaluate ordinary footing, ejection fairness, collection, rescue and shared consequences under delayed/adverse networking. Agent fixtures do not establish enjoyment or shipping responsiveness. All arcade thresholds remain provisional.
- 07: Replace rough truck/access/control geometry while preserving collision clearance and support. Existing modeled lobby/learner are the quality reference; the rough engineering captures are temporary, as recorded in `docs/corrections.md`.
- 09–12: Replace the temporary apron/raised sample with the fixed route; use terrain layer 8 for vertical support and layer 4 for hull-blocking structures. Integrate grade response, rollback and the authored uneven descent.
- 08: Replace the temporary compressed-body pose with proper recoverable learner rigging, fall/land and ragdoll transitions.

## Final results

- `04-network-final.log`: orchestrator ran the synchronized native copy headless with `--script res://tests/verify_launch_network.gd -- --boarding --recovery`. Exit 0; `DRIVE`, `RECOVERY` and both final `PASS` lines are present, with no script/assertion errors or replication errors. The isolated peers agree through roof travel, controls, stopped reverse, persistent parking, delayed-snapshot detachment, harmless landing, entrapment, actual reversed collection and guest-loss return. The final log retains the three ObjectDB/one resource shutdown-only diagnostic described above.
- `04-ready-final.log`: orchestrator ran the synchronized copy with the native Metal Forward+ display and `--script res://tests/verify_ready_up.gd`, allowing all awaited checks to finish. Exit 0 and final `PASS` are present, with no script/assertion errors. The logged host-loss path creates a fresh ENet room and spawns the remaining learner before the final assertions.
- `04-verify_attempt_state-final.log`, `04-verify_driving-final.log`, `04-verify_recovery-final.log`, `04-verify_motion-final.log`, `04-verify_recovery_scene-final.log`: exit 0, all behavioral checks pass with no script/assertion errors after the last physical changes. The other full-suite logs (`04-verify_room_state.log`, `04-verify_steam_client.log`, `04-verify_reception_input.log`) also pass; no related source changed afterward.
- `04-import-final.log`: native import completes without parse/script errors. New source/test UID files are retained in the working repository. `git diff --check` passes.

Final reviewer follow-ups found no outstanding code findings on either axis. Their requested evidence cleanup is incorporated here. All six ticket-04 criteria are verified as implementation/agent-scene criteria; human enjoyment and Steam feel remain explicitly with 06. No implementation criterion is parked behind that later human checkpoint.

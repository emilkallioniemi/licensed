# Ticket 02 implementation evidence

Review base: 8c0df04779a2c73ee92371f68f80f93f95cbba9c.
Spec base: d261b031d2750f16c6b8c544b07f7e051fd87a2d.
All ticket work is uncommitted for the orchestrator's single ticket commit.

## Scope and retained implementation

The rough cab has three physical controls, examiner/clipboard, cab access and a walkable roof ramp. The truck is secured on arrival; only the explicitly development-only ENet fixture supplies controlled motion. Ticket 03 replaces that motion with actual shared driving, and ticket 07 replaces rough geometry/access presentation.

AttemptState validates authenticated participant, attempt/phase, sequence, host-observed reach, exclusive occupancy and release generations. Active-test learner transforms no longer use the peer-owned waiting-room synchronizer. Sequenced held intentions drive host collision simulation; guests immediately predict local movement and look. Complete snapshots acknowledge sequences, include truck motion and support-relative learner poses, and replay pending movement in the same physics frame. Remote supported bodies follow the predicted support frame too. Small camera/mesh corrections do not move colliders. Held walking expires after 350 ms without fresh input; occupancy survives a short interruption.

The real three-peer ENet fixture now uses isolated World3D instances. Previously its three replicated rooms shared one physics world, which was sufficient for stationary launch assertions but invalid for locomotion collision tests.

## Validation

- Red/green at the agreed AttemptState seam: the first occupancy test failed because observe_learner did not exist; implemented world observations and player-level occupancy commands, then passed contention, membership/phase/reach, exclusivity, stale sequences and snapshot recovery.
- Full existing suite: RoomState, AttemptState, learner motion, reception input, Steam avatar conversion and display ready-up passed. Original launch/readiness/timer/departure coverage remains intact.
- Controlled scene fixture: ground-to-cab walking through the centre aisle, physical E occupancy, moving release, ground-to-roof walking, stable turning roof riding, detachment with inherited velocity, predicted guest boarding, occupied guest free look, inward pedals release, simultaneous guest E contention, expired held walking, snapshot recovery and guest-loss return.
- Logs: boarding-display.log, boarding-network.log, ready-up.log and 02-verify_*.log. The pure AttemptState rerun passes despite sandbox Steam/certificate startup diagnostics; the display integration runs with Steam available.
- Visual capture: 02-rough-truck.png was inspected. It is labeled rough box presentation with long forgiving ramps, not finished truck art.
- Large corrections in the fixture are the two explicit authoritative setup placements (one for each guest); ordinary movement/roof riding did not add large corrections.
- Some headless fixture shutdowns report five leaked ObjectDB instances / one resource after PASS; the display fixture and ready-up complete cleanly. No runtime script errors are accepted as a passing result.

## Standards review

No documented-standard violations. One advisory Feature Envy / Message Chains finding concerned boarding reaching into room/learner state. Authentication lookup was moved behind player_id_for_peer; the existing scene harness lookups remain coupled to WaitingRoom. This is an optional future locality improvement, not an acceptance failure.

## Spec review

The review found occupied guest yaw being overwritten, pedals release overlapping the wall, missing guest physical coverage, and initial rear-facing orientation being overwritten. All were addressed. Re-review confirmed host/guest one-time confirmed facing and subsequent free look. Guest scene coverage and full contention/freshness recovery passed.

## Limits and next owners

- 03: consume occupancy generations for driving intentions, retain local release neutralization, and replace controlled fixture motion with shared steering/throttle physics.
- 04: violent ejection, recoverable falls/entrapment/rescue and catastrophic outcomes build on support/detachment.
- 06: three humans over Steam must judge boarding, moving handovers and ordinary roof riding; these fixtures do not establish fun or shipping latency acceptance.
- 07: replace rough boxes and long access ramps while retaining continuous physical access and collision coverage.

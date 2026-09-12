# How will moving learners and shared truck controls stay consistent in multiplayer?

Label: wayfinder:grilling
Type: grilling
Status: resolved
Parent: ../map.md
Blocked by: 06, 07, 08, 14

## Question

Inspect the existing multiplayer implementation and decide how to keep one shared truck, three moving learners, and exclusive control occupancy consistent across the host and guests. Use the accepted physical control layout and recovery rules to identify the authority and synchronization boundaries required for a buildable specification.

Address simultaneous attempts to occupy a control, physical handovers while moving, retained unattended steering and parking brake state, walking and climbing on the moving truck, falls and collisions, and shared serious-fault outcomes. Reconcile departure and attempt transitions with the existing consistency decision rather than redefining results or license ownership.

Identify the implementation checks needed under latency and interrupted connections, and any remaining human decisions about responsiveness or visible correction. Resolve a plan grounded in the code; do not implement networking or claim online playability from this planning ticket.

## Comments

- 2026-09-13: User delegated the remaining judgment after accepting the authority/response approach and requiring excellent perceived responsiveness. Agent selected the interruption policy and implementation boundaries below within that authorization.

- 2026-09-13: Claimed the first unblocked decision. Code inspection found host-owned waiting-room state and reliable command handling (`scripts/waiting_room.gd:155-190`), but peer-owned learner movement (`scripts/waiting_room.gd:519-526`, `scripts/learner.gd:261-280`). Learner position/rotation replicate every 0.05 seconds (`scenes/learner.tscn:10-16,69-71`); remote presentation smooths while the collision body uses the received pose (`scripts/learner.gd:238-258`). Chair occupancy is exclusive but host command handling does not validate physical proximity. Test-area transitions still depend on `launched_roles`, and the test area is a static car park. Shared truck simulation, moving-truck learner synchronization and attempt-scoped control commands require implementation. These are inspection findings, not online playability evidence or a resolved architecture.
- 2026-09-13: First conversation round proposes immediate local walking/look response with host reconciliation, host-confirmed control occupancy and shared physical outcomes, and a provisional connection-quality validation target. Awaiting the user's preferences; no networking implementation or gameplay decision has been resolved.
- 2026-09-13: User accepted immediate local looking/walking with host-confirmed control occupancy and shared physical outcomes, smoothing small corrections and treating frequent snaps or apparently unjustified falls as failures to fix. User rejected a numerical latency target as sufficient acceptance: the multiplayer experience must feel very good and must not feel laggy. Apply this to driving, boarding, movement and handovers. Network measurements remain diagnostic; acceptance requires the user's experience in actual three-player online play. No universal connection-quality guarantee is established.

## Answer

Resolved on 2026-09-13 with the user's delegation of remaining judgment. This is a buildable networking plan, not an implemented or validated multiplayer experience.

### Authority and response

- The host owns the shared truck simulation, physical hazards, control occupancy, authoritative learner movement/contact state, timer, faults, and attempt outcome. Guests send intentions rather than authoritative truck transforms or fault verdicts. This extends the existing host-owned room rules; the current peer-owned learner transform replication is insufficient for the test.
- Looking and local movement respond immediately. Predict local walking, boarding movement, and the effect of accepted driving inputs, then reconcile against host snapshots with acknowledged input sequences. Truck prediction uses the latest known inputs from the other operators; it cannot assume their future inputs. Keep the learner and supporting truck in a coherent predicted frame, rather than smoothing them independently into visible slipping.
- Smooth small visual corrections without letting visual offsets become authoritative contacts. Correct large invalid states promptly and record them for investigation. Frequent snapping, sliding during ordinary roof riding, delayed-feeling controls, and apparently unjustified falls are checkpoint failures. Prediction must never award a result, announce a serious fault, or create authoritative damage before host confirmation.
- Separate frequent sequenced input/snapshot traffic from reliable occupancy, attempt-transition, and scored-event messages. Discard stale sequences; use attempt identity and occupancy generation to reject inputs from a former operator or prior attempt. Publish enough authoritative state to recover from packet loss without depending on every previous snapshot. Packet rates, prediction history, smoothing and thresholds are measured implementation tuning, not fixed requirements of this decision.

### Taking, leaving, and sharing controls

- E requests occupancy. The host checks current membership, attempt phase, physical reach, an available control, and that the learner is not already operating another control. The first valid request processed by the host wins simultaneous competition; one learner cannot operate two controls and two learners cannot operate one.
- Give immediate local interaction feedback, but confirm occupancy before enabling driving input or presenting an irrevocable seating change. Use a short transition animation to accommodate confirmation; do not introduce a waiting screen. Contention must resolve cleanly to the learner still standing beside the occupied control, with no effective double operation.
- E releases occupancy. Stop local held driving input immediately; the host serializes release before a replacement can occupy the control. Handovers remain physical and use the current truck-relative location and motion, including safe standing space when leaving while moving. Do not teleport between controls or grant a replacement operator remote reach.
- Steering angle and selected forward/reverse state persist through handovers. Unattended throttle and service brake release; parking-brake state persists. Taking a control starts from its actual state, rather than replaying the new operator's old held inputs. Validate stopped-only direction changes on the host.

### Moving learners and shared accidents

- Replicate whether a learner is occupying a control, supported by the truck, climbing, or moving independently, alongside the relevant support identity and relative pose. Preserve movement continuity when entering or leaving the truck frame, including the truck's motion on detachment. Do not rely on replicated world position alone for walking on a moving vehicle.
- The host resolves footing, support loss, impacts, harmless falls, trapped learners, and catastrophic accidents against the same truck and hazard state. Preserve secure footing in ordinary driving and the accepted candidate that sharp turns, bumps, collisions, and edges can throw learners off. Guests can predict ordinary motion; authoritative accident transitions reconcile all copies.
- Physical rescue remains the only recovery within an attempt. Networking corrections are repairs to replicated state, not a player-accessible teleport or get-unstuck action. Distinguish actual crushing from being trapped.
- Replicate scored events with stable identifiers so examiner comments, serious-fault effects, and results are not duplicated. Host-confirmed accidents determine the common event and aftermath; nonessential debris may be cosmetic, but anything affecting later driving, rescue, or scoring stays host-owned. Use the already agreed same-step failure precedence and immutable settled result.

### Interrupted input and attempt transitions

- Brief missing input does not pause the test or immediately eject the operator. Allow a bounded freshness window to absorb jitter, then neutralize stale held movement/steering commands and release throttle/service brake. Retain steering angle, gear selection and parking-brake state. Keep confirmed occupancy during a short recoverable interruption; fresh input resumes only for that same valid occupancy and attempt.
- Send current held state repeatedly so a lost release cannot leave throttle applied indefinitely. Parking-brake toggles and direction changes are deduplicated commands, not repeated toggles on packet retransmission. Tune freshness and connection-loss thresholds during adverse-network testing: routine jitter must not cause noticeable control cutouts, and a stalled connection must not drive forever on old input.
- On confirmed guest departure, clear its occupancy and follow the existing return flow, abandoning only an unfinished attempt. Host loss follows the existing return-to-own-room flow with no host migration. Late recovered packets cannot revive an abandoned attempt. Settled results and receipt recovery remain governed by [How are personal licenses saved and test transitions kept consistent?](14-trio-license-and-transition-consistency.md).
- Replace launch detection through populated roles with explicit attempt identity and phase. Load the test and acknowledge scene readiness before the host commits synchronized arrival and starts the timer; this is loading coordination, not a wait for control occupancy. Each retry gets fresh truck, hazard and learner state. Reject previous-attempt messages and clear pending interactions at departure, return, or retry. A failed loading connection follows the departure flow rather than leaving a partial test running.

### Required implementation evidence

- Put networking into the first actual playable cooperation checkpoint, before expanding to the full route. Test three humans over the shipping Steam transport, including the user and rotation of host and all three controls. Development transport fixtures can exercise protocol races but cannot establish shipping feel.
- The user's assessment that movement, driving, boarding and handovers feel very good is required for acceptance. A 150 ms target or any other network number is not a substitute. Record actual latency, jitter, loss, frame pacing, input response and correction frequency to diagnose what the players experience; repeat with adverse conditions and connection interruptions.
- Exercise simultaneous occupancy requests; leaving and taking over while turning; lost release messages; stale commands after handover; persistent steering/parking brake; ordinary roof riding; climbing and detachment; recoverable falls and rescue; shared catastrophic collisions; and exactly-once examiner/result events. Check that host and guests see the same meaningful accident and can understand its cause.
- Exercise guest and host loss while operating controls, during loading, and around result settlement; delayed messages after retry; reordered/duplicated inputs and commands; and recovery from a brief stall without a jump or control cutout under ordinary jitter. Preserve the results decision's departure and completion ordering.
- Revise prediction, synchronization, collision handling and tuning when feel or fairness fails, then repeat three-human online evaluation. Keep the accepted physical design and shared outcomes; do not hide synchronization problems by removing free movement or making one control optional. No networking code or online playtest was completed in this planning session.

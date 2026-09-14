# A complete monster truck vehicle

Status: ready-for-agent
Date: 2026-09-13
Source: [resolved decision map](map.md)

## Active amendment: approachable cooperation (2026-09-14)

This amendment governs the next playable revision and supersedes conflicting requirements in the 2026-09-13 baseline below, its decision tickets, and existing implementation tickets. Completed implementation remains retained history. The complete vehicle remains the longer-term objective; expansion requires acceptance of the revised cooperation checkpoint and reconciliation of deferred requirements.

### Playtest finding and objective

The user and two friends played. Visibility required dismounting before nearly every move, preventing improvement; front steering felt good, speed control felt unintuitive and unpleasant, and rear steering felt unnecessary. Laughter faded. These are reported human findings, not a claim that every planned network/control comparison ran. The distributed scrapyard was static scenery; the full route was not yet implemented. No successful complete-test or network acceptance is inferred.

Younger and less mechanical players must understand basic operation quickly, contribute, recover from mistakes, and realistically pass. A clean rating may take practice. Deliberate awkwardness in every control and restricted sight are superseded as mandatory sources of difficulty.

### Next playable behavior

- Retain exactly three humans, the existing waiting room, Steam shipping transport, useful assets, host authority, voice, and shared result/retry/return foundations.
- All seated players share an elevated third-person truck camera with readable road, destinations, hazards, and accidents. On-foot movement remains available. Seated learners stay attached through crashes and rollovers until deliberately exiting.
- Remove the rear staircase and revise the silhouette toward a recognisable monster truck. Board by holding Space while moving against the truck to climb; target a highlighted seat and press E to enter. Retain deliberate exit. Choose available physical seats initially; while stopped, request a swap that the other occupant accepts. Preserve exclusive occupancy and reject stale driving commands after handover.
- Test steering / speed / balance as three simple active responsibilities. Retain the satisfying front-steering feel. Replace the rear-steering role with directional weight shifting: lean into turns and shift forward/backward over bumps, with a clear exaggerated truck response. Easy ground stays manageable without balancing. Regular contribution and enjoyment are unproven and must be evaluated; avoid making the truck constantly threaten rollover just to occupy the third player.
- Speed: hold W to accelerate forward; hold S to brake then reverse after stopping; release both to slow gently. Ordinary driving requires neither separate direction selection nor parking-brake management. Bindings and guidance must agree with the implemented behavior.
- Everyone sees the current short instruction, destination/target area, passing requirement before attempting a manoeuvre, and completion feedback. Retain dry examiner personality and subtitles; speech is not the sole guidance channel.
- Build one short continuous test in the existing scrapyard: a turn, forgiving bumps, and parking to finish. Include actual ordered completion, a shared pass/result, retry, and a generous timer. Repeated parking attempts and cone contacts permit passing. Faults affect rating only; speed earns no rating bonus.
- Any player can use a clearly prompted hold-to-right action after an overturned truck settles. Restore it upright nearby and add a fault. Leaving the course similarly offers nearby recovery with a fault. Recovery permits continuing to pass; supersede automatic rollover failure and the ban on recovery assistance.
- Keep workers outside the driving path and the ravine inaccessible in this short test. Complete all three manoeuvres before timer zero to pass; timeout and existing voluntary concession can fail the test. Preserve established disconnect/lifecycle handling. Dangerous encounter rules for later route expansion require reconsideration, not automatic reuse.

### Validation and unresolved tuning

Reuse the previously confirmed public attempt/occupancy/lifecycle boundaries and existing Godot scene and multiplayer harnesses. Verify real input through visible driving, exclusive occupancy and consensual stopped swaps, stale-command rejection, secure seating, once-per-recovery faults, recovery without losing progress, ordered completion, timeout, one shared result, and clean retry. Update tests encoding superseded behavior rather than preserving old controls to satisfy them. No new test seam is assumed.

Three humans including the user rotate every responsibility and record whether each is understandable within a minute, regularly engaging, responsive, and useful. Include a successful short test and recovery followed by a pass; record build/settings and feedback. Compare active balance with an idle balance player after familiarisation. If balance is dull or routinely dispensable, revise the candidate before route expansion; artificial input gates do not establish useful cooperation. Preserve the ADR's three-player requirement while allowing easy ground to be forgiving.

Camera framing, balance strength, speed/braking response, stopping tolerance, recovery hold duration, and timer length are implementation tuning candidates. Use visibly explained, forgiving completion conditions; document chosen values with the build. Agent checks cannot establish human enjoyment or Steam feel.

### Scope and ticket disposition

- Retain done tickets 01–05, 07–08b as implementation history; new revision work changes their behavior where this amendment applies.
- Ticket 06 remains unaccepted. Replace its old comparison criteria with this revision's human acceptance criteria and keep it as the gate for expansion.
- Preserve tickets 09–28, with full-route hazards, persistence and presentation deferred. Reconcile their old role/sight/recovery assumptions before making them executable after the revised checkpoint. The short test includes a real pass and result; full personal-license durability/Cloud remains owned by the existing later tickets.
- Cuter, softer, simpler learners and friendlier movement/animation are a recorded later presentation direction, outside this revision.
- See the [approved revision breakdown](../monster-truck-build/revision-plan.md). Tickets 29–32 were authorized on 2026-09-14 (“I trust you.”) and are published in the existing implementation tracker; 32 blocks human checkpoint 06.

## Historical baseline (2026-09-13)

The following records the original complete-vehicle plan. Apply it only where it agrees with the active amendment above. In particular, its front/rear split, physical-only seated sight, direction/parking-brake bindings, mandatory physical rescue, automatic rollover failure, five-item next checkpoint, and related exclusions and tests are superseded for this revision. Deferred route and presentation details require reconciliation after the revised checkpoint.

## Problem Statement

Three friends can gather in the existing waiting room, but departure currently leads to an empty car park. They cannot yet share a monster truck, take its driving test, fail spectacularly, earn a personal license, or retry together. Completing only a manoeuvre demo would leave the intended experience unfinished.

Build one complete vehicle from waiting-room departure through cooperative driving, a full test, accidents, results, replay, and return, including substantial asset production. The central requirement is enjoyable, awkward cooperation that continues to need exactly three humans after they learn the route. Resolved planning decisions establish a candidate to build; they do not establish that it is funny, fair, or responsive in online play.

## Solution

Three players book the monster truck and ready up without choosing roles. They arrive beside a secured truck in a working mountainside scrapyard over a ravine. The timer starts immediately. They climb aboard, physically occupy front steering, rear steering, and throttle/brake controls, and exchange responsibilities by getting up and moving. Their sight follows their bodies, making blind spots and physical instruments things to communicate about.

The examiner directs one continuous test with five ordered manoeuvres and three changing worker/machinery encounters. Coordinated steering, braking, limited sight, and exaggerated bounce make ordinary driving demands awkward. Recoverable mistakes leave physical consequences and minor faults; catastrophic accidents guarantee shared failure, with time to enjoy the aftermath before results. Completing the test in time earns all three the same stamp and attempt rating on their own licenses. Personal best ratings survive worse retries and changes of friends or host.

Develop the actual vehicle through a first online cooperation checkpoint, a complete playable test with decent Blender models and generated audio, and finished presentation and persistence acceptance. Keep useful implementation and revise from human evidence. Separate throwaway prototypes are not prerequisites.

## User Stories

1. As a player, I want exactly three humans in the test, so that sharing the vehicle remains the point of playing.
2. As a player, I want every friend to remain necessary after we learn the controls, so that nobody becomes a spectator.
3. As a player, I want to book the monster truck without choosing a preassigned role, so that we can choose controls inside it.
4. As a player, I want the existing chairs, examiner call, door, and fade to take us into the test, so that departure feels connected to the waiting room.
5. As a player, I want to arrive close to a parked truck with the examiner aboard, so that we can get going quickly.
6. As a player, I want the timer running while we board, so that getting organized is part of the comedy.
7. As a player, I want to take and leave a physical control with E, so that exchanging responsibilities is understandable.
8. As a player, I want only one operator at each control, so that our actions have clear ownership.
9. As a player, I want to change controls by moving through the cab, so that handovers create physical interaction.
10. As a player, I want to leave controls even while moving, so that we can take risks and respond to trouble.
11. As a player, I want front and rear steering to hold their angles, so that turning requires anticipation and deliberate unwinding.
12. As a player, I want meaningful throttle, braking, and direction decisions, so that this responsibility is as engaging as steering.
13. As a player, I want predictable unattended controls, so that I can understand why the truck coasts or rolls away.
14. As a player, I want a separate persistent parking brake, so that everyone can leave a secured truck.
15. As a player, I want to look freely from my learner's position, so that finding better sight is a physical choice.
16. As a player, I want bodywork and height to create readable blind spots, so that I have information to ask friends for.
17. As a player, I want to climb onto the roof with friends, so that we can inspect the mess together.
18. As a player, I want ordinary footing to be reliable, so that roof riding is possible without constant frustration.
19. As a player, I want violent motion to throw learners off, so that careless driving has visible consequences.
20. As a player, I want to walk back and climb aboard after a harmless fall, so that recovery stays physical.
21. As a player, I want friends to free a trapped learner by moving the truck, so that rescue is another cooperative problem.
22. As a player, I want us to concede an impossible rescue unanimously, so that we can abandon the attempt and retry.
23. As a player, I want contextual binding hints when I occupy a control, so that I can begin operating it under pressure.
24. As a player, I want to restore those hints, so that forgotten keys do not require a separate tutorial.
25. As a player, I want physical steering, direction, and parking-brake indicators, so that I can inspect the truck's actual state.
26. As a player, I want the timer readable from its physical location, so that calling out time is part of cooperation.
27. As a player, I want examiner requests and route markings to guide the test, so that I can understand what to attempt next.
28. As a player, I want subtitled examiner speech and repeatable requests, so that missing a line does not leave us lost.
29. As a player, I want learning and repeated instructions to leave the timer running, so that pressure stays present.
30. As a player, I want one continuous scrapyard test, so that manoeuvres and connecting driving form a shared experience.
31. As a player, I want offset gates, a hill start, bridge alignment, reversing, and final parking, so that the truck demands varied coordination.
32. As a player, I want to correct a manoeuvre while time remains, so that an untidy attempt can still succeed.
33. As a player, I want hazards involving workers and moving machinery, so that the scrapyard feels active.
34. As a player, I want perceptible hazard cues and room to stop, so that looking and communication can prevent accidents.
35. As a player, I want familiar hazards with changing authored variants, so that replay rewards learning while still requiring attention.
36. As a player, I want machinery to clear the route within a bounded time, so that safe driving does not depend on luck.
37. As a player, I want recoverable scrapes counted fairly, so that one collision does not become dozens of faults.
38. As a player, I want minor faults to lower my passing rating without preventing a pass, so that messy success still earns a license.
39. As a player, I want catastrophic accidents to fail everyone, so that mistakes have shared stakes.
40. As a player, I want the physical aftermath and dry examiner response before results, so that failure is worth watching.
41. As a player, I want the timer to fail us at zero, so that finishing in time matters.
42. As a player, I want ratings based on minor faults rather than speed, so that cleaner driving gives us a reason to retry.
43. As a player, I want results over the visible aftermath, so that the assessment belongs to what just happened.
44. As a player, I want to compare the latest shared result with my personal best, so that I can see improvement.
45. As a player, I want changeable Retry or Waiting room choices requiring three matching decisions, so that no host chooses for everyone.
46. As a player, I want retries to start directly beside a reset truck, so that another attempt is quick to begin.
47. As a player, I want a fresh usable scrapyard each attempt, so that old wreckage cannot permanently block progress.
48. As a player, I want my license to remain mine across hosts and friend groups, so that earned progress follows me.
49. As a player, I want worse retries and failures to preserve earned stamps and best ratings, so that replay cannot erase success.
50. As a player, I want my physical license to show my portrait and records, so that I can show it to friends.
51. As a player, I want the booking board to show current players' stamps, so that we can see who has passed.
52. As a player, I want confirmed completed results preserved if somebody leaves, so that departure cannot revoke a pass.
53. As a player, I want surviving result receipts to recover an interrupted award, so that one missed delivery need not lose progress.
54. As a player, I want local saving to work independently of Cloud, so that unavailable backup does not stop progression.
55. As a player, I want Steam-account separation and Cloud restoration, so that my license survives a supported computer change without mixing accounts.
56. As a player, I want failed saves reported accurately with a retry, so that I know whether my result is durable.
57. As a player, I want movement, boarding, driving, and handovers to feel very good online, so that network delay does not overwhelm the intended awkwardness.
58. As a player, I want friends to see the same meaningful accident and result, so that our shared experience makes sense.
59. As a player, I want brief connection trouble to recover without stuck throttle or duplicated actions, so that old commands do not create new accidents.
60. As a player, I want interrupted attempts to return us to the appropriate rooms, so that we are not stranded in a partial test.
61. As a player, I want chunky expressive models, animated controls, and readable machinery, so that the vehicle feels complete.
62. As a player, I want visible truck damage, flying props, and ragdolls, so that catastrophic mistakes produce physical comedy.
63. As a player, I want a physical examiner who braces and occasionally loses composure, so that terrible driving affects him too.
64. As a player, I want powerful driving sounds and recognizable hazard cues, so that I can hear consequences and approaching trouble.
65. As a player, I want a shared physical radio with three contrasting music styles, so that we can choose what plays in the cab.
66. As a player, I want voice and examiner speech intelligible alongside music and machinery, so that communication remains possible.
67. As a player, I want five visible gestures with my own first-person hands, so that I can react to friends and the examiner.
68. As a player, I want emotes and showing my license to require free hands, so that social actions respect physical control use.

## Implementation Decisions

### Foundation and scope

- Retain Godot 4, Steam-only shipping networking through Godot's MultiplayerAPI, and the exactly-three-human constraint in the accepted ADRs. The existing development-only ENet path is for fixtures, not shipping or evidence of three-player gameplay. No bot learners.
- Reuse the waiting room, stations, departure theatre, voice, and available asset-generation patterns. Current RoomState is host-owned, but launch and readiness assume role holds and populated launched roles; the current test area is a car park. Learner movement currently uses peer-owned transforms and remote smoothing. These foundations need adaptation; none supplies shared truck physics, scoring, or personal licenses today.
- Introduce one host-owned attempt boundary for lifecycle, authoritative observations, control commands, timer, faults, settlement, and group choices. Keep physical simulation and presentation integrated with that boundary without exposing each sensor or prop as a separate testing API. A personal-license store owns durable records and reconciliation behind local and Steam backup adapters.
- Separate waiting-room booking from active attempt identity and phase. Explicitly represent loading, active play, settled aftermath/results, and departure transitions; do not use a populated role dictionary as launch detection.

### Booking, controls, sight, and recovery

- Hide monster-truck role pickup and show "Choose your controls in the truck". Three matching picks and three seated learners start the existing examiner call, door animation, and fade. Reconcile booking-board presentation, notice-board readiness, and arrival role text.
- Load and acknowledge scene readiness before the host commits synchronized arrival. Place learners a short walk beside the truck, parking brake engaged and examiner already seated. Start the timer and first destination request on arrival, never on control occupancy. Failed loading follows departure handling.
- Candidate cab: front steering on the left, throttle/service brake on the right, rear steering behind them facing backward; roomy interior and climbable roof. Dimensions follow handling and sight validation. Anyone can occupy any available control, with one operator per control and at most one control per learner.
- Steering gradually adjusts a limited axle angle with quick response and no automatic centring. Blind spots and coordinated front/rear steering are primary difficulties; exaggerated bounce amplifies them. Tune for arcade coordination that is a little hard and fun.
- Sight follows physical position and free looking. Windows, height, and bodywork limit it. There is no overhead sight or permanent role-specific sight assignment. Moving for sight must not erase the need for three active contributors.
- E occupies or releases a control, including while moving. Release places the learner beside it in usable standing space with coherent truck-relative motion. A handover requires release, movement, and takeover; no exchange menu or remote takeover.
- Unattended steering retains its angle; selected direction persists. Throttle and service brake release, allowing coasting or rollback. The separate parking brake remains in its current state. Taking a control uses its actual state and does not replay the new operator's old held input.
- Ordinary truck footing should be secure. Sharp turns, large bumps, collisions, or stepping over an edge can eject a learner. Harmless falls are not faults: walk back and climb aboard while time runs. Free trapped learners physically, for example by moving the truck. No teleport, get-unstuck, or truck-righting action. Catastrophic crushing, ravine falls, and overturning guarantee failure; physical recovery cannot undo it. Impossible rescue can lead to unanimous concession.

| Context | Binding | Behavior |
| --- | --- | --- |
| Either steering control | A / D | Turn the axle toward the truck's left/right, regardless of looking direction or reverse travel. Rear steering uses the same truck-relative convention. |
| Throttle/brake | W / S | Throttle in selected direction / service brake. |
| Throttle/brake | R | Switch forward/reverse only while stopped, validated by the host. |
| Throttle/brake | Space | Toggle persistent parking brake. |
| Control in reach / occupied control | E | Take / leave; driving keys never stand the learner up. |
| Occupied control | H | Restore its binding hints. |
| Active test | T | Repeat the current examiner manoeuvre request; do not stack requests or interrupt fault comments. |
| Hands free | L | Toggle personal license; taking a control or starting an emote puts it away. |
| Hands free | Hold B, release | Open the five-choice emote wheel and perform the selection. |

- Scope driving bindings to occupancy, preserving on-foot movement, jump, and interaction. Brief binding labels appear on occupation and handover, with subtle highlights on visible controls and small hints for unseen controls such as pedals.
- Place an axle-angle pointer beside each steering control; place the physical timer, selected direction, and parking-brake indicators beside throttle/brake. Other learners need sight of these instruments or a spoken call. Do not repeat instrument information on everyone's screen.
- No monster-truck test sheet. Painted arrows, numbered signs, physical markings, and examiner requests convey the route. Subtitle spoken examiner lines without extra hazard or instrument information. Learning and repeating requests do not pause time or add examiner driving advice.

### Fixed route and completion

One continuous route climbs to an upper terrace, crosses the ravine, reverses beside the crusher, then descends to final parking. Five test items must complete in order, with scored connecting driving and no separate loading or separately awarded stamps. These dimensions and section budgets are initial playtest candidates, not validated tuning or additional timers.

| Section | Required completion | Initial layout and pacing |
| --- | --- | --- |
| Arrival yard | Board and pull forward through two offset gates; the entire truck clears the second gate in the marked direction. | Stacked wrecks, cones, loose panels, and a wide recovery apron. 55 seconds including boarding and connecting travel. |
| Scrap climb | All tyre contact points remain inside the hill-start box at rest for two continuous seconds, then the entire truck clears the crest forward. | Flat rollback runout, exposed outer ravine edge. Parking-brake use is available but not itself required for this item. 55 seconds. |
| Ravine bridge | Drive forward until the entire truck clears the far marker. | Fixed bridge about 1.5 truck widths wide; flat approach and straightening/holding space before the crane sweep. Recoverable rail contact, catastrophic falls. 50 seconds. |
| Crusher terrace | Stop fully in the turnaround box, reverse around an L-shaped bend, and hold all tyre contacts inside the refuge at rest for two seconds. Leave through the marked forward exit. | Whole-truck turnaround and refuge with walking space; yielding cone boundary and a substantial apron before the crusher chamber. 70 seconds. |
| Descent and parking | Reverse into the parallel bay between fixed wrecks; full footprint inside, length within 15 degrees of bay alignment, at rest for two seconds, parking brake engaged. | Uneven descent, correction space, bay initially about 1.6 truck lengths by 1.4 widths. 70 seconds. Completes the test only after previous items. |

Stopping, extra shunts, reversing for correction, looking, swapping controls, and collecting learners are permitted without faults by themselves. Missing or out-of-order items remain incomplete. Inaccurate stop/parking placement does not add faults unless it also violates a boundary or contacts something. Bounce does not revoke already earned progress; the truck must settle to satisfy a stop box. Maintain usable boarding and rescue space at ordinary stopping areas.

### Changing hazards and physical consequences

Three encounters each have two authored variants and one active crossing per attempt. Choose variants afresh, including on failed-attempt retries; repeats are allowed. Route, manoeuvres, locations, and remaining scenery stay fixed. Machinery continues visibly working off the driving path afterward and never repeatedly blocks corrections.

| Encounter | Variants | Notice, avoidance, and consequence |
| --- | --- | --- |
| Worker with scrap trolley before the climb | Left-to-right or right-to-left from marked work bays. | Visible approach, footsteps, trolley rattle; stop on flat apron or cross after clearance. A worker strike throws them and spills scrap; trolley-only contact is not automatically a worker strike. |
| Crane with suspended wreck at bridge entrance | Sweep left-to-right or right-to-left from visible loading positions. | Motor, beacon, and load movement before the sweep; a holding apron outside its reach. Glances can remain recoverable; impact can spin the truck or fling scrap into the ravine. The load does not chase the truck. |
| Forklift with wreck after the crusher refuge | Cross forward with load or reverse across from the opposite bay with alarm. | Visible bay exits and moving load, motor/alarm, safe terrace waiting space. A brush can be minor; toppling occupied machinery or striking its operator is serious. |

- Start with four seconds of perceptible preparation plus zero to two seconds of selected additional preparation, and no more than six seconds of lane occupation. Once clear, no second scripted crossing occurs that attempt.
- Measure cue placement using actual truck stopping distance at intended approach speed, plus at least two seconds to notice and communicate. At least one occupied control must have access to the cue before the braking decision. Walking learners receive the same cues and physical consequences.
- If the truck reaches the conflict before preparation begins, defer the crossing until the entire truck and walking learners clear. Never create an unavoidable hazard around them. Deliberately entering a perceptibly announced crossing can cause an accident; reckless speed may outrun stopping space. A safe ordinary approach must have a usable gap within the timing bounds.
- The crusher cycles on a fixed schedule, compacting an unoccupied wreck outside the legal route and refuge. Its phase cannot prevent a correct manoeuvre. Players can physically enter the marked open chamber and be crushed, but crossing a cone does not magically place them inside it.
- Cones, loose panels, wrecks, weakened outer rails, and uneven ground supply physical consequences. Light props scatter; major structures need not all break. Meaningful displaced props and wreckage persist within an attempt, with physical rescue or concession if they block progress. Every retry restores the usable scrapyard.

### Faults, timer, and immutable results

- Begin with a six-minute timer and roughly five-minute successful-attempt target. Both pacing and the timer require human validation.
- Award one minor fault for a continuous cone/marker strike, recoverable contact with wrecks/rails/trolley/machinery/load, or drivable-boundary excursion. Count an impact chain or scrape once, including a boundary crossing caused by that same incident. A new contact fault requires two seconds clear of all contact; a new boundary fault requires full re-entry first.
- Hill-start rollback greater than half a tyre diameter after the required stop is one minor fault per continuous rollback. Forward travel must resume before another rollback can count. Smaller rollback is tolerated and the demonstrated stop remains earned.
- No repeated faults for remaining outside a boundary, no invisible failure wall, and no separate speed or right-of-way penalty. Bounce, roof riding, gestures, and harmless learner falls alone are not faults.
- Truck, driven load, or accident debris striking a worker; toppling occupied machinery; truck overturning onto its side; ravine falls; and catastrophic crushing or other catastrophic learner accidents are serious faults. Harmless on-foot contact with a worker and mere entrapment are distinct.
- When a contact immediately causes a serious accident, record the serious fault instead of an additional minor for the same contact. If a recoverable incident later cascades into catastrophe, retain its history and guarantee failure when catastrophe occurs.
- Complete every required item before zero without serious fault to pass, regardless of minor-fault count. Failure wins final-completion ties with zero or a serious fault in the same simulation step, including during final parking. Settle exactly one immutable outcome per unique attempt; a pass is earned at completion before the assessment, and later chaos cannot revoke it.
- Serious fault or timer zero guarantees failure, then permits physical aftermath and examiner response before results. Do not require completing the remaining route after failure. Tune aftermath duration so it neither cuts off the interesting incident nor leaves unnecessary waiting.
- Ratings use minor faults only, with no speed bonus. Initial names/bands: Suspiciously Competent (0), Mostly Harmless (1–3), Technically Licensed (4+). Names and thresholds remain playtest candidates; retained best uses quality ordering, not display text or modification time.
- Show a marked results sheet over the visible aftermath with latest shared result, minor faults, passing rating when applicable, and the viewing player's retained best. Retry and Waiting room choices are changeable until three current players match. Retry bypasses booking/chairs, creates a fresh attempt, and resets world, learners, controls, damage, effects, choices, and reaction limits before synchronized arrival.
- Replace host-only immediate return with Concede test in the Escape overlay. Anyone can propose it; all three must agree while active and time continues. Concession settles shared failure and uses the normal results flow; it cannot override a settled outcome or rescue within the attempt. Anyone can still quit.
- Membership changes invalidate choices. Guest departure abandons an unfinished attempt and returns survivors to the waiting room. Host loss sends guests to their own rooms; no host migration. Departure after settlement preserves earned results. Attempt/phase checks reject late, duplicate, or prior-membership commands and prevent old choices from triggering a retry or return.

### Shared simulation and responsiveness

- Host authority covers truck physics, meaningful hazards/debris, occupancy, learner movement/contact state, timer, scoring, and results. Guests send intentions; they do not author truck transforms, damage, or fault verdicts.
- Immediate local looking and movement, predicted boarding and accepted driving input, reconcile with acknowledged input sequences in host snapshots. Predict truck motion using the other operators' latest known inputs, not imagined future actions. Keep supporting truck and learner in one coherent predicted frame.
- Smooth small visual corrections without allowing visual offsets to author collisions. Correct large invalid states promptly and record them. Frequent snapping, ordinary roof sliding, laggy controls, and apparently unjustified falls are failures to fix. Predictions cannot award results or announce serious faults before confirmation.
- Use frequent sequenced input/snapshot traffic separately from reliable occupancy, transition, and scored-event delivery. Snapshots include enough state to recover without every preceding packet. Inputs carry attempt identity and occupancy generation to reject old operators and stale sequences. Scored events have stable identities so comments, significant effects, and results are applied once.
- Host occupancy checks membership, phase, physical reach, availability, and absence of another occupied control. First valid request processed wins contention. Give immediate interaction feedback and a short seating transition, but require confirmation before driving or irrevocable seating; no waiting screen. Losers remain beside the occupied control.
- Release stops local held driving input immediately. Host serializes release before replacement occupancy. Represent occupied, supported, climbing, and independent learner movement with support identity and relative pose; preserve truck motion on detachment. World-position replication alone is insufficient.
- Host resolves footing, ejection, impacts, entrapment, and catastrophic accidents against the same physical world. Cosmetic debris may be local; anything affecting later driving, rescue, or scoring stays authoritative. Corrections repair state and do not introduce player-accessible teleport recovery.
- Repeatedly send held state so lost releases cannot leave throttle stuck. After a bounded input-freshness window, neutralize stale held walking/steering commands and release throttle/service brake, retaining axle angle, direction, and parking brake. Keep occupancy during a short recoverable interruption; fresh input resumes only for the same valid attempt/occupancy. Deduplicate brake toggles and direction switches.
- Tune packet rates, prediction history, smoothing, freshness, and connection-loss thresholds through actual conditions. Jitter must not routinely cut controls out, and stalled connections cannot drive forever. Confirmed loss follows departure rules; recovered late packets cannot revive abandoned attempts.
- Online acceptance requires the user's experience that movement, driving, boarding, and handovers feel very good with three humans over Steam. A latency number alone cannot establish this.

### Personal licenses and Steam Cloud

- A shared pass awards all three named players the same stamp and attempt rating. Each owns a personal license across hosts/groups, retaining stamp union and best rating monotonically. No per-player performance score or exact-trio license.
- Scope records to signed-in Steam identity, serialized without precision loss, using decimal Steam ID text. Keep owned-app, app-480, and development-transport records separate. Peer IDs, names, and a previously signed-in account are not identity fallbacks.
- At settlement, commit the result/receipt locally and distribute immediately; recipients save and acknowledge. Acknowledgement of local durability follows successful validated commit. Cloud upload is independent and never gates gameplay or result presentation.
- Reconcile available valid local records, Steam copies, and surviving receipts by stamp union and best quality. Receipts restore awards only for their named participants; duplicates have no effect and unrelated-account awards are rejected. A surviving original friend's receipt can recover missed delivery later without requiring the entire original trio.
- Validate schema, owner, vehicle/rating values, attempt identity, and receipt contents. Distinguish absent data from read failure, corruption, or unsupported schema. Preserve unreadable copies for diagnosis and avoid overwriting them with an empty license.
- Use recoverable local commits with checked temporary data and a retained previous generation. Exercise interruption at write/replace steps. If local saving fails, retain memory state, continue distributing to peers, visibly report failure, and allow retries without trapping results flow. Do not claim recovery if every durable copy is lost.
- Use explicit RemoteStorage backup alongside independent account-scoped local records and receipts excluded from synchronization. Read and merge before writing the Steam snapshot; commit locally before staging backup. Start with bounded synchronous reads/writes, verify installed bindings, and measure latency. If unacceptable, replace with a serialized asynchronous owner that handles missing/late callbacks and correlation limits from the existing research.
- Bound snapshot size and receipt retention during persistence implementation and record the recovery horizon and quota calculation before Cloud setup. Preserve monotonic earned records when compacting; do not introduce an unbounded Cloud archive or imply receipts survive deletion forever. Any finite receipt retention limits must be explicit in validation evidence.
- Track the generation being staged; an older completion cannot mark a newer license backed up. Distinguish settled result, confirmed independent local save, Steam-managed staging, and verified restoration. Disabled Cloud, quota failure, timeout, and unavailable data never mean an empty license. Steam may resolve conflicts before launch; merge only copies still accessible and do not promise restoration of overwritten data.
- Owned-app Cloud setup and restoration are part of this vehicle. Prepare concrete storage bounds and configuration handoff: owned app ID, nonzero byte/file quotas with replacement headroom, published configuration, and test-account access. An authorized Steamworks partner needs app-metadata editing and publishing permissions. Keep overlapping Auto-Cloud rules absent, shared Cloud app unset, and Dynamic Cloud Sync initially disabled. App 480 can support development investigation but does not validate owned-app setup. Only touch this project's test records.

### Asset production and finished presentation

Astra owns substantial production and integration, including editable Blender sources/generators and portable Godot exports. Prior inspection located Blender 5.2.1 LTS and Godot and found existing Python/Blender/GLB workflows. Verify remaining audio runtimes during implementation. Reuse useful materials and production patterns; the learner's existing appearance and proportions are not constraints. One expressive learner body/rig, three clothing colours, and matching portraits are in scope; no customization screen.

Chunky stylised 3D uses oversized machinery, expressive people, readable silhouettes, battered industrial colours, and neglected safety. Violent slapstick starts without gore: authored wrecked shapes, ragdolls, flying props, dust, sparks, and absurd trajectories. General-purpose metal deformation is unnecessary.

| Deliverable | Production and integration | Completion check |
| --- | --- | --- |
| Truck and cabin | Exterior, oversized tyres/suspension, both axles, three controls, persistent parking brake, access/roof, examiner seat, physical instruments and radio. | Animated controls follow authoritative state; tyres/suspension communicate motion; boarding and handovers work with sight and blind spots preserved. |
| Scrapyard kit | Five route sections, ravine/bridge, crusher apron, markings/signs, cones, wrecks/stacks, rails, loose scrap, finishing bay. | Scaled to the truck; static, movable, and breakable parts have suitable collisions; art preserves cue sight, boundaries, and rescue space. |
| Active machinery and workers | Crane/load, crusher, forklift/load, trolley/scrap, workers; shared humanoid rigging where useful. | Both variants of every encounter align animation, audio, collision, and scoring; workers push/walk, machines work, loads shed, occupied machinery can topple. |
| Learner rig and first-person hands | Idle, walk, jump/fall/land, board/climb, seated control use, take/leave controls, recoverable ragdoll entry/exit, articulated gestures. | First-/third-person behavior agrees across peers, retains essential sight, and avoids distracting clipping; three colours and matching portraits are integrated. |
| Examiner | Distinct body, clipboard, coffee, seated/assessment poses, bracing, puke, swear reactions and accident response. | Props follow the body; physical distress responds to driving while spoken assessments stay dry. |
| Five emotes | Wave, clap, point, both middle fingers, alternating-palms "67" with one short "six seven" vocal line per selection. | Own hands and friends' gestures match; release controls first; starting an emote puts the license away. |
| Physical license and records | Card, printed portrait, monster-truck stamp, empty slots, rating marks, hold-up/put-away presentation; booking-board ownership display. | Owner and nearby friends can read that player's records; unavailable at driving controls; board shows current players' stamps side by side. |
| Destruction/effects | Authored damage, detachable parts, flying props, ragdolls, dust, sparks, puke. | Catastrophic truck accidents visibly leave a wreck; worker strike, overturn, ravine fall, machinery toppling, and crushing each have readable aftermath; reset cleanly. |
| Vehicle/world sound | Engine layers, loose metal, suspension, tyre scrub, cabin clatter, metal/ground/machinery impacts, footsteps, trolley rattle, motors, crane cue, reversing alarm. | Feedback follows driving/contact; duplicate impacts do not overwhelm; hazard sound precedes conflict and remains perceptible. |
| Radio | Three generated instrumental tracks: calming easy listening, heavy rock, upbeat dance; physical power, next-track, volume. | Shared speaker playback and state; nearest control can reach it, others move or ask; quieter outside, slight music ducking for voice/examiner, no distracting gaps/clipping. |
| Examiner audio | Offline rendered speech plus distress sounds; three alternatives per fault category, arrival, all five requests, pass, fail, timeout, concession. | Alternatives do not repeat until the category is exhausted; subtitles match; scored comments take priority; no runtime TTS dependency. |
| Results/return | Marked sheet over aftermath, latest shared assessment, personal best, changeable group choices; existing waiting-room integration. | Wreck remains visible; results and choices agree across peers; retry/return preserves records and resets presentation state. |

- Examiner assessments are one plain sentence, dry and factual, without explanations, encouragement, role addressing, exclamation marks, or stage directions. Understatement increases with severity. Physical distress does not turn assessments into constant shouting.
- Brace on hard jolts; at most one puke and two muttered swears per attempt, with at least 30 seconds between distress outbursts. Bracing is not itself an outburst. Tune triggering severity from play; scoring comments take priority.
- Use offline speech WAV generation following the existing System.Speech pattern because runtime Godot TTS crashes were recorded. Existing Python/numpy procedural music is a starting production path, subject to runtime verification. No dedicated audio-generation service was verified. Suitable character, coverage, and intelligibility are required; exceptional audio fidelity is not. Identify a specific unmet sound/tool dependency if encountered rather than omitting work or assigning all assets to the user.
- First cooperation checkpoint may use rough geometry, basic engine/collision sounds, a running timer, and temporary examiner speech. The complete playable checkpoint must include decent Blender models for truck, route, people, and machinery, generated driving/hazard/examiner audio, and enough animation/aftermath to evaluate play. Full gestures, radio, detailed animations, damage, and presentation coverage are required before finished acceptance.

## Testing Decisions

Testing seams were confirmed by the user on 2026-09-13: reuse RoomState for booking, use one new host-owned attempt boundary for attempt/scoring/choices, and test license durability through its public store with local/Cloud adapters. Existing scene harness patterns and three-human Steam play cover integration and physical experience. Avoid a separate seam for every internal helper, prop, or sensor.

Good tests send player-level commands or authoritative world observations through public boundaries and assert externally meaningful results: eligibility, occupancy, progress, faults, transitions, records, and visible behavior. Do not mirror implementation, assert private storage layout, or substitute synthetic fixtures for human fun/feel evidence. Controllable time, storage failures, and delivery order support behavioral checks; real scenes must also verify that physical events produce the correct observations.

### Automated and integration checks

| Boundary | Required checks | Prior art and limits |
| --- | --- | --- |
| RoomState and departure | Three matching picks/seated learners launch without monster-truck holds; cancellation, membership, explicit launch state, notice text, scene-ready arrival, return reset. | Existing headless RoomState command/snapshot verification and display-based ready-up announcement/fade test. Update assertions that encode superseded monster-truck roles. |
| Attempt public commands/observations | All five ordered completion rules; untidy valid manoeuvres; missed/out-of-order finish; stop holds; final parking brake; rollback tolerance; contact-chain/boundary deduplication and resets; minor-only pass ratings; all serious accidents; zero/completion/serious-fault same-step ties; immutable result. | Follow RoomState's deterministic command/result style with controlled time. Scene checks exercise real geometry and collisions rather than only injecting a correct fault observation. |
| Occupancy and replicated attempt | Simultaneous E requests, reach checks, one control per learner, physical release/takeover while turning, stale operator inputs, held-state release, lost/duplicated/reordered packets, toggle deduplication, snapshot recovery, once-only events. | Development transport fixtures exercise protocol races. Real online play remains necessary for Steam transport and feel. |
| Choices and lifecycle | Three changeable matching choices, active-only unanimous concession with timer running, completion/concession/departure races, scene-load failure, host/guest loss, no migration, delayed choices after retry, clean attempt reset. | Extend existing transition harness patterns through public behavior. Completed records survive departures; unfinished attempts are abandoned. |
| License store and adapters | Exact account identity, personal best across hosts/groups, weaker retries/copies, union merge, duplicate receipts, recovery from one original friend, unrelated receipt rejection, malformed/unsupported data, independent local/Cloud failure, interrupted commit, dirty-generation backup, explicit receipt-retention bounds. | New public store seam, controllable adapters, real temporary storage for commit/restart cases. A fake Cloud validates application policy only. |
| Scene/input integration | Boarding/climbing, truck-supported movement/detachment, safe ordinary roof riding, recoverable fall/collection, physical entrapment/rescue, catastrophic outcomes, contextual keys, H/T behavior, license/emote restrictions, instruments/subtitles. | Existing motion, reception input, and ready-up scene harnesses show the project's Godot verification style. Prefer externally observable behavior over their private-method coupling. |
| Presentation | Imports/materials/collisions/pivots, rig transitions, first-/third-person hands/card, all assets and accident types, audio playback and mix, shared radio, reaction caps, comment variation, clean resets. | Existing source/export/preview workflow plus integrated visual/audio review. A headless test cannot certify readability, sound, or comedy. |

### Playable checkpoint 1: cooperation and early online feel

User sequencing override (2026-09-13): produce implementation tickets 07–08 (modeled truck and animated learners) after 05, before the three-human checkpoint 06. This overrides the earlier rough-first production sequence only for these two tickets. Driving, sight, cooperation and Steam feel remain provisional until recorded human acceptance; all other downstream expansion remains gated by 06.

Build boarding, a moving turn, tight reversing, and parking to climb onto the roof as retained implementation. Include networking now, with rough presentation and a timer/examiner wrapper. Identify temporary recovery/result scaffolding and replace it as the full test develops.

Exactly three humans rotate through every control and rotate the host, including the user over Steam. After familiarisation, compare coordinated play with one person deliberately not contributing while remaining connected. Try holding rear steering fixed and having two people hop between controls. Observe anticipation, enjoyment, information exchange, ordinary footing, handovers, and shared visibility of consequences.

Revise when rear steering is optional, throttle/brake is dull, two active contributors routinely suffice, movement removes blind spots, or ordinary boarding/roof riding becomes frustrating. Compare handling, sight, or geometry changes one at a time and record player reactions and build/settings. Do not fix networking by removing free movement or making a control optional.

The user must judge movement, driving, boarding, and handovers very good, without a laggy feel. Record latency, jitter, loss, frame pacing, input response, and correction frequency as diagnostics. Repeat under adverse conditions and short interruptions; exercise control contention, moving handovers, lost releases, stale inputs, climbing/detachment, rescue, shared accidents, and host/guest loss during operation/loading/settlement. Numerical targets and agent-only tests cannot establish acceptance.

### Playable checkpoint 2: complete test, pacing, and replay

Integrate arrival, all five manoeuvres, scored connecting driving, both variants of all three encounters, recovery, timer/faults, aftermath, results, and working retry. Include the specified decent Blender models and generated audio; box-only and placeholder-only presentation is insufficient here.

Start with three familiarisation attempts so everyone operates each control, then at least three familiar attempts. Extend if there is no successful completion or variants remain unseen. Controlled variant selection may fill coverage gaps as labeled test scaffolding; normal retries still draw afresh. After revisions, use a fresh trio to check learning.

Record build/settings, controls, variants, outcomes, total/section durations, inactive stretches, confusing or unavoidable collisions, aftermath reactions, and desire to retry or improve ratings. Verify both variants and latest activation timing, actual stopping space plus communication margin, safe waiting positions including walking learners, no repeated crossings, and crusher separation from legal driving.

Prioritize enjoyable coordination and avoidable hazards before the exact five-minute target. Fix dull connecting driving, frustrating geometry, and poor cues before tuning the six-minute timer. If useful, temporarily disable a troublesome hazard to separate route and encounter problems. Compare relevant changes individually. Familiar players should still look and communicate rather than recite fixed timing.

Compare aftermath windows when results cut off action or leave dead waiting. Preserve guaranteed serious-fault failure, minor-only passing ratings, and best retention. Tune candidate rating thresholds from observed motivation. Record retain-or-revise findings for cooperation, pacing, hazard fairness, replay, aftermath, and ratings; missing successful or varied attempts requires more evidence, not a validation claim.

With new players, verify discovery and operation of each control within a minute, held steering, truck-relative rear steering, stopped-only direction switching, service versus parking brake, H hints, and T repeat. Check physical timer/instrument readability from intended positions while others require sight or communication. Check license/emote restrictions and that subtitles grant no extra sight.

### Finished vehicle and persistence acceptance

- Integrate the entire asset inventory and review a successful test and every agreed serious-accident type with three humans. Fix distracting clipping, missing reactions, unreadable cues/card, intrusive repetition, and voice/examiner masking. Confirm radio/emotes/animation/damage and shared presentation work across peers and reset correctly.
- Verify installed Steam storage bindings and actual bounded payload latency; record local-commit, staging, and restoration outcomes separately. Test Cloud disabled, stale local and Steam copies, corrupt/unknown schema, quota/write failure, interrupted upload, prelaunch conflict choices, and stronger local records surviving weaker downloads.
- Use multiple real Steam accounts to test account switching on one computer, hosts/groups, receipt recovery, and development-record isolation. Use the owned app for published quota/access verification, clean second-computer restoration, and reinstallation both with retained local data and with genuinely absent local records. App-480 success or uninstall with data left behind is insufficient.
- For transfer evidence, finish synchronization on the source computer, inspect Steam sync state/logs, restore on the clean destination, compare expected license data, then revisit the source for convergence. Preserve test originals before loss/conflict experiments. Explicitly document cases with no surviving copy rather than inventing recovery.
- Final completion requires implemented behavior, integrated assets, recorded three-human acceptance/revisions, and owned-app Cloud verification. Planning status does not claim any of these checks have passed. Three-human participation and authorized Steamworks configuration are concrete external dependencies, not reasons to omit agent-led implementation or production.

## Out of Scope

- Additional vehicles, launch lineup, later campaign content, broader Steam release/distribution operations, and post-launch planning.
- Unrelated waiting-room redesign or polish; its monster-truck booking, license display, departure, and return integration remain in scope.
- Solo, two/four-player scaling, AI teammates, bots, shipping direct-IP transport, dedicated servers, and host migration.
- Preassigned monster-truck Driver/Spotter/Navigator roles, a monster-truck test sheet, universal instruments, or overhead sight.
- Separate manoeuvre licenses, procedural route generation, a practice mode preserving failed variants, extra hazard roster, mandatory stunt jumps, machinery puzzles, and forced out-of-truck test items.
- Teleport rescue, get-unstuck buttons, righting an overturned truck to continue, and driving the remaining route after guaranteed failure.
- Individual performance scoring, speed-based ratings, lost stamps on failure, and exact-trio license ownership.
- General-purpose metal deformation, initial gore, learner customization screens, more than three radio tracks, or premium audio-service access as an assumed prerequisite.
- Separate throwaway prototypes before specification/ticketing. Gameplay experiments belong to the actual implementation checkpoints.

## Further Notes

This specification synthesizes all sixteen resolved decision tickets. Later accepted answers supersede earlier discussion: personal licenses replace exact-trio ownership; the monster truck has no preassigned roles or test sheet; the full playable checkpoint includes decent generated assets; learner design is free within the accepted coverage; radio scope is three tracks; and multiplayer acceptance depends on the user's experience, not a latency threshold.

Older README prototype sections and the design judgment's historical undecided list still mention alternatives now resolved in this effort. Follow the accepted monster-truck decisions here for this vehicle; preserve the exactly-three-player and Steam-transport ADRs. Gameplay candidates remain revisable through the specified evidence, with no claim that conversation proved them.

Decision references:

- [01: Cooperation and truck](issues/01-cooperation-and-truck.md), [02: Continuous test](issues/02-test-structure.md), [03: Failure and scoring](issues/03-failure-and-scoring.md), [04: Replay](issues/04-replay-variation.md).
- [05: Finished experience](issues/05-finished-experience.md), [06: Cooperation checkpoint](issues/06-cooperation-playable-comparison.md), [07: Movement and recovery](issues/07-movement-and-recovery.md), [08: Waiting-room integration](issues/08-waiting-room-integration.md).
- [09: Route, hazards, and exact fault rules](issues/09-scrapyard-route-and-hazards.md), [10: Full-test checkpoint](issues/10-test-structure-playtest.md), [11: Results and retries](issues/11-results-and-retries.md), [12: Asset production](issues/12-presentation-assets-and-validation.md).
- [13: Guidance and information](issues/13-control-guidance-and-test-information.md), [14: License and transitions](issues/14-trio-license-and-transition-consistency.md), [15: Cloud support](issues/15-steam-cloud-license-support.md), [16: Multiplayer consistency](issues/16-truck-multiplayer-consistency.md).
- [Existing Steam Cloud research and configuration/validation handoff](research/steam-cloud-license-support.md) provides the previously gathered primary sources and version-specific adapter constraints. Runtime and owned-app verification remain implementation work.

No game code, assets, Steam configuration, or implementation tickets are produced by this specification. The existing wayfinder decision tickets retain their identities; subsequent implementation ticketing must distinguish them from executable work.

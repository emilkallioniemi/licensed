# Which route, manoeuvres, and moving hazards make the scrapyard test work?

Label: wayfinder:grilling
Type: grilling
Status: resolved
Parent: ../map.md
Blocked by: 01, 02, 03, 04

## Question

Define a concrete candidate route through the mountainside scrapyard for the roughly five-minute continuous test accepted in [What does a complete monster truck test look like?](02-test-structure.md). Which manoeuvres, connecting drives, and final parking item exercise blind spots, coordinated steering, and bounce, and how does difficulty progress?

Choose the minimum layout and dynamic hazard roster, including workers and operating machinery. For each hazard, establish what players can notice, how they can avoid it, and the spectacular physical consequence of getting it wrong. Distinguish required test items from hazards encountered while driving. Coordinate with the replay decision on what stays familiar and what changes; do not silently make every hazard random. Produce enough detail for the bounded format playtest, not final art or implementation.

Apply [When should a disastrous test end?](03-failure-and-scoring.md) when defining fault triggers: distinguish minor mistakes from dangerous accidents, specify how each required manoeuvre is completed, and avoid repeatedly counting one continuous mistake as unspecified extra faults. Decide these details here rather than leaving them to implementation.

Apply [What stays familiar and what changes on another attempt?](04-replay-variation.md): choose the concrete encounters and authored variations within its accepted initial content target. Specify perceptible cues, avoidance opportunities, and timing bounds that keep each variation fair. Preserve the fixed route and required manoeuvres; this ticket supplies the concrete content for the replay decision.

## Comments

- 2026-09-12: User gave the agent free hands on both the route/manoeuvres and moving hazards. The following resolves those decisions under that delegation; it does not claim user playtesting or proven gameplay quality.

## Answer

Resolved on 2026-09-12 under the user's explicit design delegation. This is the concrete candidate for specification and implementation, with dimensions, speeds, timings, and handling to be validated in three-human playtests.

### Fixed route and required test items

One continuous route climbs from the arrival yard to an upper terrace, crosses the ravine, reverses through a crusher-side dogleg, then descends to the finishing yard. No branching route or separate loading between items. Painted arrows, numbered manoeuvre signs, and the examiner identify the next item; no overhead route display. The examiner requests manoeuvres, without explaining hazard solutions. All five items must be completed in order. Crossing an out-of-order finish cannot pass the test.

The following time allocations include connecting driving and typical hazard waits, and total approximately five minutes. They are pacing budgets, not extra timers; the existing six-minute candidate timer starts on arrival.

| Section | Required manoeuvre and completion | Difficulty and consequence | Budget |
| --- | --- | --- | --- |
| Arrival yard | Board and pull forward through two offset gates between stacked wrecks; complete when the whole truck clears the second gate in the marked direction. | Wide recovery apron introduces front/rear coordination. Cones and loose panels make early errors visible without routinely ending the test. | 55 s |
| Scrap climb | Stop with all tyre contact points inside the marked hill-start box for two continuous seconds, then climb forward until the whole truck clears the crest marker. Parking brake is available but its use is not itself a scoring requirement. | Throttle/brake timing and straightening both axles matter; a flat runout below permits recovery from rollback. The exposed outer edge still leads to the ravine. | 55 s |
| Ravine bridge | Drive forward over a fixed, single-truck-width bridge; complete when the whole truck clears the far marker. | Enter straight, keep both axles aligned, and brake for the crane before committing. Bridge width starts at roughly 1.5 truck widths, with a flat approach and room to straighten. Rail contact is recoverable; breaking through and falling is catastrophic. | 50 s |
| Crusher terrace | Stop fully in the turnaround box, then reverse around an L-shaped bend into a marked refuge. Complete after all tyre contact points remain inside the refuge at rest for two seconds. Drive forward out through the marked exit afterward. | Reverse sight and rear-wheel placement matter. A yielding cone line separates the legal path from the crusher loading apron; crossed cones do not magically put the truck in the crusher. | 70 s |
| Descent and parking | Descend an uneven scrap lane, then reverse into a parallel bay between two fixed wrecks. Complete with the full truck footprint inside the bay, its length aligned within 15 degrees of the bay, at rest for two seconds, and parking brake engaged. | Bounce complicates braking and alignment. The parking yard has room for repeated corrections. Parking completes the test when all preceding items are complete and no failure has been guaranteed. | 70 s |

Stopping and retrying a manoeuvre is allowed while time remains. Failure to satisfy its completion rule leaves it incomplete, rather than adding faults every second. Brief wheel lift from bounce does not reset progress already earned; settle onto the ground to satisfy a stop box. Reverse travel outside the required reversing items is permitted for corrections. No fault merely for extra shunts, stopping to look, exchanging controls, or physically retrieving a learner.

Scale corners and parking spaces around the implemented truck, beginning with a parking bay about 1.6 truck lengths long and 1.4 truck widths wide. The crusher refuge and turnaround each accommodate the whole truck plus walking space. Keep usable boarding space at ordinary stopping areas. The route should make active rear steering valuable in moving turns and reversing; do not claim these dimensions prove that all three players are necessary. If two players can routinely leave one steering control untouched, revise the control/route candidate through the cooperation checkpoint.

### Three changing encounters

Use precisely these three varying encounters, each with two authored variants selected afresh each attempt and modest timing variation. A variant can repeat. Required manoeuvres, static layout, and hazard locations remain fixed. Each encounter has one active crossing per attempt; machinery continues visibly working outside the driving path afterward. No endless forced waiting or re-triggering while players correct or reverse.

| Encounter | Two authored variants | Notice and avoidance | Accident |
| --- | --- | --- | --- |
| Workers and scrap trolley, on the flat lane before the climb | A worker pushes a rattling trolley left-to-right; or pushes it right-to-left from the opposite marked work bay. | Both entrances are visible from the approach, with movement, footsteps, and trolley rattle before entering the lane. Stop on the flat apron or proceed once the crossing has cleared; no worker emerges from immediately behind the truck. | Hitting the worker throws them and spills the trolley; loose scrap can bounce into nearby wrecks. Hitting only the trolley spills scrap without automatically counting as a worker strike. |
| Crane and suspended wreck, before/over the bridge entrance | A car swings across the entrance left-to-right; or right-to-left, from fixed visible loading positions. | Crane motor, beacon, and visible load movement precede the sweep. The flat holding apron is outside the load's sweep; wait there, then cross after the car clears. The load never chases the truck. | Impact can spin the truck into a rail or fling the suspended wreck into scrap below. Falling, overturning, or a catastrophic learner impact guarantees failure; a survivable glance remains playable. |
| Forklift carrying a wreck, at the broad junction after the crusher refuge and before the descent | Forklift crosses forwards with its load; or reverses across from the opposite work bay with its reversing alarm. | Work-bay exits and the moving load are visible before the truck enters the junction; motor/alarm provides an additional cue. Stop on the terrace and let it pass. | Truck contact can tip the forklift or shed its wreck across the apron. A minor brush remains recoverable; toppling occupied machinery or striking its operator guarantees failure. |

For each encounter, start with four seconds of visible/audible preparation before entering the truck's lane, plus zero to two seconds of additional preparation selected for the attempt. Actual lane occupation lasts at most six seconds; once clear, it stays clear of another scripted crossing for the rest of the attempt. These are initial tuning values. A hazard may finish its crossing whether players stop or continue; it does not wait indefinitely for them to collide with it.

Place each approach cue far enough ahead that a truck at the intended approach speed can brake fully before the conflict, with at least two additional seconds for a player to notice and communicate. Measure this against actual handling in the playable build. If the truck reaches the conflict before an encounter has begun its preparation, defer the crossing until the entire truck and any learners on foot have cleared; never spawn an unavoidable hazard around them. Once preparation is perceptible, deliberately entering its announced crossing can cause an accident. Ordinary safe play must have a usable gap within the stated preparation/occupation bounds, without waiting for luck. Faster reckless approaches may outrun the available stopping distance.

Walking learners get the same physical cues and collision consequences; unoccupied controls do not pause machinery. Preserve physical rescue space on aprons. A crane sweep must not silently hit someone waiting on the safe side, and encounter cues must remain perceivable from at least one occupied control before the braking decision, without requiring a magical view for every player.

### Crusher and fixed surroundings

The crusher visibly operates beside the reversing bend throughout the test, compacting an unoccupied wreck on a fixed cycle. Its moving mechanism stays outside the legal route and refuge, so its phase cannot make a correct manoeuvre impossible. A substantial loading apron separates a minor boundary mistake from the crushing chamber. Entering the marked chamber while it is open remains physically possible; being caught and crushed is a serious fault with the accepted aftermath. No extra randomized crusher encounter, mandatory stunt jump, machinery button puzzle, or forced out-of-truck task is added.

Stacked wrecks, loose sheet metal, cones, the uneven descent, and weakened outer rails provide fixed physical consequences. Light props can scatter; major structures need not all be destructible. Within an attempt, displaced props and wreckage remain, with recovery by physical action where possible. An impossible rescue or blocked route uses the established concession flow; a new attempt restores the usable scrapyard.

### Fault rules

- One minor fault for a continuous cone/marker strike, boundary excursion, or recoverable contact with a wreck, rail, trolley, machinery, or its load. Merely entering a required parking/stop box inaccurately does not count unless it also violates one of those boundaries or contacts something.
- Count a cluster of contacts from one scrape or continuous impact chain once. A new contact fault requires at least two seconds clear of all contact; a new boundary fault requires returning fully inside the legal area first. Where the same impact also pushes the truck over a boundary, count that incident once, not once per sensor or prop.
- Hill-start rollback greater than half a tyre diameter after achieving the required stop is one minor fault per continuous rollback. A fresh rollback is countable only after forward travel resumes. A rollback below that distance is tolerated. It does not cancel the stop already demonstrated; players can still complete the climb.
- Missing an item or taking a wrong turn leaves progress incomplete. Going beyond a marked drivable boundary adds one minor fault per excursion if recoverable; there is no invisible failure wall. Do not award repeated faults merely for remaining outside it. There is no separate speeding penalty in this candidate: speed produces handling and collision consequences.
- A truck, driven load, or accident debris striking a worker is a serious fault. So are toppling occupied machinery, overturning onto the truck's side, falling into the ravine, and catastrophic crushing or other catastrophic learner accidents. Touching a worker harmlessly while walking is not a vehicle strike. Mere learner entrapment and harmless falls follow the accepted physical recovery rules.
- For a contact that itself causes a serious accident, record the serious fault instead of an extra minor for that same contact. If an initially recoverable incident later cascades into catastrophe, retain its history but guarantee failure when the catastrophe occurs. No amount of subsequent recovery can reverse guaranteed failure.
- Hazard avoidance is scored through these contact and accident rules, without an additional invisible right-of-way penalty. Incidental bumps, bounce, roof riding, and emotes alone are not faults.
- All required items complete before timer zero and no serious fault means pass, with minor faults determining rating. Completion at or after zero fails. Serious fault or timer expiry follows the established aftermath and examiner-response policy, including when catastrophe occurs during the final parking hold.

### Implementation validation and handoff

[How will the complete playable test validate pacing and replay?](10-test-structure-playtest.md) uses this route as its minimum integrated content. Verify each completion rule with an untidy but valid manoeuvre, each recoverable error without accidental failure, contact-chain deduplication, missed/out-of-order items, and each serious accident. Exercise both variants of all three encounters and the latest activation timing. Measure stopping opportunities with actual controls and ordinary network conditions; lengthen cue distance or preparation if observation and communication cannot prevent a collision.

Use repeated three-human attempts to tune the five-minute pace, six-minute timer, dimensions, and timing windows. Check whether the hill start gives throttle/brake satisfying work, reversing and bridge alignment involve both steering operators, and bounce adds recoverable trouble. Compare experienced attempts: if a hazard can be handled by memorized timing without looking, revise its variants within the accepted roster; if it regularly causes unavoidable failure, revise cues, geometry, and activation. These are future checks, not completed evidence.

The existing pacing/replay and asset-production decisions cover the resulting follow-up work; no new decision ticket is needed from this resolution. This session produced planning only, with no prototype, game code, or final assets.

# How will the complete playable test validate pacing and replay?

Label: wayfinder:grilling
Type: grilling
Status: resolved
Parent: ../map.md
Blocked by: 03, 04, 06, 09

## Question

Define the implementation checkpoint and evaluation plan for the complete playable test: minimum integrated content, three-human playtest procedure, and criteria for retaining or revising pacing, failure timing, ratings, and hazard variation. Resolve this planning ticket from the agreed plan. The observations described below are gathered during the actual build after `/to-spec` and `/to-tickets`; they are not a separate throwaway-prototype prerequisite for specification. Gameplay conclusions remain provisional until that evidence exists.

Build a complete playable route using the accepted cooperation candidate and the route-and-hazard decision, with decent Blender-generated models and generated audio as clarified in the answer. With exactly three humans, test the continuous examiner-directed format, scored connecting driving, dynamic workers and machinery, and parking finish. Use the settled failure rules; this experiment does not decide failure timing by accident.

Observe initial and familiarised attempts, rotating players through controls. Does a successful attempt take roughly five minutes, does every player stay involved, and is driving between manoeuvres entertaining? Can players perceive and avoid moving hazards through cooperation, or do collisions feel unavoidable? Include a controlled comparison of a troublesome section with its moving hazard inactive if needed to distinguish route problems from hazard problems.

Record player reactions, approximate successful-attempt duration, inactive stretches, and avoidability problems. Adjust route, pacing, or hazards one at a time and compare where observations warrant it. Record whether to retain or revise the candidate; do not claim success from agent-only testing. Link the playable implementation checkpoint and document temporary scaffolding. This is an iteration within the complete vehicle build.

Also validate [When should a disastrous test end?](03-failure-and-scoring.md) across repeated attempts: do players have enough time to enjoy the accident, want to restart after failure, and want to improve a passing rating? Compare shorter and longer aftermath windows if timing feels wrong. Tune the candidate timer and rating thresholds from observed attempts. Record reactions and a retain-or-revise conclusion; do not silently switch to continuing an already failed test.

Also validate [What stays familiar and what changes on another attempt?](04-replay-variation.md) with experienced players over repeated attempts. Does route familiarity support improvement while the accepted hazard variations still require looking and communication? Record whether the initial amount of variation is enough and whether players can notice and avoid each variation. Retain or revise the candidate from observed play; do not claim that variation itself proves three-player necessity.

## Comments

- 2026-09-12: User corrected the proposed rough-geometry presentation: Astra will generate decent models using Blender and generate audio. User accepted the proposed repeated-play procedure and delegated revision priorities to the agent.
- 2026-09-12: User explained that they have observed Astra easily producing models and audio, so including them early makes sense. The intent is affordable early presentation, not requiring all final polish before gameplay can be evaluated.

## Answer

Resolved on 2026-09-12 from the user's presentation correction, accepted playtest procedure, and delegated tuning judgment. This resolves the implementation evaluation plan, not gameplay validation.

- Integrate arrival and boarding, all five ordered manoeuvres and connecting driving, both authored variants of each of the three changing encounters, scoring and timer, physical recovery, accident aftermath and examiner response, results, and a working reset/retry. Use the accepted cooperation candidate and existing completion and fault rules.
- Include decent models generated through Blender by Astra and generated audio in this complete playable checkpoint. A box-only route and placeholder-only audio are not its presentation target. Assets remain revisable when driving, sight, hazard cues, or timing change; complete final animation and presentation coverage is specified by [Which presentation assets and checks are required to finish the monster truck?](12-presentation-assets-and-validation.md). That ticket must identify actual tooling and integration dependencies; this decision does not claim those capabilities have been verified or assets produced.
- Begin with exactly three humans: three familiarisation attempts, rotating so everyone operates every control, followed by at least three familiar attempts. Extend the session if there is no successful completion or some hazard variants remain unobserved. Use controlled variant selection for missing coverage when necessary, identifying it as test scaffolding; normal retries retain fresh variant selection. After revisions, use a fresh trio to check learning. These are starting observation counts, not statistical proof or an automatic pass gate.
- Record the build and settings, control assignments, hazard variants, attempt outcomes, approximate total and section durations, inactive stretches, confusing or apparently unavoidable collisions, player reactions to the aftermath, and desire to retry or improve a passing rating. Observe familiar players looking and communicating rather than merely reciting memorized hazard timing.
- Under delegated judgment, prioritize enjoyable coordinated driving and avoidable hazards over hitting exactly five minutes. Fix dull connecting drives, frustrating manoeuvres, and cue/avoidance problems before tuning the six-minute candidate timer. Compare one relevant change at a time; temporarily disable a troublesome moving hazard to distinguish route trouble from encounter trouble if needed. Preserve all three players' involvement and refer optional-control or two-player shortcuts back to the cooperation checkpoint.
- Keep serious faults guaranteeing failure, followed by the physical aftermath and examiner response. Compare shorter or longer aftermath windows if results interrupt the accident or players wait after the interesting action has ended. Retain minor-fault-only passing ratings and best-rating preservation; tune candidate thresholds if improvement feels unrewarding. Do not add speed-based ratings or extend an already failed attempt through the remaining route.
- Retain the pacing and replay candidates only when observed play supports them: successful attempts are reasonably near the five-minute target without cutting enjoyable sections for stopwatch compliance; each player contributes; hazard cues permit notice, communication, and avoidance; familiarity supports improvement while variants still require attention; aftermath lands before results without needless waiting. Record a retain-or-revise conclusion and its evidence for each area. Absence of successful or sufficiently varied attempts requires further observation or revision, not a validation claim.
- Gather this evidence during the actual build after specification and implementation ticketing. This session creates no game assets or implementation and does not require a separate throwaway prototype. No new decision ticket is needed; presentation production details remain with the existing asset-planning ticket.

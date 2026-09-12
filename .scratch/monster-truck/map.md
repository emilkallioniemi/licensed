# Map: a complete monster truck vehicle

Label: wayfinder:map
Charted: 2026-09-12

## Destination

A buildable specification for one complete monster truck vehicle: its cooperative driving, full test experience, failure and success, replay, and finished presentation from leaving the waiting room to returning. Smaller playable checkpoints support iteration within this scope. This map finds the decisions; `/to-spec` produces the specification afterward, followed by `/to-tickets`.

## Notes

- Consult `grilling` and `domain-modeling` for conversation tickets and `prototype` for questions requiring playable evidence. Read `docs/design.md` before player-facing design and record steering in `docs/corrections.md`.
- Use `CONTEXT.md` vocabulary: vehicle, test, test item, role split, examiner, license. The test-structure decision retains its one-test-per-vehicle relationship.
- This is planning, not implementation. Work at most one non-research decision ticket per session. Define gameplay experiments as implementation checkpoints within the full specification.
- Build the actual complete vehicle through playable checkpoints after `/to-spec` and `/to-tickets`; separate throwaway gameplay prototypes are not prerequisites for finishing this map. Plan experiments and revision criteria here, then gather three-human evidence during implementation. Unvalidated gameplay candidates must remain identified as such.
- Asset production is part of the implementation scope: the scrapyard environment, truck, learners, examiner, workers, rigs and animations, emotes, effects, sound, and music need explicit deliverables and completion checks. The agent is expected to do substantial production and integration work, with tooling and any human dependencies identified during asset planning.
- The complete playable test checkpoint includes decent Blender models produced by Astra and generated audio, as clarified in the pacing/replay decision; do not interpret earlier rough-presentation guidance as a requirement to keep this checkpoint box-only. Assets remain open to gameplay-driven revision.
- The waiting room is the existing foundation. Its integration with the completed test is in scope; unrelated waiting-room improvements are not.
- Steam Cloud configuration and verification required for personal licenses are in scope; broader Steam release operations remain outside this effort.
- Factual research linked from the cooperation decision grounds the candidate in real truck controls; it does not establish gameplay quality.

### Agreed while charting

- Target one complete vehicle, including presentation, rather than limiting the effort to a one-item demo. Iterate through playable checkpoints.
- Exactly three players must remain necessary; communication and chaos are central.
- The candidate Driver, Spotter, Navigator split may be completely replaced.
- Difficulties must express the monster truck specifically. Future vehicles should have their own difficulties, but designing them is outside this map.
- Shocking fictional accidents, including hitting a pedestrian, belong in the intended comedy. Tone: exaggerated physical comedy with a dry examiner response.
- Repetition should combine learnable situations with changing hazards or instructions. No procedural-generation implementation is implied.

## Decisions so far

- [What makes the monster truck require three players?](issues/01-cooperation-and-truck.md): Test three freely swappable physical controls, sight from the learner's position, and free movement with deliberate parking; enjoyment and three-player necessity remain to be demonstrated.
- [What does a complete monster truck test look like?](issues/02-test-structure.md): One continuous examiner-directed scrapyard test with dynamic hazards and a five-minute successful-attempt target, pending playable validation.

- [When should a disastrous test end?](issues/03-failure-and-scoring.md): End failures after the aftermath; minor faults grade passes, with best ratings retained; timer and rating bands await playtesting.
- [What stays familiar and what changes on another attempt?](issues/04-replay-variation.md): Fixed route and manoeuvres, fresh authored hazard variation, and a reset scrapyard each attempt; initial variation scope awaits repeated play.
- [What presentation makes the monster truck feel complete?](issues/05-finished-experience.md): Chunky stylised slapstick, a physical examiner, rich sound with a shared radio, five emotes, and results over the aftermath; rough gameplay validation precedes finished presentation.

- [How do players recover after leaving or overturning the truck?](issues/07-movement-and-recovery.md): Recover harmless falls and trapped learners physically with the timer running; catastrophic accidents fail, and impossible rescues can end in concession.

- [How does the monster truck connect to the waiting room without preassigned roles?](issues/08-waiting-room-integration.md): Book without roles, arrive beside the secured truck with the timer running, and use E to occupy or leave controls with contextual guidance.

- [Which route, manoeuvres, and moving hazards make the scrapyard test work?](issues/09-scrapyard-route-and-hazards.md): Five ordered scrapyard manoeuvres with worker, crane, and forklift variations; completion, faults, and reaction windows specified as playtest candidates.

- [How are results, best ratings, and retries shared?](issues/11-results-and-retries.md): Shared results award personal licenses retained across groups; unanimous choices govern retry, return, and concession, with earned records preserved on departure.

- [How are personal licenses saved and test transitions kept consistent?](issues/14-trio-license-and-transition-consistency.md): Steam-account licenses use local saving and Cloud backup; results settle at completion, surviving receipts recover interrupted awards, and choices expire with the attempt or membership.

- [What Steam Cloud setup and reconciliation support personal licenses?](issues/15-steam-cloud-license-support.md): Recommend explicit RemoteStorage plus independent account-scoped local records; preserve surviving progress, with owned-app setup and restoration checks required during implementation.

- [How will the first playable build validate three-player cooperation?](issues/06-cooperation-playable-comparison.md): Hold-angle steering and a three-position cab tested through boarding, turning, reversing, and roof access; three-human evaluation during implementation must expose optional controls or two-player shortcuts.

- [How will the complete playable test validate pacing and replay?](issues/10-test-structure-playtest.md): Test the full attempt with decent Blender models and generated audio, repeated three-human play, and a fresh trio after revisions; prioritize enjoyable coordination and fair hazards when tuning pacing.

- [Which presentation assets and checks are required to finish the monster truck?](issues/12-presentation-assets-and-validation.md): Astra may freely redesign the learner; agent-led production covers models, animation, authored destruction, three radio tracks, generated audio, and integrated three-human presentation checks.

- [How do players learn the controls and see test information under pressure?](issues/13-control-guidance-and-test-information.md): Physical timer and instruments, contextual keyboard guidance, no test sheet, and repeatable subtitled examiner requests; learning and sight-sharing await three-human validation.

- [How will moving learners and shared truck controls stay consistent in multiplayer?](issues/16-truck-multiplayer-consistency.md): Host-owned shared physics with responsive local prediction, exclusive physical handovers, and bounded stale-input recovery; early three-human Steam testing must satisfy the user's standard for feel.

## Not yet specified

None before specification. Questions revealed by the planned implementation checkpoints are revision triggers owned by their decision tickets; they do not require separate experiments before specification.

## Out of scope

- Additional vehicles, launch lineup, Steam release operations, and post-launch plans: this effort completes the first vehicle.
- Unrelated waiting-room redesign or polish.

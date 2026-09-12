# Corrections log

Raw material for `docs/design.md`. One line per time an agent or a person was steered on tone, control feel, role split, scope, or a screen. Write each as something observable ("examiner line had an exclamation mark", not "examiner felt too keen"). A correction that repeats gets promoted; see "How this file grows" in `docs/design.md`.

Format: `- YYYY-MM-DD | area | what was corrected → what it should have been`

Areas: `examiner`, `controls`, `split`, `sight`, `sheet`, `scope`, `ui`, `scoring`, `other`.

## Log

- 2026-09-12 | controls | The fifth emote is "67": alternate both palms up and down with a short "six seven" vocal line once per selection.

- 2026-09-12 | controls | Use a "67" emote as the fifth gesture instead of thumbs-up or double facepalm; exact motion and sound remain to clarify.
- 2026-09-12 | other | Monster-truck sound combines a powerful engine with rattles, suspension creaks, tyre scrub, cabin clatter, and material-specific impacts, leaving room for player conversation.
- 2026-09-12 | ui | Present the shared result through a short examiner assessment and marked test sheet over the aftermath, with the wreck still visible.
- 2026-09-12 | scope | First playable presentation uses rough shapes, readable hazards, collision and engine sounds, and temporary examiner speech; finished art, detailed sound, radio, gestures, and examiner animation follow gameplay validation.

- 2026-09-12 | controls | Radio access follows physical reach in the truck; players can ask someone nearby to operate it or leave their control and walk over, rather than requiring access from every driving position.
- 2026-09-12 | other | Begin radio music with calming easy listening, heavy rock, and upbeat dance; dip music beneath examiner comments and player voice while retaining audible vehicle and hazard sounds.
- 2026-09-12 | controls | The fifth emote should be goofier than a thumbs-up; its replacement remains to be chosen.
- 2026-09-12 | controls | Disable emotes while operating a driving control; use a held-key five-choice wheel and show the player's own gesturing hands in first person.

- 2026-09-12 | other | Monster-truck presentation uses chunky stylised 3D, expressive people, readable silhouettes, oversized machinery, and a battered working scrapyard.
- 2026-09-12 | other | Monster-truck accidents start with violent ragdoll slapstick, flying objects, dust, and crumpled wrecks without gore.
- 2026-09-12 | examiner | Seat the examiner physically in the monster truck so players can see him brace and clutch his clipboard; reserve puking and muttered swearing for occasional violent-driving reactions.
- 2026-09-12 | other | Test audio should include a player-operated vehicle radio with on/off and next-track controls, offering calming and hard music; sound is a major part of the finished experience.
- 2026-09-12 | controls | Expand monster-truck emotes to wave, clap, point, and both middle fingers, with a possible fifth gesture still to choose.

- 2026-09-12 | other | Monster-truck test follows examiner directions through the scrapyard, with scored driving between manoeuvres and parking to finish.
- 2026-09-12 | other | Include social emotes such as clapping and giving the middle finger in complete-vehicle presentation planning; their controls and final set remain open.
- 2026-09-12 | examiner | Dry spoken assessment can coexist with physical distress from terrible driving, including bracing and puking, plus occasional muttered swearing; do not turn the examiner into a constant shouter.

- 2026-09-12 | other | The monster-truck mountainside scrapyard must include dynamic activity such as workers, so hazards arise from an operating workplace as well as its terrain and wrecks.

- 2026-09-12 | other | Ordinary streets adjoining the test centre felt too realistic and generic → give each vehicle a fitting, distinctive environment where holding a driving test is absurd and mistakes can cause spectacular physical accidents.
- 2026-09-12 | scope | Start monster-truck successful-attempt playtesting at about five minutes; distinguish this pacing target from the timer limit.

- 2026-09-12 | scope | Monster-truck format is one continuous test combining driving and several manoeuvres with one shared result, rather than several separately passed smaller tests; duration remains undecided.

- 2026-09-12 | split | Front steering / rear steering / throttle-and-brake is accepted as a candidate for three-human playtesting, not a proven split; revise it if a responsibility is dull, two players can do the work, or free movement trivialises blind spots.

- 2026-09-12 | sight | Monster-truck sight follows the learner's physical position, with blind spots from windows, bodywork, and height; no permanently assigned view or magical overhead camera.
- 2026-09-12 | controls | Add a parking brake beside the monster-truck throttle/brake control that remains engaged when unattended so all three players can leave a secured truck.

- 2026-09-12 | split | Monster-truck roles are not preassigned: players physically take over available controls, one operator per control, and may trade places during the test.
- 2026-09-12 | controls | Unattended monster-truck steering retains its setting while throttle and service brake release; getting up does not stop the truck automatically.

- 2026-09-12 | split | Players may leave monster-truck controls at any time, including while moving; pre-test role locking is reopened so players could swap places during the test to suit their strengths.

- 2026-09-12 | split | Everyone riding in the monster truck must not imply permanently fixed players; allow shared physical moments such as climbing onto the roof to inspect an accident, with movement timing still to decide.

- 2026-09-12 | split | Requiring every player to hold a physical control should depend on the vehicle; preserve distinct roles and make the fun available to every player.
- 2026-09-12 | controls | Monster-truck difficulty should centre on blind spots and coordinated steering, with bouncing amplifying mistakes.

- 2026-09-12 | split | Existing Driver, Spotter, and Navigator roles are fully replaceable; design the monster truck's cooperation without preserving the candidate split by default.
- 2026-09-12 | scoring | Immediate serious-fault termination is reopened: compare letting the aftermath unfold and ending the attempt with letting players finish and receiving an overall pass or fail.
- 2026-09-12 | other | Accident tone is exaggerated physical comedy with a dry examiner response; test repetition should combine learnable situations with changing hazards or instructions, while one full test versus multiple smaller tests remains open.

- 2026-09-12 | scope | Complete monster truck planning includes finished presentation as well as gameplay; focus this effort on the first vehicle and leave the launch lineup outside it.
- 2026-09-12 | other | Monster truck gameplay should allow shocking fictional accidents such as running over a pedestrian, require all three players to cooperate, and derive its difficulties from the vehicle rather than repeating the same experience across vehicles.

- 2026-09-12 | scope | Monster truck planning was narrowed to a one-item demo slice → target one complete vehicle and its full test, using smaller playable checkpoints to learn and iterate within that scope.

- 2026-09-12 | controls | Lobby movement was walking only → allow holding Shift to sprint and pressing Space to jump while waiting.

- 2026-09-12 | controls | Smooth walking and remote movement and reduce unnecessary screen redraws while preserving the room's visual quality.

- 2026-09-12 | ui | Start the game in fullscreen mode.

- 2026-09-12 | ui | Waiting-room model lacked a visible role-choice area → place Driver, Spotter, Navigator, and Random controls beside vehicle booking, with separate meshes for future interaction.

- 2026-09-12 | scope | Create a customizable placeholder player and main-menu song as standalone assets; leave existing game scenes and menu integration untouched.
- 2026-09-12 | scope | Waiting-room work is limited to the visual environment and models, including a terminal screen for future friends and invites; Steam, multiplayer, voice, and lobby logic are separate implementation work.
- 2026-09-12 | other | Waiting-room map used "license" for one vehicle's test ("pick the license you want to sit") → "vehicle" is the level, "license" is the shared card of stamps; the board books a vehicle.
- 2026-09-12 | ui | Waiting-room map planned a greybox room and capsule learner → the kit in `assets/` (room, learner, loop) already exists; tickets build on it and send change requests to Astra instead.
- 2026-09-12 | scope | Agent started building a walkable prototype of the waiting room to answer ticket 04 → the room model exists; decide controller, camera, identity, and interaction grammar in conversation and let the first build check the feel.
- 2026-09-12 | ui | Voice ticket recommended open mic only and deferred "any settings screen" → mic mode (open mic / push-to-talk) and mute are player settings; they live in an Escape overlay that is also the game's only quit.
- 2026-09-12 | other | Voice ticket recommended positional voice with no distance falloff → a little quieter with distance is wanted, as long as nobody in the room is ever hard to hear.
- 2026-09-12 | scope | Voice ticket recommended voice off under the dev transport → keep it on everywhere; the self-echo from three instances on one mic is the proof it works, and mute is the escape.
- 2026-09-12 | ui | Walkthrough ticket recommended one fixed room camera, then third-person orbit → each player has their own first-person camera and can walk around and investigate the room.
- 2026-09-12 | scope | Reception desk ticket recommended no way to leave a friend's room short of quitting to desktop → a player can always leave the room they are in and be back in a room of their own.
- 2026-09-12 | other | A friend dropping mid-room had no decided read → they vanish where they stood and the entrance door sounds once; the reverse door theatre is only for a deliberate Leave, because a drop is not a walk out.
- 2026-09-12 | ui | Reception Invite and Join appeared inert during friend updates → refreshing Steam status must not replace a button between mouse-down and mouse-up or continually request another refresh.
- 2026-09-12 | ui | Looking down showed a stuttering body while walking or running → hide the player's own body locally; the other players still see their full learner.
- 2026-09-12 | other | Monster-truck serious-accident timing: guarantee failure, let the physical aftermath and examiner response play out, then end the test; use this as the first candidate for playtesting.
- 2026-09-12 | other | Monster-truck scoring should support earning the license despite minor faults and replaying for a better performance rating; exact ratings and any minor-fault failure threshold remain undecided.
- 2026-09-12 | other | Start monster-truck timer testing at six minutes; zero guarantees failure, but an unfolding crash finishes before the test ends.
- 2026-09-12 | other | Completing every required monster-truck manoeuvre within the timer without a serious fault always passes; minor faults lower the rating and never cause failure.
- 2026-09-12 | other | Rate monster-truck passes by minor faults only; finishing faster gives no rating bonus. Preserve the earned stamp and best rating across worse retries, and show the latest attempt for comparison.
- 2026-09-12 | tone | Monster-truck passing ratings may use mildly funny names; start with three bands at 4+, 1-3, and zero minor faults.
- 2026-09-12 | other | A monster-truck cone clip is a minor fault; reserve serious faults for dangerous accidents such as hitting a worker or driving into the ravine.
- 2026-09-12 | other | Monster-truck retries initially retain the route and required manoeuvres, vary familiar hazards through timing and a few authored variations with time to react, and reset the scrapyard; physical consequences persist within an attempt.
- 2026-09-12 | scope | Draw fresh monster-truck hazard variation each attempt; initially vary three encounters with two authored variations each and modest timing changes, keep the rest consistent, and validate continued communication through repeated play.
- 2026-09-12 | feel | Monster-truck controls should be non-realistic, a little difficult, and still fun; judge handling by enjoyable coordination and recoverable mistakes rather than simulation fidelity.
- 2026-09-12 | scope | Build toward the actual complete monster truck through playable implementation checkpoints; do not make separate throwaway prototypes a planning prerequisite. Include substantial agent-assisted environment, vehicle, people, emote, animation, and audio production in the spec and implementation tickets.
- 2026-09-12 | other | Overturning the monster truck or a catastrophic learner accident guarantees shared failure after the aftermath and examiner response; harmless tumbles remain recoverable. Falling off versus staying attached to the roof remains undecided.
- 2026-09-12 | feel | Give learners secure footing during ordinary monster-truck driving, but allow sharp turns, big bumps, collisions, and stepping over the edge to throw them off; recover harmless falls by physically reboarding with the timer running.
- 2026-09-12 | feel | No teleport or get-unstuck action for trapped learners: players must physically free them, for example by moving the monster truck, making recovery a shared problem under time pressure.
- 2026-09-12 | other | Allow the group to concede a failed monster-truck attempt and retry when physical rescue proves impossible; only physical rescue continues the current test. Concession agreement and retry flow belong to the results decision.
- 2026-09-12 | feel | Arrive beside the parked monster truck with its parking brake engaged and examiner already seated; keep the walk short and let learners physically climb aboard and approach their chosen controls.
- 2026-09-12 | screen | Hide monster-truck role selection and show "Choose your controls in the truck"; retain three matching picks, three seated learners, and the existing departure sequence.
- 2026-09-12 | feel | Start the monster-truck timer immediately on arrival so boarding happens under pressure; do not wait for all three controls to be occupied.
- 2026-09-12 | control | Give the monster truck three physical interaction spots: pressing E seats the learner at that control and reveals its controls, following the waiting-room interaction pattern.
- 2026-09-12 | control | Release-key choice delegated: use E again to leave a monster-truck control, including while moving, preserving physical handovers.
- 2026-09-12 | screen | Explain occupied monster-truck controls with subtle highlighting on visible physical controls and small UI hints for unseen controls such as pedals.
- 2026-09-12 | scope | Route/manoeuvre and moving-hazard design delegated to the agent for the monster-truck map; choose concrete completion rules, fault triggers, and avoidable hazard variations as candidates for implementation playtests.
- 2026-09-12 | screen | Results require three matching Retry or Waiting room choices, changeable while waiting; anyone can propose concession through Escape, but all three must agree while the timer continues before shared failure opens results.
- 2026-09-12 | screen | Retry directly beside the reset, parked monster truck with the examiner seated and timer starting immediately; replace host-only immediate return with concession, and abandon unfinished tests on departure without losing earned records.
- 2026-09-12 | other | License ownership should follow the friends who earned it together; explore a license per exact trio rather than defaulting to a host-owned record.
- 2026-09-12 | other | Keep one saved license per exact trio regardless of host; changing a friend selects a separate license, and reuniting restores that trio's stamps and best ratings.
- 2026-09-12 | screen | Reopen exact-trio license ownership: explore personal earned licenses retained across friend groups, visible ownership among current players, and a physical license each learner can hold up to show off.
- 2026-09-12 | screen | Confirm personal licenses across friend groups: a shared pass awards all three the same stamp and attempt rating, preserving each player's best; hold up a portrait/stamp/rating card, and show current players' stamp ownership side by side on the booking board.
- 2026-09-12 | other | Personal licenses follow the player's Steam account across computers and reinstallations through local saving with Steam Cloud backup; local saving must work independently.
- 2026-09-12 | control | Test gradual, quick-response axle steering that holds its angle on input release and requires deliberate unwinding; keep the monster truck arcade rather than realistic.
- 2026-09-12 | control | Test front steering on the left, throttle/brake on the right, and rear steering behind facing backward, with free looking, bodywork blind spots, and a climbable roof.
- 2026-09-12 | scope | The first actual vehicle checkpoint covers boarding, moving turns, tight reversing, and parking for roof access with rough geometry, timer, and placeholder examiner audio; three-human control rotations and two-active-player attempts determine whether the candidate needs revision.
- 2026-09-12 | presentation | Include decent Astra-produced Blender models and generated audio in the complete playable test checkpoint: the user has observed that production is easy, so use it early while keeping assets revisable as gameplay changes.
- 2026-09-13 | presentation | Use one expressive learner body and rig with three clothing colours and matching license portraits; a hands-free license toggle puts the card away on taking a control or starting an emote.
- 2026-09-13 | presentation | Limit examiner distress to one puke and two muttered swears per attempt, at least 30 seconds apart, with scored comments taking priority; brace for hard jolts and tune triggers through play.
- 2026-09-13 | presentation | Produce three radio tracks, one per agreed style; provide three comment alternatives per fault category, plus arrival, five manoeuvre requests, pass, fail, timeout, and concession coverage.
- 2026-09-13 | presentation | Give Astra free hands to design the learner without preserving its current appearance or proportions; retain the agreed bounded variety and interaction coverage.
- 2026-09-13 | presentation | Use authored damaged shapes, detachable parts, ragdolls, flying props, dust, sparks, and puke for readable accident aftermath; accept generated audio without demanding exceptional fidelity.
- 2026-09-13 | presentation | Finish presentation only after the asset set is integrated and three-human review covers success and every serious-accident type, readable hazards, hands/gestures/license, aftermath, and intelligible sound together.
- 2026-09-13 | screen | Place the monster-truck timer physically beside throttle/brake; other learners need sight of it or a spoken time call.
- 2026-09-13 | control | Remove the monster-truck test sheet; convey manoeuvre requests through the examiner and route locations through physical signs and markings.
- 2026-09-13 | control | Show brief binding labels when occupying a control and make them available again; request the first destination immediately and keep the timer running through learning without examiner driving advice.
- 2026-09-13 | control | Use A/D steering, W throttle, S service brake, stopped-only R forward/reverse selection, and Space parking-brake toggle at throttle/brake; E alone leaves the occupied control.
- 2026-09-13 | screen | Show steering angle, forward/reverse selection, and parking-brake state on physical instruments beside their controls, requiring sight or communication from other learners.
- 2026-09-13 | examiner | Subtitle spoken examiner lines and allow repeating the current manoeuvre request without additional advice or stopping the timer.
- 2026-09-13 | control | Keep A/D relative to the truck's left/right for both axles regardless of learner sight or reverse travel, with physical axle-angle pointers showing the setting.
- 2026-09-13 | control | Use H to redisplay occupied-control hints, T to repeat the current manoeuvre without stacking requests or interrupting faults, L for the hands-free license toggle, and hold B/release for the hands-free emote wheel.
- 2026-09-13 | scope | Validate control discovery and operation within a minute with three new players, missed-instruction recovery, readable instruments, correct handover hints, and sight-dependent information sharing during implementation; revise confusing bindings or presentation.
- 2026-09-13 | feel | Multiplayer walking, driving, boarding, and handovers must feel responsive and very good to the user; passing a numerical latency target does not establish acceptable feel, and frequent snaps or apparently unjustified falls require revision.
- 2026-09-13 | control | Under delegated networking judgment, absorb brief jitter, neutralize stale held input without pausing the test, retain steering angle and parking-brake state, and use the agreed departure flow when the connection is lost.

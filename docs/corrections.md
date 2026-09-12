# Corrections log

Raw material for `docs/design.md`. One line per time an agent or a person was steered on tone, control feel, role split, scope, or a screen. Write each as something observable ("examiner line had an exclamation mark", not "examiner felt too keen"). A correction that repeats gets promoted; see "How this file grows" in `docs/design.md`.

Format: `- YYYY-MM-DD | area | what was corrected → what it should have been`

Areas: `examiner`, `controls`, `split`, `sight`, `sheet`, `scope`, `ui`, `scoring`, `other`.

## Log

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

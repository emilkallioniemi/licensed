# Corrections log

Raw material for `docs/design.md`. One line per time an agent or a person was steered on tone, control feel, role split, scope, or a screen. Write each as something observable ("examiner line had an exclamation mark", not "examiner felt too keen"). A correction that repeats gets promoted; see "How this file grows" in `docs/design.md`.

Format: `- YYYY-MM-DD | area | what was corrected → what it should have been`

Areas: `examiner`, `controls`, `split`, `sight`, `sheet`, `scope`, `ui`, `scoring`, `other`.

## Log

- 2026-09-12 | ui | Waiting-room model lacked a visible role-choice area → place Driver, Spotter, Navigator, and Random controls beside vehicle booking, with separate meshes for future interaction.

- 2026-09-12 | scope | Create a customizable placeholder player and main-menu song as standalone assets; leave existing game scenes and menu integration untouched.
- 2026-09-12 | scope | Waiting-room work is limited to the visual environment and models, including a terminal screen for future friends and invites; Steam, multiplayer, voice, and lobby logic are separate implementation work.

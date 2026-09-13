# 08a: Set the playtest in a static scrapyard

Status: done
Blocked by: 07, 08
Parent: [A complete monster truck vehicle](../../monster-truck/spec.md)

## What to build

Create a rich, fully static scrapyard environment around the existing cooperation exercise before the Windows/macOS playtest release. The user explicitly authorized this scoped art pass before checkpoint 06, without advancing ticket 09 gameplay or the later route.

## Acceptance criteria

- [x] Produce original revisable Blender sources/generator and Godot assets for wreck stacks, scrap piles/panels, containers, fencing, workshop and surrounding industrial skyline, with ground detail and cohesive lighting matching the modeled truck/learners/lobby.
- [x] Integrate scenery into the actual arrival and driving area; retain the current exercise, timer, controls and provisional handling. No new manoeuvres, scoring, interactions, moving machinery or hazards.
- [x] Keep clear driving, boarding, walking and rescue space. Solid reachable scenery has appropriate static collision; preserve existing gate/parking/bump collision footprints when dressing their placeholders. Avoid accidental traps and misleading route cues.
- [x] Verify actual arrival, ground/roof/cab views, instrument sight and scene performance. Check three-peer boarding/driving/recovery and fresh-session retry after integration; record agent evidence without claiming human Steam acceptance.
- [x] Keep assets reusable for later route tickets and record ownership/limitations; update relevant index and corrections log. Complete both review axes before root commits.

## Comments

- 2026-09-13 user approval: add the scrapyard environment, fully static, before bundling and GitHub release. Accepted scope includes appropriate collision only; no ticket 09 manoeuvre/scoring work. Existing checkpoint 06 human gate remains pending.
- Fixed ticket base: `ff83f5d57e8352c66c2be5bd8b4abf1472038c20`. Leave implementation uncommitted for orchestrator; one ticket, one commit.

- 2026-09-13 root acceptance verification: original editable static kit integrated; actual1280x720/MSAA4 arrival/cab/roof views approved; preserved exercise colliders, solid exterior ground/props verified through three-peer queries and actual capsule movement. Eleven suites and final native network/failure/ready runs passed. All27manifest hashes independently match workspace/native copy. See ../08a-evidence.md.

- Final Standards and Spec review axes: zero outstanding findings.

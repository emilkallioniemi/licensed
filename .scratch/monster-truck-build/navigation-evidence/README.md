# Navigation track verification — 2026-10-08

All prior branch work was consolidated and pushed to `main` at `6493781` before gameplay edits. The waiting-room branch exactly matched the tree at `7709c8d`, already included in main; its history was merged without replacing newer contents. Three research branches were merged normally. All three external research worktrees are clean. Gameplay work uses `codex/navigation-survival-track`.

## Passed checks

Godot 4.7.2 on Windows:

- Existing attempt, driving, motion, room state, reception, ready-up, recovery, boarding, truck presentation and learner animation checks.
- Navigation/swap checks replace the balance test, including immutable occupancy generations, delayed consent and no navigator driving authority.
- Survival attempt checks cover all eight layouts, ordered intact crossings, no skipped finish, retained progress after ordinary recovery, immutable outcomes and lethal/timeout precedence at finish.
- Physical track fixture probes the actual collision geometry for all eight layouts, drives into a wall and reverses free, then falls through an actual missing span and settles shared loss. Dead learners continue falling rather than freezing in the air.
- Rehearsal checks record actual W input, replay speed while navigation remains live, switch report access, disable speed and rewind the same route.
- `verify_launch_network.gd -- --survival` passes with three actual local ENet peers: exclusive seat occupancy, private report access, replicated bridge geometry, full production-input traversal without truck-pose/progress injection, shared pass, unanimous retry, fresh synchronized geometry, actual gravity fall while recovery is held, shared failure, and guest-loss return.

The network driver needed reverse recovery after a wall contact. A finish assertion was corrected to accept settlement when the whole truck clears the finish, rather than requiring continued driving after a pass. The retained final network log has both PASS summaries and no FAIL lines. Fall and wall setups in the isolated scene checks are fixture placement; their subsequent motion uses production mechanics.

## Rendered inspection

Inspected `navigation-navigator.png`, `navigation-steering.png` and `navigation-overview.png`. The navigator has a readable paper report; steering has no private directions. The road, exposed bridge edges, missing spans and numbered branches are visible. These are gameplay placeholders using the retained modeled truck and learners, not final track art.

## Limits

These checks establish behavior, not human fun, equal role engagement, or Steam feel. The navigator's information can be bypassed through careful visual inspection; the intended contribution is timely route information under shared pressure. Three humans must test whether this is enough, especially long straight sections and memorized directions. The six-minute timer and three-junction layout remain tuning candidates.

Sandbox runs report unavailable Steam and inability to write Godot's user log/cache/settings; permitted native network execution initializes Steam but uses ENet for deterministic local peers. Fixture shutdowns retain the existing ObjectDB/resource warning. There is no claim of a new packaged release, macOS execution or cross-platform Steam acceptance.

The local Steam account identifier and persona are redacted from the network log.

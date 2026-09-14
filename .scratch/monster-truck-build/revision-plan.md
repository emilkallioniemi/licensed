# Monster-truck revision breakdown

Status: ready-for-human
Date: 2026-09-14

Approved 2026-09-14: the user authorized this four-ticket revision breakdown (“I trust you.”). Tickets 29–32 are published in the existing executable issue directory. The existing spec's active amendment is authoritative.

| Ticket | Blocked by | End-to-end deliverable |
| --- | --- | --- |
| [29: Board and drive with shared visibility](issues/29-board-and-drive.md) | 08b | Revised climbable truck, shared seated camera, secure seating, retained steering and simple W/S speed. |
| [30: Cooperate through balance and consensual swaps](issues/30-balance-and-swap.md) | 29 | Visible directional weight shifting replaces rear steering; occupants can agree to swap while stopped. |
| [31: Recover mistakes and pass the short test](issues/31-short-test-and-recovery.md) | 30 | Turn, bumps and parking with shared guidance, recovery, achievable pass, result and retry. |
| [32: Prepare the revised three-human playtest](issues/32-revised-playtest-package.md) | 31 | Verified Windows/macOS packages and updated procedure ready for the trio. |
| Existing [06: Cooperation checkpoint](issues/06-cooperation-checkpoint.md) | 05, 32 | Three-human acceptance of role enjoyment, accessibility, successful completion and Steam feel. |

Reuse the existing, previously confirmed test boundaries; this breakdown proposes no new architecture seam. New numbers preserve every existing ticket identity. Dependency order is 08b → 29 → 30 → 31 → 32 → 06; numbering does not imply execution order.

## Existing-ticket reconciliation

- Done 01–05 and 07–08b: retain completion and evidence as history; 29–31 own changed boarding, controls, sight, seated recovery and scoring behavior.
- 06: acceptance criteria amended now; remains unaccepted. Ticket 32 is now a blocker.
- 09–12: deferred full-route work. Reconcile two-axle steering, parking-brake requirements, route difficulty and catastrophic falls after 06; reuse 31's ordered completion/result behavior rather than rebuilding it.
- 13–16: deferred hazards and full-route acceptance. Reconsider dangerous encounters and failure rules against the forgiving direction before implementation.
- 17–21: retain personal license and persistence ownership/dependencies. The revised short test's result does not claim durable awards or Cloud completion.
- 22–24: retain later social/audio/examiner work, but reconcile any physical-reach or first-person assumptions with shared seated sight before implementation.
- 25–28: retain later aftermath/presentation/final acceptance ownership; replace seated ejection and automatic rollover-failure expectations and account for deferred dangerous encounters before implementation.
- Cuter learner redesign: recorded later direction; no executable ticket is created in this revision.

All 09–28 remain deferred behind 06 and must be checked against the amendment before implementation. No completed ticket is reopened or silently declared invalid. No old route plan becomes accepted simply because 06 later passes.

## Implementation order

Tickets 29–32 are ready-for-agent, with blocking edges controlling eligibility. Ticket 06 remains ready-for-human and blocked by 32 until the revised build is prepared. Start implementation with 29 in a fresh context; later work follows the blocking edges.

## Coding handoff — 2026-09-14

User sequencing: finish coding, then Astra for 3D work. Code for 29–31 is implemented and verified; 30–31 are done, 29 awaits the model/integration finish, and 32 awaits final packaging after that art. Continue from [Astra handoff](astra-handoff.md) and [verification](revision-verification.md). Historical dependencies remain in the table above; this explicit user sequencing allowed coding ahead of 29’s art completion. No human acceptance or release is claimed.

## Final local playtest preparation

29–32 are complete. The user’s Hot Wheels-style correction is integrated and packaged in `export/monster-truck-high-body-2026-09-14`. See [final evidence](art-verification.md). Next is human checkpoint 06; do not expand the route before acceptance.

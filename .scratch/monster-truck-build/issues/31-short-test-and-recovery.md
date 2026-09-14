# 31: Recover mistakes and pass the short test

Status: done
Blocked by: 30
Parent: [Active spec amendment](../../monster-truck/spec.md)

Approved 2026-09-14: user authorized the four-ticket revision breakdown (“I trust you.”).

## What to build

Recover mistakes and pass the short test in the retained monster-truck implementation, following the active 2026-09-14 amendment.

## Acceptance criteria

- [x] Integrate a turn, forgiving bump section and parking finish in order within the existing scrapyard, with a generous tunable timer.
- [x] All players see the current instruction, passing requirement and destination/target; completion feedback advances only after actual conditions hold. Choose and document forgiving geometry and tolerances.
- [x] Any player can hold a clearly prompted action after a rollover settles to restore the truck upright nearby. Off-course recovery offers nearby safe placement. Validate safe placement and count each recovery once.
- [x] Preserve manoeuvre progress during recovery. Cone hits and repeated parking corrections cannot prevent passing; keep workers outside the driving path and the ravine inaccessible.
- [x] Completing all three items before zero settles one shared pass and rating; faults affect rating only. Timeout and unanimous concession settle failure, with existing departure semantics retained.
- [x] Results, unanimous retry and waiting-room return work. Retry clears progress, faults and control/recovery state. Full durable license/Cloud work remains in later tickets; do not claim it is implemented.
- [x] Verify real scene completion, invalid/out-of-order parking, recovery followed by pass, timeout/completion races, duplicate recovery input and three-peer result/retry agreement.

## Verification guidance

Reuse the previously confirmed public attempt/occupancy/lifecycle boundaries and existing Godot scene/network harnesses. Assert player-visible behavior, not private structure. Preserve exactly three humans and Steam-only shipping. Record evidence and update superseded assertions; human fun/feel is judged in checkpoint 06.

## Comments

- 2026-09-14: Ordered short test, shared guidance, cone/recovery faults, pass/rating, timeout/concession, recovery, retry and return are implemented. Real three-peer held controls completed the actual course after recovery; tests and tolerances are recorded in ../revision-verification.md. Durable licenses remain deferred.

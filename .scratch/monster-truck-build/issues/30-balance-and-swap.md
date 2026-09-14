# 30: Cooperate through balance and consensual swaps

Status: done
Blocked by: 29
Parent: [Active spec amendment](../../monster-truck/spec.md)

Approved 2026-09-14: user authorized the four-ticket revision breakdown (“I trust you.”).

## What to build

Cooperate through balance and consensual swaps in the retained monster-truck implementation, following the active 2026-09-14 amendment.

## Acceptance criteria

- [x] Replace the rear-steering responsibility with directional weight shifting that visibly affects cornering and fore/aft bump response.
- [x] Easy ground remains manageable without balance; tuning makes assistance readable without continuous unavoidable rollovers. Record provisional values.
- [x] Each player exclusively occupies steering, speed or balance; direction controls and hints are understandable and truck-relative.
- [x] A stopped player can request a seat swap; the other occupant accepts before authority atomically changes. Movement, exit, membership change or a stale request cannot force an invalid swap.
- [x] Verify real balance motion, refusal/cancellation, simultaneous requests, stale operator input and three-peer agreement. Human enjoyment remains ticket 06.

## Verification guidance

Reuse the previously confirmed public attempt/occupancy/lifecycle boundaries and existing Godot scene/network harnesses. Assert player-visible behavior, not private structure. Preserve exactly three humans and Steam-only shipping. Record evidence and update superseded assertions; human fun/feel is judged in checkpoint 06.

## Comments

- 2026-09-14: Balance and consent-based stopped swaps implemented and verified at attempt and real three-peer scene boundaries. Tuning and remaining human enjoyment checks are recorded in ../revision-verification.md. Internal rear key retained for the balance seat.

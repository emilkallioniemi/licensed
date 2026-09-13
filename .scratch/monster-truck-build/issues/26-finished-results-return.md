# 26: Finish results presentation and the return journey

Status: ready-for-agent
Blocked by: 19, 23, 25
Parent: [A complete monster truck vehicle](../../monster-truck/spec.md)

## What to build

The complete marked assessment sits over the accident or successful finish and leads cleanly into retry or the waiting room.

## Acceptance criteria

- [ ] Produce finished marked results-sheet treatment with latest shared pass/fail, minor faults, applicable passing rating and viewer’s own retained best; keep aftermath visible.
- [ ] Present changeable Retry/Waiting room choices for all three; only current matching choices transition, with pending membership/attempt changes invalidating stale choices.
- [ ] Integrate physical examiner assessment/damage timing without cutting off interesting action or requiring the failed route to continue; settled pass/award remains immutable.
- [ ] Retry skips chairs/booking, restores truck/learners/world, resets reaction/effect/choice state and starts synchronized arrival timer; return restores correct waiting-room state and current-player license display.
- [ ] Keep failed local-save feedback and retry usable without trapping the trio; completed awards survive departure.
- [ ] Verify final scenes and input alongside public lifecycle checks for concession, changed choice, host/guest departure and delayed messages. Broader final human mix/feel review is 27.

## Implementation and verification guidance

Read the parent specification in full before implementation; the sections most relevant here are **Faults, timer, and immutable results; Asset production and finished presentation**. These criteria narrow this ticket's deliverable; they do not replace the spec's detailed rules. Use the domain vocabulary and preserve the exactly-three-human and Steam-only shipping ADRs.

Use the confirmed seams: public RoomState commands for booking, one host-owned attempt boundary for lifecycle/scoring/choices, and the public license store with local/Cloud adapters for durability. Extend existing Godot scene harness patterns for physical/input integration. Assert observable behavior rather than private fields or a test seam per sensor. Record meaningful tests and build-linked evidence under Comments.

This is retained implementation toward the complete vehicle. Any temporary harness or presentation must be labeled and its replacement owner recorded; do not count agent fixtures as evidence of human enjoyment or shipping Steam feel. Perform agent-owned production, integration and verification before requesting an unavailable human action. If required three-human play or owned-app access is unavailable, record the exact remaining dependency and use ready-for-human, not done. Gameplay tuning candidates stay provisional until their checkpoint evidence supports them.

## Comments

- From ticket 05: Replace rough shared results with marked-sheet presentation; retain changeable unanimous choices and synchronized clean retry.

- 2026-09-13: Published after the user authorized the proposed 28-ticket breakdown. Dependencies refer only to implementation tickets in this directory, not the sixteen resolved wayfinder decisions.

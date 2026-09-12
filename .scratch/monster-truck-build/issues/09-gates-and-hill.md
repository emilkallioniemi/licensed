# 09: Complete the scrapyard gates and hill start

Status: ready-for-agent
Blocked by: 07
Parent: [A complete monster truck vehicle](../../monster-truck/spec.md)

## What to build

Players begin the modeled scrapyard test by clearing offset gates and completing a hill start under examiner direction.

## Acceptance criteria

- [ ] Create arrival/climb kit with stacked wrecks, loose panels, cones, route arrows/numbered signs, stop box, flat rollback runout and usable boarding/recovery space. Initial section budgets are 55 seconds each, not additional timers.
- [ ] Item one completes when the entire truck clears the second offset gate forward. Item two requires all tyre contacts inside the hill-start box at rest for two seconds, then the whole truck clearing the crest forward; parking-brake use is optional.
- [ ] Implement ordered progression, scored connecting driving and minor-fault incident deduplication: one scrape/impact chain including its induced boundary excursion, two seconds contact-clear before new contact, full re-entry before new boundary fault.
- [ ] Rollback over half a tyre diameter after the required stop counts once until forward travel resumes; smaller rollback is tolerated and the earned stop persists.
- [ ] Generate arrival/manoeuvre requests and subtitles, first destination at arrival, T repeat without stacked requests or interruption of fault comments. No test sheet, added driving advice or paused timer.
- [ ] Test untidy valid completions, missed/out-of-order items, bounce, rollback and boundary/contact chains at the attempt boundary and actual scenes. Extra shunts/look/swaps/rescue are not faults.

## Implementation and verification guidance

Read the parent specification in full before implementation; the sections most relevant here are **Fixed route and completion; Faults, timer, and immutable results; Booking, controls, sight, and recovery**. These criteria narrow this ticket's deliverable; they do not replace the spec's detailed rules. Use the domain vocabulary and preserve the exactly-three-human and Steam-only shipping ADRs.

Use the confirmed seams: public RoomState commands for booking, one host-owned attempt boundary for lifecycle/scoring/choices, and the public license store with local/Cloud adapters for durability. Extend existing Godot scene harness patterns for physical/input integration. Assert observable behavior rather than private fields or a test seam per sensor. Record meaningful tests and build-linked evidence under Comments.

This is retained implementation toward the complete vehicle. Any temporary harness or presentation must be labeled and its replacement owner recorded; do not count agent fixtures as evidence of human enjoyment or shipping Steam feel. Perform agent-owned production, integration and verification before requesting an unavailable human action. If required three-human play or owned-app access is unavailable, record the exact remaining dependency and use ready-for-human, not done. Gameplay tuning candidates stay provisional until their checkpoint evidence supports them.

## Comments

- 2026-09-13: Published after the user authorized the proposed 28-ticket breakdown. Dependencies refer only to implementation tickets in this directory, not the sixteen resolved wayfinder decisions.

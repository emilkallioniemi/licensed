# 15: Yield to the loaded forklift

Status: ready-for-agent
Blocked by: 08, 11
Parent: [A complete monster truck vehicle](../../monster-truck/spec.md)

## What to build

Players yield at the broad terrace junction to a forklift whose collision can shed its wreck or topple occupied machinery.

## Acceptance criteria

- [ ] Create modeled forklift/carried wreck/operator with movement, load shedding, toppling and motor/reverse-alarm audio, after the crusher refuge and before descent.
- [ ] Provide forward crossing with load or reverse crossing from opposite work bay, chosen fresh each attempt; one crossing with four plus zero–two seconds preparation and maximum six seconds lane occupation.
- [ ] Keep visible bay exits/cues, safe terrace waiting and stopping distance plus two seconds communication; defer unannounced crossing until truck and on-foot learners clear.
- [ ] Minor brush remains recoverable; toppling occupied machinery or striking operator is serious, with host-owned meaningful physical aftermath.
- [ ] Keep machinery working outside the path after clearance, persist relevant debris during attempt and restore on retry.
- [ ] Verify both variants, cue/avoidance bounds, load versus operator contact and catastrophic cascades in real scenes and shared event/score behavior.

## Implementation and verification guidance

Read the parent specification in full before implementation; the sections most relevant here are **Changing hazards and physical consequences; Faults, timer, and immutable results**. These criteria narrow this ticket's deliverable; they do not replace the spec's detailed rules. Use the domain vocabulary and preserve the exactly-three-human and Steam-only shipping ADRs.

Use the confirmed seams: public RoomState commands for booking, one host-owned attempt boundary for lifecycle/scoring/choices, and the public license store with local/Cloud adapters for durability. Extend existing Godot scene harness patterns for physical/input integration. Assert observable behavior rather than private fields or a test seam per sensor. Record meaningful tests and build-linked evidence under Comments.

This is retained implementation toward the complete vehicle. Any temporary harness or presentation must be labeled and its replacement owner recorded; do not count agent fixtures as evidence of human enjoyment or shipping Steam feel. Perform agent-owned production, integration and verification before requesting an unavailable human action. If required three-human play or owned-app access is unavailable, record the exact remaining dependency and use ready-for-human, not done. Gameplay tuning candidates stay provisional until their checkpoint evidence supports them.

## Comments

- 2026-09-13: Published after the user authorized the proposed 28-ticket breakdown. Dependencies refer only to implementation tickets in this directory, not the sixteen resolved wayfinder decisions.

# 06: Validate three-player cooperation and online feel

Status: ready-for-agent
Blocked by: 05
Parent: [A complete monster truck vehicle](../../monster-truck/spec.md)

## What to build

A retained playable checkpoint demonstrates whether all three controls are necessary, enjoyable and responsive online.

## Acceptance criteria

- [ ] Prepare a reproducible Steam build/settings and test procedure covering boarding, moving turn, tight reverse, parking/roof access, falls and rescue.
- [ ] Run exactly three humans including the user, rotating host and every control. After familiarisation compare coordinated play against one idle participant, fixed rear steering and two people hopping controls.
- [ ] Record anticipation, each control’s engagement, sight-sharing, physical comedy and whether movement removes blind spots. Rear steering optionality, dull throttle/brake or two-person success require revision.
- [ ] Exercise contention, handover during turns, lost releases, stale commands, roof support, detachment, rescue and host/guest loss under ordinary and adverse connections.
- [ ] Record actual latency/jitter/loss, frame pacing, input response and correction frequency as diagnostics. User assessment that driving, walking, boarding and handovers feel very good is required; numbers alone are insufficient.
- [ ] Make bounded relevant revisions and repeat comparisons, retaining implementation. Record build-linked retain/revise findings and remaining work; do not mark done with missing human evidence or hide issues by removing free movement.

## Implementation and verification guidance

Read the parent specification in full before implementation; the sections most relevant here are **Playable checkpoint 1: cooperation and early online feel**. These criteria narrow this ticket's deliverable; they do not replace the spec's detailed rules. Use the domain vocabulary and preserve the exactly-three-human and Steam-only shipping ADRs.

Use the confirmed seams: public RoomState commands for booking, one host-owned attempt boundary for lifecycle/scoring/choices, and the public license store with local/Cloud adapters for durability. Extend existing Godot scene harness patterns for physical/input integration. Assert observable behavior rather than private fields or a test seam per sensor. Record meaningful tests and build-linked evidence under Comments.

This is retained implementation toward the complete vehicle. Any temporary harness or presentation must be labeled and its replacement owner recorded; do not count agent fixtures as evidence of human enjoyment or shipping Steam feel. Perform agent-owned production, integration and verification before requesting an unavailable human action. If required three-human play or owned-app access is unavailable, record the exact remaining dependency and use ready-for-human, not done. Gameplay tuning candidates stay provisional until their checkpoint evidence supports them.

## Comments

- From ticket 04: Evaluate provisional recovery tuning, ejection fairness and responsiveness with three humans over Steam. Native ENet checks pass; they do not establish Steam feel.

- From tickets 02–03: Agent fixtures verify physical boarding, roof riding, moving releases and actual shared driving. Exactly three humans must still judge control necessity, cooperation and Steam feel; see 02-evidence.md and 03-evidence.md.

- From ticket 01: Three-peer development ENet launch and display transition checks pass; these do not establish three-human Steam cooperation or feel acceptance.

- 2026-09-13: Published after the user authorized the proposed 28-ticket breakdown. Dependencies refer only to implementation tickets in this directory, not the sixteen resolved wayfinder decisions.

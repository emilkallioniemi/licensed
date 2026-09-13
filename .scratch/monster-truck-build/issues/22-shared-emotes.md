# 22: Perform five shared emotes

Status: ready-for-agent
Blocked by: 19
Parent: [A complete monster truck vehicle](../../monster-truck/spec.md)

## What to build

Players react with five animated gestures visible in their own hands and to friends.

## Acceptance criteria

- [ ] Produce/integrate wave, clap, point, both middle fingers and alternating-palms “67” animations with articulated first-person hands and third-person body.
- [ ] Hold B to open five-choice wheel, release to perform selected gesture. “67” emits one short “six seven” line per selection.
- [ ] Require free hands: unavailable while operating driving controls, and starting an emote puts away the license. Preserve physical E handovers rather than gesturing while driving.
- [ ] Replicate selection/presentation without duplicated vocals on retransmission and retain learner support/locomotion consistency.
- [ ] Keep editable animation/audio sources; gestures remain legible without obstructing essential sight or clipping distractingly.
- [ ] Exercise input, card/control conflicts, peer visibility, audio repetition, cancellation during transitions and clean retry; demonstrate all five from first/third person.

## Implementation and verification guidance

Read the parent specification in full before implementation; the sections most relevant here are **Asset production and finished presentation; Booking, controls, sight, and recovery**. These criteria narrow this ticket's deliverable; they do not replace the spec's detailed rules. Use the domain vocabulary and preserve the exactly-three-human and Steam-only shipping ADRs.

Use the confirmed seams: public RoomState commands for booking, one host-owned attempt boundary for lifecycle/scoring/choices, and the public license store with local/Cloud adapters for durability. Extend existing Godot scene harness patterns for physical/input integration. Assert observable behavior rather than private fields or a test seam per sensor. Record meaningful tests and build-linked evidence under Comments.

This is retained implementation toward the complete vehicle. Any temporary harness or presentation must be labeled and its replacement owner recorded; do not count agent fixtures as evidence of human enjoyment or shipping Steam feel. Perform agent-owned production, integration and verification before requesting an unavailable human action. If required three-human play or owned-app access is unavailable, record the exact remaining dependency and use ready-for-human, not done. Gameplay tuning candidates stay provisional until their checkpoint evidence supports them.

## Comments

- 2026-09-13: Published after the user authorized the proposed 28-ticket breakdown. Dependencies refer only to implementation tickets in this directory, not the sixteen resolved wayfinder decisions.

- From completed 08: Use the shared articulated rig and first-person world-space hands from completed 08; preserve host-confirmed occupancy and visibility while adding the five gestures. See ../08-evidence.md.

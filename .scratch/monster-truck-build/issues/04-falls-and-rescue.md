# 04: Fall, reboard, and rescue physically

Status: ready-for-agent
Blocked by: 03
Parent: [A complete monster truck vehicle](../../monster-truck/spec.md)

## What to build

Learners can ride the roof, fall harmlessly, reboard, and physically rescue a trapped friend while time continues.

## Acceptance criteria

- [ ] Provide secure ordinary footing; sharp turns, big bumps, impacts and stepping over edges can eject learners. Tune arcade behavior rather than realistic simulation.
- [ ] Harmless falls cause no fault. Learners walk back and climb aboard; friends can stop/reverse for collection, with the timer continuing.
- [ ] Distinguish entrapment from catastrophic crushing. Moving the truck can free a trapped learner; no teleport/get-unstuck or truck-righting control.
- [ ] Host resolves support loss, impacts and rescue against shared truck/hazard state. Guests predict ordinary movement without issuing authoritative accident verdicts.
- [ ] Expose meaningful accident observations to the attempt boundary for 05, preserving support motion and coherent corrections on all peers.
- [ ] Demonstrate roof travel, recoverable ejection/collection, trapped-operator rescue and an impossible-rescue setup. Verify scene behavior and detachment under delayed snapshots; human enjoyment is evaluated in 06.

## Implementation and verification guidance

Read the parent specification in full before implementation; the sections most relevant here are **Booking, controls, sight, and recovery; Shared simulation and responsiveness**. These criteria narrow this ticket's deliverable; they do not replace the spec's detailed rules. Use the domain vocabulary and preserve the exactly-three-human and Steam-only shipping ADRs.

Use the confirmed seams: public RoomState commands for booking, one host-owned attempt boundary for lifecycle/scoring/choices, and the public license store with local/Cloud adapters for durability. Extend existing Godot scene harness patterns for physical/input integration. Assert observable behavior rather than private fields or a test seam per sensor. Record meaningful tests and build-linked evidence under Comments.

This is retained implementation toward the complete vehicle. Any temporary harness or presentation must be labeled and its replacement owner recorded; do not count agent fixtures as evidence of human enjoyment or shipping Steam feel. Perform agent-owned production, integration and verification before requesting an unavailable human action. If required three-human play or owned-app access is unavailable, record the exact remaining dependency and use ready-for-human, not done. Gameplay tuning candidates stay provisional until their checkpoint evidence supports them.

## Comments

- From ticket 02: Build violent ejection, entrapment and rescue on the tested support-relative movement and inherited detachment velocity. The isolated-world three-peer boarding fixture covers ordinary roof riding.

- 2026-09-13: Published after the user authorized the proposed 28-ticket breakdown. Dependencies refer only to implementation tickets in this directory, not the sixteen resolved wayfinder decisions.

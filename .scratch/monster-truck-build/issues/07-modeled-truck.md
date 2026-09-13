# 07: Drive the modeled and animated truck

Status: ready-for-agent
Blocked by: 06
Parent: [A complete monster truck vehicle](../../monster-truck/spec.md)

## What to build

The playable truck gains decent Blender models, animated controls and motion, without losing its validated driving and sight.

## Acceptance criteria

- [ ] Produce editable Blender sources/generators and portable Godot exports for exterior, oversized tyres/suspension, both steering axles, cab/three controls, parking brake, examiner seat, roof/access, physical instruments and radio provision.
- [ ] Integrate materials, pivots, collisions and control/tyre/suspension animation driven by shared state. This is in-game production, not an unattached asset pack.
- [ ] Preserve physical blind spots, instrument readability, safe boarding/release space and roof access around actual handling. No overhead or universal instrument display.
- [ ] Generate and integrate engine layers and basic suspension/tyre/cabin/impact feedback that follow driving while leaving voice intelligible.
- [ ] Verify local Blender/Godot and audio runtime availability; agent owns creation/integration. Keep sources revisable; premium services are not prerequisites.
- [ ] Demonstrate the existing driving exercise and retry online with modeled truck, verify import/collision/reset behavior and fix distracting clipping. Radio behavior arrives in 24.

## Implementation and verification guidance

Read the parent specification in full before implementation; the sections most relevant here are **Asset production and finished presentation; Booking, controls, sight, and recovery**. These criteria narrow this ticket's deliverable; they do not replace the spec's detailed rules. Use the domain vocabulary and preserve the exactly-three-human and Steam-only shipping ADRs.

Use the confirmed seams: public RoomState commands for booking, one host-owned attempt boundary for lifecycle/scoring/choices, and the public license store with local/Cloud adapters for durability. Extend existing Godot scene harness patterns for physical/input integration. Assert observable behavior rather than private fields or a test seam per sensor. Record meaningful tests and build-linked evidence under Comments.

This is retained implementation toward the complete vehicle. Any temporary harness or presentation must be labeled and its replacement owner recorded; do not count agent fixtures as evidence of human enjoyment or shipping Steam feel. Perform agent-owned production, integration and verification before requesting an unavailable human action. If required three-human play or owned-app access is unavailable, record the exact remaining dependency and use ready-for-human, not done. Gameplay tuning candidates stay provisional until their checkpoint evidence supports them.

## Comments

- From ticket 04: Replace rough geometry while preserving support and rescue clearance; existing modeled lobby and learner are the presentation quality reference.

- From ticket 03: Replace rough controls and floating physical labels with modeled instrument surfaces, retaining rotating axle pointers, sight restrictions and readable pedals instruments.

- From ticket 02: Replace the rough boxes and long access ramps while preserving continuous ground/cab/roof access, moving release space and the physical boarding regression coverage.

- 2026-09-13: Published after the user authorized the proposed 28-ticket breakdown. Dependencies refer only to implementation tickets in this directory, not the sixteen resolved wayfinder decisions.

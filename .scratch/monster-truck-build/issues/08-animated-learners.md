# 08: Move as expressive, animated learners

Status: ready-for-agent
Blocked by: 06
Parent: [A complete monster truck vehicle](../../monster-truck/spec.md)

## What to build

Each player moves, boards and drives as an expressive learner visible consistently to friends.

## Acceptance criteria

- [ ] Astra may redesign the learner freely; create one expressive body and rig with three distinct clothing colours, first-person hands and portrait-ready appearance. No customization screen.
- [ ] Integrate idle/walk, jump/fall/land, boarding/climbing, seated control use, take/leave transitions and recoverable ragdoll entry/exit.
- [ ] First-/third-person poses agree with host-confirmed support and occupancy; preserve essential sight and avoid distracting clipping through truck or hands.
- [ ] Provide articulated hands suitable for later five emotes and physical license; do not require gesture or card gameplay yet.
- [ ] Keep editable source assets and generation scripts with Godot-ready exports, materials and animation transitions; share humanoid rigging for later people where useful.
- [ ] Demonstrate three coloured learners walking, boarding, swapping and recovering across peers and retry. Use existing movement scenes plus visual review; 22 owns completed gestures.

## Implementation and verification guidance

Read the parent specification in full before implementation; the sections most relevant here are **Asset production and finished presentation**. These criteria narrow this ticket's deliverable; they do not replace the spec's detailed rules. Use the domain vocabulary and preserve the exactly-three-human and Steam-only shipping ADRs.

Use the confirmed seams: public RoomState commands for booking, one host-owned attempt boundary for lifecycle/scoring/choices, and the public license store with local/Cloud adapters for durability. Extend existing Godot scene harness patterns for physical/input integration. Assert observable behavior rather than private fields or a test seam per sensor. Record meaningful tests and build-linked evidence under Comments.

This is retained implementation toward the complete vehicle. Any temporary harness or presentation must be labeled and its replacement owner recorded; do not count agent fixtures as evidence of human enjoyment or shipping Steam feel. Perform agent-owned production, integration and verification before requesting an unavailable human action. If required three-human play or owned-app access is unavailable, record the exact remaining dependency and use ready-for-human, not done. Gameplay tuning candidates stay provisional until their checkpoint evidence supports them.

## Comments

- From ticket 04: Replace ticket 04's temporary compressed learner pose with the agreed animation and rigging.

- 2026-09-13: Published after the user authorized the proposed 28-ticket breakdown. Dependencies refer only to implementation tickets in this directory, not the sixteen resolved wayfinder decisions.

# 03: Drive with three shared controls

Status: ready-for-agent
Blocked by: 02
Parent: [A complete monster truck vehicle](../../monster-truck/spec.md)

## What to build

Three players steer both axles and operate throttle/brakes to negotiate a moving turn and tight reverse.

## Acceptance criteria

- [ ] Implement quick gradual limited-angle steering with A/D truck-relative at both axles, unchanged by looking or reversing; angle holds on input release and vacancy.
- [ ] W throttles in selected direction, S applies service brake, R changes direction only while stopped, Space toggles separate parking brake. Host validates actions; throttle/service brake release unattended, direction and parking brake persist.
- [ ] Predict accepted driving inputs using other operators’ latest known inputs and reconcile against host snapshots. Scope messages to attempt, input sequence and occupancy generation.
- [ ] Resend held states; deduplicate toggles and neutralize stale held commands after a bounded freshness window without erasing angle/direction/parking brake. Prevent lost releases and old operators from driving.
- [ ] Add physical timer and direction/brake indicators at throttle/brake, axle pointers beside steering, position-based blind spots, brief contextual bindings and H redisplay. Driving keys do not stand learners up.
- [ ] Demonstrate boarding, turning, reversing and deliberate parking with rough geometry, engine/collision feedback, running timer and temporary offline examiner audio. Verify handover state, lost/reordered input and stopped-only direction behavior through attempt/scene boundaries.

## Implementation and verification guidance

Read the parent specification in full before implementation; the sections most relevant here are **Booking, controls, sight, and recovery; Shared simulation and responsiveness**. These criteria narrow this ticket's deliverable; they do not replace the spec's detailed rules. Use the domain vocabulary and preserve the exactly-three-human and Steam-only shipping ADRs.

Use the confirmed seams: public RoomState commands for booking, one host-owned attempt boundary for lifecycle/scoring/choices, and the public license store with local/Cloud adapters for durability. Extend existing Godot scene harness patterns for physical/input integration. Assert observable behavior rather than private fields or a test seam per sensor. Record meaningful tests and build-linked evidence under Comments.

This is retained implementation toward the complete vehicle. Any temporary harness or presentation must be labeled and its replacement owner recorded; do not count agent fixtures as evidence of human enjoyment or shipping Steam feel. Perform agent-owned production, integration and verification before requesting an unavailable human action. If required three-human play or owned-app access is unavailable, record the exact remaining dependency and use ready-for-human, not done. Gameplay tuning candidates stay provisional until their checkpoint evidence supports them.

## Comments

- 2026-09-13: Published after the user authorized the proposed 28-ticket breakdown. Dependencies refer only to implementation tickets in this directory, not the sixteen resolved wayfinder decisions.

# 02: Board and occupy controls on a moving truck

Status: ready-for-agent
Blocked by: 01
Parent: [A complete monster truck vehicle](../../monster-truck/spec.md)

## What to build

Learners physically board a rough truck, walk on it, and exclusively take or leave its controls, including during movement.

## Acceptance criteria

- [ ] Build a roomy rough cab with front steering left, throttle/brake right, rear steering behind facing backward, examiner placeholder and climbable roof.
- [ ] E requests occupancy; host validates membership, phase, reach, availability and one control per learner. First valid request wins contention; no remote takeover or effective double operation.
- [ ] Give immediate feedback but confirm occupancy before driving or irrevocable seating. E release leaves usable standing space; handovers require physical movement.
- [ ] Introduce host-authoritative learner movement with immediate local look/walk prediction, acknowledged sequences and reconciliation. Represent support/climbing/occupancy and truck-relative pose, retaining support velocity on detachment.
- [ ] Keep supporting truck and learner coherent during prediction; smooth visual corrections without authoring contacts. Frequent slips/snaps are defects.
- [ ] Use a labeled controlled-moving-truck harness to verify boarding, roof walking, moving release, simultaneous requests and state recovery across peers. Actual driving follows in 03; this harness is not a shipping mode.

## Implementation and verification guidance

Read the parent specification in full before implementation; the sections most relevant here are **Shared simulation and responsiveness; Booking, controls, sight, and recovery**. These criteria narrow this ticket's deliverable; they do not replace the spec's detailed rules. Use the domain vocabulary and preserve the exactly-three-human and Steam-only shipping ADRs.

Use the confirmed seams: public RoomState commands for booking, one host-owned attempt boundary for lifecycle/scoring/choices, and the public license store with local/Cloud adapters for durability. Extend existing Godot scene harness patterns for physical/input integration. Assert observable behavior rather than private fields or a test seam per sensor. Record meaningful tests and build-linked evidence under Comments.

This is retained implementation toward the complete vehicle. Any temporary harness or presentation must be labeled and its replacement owner recorded; do not count agent fixtures as evidence of human enjoyment or shipping Steam feel. Perform agent-owned production, integration and verification before requesting an unavailable human action. If required three-human play or owned-app access is unavailable, record the exact remaining dependency and use ready-for-human, not done. Gameplay tuning candidates stay provisional until their checkpoint evidence supports them.

## Comments

- 2026-09-13: Published after the user authorized the proposed 28-ticket breakdown. Dependencies refer only to implementation tickets in this directory, not the sixteen resolved wayfinder decisions.

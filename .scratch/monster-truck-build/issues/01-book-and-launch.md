# 01: Book and launch without preassigned roles

Status: ready-for-agent
Blocked by: None
Parent: [A complete monster truck vehicle](../../monster-truck/spec.md)

## What to build

Three friends book the monster truck, sit down, and arrive together without selecting roles.

## Acceptance criteria

- [ ] Replace role-dictionary launch detection with explicit attempt identity and phase throughout readiness, replication, departure and return. Prefactor this first while keeping existing behavior verifiable.
- [ ] Hide monster-truck role pickup; show “Choose your controls in the truck”. Three matching picks and three seated learners trigger the existing examiner call, door and fade; changes cancel correctly.
- [ ] Load and acknowledge scene readiness before synchronized arrival. Begin the shared candidate six-minute timer at arrival, without waiting for controls; failed loading follows membership/departure handling.
- [ ] Keep exactly three humans in shipping play. Development fixtures do not create a solo or bot mode.
- [ ] Demonstrate departure into the current test area and return/reset, without stale roles, picks or launch state. Identify temporary arrival geometry for ticket 02.
- [ ] Extend public RoomState command/snapshot checks and the ready-up scene harness for no-role launch, cancellation, host/guest loading loss and explicit transition replication.

## Implementation and verification guidance

Read the parent specification in full before implementation; the sections most relevant here are **Foundation and scope; Booking, controls, sight, and recovery**. These criteria narrow this ticket's deliverable; they do not replace the spec's detailed rules. Use the domain vocabulary and preserve the exactly-three-human and Steam-only shipping ADRs.

Use the confirmed seams: public RoomState commands for booking, one host-owned attempt boundary for lifecycle/scoring/choices, and the public license store with local/Cloud adapters for durability. Extend existing Godot scene harness patterns for physical/input integration. Assert observable behavior rather than private fields or a test seam per sensor. Record meaningful tests and build-linked evidence under Comments.

This is retained implementation toward the complete vehicle. Any temporary harness or presentation must be labeled and its replacement owner recorded; do not count agent fixtures as evidence of human enjoyment or shipping Steam feel. Perform agent-owned production, integration and verification before requesting an unavailable human action. If required three-human play or owned-app access is unavailable, record the exact remaining dependency and use ready-for-human, not done. Gameplay tuning candidates stay provisional until their checkpoint evidence supports them.

## Comments

- 2026-09-13: Published after the user authorized the proposed 28-ticket breakdown. Dependencies refer only to implementation tickets in this directory, not the sixteen resolved wayfinder decisions.

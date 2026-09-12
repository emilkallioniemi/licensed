# 01: Book and launch without preassigned roles

Status: done
Blocked by: None
Parent: [A complete monster truck vehicle](../../monster-truck/spec.md)

## What to build

Three friends book the monster truck, sit down, and arrive together without selecting roles.

## Acceptance criteria

- [x] Replace role-dictionary launch detection with explicit attempt identity and phase throughout readiness, replication, departure and return. Prefactor this first while keeping existing behavior verifiable.
- [x] Hide monster-truck role pickup; show “Choose your controls in the truck”. Three matching picks and three seated learners trigger the existing examiner call, door and fade; changes cancel correctly.
- [x] Load and acknowledge scene readiness before synchronized arrival. Begin the shared candidate six-minute timer at arrival, without waiting for controls; failed loading follows membership/departure handling.
- [x] Keep exactly three humans in shipping play. Development fixtures do not create a solo or bot mode.
- [x] Demonstrate departure into the current test area and return/reset, without stale roles, picks or launch state. Identify temporary arrival geometry for ticket 02.
- [x] Extend public RoomState command/snapshot checks and the ready-up scene harness for no-role launch, cancellation, host/guest loading loss and explicit transition replication.

## Implementation and verification guidance

Read the parent specification in full before implementation; the sections most relevant here are **Foundation and scope; Booking, controls, sight, and recovery**. These criteria narrow this ticket's deliverable; they do not replace the spec's detailed rules. Use the domain vocabulary and preserve the exactly-three-human and Steam-only shipping ADRs.

Use the confirmed seams: public RoomState commands for booking, one host-owned attempt boundary for lifecycle/scoring/choices, and the public license store with local/Cloud adapters for durability. Extend existing Godot scene harness patterns for physical/input integration. Assert observable behavior rather than private fields or a test seam per sensor. Record meaningful tests and build-linked evidence under Comments.

This is retained implementation toward the complete vehicle. Any temporary harness or presentation must be labeled and its replacement owner recorded; do not count agent fixtures as evidence of human enjoyment or shipping Steam feel. Perform agent-owned production, integration and verification before requesting an unavailable human action. If required three-human play or owned-app access is unavailable, record the exact remaining dependency and use ready-for-human, not done. Gameplay tuning candidates stay provisional until their checkpoint evidence supports them.

## Comments

- 2026-09-13: Published after the user authorized the proposed 28-ticket breakdown. Dependencies refer only to implementation tickets in this directory, not the sixteen resolved wayfinder decisions.

- 2026-09-13 implementation evidence: spec branch `spec/monster-truck-build`; spec base and fixed ticket/review base `d261b031d2750f16c6b8c544b07f7e051fd87a2d`. HEAD preserved; all implementation is uncommitted for the orchestrator's single ticket commit. Status intentionally remains claimed until orchestration accepts this report.
- Prefactor verified first: the original RoomState regression suite passed with explicit attempt identity/phase before changing role requirements. No-role booking and readiness/timer behavior then went red before green at the agreed RoomState and AttemptState public seams. Existing preassigned-role regression tests remain against an explicitly unshipped fixture vehicle; unrelated booking, membership, chair, countdown, serialization and reset checks remain covered.
- Validation on Godot 4.7.2: `verify_room_state.gd`, `verify_attempt_state.gd`, `verify_motion.gd`, `verify_reception_input.gd`, and `verify_steam_client.gd` all PASS. Sandboxed headless runs report inaccessible user-log/certificate-store/Steam initialization diagnostics, but all assertions and script loading pass. Display/network runs use the real runtime with Steam access.
- Display integration: `verify_ready_up.gd --quit-after 1200 --max-fps 60` PASS, covering examiner audio, seat cancellation/restart, delayed scene readiness, six-minute timer beginning at arrival, explicit departure/reset, guest loss during loading, failed loading, replicated loading/active/departing presentation, and host-loss recovery into an own room. Evidence: [ready-up.log](../ready-up.log). The optional `-- --capture-booking` capture was visually inspected: no role buttons/heading remain and the controls guidance is readable; corrected the initial imported-coordinate placement. Evidence: [booking.png](../booking.png).
- Network integration: `verify_launch_network.gd --headless --quit-after 1800 --max-fps 60` runs three actual local ENet peers with replicated learners and real commands/readiness RPCs. PASS for arrival on all peers, shared attempt identity, running timer snapshots, guest loss, and survivor return/reset. Evidence: [network.log](../network.log). The fixture exits 0 after PASS, with five ObjectDB instances/one resource reported at engine shutdown from the multi-scene harness; no protocol assertion or live-transition error remains. These are development protocol fixtures, not human players or shipping Steam feel evidence.
- Code review: Standards found zero documented violations and one nonblocking possible Primitive Obsession suggestion (phase enum); retained readable StringName phases in serialized snapshots for this slice. Spec review found no implementation defects or scope creep; its initial evidence gap was closed by guest transition/host-loss checks and the three-peer RPC harness. Review fixes include verified visible board guidance. No outstanding ticket-01 review findings.
- Later tickets: 02 replaces the explicitly labeled temporary car-park arrival geometry with the secured truck, seated examiner and boarding space, and integrates physical instruments. 05 replaces temporary host Back and bare settled-at-zero behavior with concession, immutable assessment, aftermath and unanimous retry/return. 06 owns three-human Steam cooperation/feel evidence; it has not been claimed by these fixtures. All ticket-01 criteria are verified at their scoped implementation/integration level.

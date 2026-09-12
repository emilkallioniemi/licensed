# 02: Board and occupy controls on a moving truck

Status: done
Blocked by: 01
Parent: [A complete monster truck vehicle](../../monster-truck/spec.md)

## What to build

Learners physically board a rough truck, walk on it, and exclusively take or leave its controls, including during movement.

## Acceptance criteria

- [x] Build a roomy rough cab with front steering left, throttle/brake right, rear steering behind facing backward, examiner placeholder and climbable roof.
- [x] E requests occupancy; host validates membership, phase, reach, availability and one control per learner. First valid request wins contention; no remote takeover or effective double operation.
- [x] Give immediate feedback but confirm occupancy before driving or irrevocable seating. E release leaves usable standing space; handovers require physical movement.
- [x] Introduce host-authoritative learner movement with immediate local look/walk prediction, acknowledged sequences and reconciliation. Represent support/climbing/occupancy and truck-relative pose, retaining support velocity on detachment.
- [x] Keep supporting truck and learner coherent during prediction; smooth visual corrections without authoring contacts. Frequent slips/snaps are defects.
- [x] Use a labeled controlled-moving-truck harness to verify boarding, roof walking, moving release, simultaneous requests and state recovery across peers. Actual driving follows in 03; this harness is not a shipping mode.

## Implementation and verification guidance

Read the parent specification in full before implementation; the sections most relevant here are **Shared simulation and responsiveness; Booking, controls, sight, and recovery**. These criteria narrow this ticket's deliverable; they do not replace the spec's detailed rules. Use the domain vocabulary and preserve the exactly-three-human and Steam-only shipping ADRs.

Use the confirmed seams: public RoomState commands for booking, one host-owned attempt boundary for lifecycle/scoring/choices, and the public license store with local/Cloud adapters for durability. Extend existing Godot scene harness patterns for physical/input integration. Assert observable behavior rather than private fields or a test seam per sensor. Record meaningful tests and build-linked evidence under Comments.

This is retained implementation toward the complete vehicle. Any temporary harness or presentation must be labeled and its replacement owner recorded; do not count agent fixtures as evidence of human enjoyment or shipping Steam feel. Perform agent-owned production, integration and verification before requesting an unavailable human action. If required three-human play or owned-app access is unavailable, record the exact remaining dependency and use ready-for-human, not done. Gameplay tuning candidates stay provisional until their checkpoint evidence supports them.

## Comments

- From ticket 01: Replace the labeled temporary car-park arrival geometry with the secured truck, seated examiner and boarding space. Arrival already uses AttemptState readiness and a shared timer.

- 2026-09-13: Published after the user authorized the proposed 28-ticket breakdown. Dependencies refer only to implementation tickets in this directory, not the sixteen resolved wayfinder decisions.

- 2026-09-13 implementation (left Status: claimed and all work uncommitted per orchestrator): fixed ticket review base 8c0df04779a2c73ee92371f68f80f93f95cbba9c, spec base d261b031d2750f16c6b8c544b07f7e051fd87a2d. Added rough truck/examiner/access, host-owned occupancy and sequenced predicted learner movement with support-relative recovery. See [implementation/review evidence](../02-evidence.md) and [rough truck capture](../02-rough-truck.png).
- Validation: AttemptState red/green occupancy tests; full RoomState, AttemptState, motion, reception and Steam avatar suite; display ready-up regression; actual three-peer isolated-world ENet fixture. Final [display log](../boarding-display.log) exits 0 with physical ground/cab/roof walking, inherited detachment velocity, guest E/free look, moving pedals release, simultaneous contention, held-walk expiry, snapshot recovery and guest-loss return all passing. Existing launch/readiness/timer/departure tests remain intact. git diff --check passes.
- Two-axis code review: Standards found no hard violations and one optional cross-module coupling smell; Spec found guest occupied-look, pedals-wall release, guest coverage and initial rear-facing transition issues, all fixed and reviewed again. Agent-owned criteria are checked; human Steam responsiveness/fun remains ticket 06's checkpoint, not certified by local fixtures.
- Replacement owners: 03 replaces controlled-motion fixture behavior with actual driving and consumes occupancy generations; 04 extends support/detachment into violent falls and rescue; 07 replaces rough truck/long access ramps with modeled presentation while preserving continuous physical access.

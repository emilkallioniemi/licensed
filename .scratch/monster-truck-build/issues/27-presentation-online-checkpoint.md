# 27: Validate the complete presentation online

Status: ready-for-agent
Blocked by: 16, 22, 24, 26
Parent: [A complete monster truck vehicle](../../monster-truck/spec.md)

## What to build

Three humans experience the finished assets, sound and complete test together, with recorded fixes for presentation and responsiveness.

## Acceptance criteria

- [ ] Prepare acceptance build integrating entire specified inventory, all hazard variants and current license/results behavior; identify missing assets rather than treating them as optional polish.
- [ ] Review successful play and every serious-accident type with exactly three humans, including user feedback on online movement/driving/boarding/handovers.
- [ ] Verify intended-position hazard/instrument readability, first-/third-person gestures/card, learner/examiner animations, readable truck wreckage, and clean retries/returns across peers.
- [ ] Mix engine, suspension/tyres/metal/cabin, footsteps/impacts, machinery/worker cues, radio, examiner and player voice; preserve intelligibility, distinct hazard cues and restrained repetition.
- [ ] Fix distracting clipping, absent reactions, duplicated effects, gaps/clipping in audio, ordinary roof sliding, frequent snaps and laggy controls; perform focused regressions after changes.
- [ ] Record build and observed acceptance for inventory, sound, accidents and responsiveness, plus bounded revision evidence. Missing human feedback is not a pass; park ready-for-human if required after preparation.

## Implementation and verification guidance

Read the parent specification in full before implementation; the sections most relevant here are **Finished vehicle and persistence acceptance; Asset production and finished presentation**. These criteria narrow this ticket's deliverable; they do not replace the spec's detailed rules. Use the domain vocabulary and preserve the exactly-three-human and Steam-only shipping ADRs.

Use the confirmed seams: public RoomState commands for booking, one host-owned attempt boundary for lifecycle/scoring/choices, and the public license store with local/Cloud adapters for durability. Extend existing Godot scene harness patterns for physical/input integration. Assert observable behavior rather than private fields or a test seam per sensor. Record meaningful tests and build-linked evidence under Comments.

This is retained implementation toward the complete vehicle. Any temporary harness or presentation must be labeled and its replacement owner recorded; do not count agent fixtures as evidence of human enjoyment or shipping Steam feel. Perform agent-owned production, integration and verification before requesting an unavailable human action. If required three-human play or owned-app access is unavailable, record the exact remaining dependency and use ready-for-human, not done. Gameplay tuning candidates stay provisional until their checkpoint evidence supports them.

## Comments

- 2026-09-13: Published after the user authorized the proposed 28-ticket breakdown. Dependencies refer only to implementation tickets in this directory, not the sixteen resolved wayfinder decisions.

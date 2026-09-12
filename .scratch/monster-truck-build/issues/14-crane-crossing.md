# 14: Avoid the crane’s suspended wreck

Status: ready-for-agent
Blocked by: 10
Parent: [A complete monster truck vehicle](../../monster-truck/spec.md)

## What to build

Players notice a suspended wreck sweep across the bridge entrance and wait safely or suffer a shared collision.

## Acceptance criteria

- [ ] Create and integrate modeled crane, suspended wreck, motors/beacon, sweep animation and load collisions.
- [ ] Two authored sweep directions from visible loading positions are selected afresh each attempt; one crossing, four seconds plus zero–two preparation, maximum six seconds lane occupation.
- [ ] Measure cue distance against stopping plus two seconds communication. Keep holding apron beyond load reach, including walking learners; load never chases truck.
- [ ] Defer unannounced crossing until truck and learners clear; no repeat scripted blockage while correcting or reversing.
- [ ] Recoverable glances count through existing deduplication; ensuing overturn, ravine fall or catastrophic learner impact guarantees failure. Meaningful load/debris physics stays host-owned.
- [ ] Verify both variants, latest activation, safe waiting and cascade outcomes through real scene behavior across peers, with machinery continuing visibly off-route and clean retry.

## Implementation and verification guidance

Read the parent specification in full before implementation; the sections most relevant here are **Changing hazards and physical consequences; Shared simulation and responsiveness**. These criteria narrow this ticket's deliverable; they do not replace the spec's detailed rules. Use the domain vocabulary and preserve the exactly-three-human and Steam-only shipping ADRs.

Use the confirmed seams: public RoomState commands for booking, one host-owned attempt boundary for lifecycle/scoring/choices, and the public license store with local/Cloud adapters for durability. Extend existing Godot scene harness patterns for physical/input integration. Assert observable behavior rather than private fields or a test seam per sensor. Record meaningful tests and build-linked evidence under Comments.

This is retained implementation toward the complete vehicle. Any temporary harness or presentation must be labeled and its replacement owner recorded; do not count agent fixtures as evidence of human enjoyment or shipping Steam feel. Perform agent-owned production, integration and verification before requesting an unavailable human action. If required three-human play or owned-app access is unavailable, record the exact remaining dependency and use ready-for-human, not done. Gameplay tuning candidates stay provisional until their checkpoint evidence supports them.

## Comments

- 2026-09-13: Published after the user authorized the proposed 28-ticket breakdown. Dependencies refer only to implementation tickets in this directory, not the sixteen resolved wayfinder decisions.

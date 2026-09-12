# 13: Encounter workers crossing with scrap

Status: ready-for-agent
Blocked by: 08, 09
Parent: [A complete monster truck vehicle](../../monster-truck/spec.md)

## What to build

Players perceive and avoid a working learner-sized hazard: a worker crossing the lane with a rattling scrap trolley.

## Acceptance criteria

- [ ] Produce and integrate worker/trolley/scrap models, pushing/walking animation, footsteps/rattle and strike aftermath on the flat lane before the climb.
- [ ] Provide left-to-right/right-to-left authored crossings from visible marked work bays, selected afresh per attempt with repeats allowed.
- [ ] Use four seconds preparation plus zero–two additional seconds and at most six seconds lane occupation; cross once, then keep working outside the path.
- [ ] Place cues for actual stopping distance plus two seconds communication at intended speed, perceptible from at least one occupied control; safe apron includes walking learners.
- [ ] If preparation has not started before arrival at conflict, defer until truck and on-foot learners clear. Do not spawn unavoidable collisions or repeated crossings during corrections.
- [ ] Trolley-only contact can be minor; truck/load/accident-debris worker strikes are serious. Harmless on-foot touch is distinct. Verify both variants, latest activation, shared aftermath and reset with real collision integration.

## Implementation and verification guidance

Read the parent specification in full before implementation; the sections most relevant here are **Changing hazards and physical consequences; Faults, timer, and immutable results**. These criteria narrow this ticket's deliverable; they do not replace the spec's detailed rules. Use the domain vocabulary and preserve the exactly-three-human and Steam-only shipping ADRs.

Use the confirmed seams: public RoomState commands for booking, one host-owned attempt boundary for lifecycle/scoring/choices, and the public license store with local/Cloud adapters for durability. Extend existing Godot scene harness patterns for physical/input integration. Assert observable behavior rather than private fields or a test seam per sensor. Record meaningful tests and build-linked evidence under Comments.

This is retained implementation toward the complete vehicle. Any temporary harness or presentation must be labeled and its replacement owner recorded; do not count agent fixtures as evidence of human enjoyment or shipping Steam feel. Perform agent-owned production, integration and verification before requesting an unavailable human action. If required three-human play or owned-app access is unavailable, record the exact remaining dependency and use ready-for-human, not done. Gameplay tuning candidates stay provisional until their checkpoint evidence supports them.

## Comments

- 2026-09-13: Published after the user authorized the proposed 28-ticket breakdown. Dependencies refer only to implementation tickets in this directory, not the sixteen resolved wayfinder decisions.

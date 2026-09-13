# 11: Reverse beside the working crusher

Status: ready-for-agent
Blocked by: 10
Parent: [A complete monster truck vehicle](../../monster-truck/spec.md)

## What to build

Players reverse through the crusher-side bend while a modeled crusher works beside the legal route.

## Acceptance criteria

- [ ] Create turnaround, L-shaped bend, refuge, marked forward exit, yielding cone line and substantial loading apron; accommodate whole truck plus walking space. Initial section budget is 70 seconds.
- [ ] Require full stop in turnaround, reverse around the bend, then all tyre contacts inside refuge at rest for two seconds; exit forward afterward.
- [ ] Animate and sound a fixed-cycle crusher compacting an unoccupied wreck outside legal route/refuge. Its phase cannot make a correct manoeuvre impossible.
- [ ] Physically entering the marked open chamber and being caught causes crushing and shared serious failure; a cone crossing alone does not move the truck into the crusher.
- [ ] Integrate generated examiner request, actual completion/collision observations, boundary deduplication and persistent local wreckage with reset.
- [ ] Verify valid untidy reverse, retries of the manoeuvre, safe refuge at every crusher phase and chamber failure. No extra randomized encounter, machinery puzzle or forced on-foot item.

## Implementation and verification guidance

Read the parent specification in full before implementation; the sections most relevant here are **Fixed route and completion; Changing hazards and physical consequences**. These criteria narrow this ticket's deliverable; they do not replace the spec's detailed rules. Use the domain vocabulary and preserve the exactly-three-human and Steam-only shipping ADRs.

Use the confirmed seams: public RoomState commands for booking, one host-owned attempt boundary for lifecycle/scoring/choices, and the public license store with local/Cloud adapters for durability. Extend existing Godot scene harness patterns for physical/input integration. Assert observable behavior rather than private fields or a test seam per sensor. Record meaningful tests and build-linked evidence under Comments.

This is retained implementation toward the complete vehicle. Any temporary harness or presentation must be labeled and its replacement owner recorded; do not count agent fixtures as evidence of human enjoyment or shipping Steam feel. Perform agent-owned production, integration and verification before requesting an unavailable human action. If required three-human play or owned-app access is unavailable, record the exact remaining dependency and use ready-for-human, not done. Gameplay tuning candidates stay provisional until their checkpoint evidence supports them.

## Comments

- From ticket 03: Reverse driving works, but this route ticket owns its actual geometry and scored manoeuvre observations; the temporary driving apron does not establish route completion.

- 2026-09-13: Published after the user authorized the proposed 28-ticket breakdown. Dependencies refer only to implementation tickets in this directory, not the sixteen resolved wayfinder decisions.

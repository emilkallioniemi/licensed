# 25: Finish accident damage and aftermath

Status: ready-for-agent
Blocked by: 12, 13, 14, 15
Parent: [A complete monster truck vehicle](../../monster-truck/spec.md)

## What to build

Every agreed serious accident leaves a readable, shared physical aftermath that survives until retry.

## Acceptance criteria

- [ ] Produce authored truck damaged shapes/detachable parts, flying props, ragdolls, dust/sparks and appropriate crushing damage. Start without gore; general-purpose deformation is unnecessary.
- [ ] Catastrophic truck crashes leave a visibly wrecked truck. Cover worker strike, overturn, ravine fall, occupied-machinery toppling, crusher accidents and catastrophic learner impacts distinctly.
- [ ] Trigger damage from actual host-confirmed incidents, preserving minor/serious distinctions and harmless-fall recovery. Stable event identities prevent duplicate significant effects.
- [ ] Keep debris affecting future driving/rescue/scoring host-owned and persistent during attempt; nonessential debris may be cosmetic. Correlate recoverable collision chains with catastrophe without double minor scoring.
- [ ] Maintain aftermath-before-results and immutable settled outcomes; no recovery/righting changes a guaranteed failure.
- [ ] Demonstrate each category across peers and verify impact audio, meaningful wreck visibility and complete geometry/effects reset on retry. Examiner-specific distress is owned by 23 and combines in 26/27.

## Implementation and verification guidance

Read the parent specification in full before implementation; the sections most relevant here are **Asset production and finished presentation; Changing hazards and physical consequences**. These criteria narrow this ticket's deliverable; they do not replace the spec's detailed rules. Use the domain vocabulary and preserve the exactly-three-human and Steam-only shipping ADRs.

Use the confirmed seams: public RoomState commands for booking, one host-owned attempt boundary for lifecycle/scoring/choices, and the public license store with local/Cloud adapters for durability. Extend existing Godot scene harness patterns for physical/input integration. Assert observable behavior rather than private fields or a test seam per sensor. Record meaningful tests and build-linked evidence under Comments.

This is retained implementation toward the complete vehicle. Any temporary harness or presentation must be labeled and its replacement owner recorded; do not count agent fixtures as evidence of human enjoyment or shipping Steam feel. Perform agent-owned production, integration and verification before requesting an unavailable human action. If required three-human play or owned-app access is unavailable, record the exact remaining dependency and use ready-for-human, not done. Gameplay tuning candidates stay provisional until their checkpoint evidence supports them.

## Comments

- From ticket 05: Replace temporary rolled truck/compressed learner presentation with authored wrecks, debris and ragdolls; physical aftermath must not mutate the settled result.

- 2026-09-13: Published after the user authorized the proposed 28-ticket breakdown. Dependencies refer only to implementation tickets in this directory, not the sixteen resolved wayfinder decisions.

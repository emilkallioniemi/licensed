# 24: Operate the shared radio

Status: ready-for-agent
Blocked by: 06, 07
Parent: [A complete monster truck vehicle](../../monster-truck/spec.md)

## What to build

Players physically operate a shared dashboard radio with three generated instrumental styles.

## Acceptance criteria

- [ ] Integrate reachable dashboard power, next-track and volume controls; nearest driving control can reach it, others ask or move to it. No remote access from every control.
- [ ] Produce exactly three instrumental tracks: calming easy listening, heavy rock and upbeat dance, using available generation tooling and editable sources. Suitable character/intelligibility matters, not exceptional fidelity.
- [ ] Synchronize shared radio state/playback, avoid duplicate toggles/advances, and make sound quieter outside the truck.
- [ ] Slightly duck music beneath player voice and examiner speech while keeping engine and hazard cues audible; use existing voice/audio integration.
- [ ] Scope interactions safely against driving/on-foot bindings and verify availability/physical reach, track switching, volume and no distracting gaps/clipping across peers.
- [ ] Demonstrate retry/return cleanup and consistent playback; final combined audio review with full examiner/hazards occurs in 27.

## Implementation and verification guidance

Read the parent specification in full before implementation; the sections most relevant here are **Asset production and finished presentation**. These criteria narrow this ticket's deliverable; they do not replace the spec's detailed rules. Use the domain vocabulary and preserve the exactly-three-human and Steam-only shipping ADRs.

Use the confirmed seams: public RoomState commands for booking, one host-owned attempt boundary for lifecycle/scoring/choices, and the public license store with local/Cloud adapters for durability. Extend existing Godot scene harness patterns for physical/input integration. Assert observable behavior rather than private fields or a test seam per sensor. Record meaningful tests and build-linked evidence under Comments.

This is retained implementation toward the complete vehicle. Any temporary harness or presentation must be labeled and its replacement owner recorded; do not count agent fixtures as evidence of human enjoyment or shipping Steam feel. Perform agent-owned production, integration and verification before requesting an unavailable human action. If required three-human play or owned-app access is unavailable, record the exact remaining dependency and use ready-for-human, not done. Gameplay tuning candidates stay provisional until their checkpoint evidence supports them.

## Comments

- 2026-09-13: Published after the user authorized the proposed 28-ticket breakdown. Dependencies refer only to implementation tickets in this directory, not the sixteen resolved wayfinder decisions.

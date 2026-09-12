# 10: Cross the ravine bridge

Status: ready-for-agent
Blocked by: 09
Parent: [A complete monster truck vehicle](../../monster-truck/spec.md)

## What to build

Players align both axles and cross a narrow bridge, with recoverable scrapes and catastrophic falls.

## Acceptance criteria

- [ ] Create modeled ravine bridge and approaches, initially about 1.5 truck widths, with flat holding/straightening apron and space reserved outside the future crane sweep.
- [ ] Require forward travel until the whole truck clears the far marker, after prior items; use physical markers and a generated subtitled examiner request. Initial section budget is 50 seconds.
- [ ] Integrate recoverable rail contact with existing incident deduplication; breaking through/falling produces host-confirmed serious failure and rough meaningful aftermath.
- [ ] Keep truck and walking learners’ safe approach, boarding and rescue space; out-of-order crossing cannot advance the ordered test.
- [ ] Demonstrate crossing, correction, scrape and ravine failure/retry with shared geometry and collision state; major scenery need not be universally destructible.
- [ ] Test completion through actual scene markers as well as attempt observations; later crane behavior and final damage coverage belong to 14 and 25.

## Implementation and verification guidance

Read the parent specification in full before implementation; the sections most relevant here are **Fixed route and completion; Changing hazards and physical consequences**. These criteria narrow this ticket's deliverable; they do not replace the spec's detailed rules. Use the domain vocabulary and preserve the exactly-three-human and Steam-only shipping ADRs.

Use the confirmed seams: public RoomState commands for booking, one host-owned attempt boundary for lifecycle/scoring/choices, and the public license store with local/Cloud adapters for durability. Extend existing Godot scene harness patterns for physical/input integration. Assert observable behavior rather than private fields or a test seam per sensor. Record meaningful tests and build-linked evidence under Comments.

This is retained implementation toward the complete vehicle. Any temporary harness or presentation must be labeled and its replacement owner recorded; do not count agent fixtures as evidence of human enjoyment or shipping Steam feel. Perform agent-owned production, integration and verification before requesting an unavailable human action. If required three-human play or owned-app access is unavailable, record the exact remaining dependency and use ready-for-human, not done. Gameplay tuning candidates stay provisional until their checkpoint evidence supports them.

## Comments

- 2026-09-13: Published after the user authorized the proposed 28-ticket breakdown. Dependencies refer only to implementation tickets in this directory, not the sixteen resolved wayfinder decisions.

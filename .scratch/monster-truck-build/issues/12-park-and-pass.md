# 12: Descend, park, and pass the complete route

Status: ready-for-agent
Blocked by: 11
Parent: [A complete monster truck vehicle](../../monster-truck/spec.md)

## What to build

Players finish the five-item route with reverse parallel parking and receive a shared passing rating.

## Acceptance criteria

- [ ] Create modeled uneven descent and bay between fixed wrecks with correction space, initially 1.6 truck lengths by 1.4 widths. Initial section budget is 70 seconds.
- [ ] Final item requires reverse parking, full footprint inside, length within 15 degrees, two seconds at rest and parking brake engaged, with all prior items complete.
- [ ] Host settles pass once at completion with time remaining and no serious fault. Zero or serious fault in the same simulation step wins, including during parking hold; later aftermath cannot revoke settled pass.
- [ ] Minor faults never cause failure. Candidate ratings: zero Suspiciously Competent, 1–3 Mostly Harmless, 4+ Technically Licensed; no speed bonus.
- [ ] Display latest shared result/faults/passing rating with generated pass/fail assessment and retry/return behavior. Durable personal license delivery follows in 17; identify that temporary gap.
- [ ] Verify each completion boundary, out-of-order finish, inaccurate but non-contact parking, serious/timeout ties and immutable result through public attempt tests and actual scene maneuvers.

## Implementation and verification guidance

Read the parent specification in full before implementation; the sections most relevant here are **Fixed route and completion; Faults, timer, and immutable results**. These criteria narrow this ticket's deliverable; they do not replace the spec's detailed rules. Use the domain vocabulary and preserve the exactly-three-human and Steam-only shipping ADRs.

Use the confirmed seams: public RoomState commands for booking, one host-owned attempt boundary for lifecycle/scoring/choices, and the public license store with local/Cloud adapters for durability. Extend existing Godot scene harness patterns for physical/input integration. Assert observable behavior rather than private fields or a test seam per sensor. Record meaningful tests and build-linked evidence under Comments.

This is retained implementation toward the complete vehicle. Any temporary harness or presentation must be labeled and its replacement owner recorded; do not count agent fixtures as evidence of human enjoyment or shipping Steam feel. Perform agent-owned production, integration and verification before requesting an unavailable human action. If required three-human play or owned-app access is unavailable, record the exact remaining dependency and use ready-for-human, not done. Gameplay tuning candidates stay provisional until their checkpoint evidence supports them.

## Comments

- 2026-09-13: Published after the user authorized the proposed 28-ticket breakdown. Dependencies refer only to implementation tickets in this directory, not the sixteen resolved wayfinder decisions.

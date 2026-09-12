# 05: Fail, assess, concede, and retry together

Status: ready-for-agent
Blocked by: 04
Parent: [A complete monster truck vehicle](../../monster-truck/spec.md)

## What to build

An accident or timeout fails the trio after its aftermath; players can unanimously concede, retry or return.

## Acceptance criteria

- [ ] Use the host-owned attempt boundary for timer, serious-fault observations, immutable once-only settlement and group choices. Initial rough setups demonstrate overturn, ravine fall and catastrophic crushing; later route tickets integrate their real triggers.
- [ ] Serious faults or timer zero guarantee failure; allow the interesting physical aftermath and an offline dry examiner response before results, without continuing the remaining test. Recovery cannot revoke failure.
- [ ] Replace host-only immediate return with Escape-overlay concession requiring three current agreements while active, with time running. Settled outcomes cannot be overridden.
- [ ] Show rough shared results with changeable Retry/Waiting room choices; three matching choices transition. Retry creates fresh state beside a secured truck, starts on synchronized arrival and bypasses booking/chairs.
- [ ] Invalidate choices on membership/attempt changes; reject stale/duplicate commands. Guest departure returns survivors; host loss sends guests to their own rooms with no migration. Unfinished attempts are abandoned.
- [ ] Test time, concession/departure races, once-only scored events and clean reset through public attempt behavior plus scene aftermath. Record temporary presentation for 23/25/26; passing and persistence arrive in 12/17.

## Implementation and verification guidance

Read the parent specification in full before implementation; the sections most relevant here are **Faults, timer, and immutable results; Shared simulation and responsiveness**. These criteria narrow this ticket's deliverable; they do not replace the spec's detailed rules. Use the domain vocabulary and preserve the exactly-three-human and Steam-only shipping ADRs.

Use the confirmed seams: public RoomState commands for booking, one host-owned attempt boundary for lifecycle/scoring/choices, and the public license store with local/Cloud adapters for durability. Extend existing Godot scene harness patterns for physical/input integration. Assert observable behavior rather than private fields or a test seam per sensor. Record meaningful tests and build-linked evidence under Comments.

This is retained implementation toward the complete vehicle. Any temporary harness or presentation must be labeled and its replacement owner recorded; do not count agent fixtures as evidence of human enjoyment or shipping Steam feel. Perform agent-owned production, integration and verification before requesting an unavailable human action. If required three-human play or owned-app access is unavailable, record the exact remaining dependency and use ready-for-human, not done. Gameplay tuning candidates stay provisional until their checkpoint evidence supports them.

## Comments

- 2026-09-13: Published after the user authorized the proposed 28-ticket breakdown. Dependencies refer only to implementation tickets in this directory, not the sixteen resolved wayfinder decisions.

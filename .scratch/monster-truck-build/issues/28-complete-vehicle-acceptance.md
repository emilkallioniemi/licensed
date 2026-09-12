# 28: Verify the complete vehicle acceptance

Status: ready-for-agent
Blocked by: 21, 27
Parent: [A complete monster truck vehicle](../../monster-truck/spec.md)

## What to build

The complete monster truck has traceable end-to-end evidence satisfying the specification.

## Acceptance criteria

- [ ] Audit every spec requirement against completed implementation tickets and concrete evidence; include all 68 user stories, route/fault boundaries, multiplayer races, assets and persistence semantics.
- [ ] Demonstrate waiting-room booking/departure, synchronized timed boarding, all five items, varied hazards, pass and serious/timeout/concession failure, aftermath, unanimous retry/return and clean reset.
- [ ] Verify personal stamp/best preservation across worse retries, membership/host changes and interrupted awards, with owned-app clean restoration evidence from 21.
- [ ] Confirm cooperation remains necessary after familiarity, fresh-trio controls learning, fair replay and user-approved online feel using checkpoint evidence; repeat only where final changes invalidate it.
- [ ] Confirm no temporary checkpoint behavior remains in the shipping path, no bots/scaled player count, no preassigned truck roles/test sheet, and no omitted inventory or unverified Cloud claim.
- [ ] Record final build/settings, evidence links, known limits and complete requirement coverage. Fix bounded integration gaps; explicitly record and block on larger unmet requirements instead of declaring the vehicle finished.

## Implementation and verification guidance

Read the parent specification in full before implementation; the sections most relevant here are **Finished vehicle and persistence acceptance; Out of Scope**. These criteria narrow this ticket's deliverable; they do not replace the spec's detailed rules. Use the domain vocabulary and preserve the exactly-three-human and Steam-only shipping ADRs.

Use the confirmed seams: public RoomState commands for booking, one host-owned attempt boundary for lifecycle/scoring/choices, and the public license store with local/Cloud adapters for durability. Extend existing Godot scene harness patterns for physical/input integration. Assert observable behavior rather than private fields or a test seam per sensor. Record meaningful tests and build-linked evidence under Comments.

This is retained implementation toward the complete vehicle. Any temporary harness or presentation must be labeled and its replacement owner recorded; do not count agent fixtures as evidence of human enjoyment or shipping Steam feel. Perform agent-owned production, integration and verification before requesting an unavailable human action. If required three-human play or owned-app access is unavailable, record the exact remaining dependency and use ready-for-human, not done. Gameplay tuning candidates stay provisional until their checkpoint evidence supports them.

## Comments

- 2026-09-13: Published after the user authorized the proposed 28-ticket breakdown. Dependencies refer only to implementation tickets in this directory, not the sixteen resolved wayfinder decisions.

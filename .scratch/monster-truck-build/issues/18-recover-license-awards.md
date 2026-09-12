# 18: Recover interrupted license awards

Status: ready-for-agent
Blocked by: 17
Parent: [A complete monster truck vehicle](../../monster-truck/spec.md)

## What to build

A player whose award delivery was interrupted can recover earned progress from a surviving original friend.

## Acceptance criteria

- [ ] Retain validated settled-result receipts containing stable attempt and exact participant identity, awarding only named participants.
- [ ] Exchange surviving receipts to recover a missed award with one original friend; no need to reunite all three. Duplicate or reordered receipts have no additional effect and unrelated awards are rejected.
- [ ] Merge available records/receipts monotonically by stamps and explicit best-rating quality; preserve personal ownership across hosts/groups.
- [ ] Validate schema, owner, known vehicle/rating and settlement contents, including malformed/unsupported data handling. Never invent recovery if every durable copy is lost.
- [ ] Exercise interrupted host distribution, one missed recipient, later two-friend recovery, duplicate receipts, unrelated accounts, worse/stale records and host loss around settlement.
- [ ] Demonstrate end-to-end recovery and a renewed durable local record through the public store and actual peer exchange. Document receipt contents/size growth to inform bounded retention and Cloud quota work in 20.

## Implementation and verification guidance

Read the parent specification in full before implementation; the sections most relevant here are **Personal licenses and Steam Cloud; Faults, timer, and immutable results**. These criteria narrow this ticket's deliverable; they do not replace the spec's detailed rules. Use the domain vocabulary and preserve the exactly-three-human and Steam-only shipping ADRs.

Use the confirmed seams: public RoomState commands for booking, one host-owned attempt boundary for lifecycle/scoring/choices, and the public license store with local/Cloud adapters for durability. Extend existing Godot scene harness patterns for physical/input integration. Assert observable behavior rather than private fields or a test seam per sensor. Record meaningful tests and build-linked evidence under Comments.

This is retained implementation toward the complete vehicle. Any temporary harness or presentation must be labeled and its replacement owner recorded; do not count agent fixtures as evidence of human enjoyment or shipping Steam feel. Perform agent-owned production, integration and verification before requesting an unavailable human action. If required three-human play or owned-app access is unavailable, record the exact remaining dependency and use ready-for-human, not done. Gameplay tuning candidates stay provisional until their checkpoint evidence supports them.

## Comments

- 2026-09-13: Published after the user authorized the proposed 28-ticket breakdown. Dependencies refer only to implementation tickets in this directory, not the sixteen resolved wayfinder decisions.

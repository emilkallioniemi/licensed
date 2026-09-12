# 19: Show personal licenses and booking-board stamps

Status: ready-for-agent
Blocked by: 08, 17
Parent: [A complete monster truck vehicle](../../monster-truck/spec.md)

## What to build

Players show their personal license to friends and see current players’ stamps on the booking board.

## Acceptance criteria

- [ ] Produce matching learner portraits, physical card/printed layout, monster-truck stamp, visibly empty slots and readable best-rating marks with editable sources and exports.
- [ ] L toggles the card with hands free; owner and nearby friends can read it. Taking a driving control puts it away and showing it while occupied is rejected.
- [ ] Animate hold-up/put-away in first and third person, preserving sight and body agreement across peers. Provide clear integration behavior for future emotes putting it away.
- [ ] Booking board displays each current player’s stamp ownership side by side and updates on membership/record changes; keep no-role booking behavior.
- [ ] Cards show their owner’s records across hosts/groups without exposing another account’s stored license; worse retries preserve presentation of best.
- [ ] Verify input/occupancy and membership changes through scene/public-store checks; visually review readability from owner/friend positions and clean retry/return.

## Implementation and verification guidance

Read the parent specification in full before implementation; the sections most relevant here are **Asset production and finished presentation; Personal licenses and Steam Cloud**. These criteria narrow this ticket's deliverable; they do not replace the spec's detailed rules. Use the domain vocabulary and preserve the exactly-three-human and Steam-only shipping ADRs.

Use the confirmed seams: public RoomState commands for booking, one host-owned attempt boundary for lifecycle/scoring/choices, and the public license store with local/Cloud adapters for durability. Extend existing Godot scene harness patterns for physical/input integration. Assert observable behavior rather than private fields or a test seam per sensor. Record meaningful tests and build-linked evidence under Comments.

This is retained implementation toward the complete vehicle. Any temporary harness or presentation must be labeled and its replacement owner recorded; do not count agent fixtures as evidence of human enjoyment or shipping Steam feel. Perform agent-owned production, integration and verification before requesting an unavailable human action. If required three-human play or owned-app access is unavailable, record the exact remaining dependency and use ready-for-human, not done. Gameplay tuning candidates stay provisional until their checkpoint evidence supports them.

## Comments

- 2026-09-13: Published after the user authorized the proposed 28-ticket breakdown. Dependencies refer only to implementation tickets in this directory, not the sixteen resolved wayfinder decisions.

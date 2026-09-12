# 21: Verify owned-app Cloud restoration

Status: ready-for-agent
Blocked by: 20
Parent: [A complete monster truck vehicle](../../monster-truck/spec.md)

## What to build

A license is demonstrably restored through the game’s owned Steam application on a clean computer or installation.

## Acceptance criteria

- [ ] Prepare executable validation build, bounded quota values and exact configuration checklist before requiring human-only account actions. Authorized Steamworks partner must supply owned app ID, edit/publish permissions and test-account ownership access.
- [ ] Configure/publish nonzero byte/file quotas with headroom and verify absence of overlapping Auto-Cloud rules; record published-state and access evidence, never credentials.
- [ ] Verify multiple real accounts on one OS account, development namespace isolation, changed hosts/groups and independent local persistence with Cloud unavailable.
- [ ] Exercise stale local/Steam copies, preserved prelaunch conflict scenarios, interrupted staging versus upload, rejected writes/quota, unsupported data and subsequent convergence without false restoration claims.
- [ ] After source sync, inspect Steam state/logs and compare exact expected restored payload on clean second computer; test reinstall both with retained local records and with genuinely absent independent records, then revisit source.
- [ ] Record app/build/account/machine labels, inputs and observed outcomes. App 480 or uninstall leaving local data does not satisfy owned-app restoration. If access/human participation is unavailable, preserve prepared work and park ready-for-human rather than declaring done.

## Implementation and verification guidance

Read the parent specification in full before implementation; the sections most relevant here are **Finished vehicle and persistence acceptance; Personal licenses and Steam Cloud**. These criteria narrow this ticket's deliverable; they do not replace the spec's detailed rules. Use the domain vocabulary and preserve the exactly-three-human and Steam-only shipping ADRs.

Use the confirmed seams: public RoomState commands for booking, one host-owned attempt boundary for lifecycle/scoring/choices, and the public license store with local/Cloud adapters for durability. Extend existing Godot scene harness patterns for physical/input integration. Assert observable behavior rather than private fields or a test seam per sensor. Record meaningful tests and build-linked evidence under Comments.

This is retained implementation toward the complete vehicle. Any temporary harness or presentation must be labeled and its replacement owner recorded; do not count agent fixtures as evidence of human enjoyment or shipping Steam feel. Perform agent-owned production, integration and verification before requesting an unavailable human action. If required three-human play or owned-app access is unavailable, record the exact remaining dependency and use ready-for-human, not done. Gameplay tuning candidates stay provisional until their checkpoint evidence supports them.

## Comments

- 2026-09-13: Published after the user authorized the proposed 28-ticket breakdown. Dependencies refer only to implementation tickets in this directory, not the sixteen resolved wayfinder decisions.

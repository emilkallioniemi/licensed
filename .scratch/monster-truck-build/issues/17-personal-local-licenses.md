# 17: Earn and retain personal licenses locally

Status: ready-for-agent
Blocked by: 12
Parent: [A complete monster truck vehicle](../../monster-truck/spec.md)

## What to build

Each player immediately earns the shared pass on their own durable license and sees their retained best on results.

## Acceptance criteria

- [ ] Use a public personal-license store behind local/backup adapters. Scope owned-app, app-480 and development records separately to exact signed-in Steam identity serialized without precision loss; never use peer IDs/names/last account as fallback.
- [ ] A settled shared pass awards all three named participants identical stamp/attempt rating, retaining each person’s own stamp union and best quality across hosts/groups and weaker retries. No individual scoring.
- [ ] Commit locally and distribute at settlement before assessment finishes; recipients persist and acknowledge validated local success. Departure after settlement cannot revoke it.
- [ ] Implement recoverable checked temporary/previous-generation writes; distinguish absent, malformed, unsupported and failed reads. Preserve unreadable data rather than overwriting with blank records.
- [ ] On local write failure preserve memory, continue peer distribution, visibly report inability to save and allow retry without trapping results. Show personal retained best beside shared latest result.
- [ ] Test actual temporary storage restart/interruption stages, identity separation, best retention, duplicate delivery, local failure and completion/departure ordering. Durable cross-session friend receipt recovery is completed in 18.

## Implementation and verification guidance

Read the parent specification in full before implementation; the sections most relevant here are **Personal licenses and Steam Cloud**. These criteria narrow this ticket's deliverable; they do not replace the spec's detailed rules. Use the domain vocabulary and preserve the exactly-three-human and Steam-only shipping ADRs.

Use the confirmed seams: public RoomState commands for booking, one host-owned attempt boundary for lifecycle/scoring/choices, and the public license store with local/Cloud adapters for durability. Extend existing Godot scene harness patterns for physical/input integration. Assert observable behavior rather than private fields or a test seam per sensor. Record meaningful tests and build-linked evidence under Comments.

This is retained implementation toward the complete vehicle. Any temporary harness or presentation must be labeled and its replacement owner recorded; do not count agent fixtures as evidence of human enjoyment or shipping Steam feel. Perform agent-owned production, integration and verification before requesting an unavailable human action. If required three-human play or owned-app access is unavailable, record the exact remaining dependency and use ready-for-human, not done. Gameplay tuning candidates stay provisional until their checkpoint evidence supports them.

## Comments

- From ticket 05: Add personal records and retained-best data to the shared results, preserving immutable settlement.

- 2026-09-13: Published after the user authorized the proposed 28-ticket breakdown. Dependencies refer only to implementation tickets in this directory, not the sixteen resolved wayfinder decisions.

# 20: Back up licenses through Steam RemoteStorage

Status: ready-for-agent
Blocked by: 18
Parent: [A complete monster truck vehicle](../../monster-truck/spec.md)

## What to build

Personal licenses remain locally usable while valid surviving progress is backed up and reconciled through Steam storage.

## Acceptance criteria

- [ ] Implement explicit RemoteStorage adapter separate from independent account-scoped local records/receipts excluded from synchronization. Validate installed runtime bindings against existing research before enabling backup.
- [ ] Read/validate/merge surviving Steam, local and receipt copies before staging; commit merged data locally first. Never replace unavailable/corrupt/unsupported data with an empty license.
- [ ] Bound snapshot payload and receipt retention, document recovery horizon and compaction preserving earned records, and calculate byte/file quota plus replacement headroom. Do not introduce an unbounded Cloud archive.
- [ ] Start with bounded synchronous reads/writes and measure latency. If unsuitable, implement serialized asynchronous lifecycle with callback correlation, missing/late callbacks and timeout recovery before switching.
- [ ] Track staged generation so old completion cannot mark newer data backed up. Clearly distinguish confirmed local save, Steam-managed staging and actual cross-computer restoration; disabled Cloud/quota failures do not gate play.
- [ ] Test stronger/weaker copies, malformed data, quota/write failure, interrupted staging and dirty generations using public adapters plus narrowly scoped app-480 investigation where available.
- [ ] Prepare concrete owned-app handoff: app ID/access, calculated quotas, published settings, no overlapping Auto-Cloud, no shared Cloud app, Dynamic Cloud Sync initially disabled. Owned-app evidence is 21.

## Implementation and verification guidance

Read the parent specification in full before implementation; the sections most relevant here are **Personal licenses and Steam Cloud; Finished vehicle and persistence acceptance**. These criteria narrow this ticket's deliverable; they do not replace the spec's detailed rules. Use the domain vocabulary and preserve the exactly-three-human and Steam-only shipping ADRs.

Use the confirmed seams: public RoomState commands for booking, one host-owned attempt boundary for lifecycle/scoring/choices, and the public license store with local/Cloud adapters for durability. Extend existing Godot scene harness patterns for physical/input integration. Assert observable behavior rather than private fields or a test seam per sensor. Record meaningful tests and build-linked evidence under Comments.

This is retained implementation toward the complete vehicle. Any temporary harness or presentation must be labeled and its replacement owner recorded; do not count agent fixtures as evidence of human enjoyment or shipping Steam feel. Perform agent-owned production, integration and verification before requesting an unavailable human action. If required three-human play or owned-app access is unavailable, record the exact remaining dependency and use ready-for-human, not done. Gameplay tuning candidates stay provisional until their checkpoint evidence supports them.

## Comments

- 2026-09-13: Published after the user authorized the proposed 28-ticket breakdown. Dependencies refer only to implementation tickets in this directory, not the sixteen resolved wayfinder decisions.

# 16: Validate the complete test’s pacing and replay

Status: ready-for-agent
Blocked by: 12, 13, 14, 15
Parent: [A complete monster truck vehicle](../../monster-truck/spec.md)

## What to build

Repeated human attempts establish whether the full modeled and sounded route sustains enjoyable cooperation and fair replay.

## Acceptance criteria

- [ ] Prepare integrated arrival, five items, all six hazard variants, recovery/scoring, aftermath/results and reset with decent Blender models and generated driving/hazard/examiner audio. Box-only/placeholder-only full-test presentation is insufficient.
- [ ] Run exactly three humans through three familiarisation attempts rotating controls and at least three familiar attempts; extend for missing success or variant coverage. Label forced variant coverage as scaffolding.
- [ ] Record build/settings, controls/variants, results, total/section durations, inactive stretches, confusing/unavoidable collisions and reactions/desire to retry or improve ratings.
- [ ] Measure actual hazard braking/communication opportunity and safe waiting including walking learners; familiar players must still observe/communicate rather than recite timing.
- [ ] Make focused revisions prioritizing coordination/fairness before five-minute precision or six-minute timer tuning. Compare hazard-disabled sections if useful and shorter/longer aftermath windows while preserving failure/rating policy.
- [ ] After revisions use a fresh trio to verify learning, hints/H, repeat/T, held/rear steering, brakes and position-based instruments. Record retain/revise findings; do not mark complete without observed successful and sufficiently varied play.

## Implementation and verification guidance

Read the parent specification in full before implementation; the sections most relevant here are **Playable checkpoint 2: complete test, pacing, and replay**. These criteria narrow this ticket's deliverable; they do not replace the spec's detailed rules. Use the domain vocabulary and preserve the exactly-three-human and Steam-only shipping ADRs.

Use the confirmed seams: public RoomState commands for booking, one host-owned attempt boundary for lifecycle/scoring/choices, and the public license store with local/Cloud adapters for durability. Extend existing Godot scene harness patterns for physical/input integration. Assert observable behavior rather than private fields or a test seam per sensor. Record meaningful tests and build-linked evidence under Comments.

This is retained implementation toward the complete vehicle. Any temporary harness or presentation must be labeled and its replacement owner recorded; do not count agent fixtures as evidence of human enjoyment or shipping Steam feel. Perform agent-owned production, integration and verification before requesting an unavailable human action. If required three-human play or owned-app access is unavailable, record the exact remaining dependency and use ready-for-human, not done. Gameplay tuning candidates stay provisional until their checkpoint evidence supports them.

## Comments

- 2026-09-13: Published after the user authorized the proposed 28-ticket breakdown. Dependencies refer only to implementation tickets in this directory, not the sixteen resolved wayfinder decisions.

# 06: Validate three-player cooperation and online feel

Status: ready-for-human
Blocked by: 05
Parent: [A complete monster truck vehicle](../../monster-truck/spec.md)

## What to build

A retained playable checkpoint demonstrates whether all three controls are necessary, enjoyable and responsive online.

## Acceptance criteria

- [x] Prepare a reproducible Steam build/settings and test procedure covering boarding, moving turn, tight reverse, parking/roof access, falls and rescue.
- [ ] Run exactly three humans including the user, rotating host and every control. After familiarisation compare coordinated play against one idle participant, fixed rear steering and two people hopping controls.
- [ ] Record anticipation, each control’s engagement, sight-sharing, physical comedy and whether movement removes blind spots. Rear steering optionality, dull throttle/brake or two-person success require revision.
- [ ] Exercise contention, handover during turns, lost releases, stale commands, roof support, detachment, rescue and host/guest loss under ordinary and adverse connections.
- [ ] Record actual latency/jitter/loss, frame pacing, input response and correction frequency as diagnostics. User assessment that driving, walking, boarding and handovers feel very good is required; numbers alone are insufficient.
- [ ] Make bounded relevant revisions and repeat comparisons, retaining implementation. Record build-linked retain/revise findings and remaining work; do not mark done with missing human evidence or hide issues by removing free movement.

## Implementation and verification guidance

Read the parent specification in full before implementation; the sections most relevant here are **Playable checkpoint 1: cooperation and early online feel**. These criteria narrow this ticket's deliverable; they do not replace the spec's detailed rules. Use the domain vocabulary and preserve the exactly-three-human and Steam-only shipping ADRs.

Use the confirmed seams: public RoomState commands for booking, one host-owned attempt boundary for lifecycle/scoring/choices, and the public license store with local/Cloud adapters for durability. Extend existing Godot scene harness patterns for physical/input integration. Assert observable behavior rather than private fields or a test seam per sensor. Record meaningful tests and build-linked evidence under Comments.

This is retained implementation toward the complete vehicle. Any temporary harness or presentation must be labeled and its replacement owner recorded; do not count agent fixtures as evidence of human enjoyment or shipping Steam feel. Perform agent-owned production, integration and verification before requesting an unavailable human action. If required three-human play or owned-app access is unavailable, record the exact remaining dependency and use ready-for-human, not done. Gameplay tuning candidates stay provisional until their checkpoint evidence supports them.

## Comments

- 2026-09-13 user sequencing change: build modeled truck 07 and animated learners 08 before running this checkpoint. The current checkpoint ZIP predates those assets; refresh it after 08 before human trials. Human evidence is still required, and downstream work beyond 07–08 remains gated by this checkpoint.

### Orchestration attempt 2 — 2026-09-13

Outcome: blocked

Changes: Audited and retained the uncommitted checkpoint diagnostics, build tooling, Steam package, procedure, summarizer and evidence against `892b3fc8a2dc0ece4d1d57ad25d52f2e2429a600`. No concrete unmet agent-owned implementation work was found; this retry changes only this evidence comment. Preparation stays checked and all five human-dependent criteria stay unchecked; status remains claimed for the orchestrator to park.

Validation: Read both specifications, design/domain rules, attempt 1, `06-evidence.md`, complete tracked diff and new recorder/build/procedure/summarizer sources, manifest and existing verification results. Existing nine-suite, native display and final three-peer ENet results remain applicable; unchanged passing checks were not rerun. Existing standards/spec reviews are clear. Root's independent ZIP CRC/package/source-hash checks remain the archive verification evidence; this retry does not claim to have repeated them. Retained ZIP SHA-256: `72e9f082ac93324b8bae0a77fff4cbe7b2601da9775fa8a631e5c92df2a6d353`. Native fixture shutdown resource warnings and unavailable Steam login remain documented limitations.

Unmet criteria: Windows Steam launch with exactly three humans including the user; host/control rotations and idle/fixed-rear/two-person comparisons; anticipation, engagement, sight-sharing and comedy observations; ordinary/adverse Steam operation and interruption coverage; actual input-response diagnostics and the user's very-good assessment; evidence-led bounded revisions/repeats and build-linked retain/revise decisions. The user being available does not supply the absent three-human trial data.

Notes for later tickets: Preserve the checkpoint gate. Retained optional diagnostics and preparation introduce no replacement gameplay path. Temporary presentation ownership remains 07 truck/cab, 08 learners/recovery animation, 09–12 route/encounters/scoring, 23 examiner audio, 25 accident aftermath and 26 results presentation; tuning remains provisional pending these human comparisons.

### Orchestration attempt 1 — 2026-09-13

Outcome: blocked

Changes: Opt-in diagnostics, reproducible local Windows Steam package, launcher, session/comparison procedure, summarizer, raw captures and evidence retained uncommitted against `892b3fc8a2dc0ece4d1d57ad25d52f2e2429a600`.

Validation: Behavioral red/green, nine boundary/physical suites, native display and final three-peer ENet fixture passed. Both review axes clear. Root independently verified ZIP CRC, packaged hashes and current-source manifest. ZIP SHA-256: `72e9f082ac93324b8bae0a77fff4cbe7b2601da9775fa8a631e5c92df2a6d353`.

Unmet criteria: Actual Windows Steam launch and exactly three-human trials including the user; host/control rotations and reduced-contribution comparisons; engagement/sight-sharing/comedy observations; ordinary/adverse Steam connections and interruptions; recorded input response and the user's very-good judgement; evidence-led revisions/repeats and retain/revise findings.

Notes for later tickets: Preserve the checkpoint gate and documented temporary presentation ownership. A fresh retry will audit retained preparation before parking for the missing human evidence.

- From ticket 05: Evaluate shared failure, six-second provisional aftermath, concession and desire to retry with three humans over Steam; agent three-peer and display checks pass (05-evidence.md).

- From ticket 04: Evaluate provisional recovery tuning, ejection fairness and responsiveness with three humans over Steam. Native ENet checks pass; they do not establish Steam feel.

- From tickets 02–03: Agent fixtures verify physical boarding, roof riding, moving releases and actual shared driving. Exactly three humans must still judge control necessity, cooperation and Steam feel; see 02-evidence.md and 03-evidence.md.

- From ticket 01: Three-peer development ENet launch and display transition checks pass; these do not establish three-human Steam cooperation or feel acceptance.

- 2026-09-13: Published after the user authorized the proposed 28-ticket breakdown. Dependencies refer only to implementation tickets in this directory, not the sixteen resolved wayfinder decisions.

- 2026-09-13: Agent preparation complete; see [06-evidence.md](../06-evidence.md) and [session procedure](../checkpoint-06/session.md). Retained local Windows Steam export/settings/launcher/summarizer and build hashes, opt-in actual diagnostic capture, red/green native three-peer verification, full boundary/physical suite and display checks prepared; both reviews have no outstanding findings. Exactly three-human Steam trials including the user, Windows launch, ordinary/adverse comparisons, subjective acceptance and resulting bounded revisions remain unperformed. Only preparation criterion checked; keep the human checkpoint gated.

- From completed 07–08: use `export/checkpoint-06-modeled/licensed-checkpoint-06.zip` (SHA-256 `0e7237433698e990fe6af9076910472e3a1a5243cf55f1a670abf5e3d07b58ee`) and the refreshed session/manifest. Both modeled tickets and agent checks are complete; Windows launch and three-human Steam acceptance remain pending. See ../08-evidence.md.

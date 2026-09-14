# 06: Validate three-player cooperation and online feel

Status: ready-for-human
Blocked by: 05, 32
Parent: [A complete monster truck vehicle](../../monster-truck/spec.md)

## What to build

A retained playable checkpoint demonstrates whether all three controls are necessary, enjoyable and responsive online.

## Acceptance criteria

- [ ] Prepare a reproducible revised Windows/macOS Steam playtest package with build/settings and instructions covering boarding, shared sight, steering/speed/balance, swaps, recovery, the short test, results and retry.
- [ ] Exactly three humans including the user rotate all three responsibilities. Record whether each is understandable within a minute, regularly engaging and useful; compare active and idle balance after familiarisation. Revise a dull or dispensable balance role.
- [ ] Record a successful three-item test and a recovered-mistake attempt that still passes. Verify readable instructions, targets and completion, a generous timer and motivation to improve the rating.
- [ ] Validate responsive boarding, driving, secure seating, stopped consensual swaps and shared recovery under ordinary and adverse Steam conditions; exercise contention, stale/lost inputs and host/guest loss with agent fixtures and human checks as appropriate.
- [ ] Record build-linked user assessment of feel, meaningful diagnostics and retain/revise findings. Agent fixtures and numerical thresholds do not establish human enjoyment or acceptance.
- [ ] Resolve material findings and repeat affected comparisons before marking done or opening full-route expansion.

## Implementation and verification guidance

Read the active amendment in the parent spec. Reuse the existing public attempt, occupancy and lifecycle boundaries and scene/network harnesses. Revision tickets 29–32 must be completed and packaged before this human checkpoint. This ticket remains ready-for-human and blocked by 32; it is not a request to replay the unchanged build.

Earlier comments describe historical preparation and requirements. Physical-only sight, rear-steering necessity, involuntary seated ejection and forced physical rescue are superseded by the amendment. Preserve three humans, Steam shipping transport and honest evidence reporting.

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

### 2026-09-14 — Playtest outcome: revise

The user reports playing with two friends. Sight required frequent dismounting, front steering felt good, speed was unintuitive/unpleasant, rear steering felt unnecessary, and laughter faded. This does not establish every originally requested comparison, build identity or network metric. The static scrapyard did not yet contain the full route. Checkpoint acceptance is withheld; use the active spec amendment and proposed revision breakdown for the next build.

- 2026-09-14: User approved the four-ticket revision breakdown (“I trust you.”). Published 29–32 and added 32 as a blocker; acceptance remains pending.

- 2026-09-14: Revised high-body monster-truck local Windows/macOS packages are prepared; blockers 29–32 are complete. Use `export/monster-truck-high-body-2026-09-14`, source manifest `5a2289862bcce2ef534fb6676f95f4957b1640f1e8eaf60a1a2ec79c517d5f7b`, and the packaged SESSION.md. Human acceptance remains pending.

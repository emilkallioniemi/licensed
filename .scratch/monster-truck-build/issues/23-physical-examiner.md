# 23: Ride with the physical examiner

Status: ready-for-agent
Blocked by: 07, 12
Parent: [A complete monster truck vehicle](../../monster-truck/spec.md)

## What to build

A physical examiner reacts to driving and delivers the complete dry assessment repertoire.

## Acceptance criteria

- [ ] Produce examiner model/rig, clipboard/coffee and seated/assessment/bracing/puke/swear animations, integrated into dedicated passenger location without distracting prop separation/clipping.
- [ ] Brace on hard jolts; cap puke at one and muttered swears at two per attempt, with at least 30 seconds between distress outbursts. Bracing is not itself an outburst; tune thresholds and reset limits on retry.
- [ ] Generate offline speech and distress sounds: arrival, all five requests, pass/fail/timeout/concession and three alternatives per spec fault category. Avoid repeated alternatives until a category is exhausted.
- [ ] Use one plain dry sentence for assessments, no driving advice, encouragement, role addressing, exclamations or stage directions; severe events receive understatement. Physical distress does not become constant shouting.
- [ ] Subtitle speech; prioritize scored comments over repeats and distress, T does not stack or interrupt. Use host-confirmed stable events so peers do not duplicate reactions.
- [ ] Demonstrate full route assessments and controlled fault-category playback; verify limits/priorities/reset and visual/audio integration. Offline WAV pipeline avoids recorded runtime TTS crash path.

## Implementation and verification guidance

Read the parent specification in full before implementation; the sections most relevant here are **Asset production and finished presentation; Faults, timer, and immutable results**. These criteria narrow this ticket's deliverable; they do not replace the spec's detailed rules. Use the domain vocabulary and preserve the exactly-three-human and Steam-only shipping ADRs.

Use the confirmed seams: public RoomState commands for booking, one host-owned attempt boundary for lifecycle/scoring/choices, and the public license store with local/Cloud adapters for durability. Extend existing Godot scene harness patterns for physical/input integration. Assert observable behavior rather than private fields or a test seam per sensor. Record meaningful tests and build-linked evidence under Comments.

This is retained implementation toward the complete vehicle. Any temporary harness or presentation must be labeled and its replacement owner recorded; do not count agent fixtures as evidence of human enjoyment or shipping Steam feel. Perform agent-owned production, integration and verification before requesting an unavailable human action. If required three-human play or owned-app access is unavailable, record the exact remaining dependency and use ready-for-human, not done. Gameplay tuning candidates stay provisional until their checkpoint evidence supports them.

## Comments

- From ticket 05: Replace the single temporary offline failure line/voice with complete categories and alternatives; validate nonempty generated audio and actual playback.

- From ticket 03: Replace assets/monster_truck/temporary_request.wav with complete offline examiner coverage, repeats, reactions and mix; the retained PowerShell source demonstrates the current speech path.

- 2026-09-13: Published after the user authorized the proposed 28-ticket breakdown. Dependencies refer only to implementation tickets in this directory, not the sixteen resolved wayfinder decisions.

- From completed 07: replace the temporary reused learner examiner body/pose in the modeled examiner seat; see ../07-evidence.md.

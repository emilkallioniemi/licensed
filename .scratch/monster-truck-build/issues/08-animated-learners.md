# 08: Move as expressive, animated learners

Status: done
Blocked by: 05
Parent: [A complete monster truck vehicle](../../monster-truck/spec.md)

## What to build

Each player moves, boards and drives as an expressive learner visible consistently to friends.

## Acceptance criteria

- [x] Astra may redesign the learner freely; create one expressive body and rig with three distinct clothing colours, first-person hands and portrait-ready appearance. No customization screen.
- [x] Integrate idle/walk, jump/fall/land, boarding/climbing, seated control use, take/leave transitions and recoverable ragdoll entry/exit.
- [x] First-/third-person poses agree with host-confirmed support and occupancy; preserve essential sight and avoid distracting clipping through truck or hands.
- [x] Provide articulated hands suitable for later five emotes and physical license; do not require gesture or card gameplay yet.
- [x] Keep editable source assets and generation scripts with Godot-ready exports, materials and animation transitions; share humanoid rigging for later people where useful.
- [x] Demonstrate three coloured learners walking, boarding, swapping and recovering across peers and retry. Use existing movement scenes plus visual review; 22 owns completed gestures.

## Implementation and verification guidance

Read the parent specification in full before implementation; the sections most relevant here are **Asset production and finished presentation**. These criteria narrow this ticket's deliverable; they do not replace the spec's detailed rules. Use the domain vocabulary and preserve the exactly-three-human and Steam-only shipping ADRs.

Use the confirmed seams: public RoomState commands for booking, one host-owned attempt boundary for lifecycle/scoring/choices, and the public license store with local/Cloud adapters for durability. Extend existing Godot scene harness patterns for physical/input integration. Assert observable behavior rather than private fields or a test seam per sensor. Record meaningful tests and build-linked evidence under Comments.

This is retained implementation toward the complete vehicle. Any temporary harness or presentation must be labeled and its replacement owner recorded; do not count agent fixtures as evidence of human enjoyment or shipping Steam feel. Perform agent-owned production, integration and verification before requesting an unavailable human action. If required three-human play or owned-app access is unavailable, record the exact remaining dependency and use ready-for-human, not done. Gameplay tuning candidates stay provisional until their checkpoint evidence supports them.

## Comments

- 2026-09-13 user sequencing change: implement 07 and 08 before the three-human playtest. Preserve current movement/support/control behavior and verify across agent network fixtures; human Steam acceptance remains in 06 afterward. Existing modeled lobby and learner establish the presentation quality reference.

- From ticket 04: Replace ticket 04's temporary compressed learner pose with the agreed animation and rigging.

- 2026-09-13: Published after the user authorized the proposed 28-ticket breakdown. Dependencies refer only to implementation tickets in this directory, not the sixteen resolved wayfinder decisions.

- 2026-09-13: From completed 07: rig seated learners and hands to the modeled seats/wheels/pedals; close occupied-body clipping using the 07 occupied-cab baseline, preserve physical instrument sight, and refresh the Windows checkpoint ZIP after 08. See ../07-evidence.md.

- 2026-09-13 claimed after 07; fixed ticket base `600dd5fb2e103d63a429c52d3069c7bbef7b85f2`. User-authorized scope is 08 then refreshed checkpoint package; 06 remains the human gate.


- 2026-09-13 implemented and verified; Status remains claimed for the orchestrator's review/commit. See [08 evidence](../08-evidence.md): original articulated body/three palettes/matching portraits, full required movement and authored recoverable collapse/recovery, same world first-person hands, actual seat/wheel/pedal contact and clear physical instrument sight. Host support/occupancy remains authoritative. Distinct examiner 23, physical license 19 and full gestures 22 retain their scope.
- Verification: eleven final headless suites PASS; native three-world boarding/turn/handovers/retake-before-landing/recovery/guest-loss run PASS; separate native failure/retry and ready-up runs PASS. Actual occupied forward/down-look and movement/recovery screenshots inspected. Genuine prone-clearance, late-tumble, moving-hand-contact and airborne-retake reds were fixed. Both review axes have no remaining source findings; final evidence closure belongs to the orchestrator.
- Refreshed local Windows package: `export/checkpoint-06-modeled/licensed-checkpoint-06.zip`, SHA-256 `0e7237433698e990fe6af9076910472e3a1a5243cf55f1a670abf5e3d07b58ee`. Independent CRC, all 177 source hashes, seven packaged-file hashes, manifest and x86_64 PE/shipping DLL checks pass. No Windows launch, human Steam acceptance, publishing or external sharing is claimed. 06 remains the human gate and 09+ remain gated.

- 2026-09-13 orchestration verification: both final review axes clear; native PASS markers, sixteen workspace/native hashes, 177 build source hashes, package hashes/CRC, x86_64 PE and shipping DLL equality independently verified. One ticket commit follows fixed base `600dd5fb2e103d63a429c52d3069c7bbef7b85f2`.

# Ticket 06 checkpoint preparation and evidence

Ticket/review base: `892b3fc8a2dc0ece4d1d57ad25d52f2e2429a600`. All changes remain uncommitted for the orchestrator. This checkpoint is **blocked for human evidence**, not complete. No human session, Steam acceptance, retain decision or tuning revision has been invented.

## Prepared deliverables

`checkpoint-06/session.md` supplies the reproducible Windows/Steam settings and launcher, boarding/offset moving turn/tight reverse/parking/roof/fall/rescue procedure, familiarisation, all three host rotations and every control rotation, baseline versus each idle contributor/fixed rear angles/two-person control hopping, ordinary/adverse conditions, short blackholes, contention/stale release/handover checks, host and guest loss at operation/loading/settlement, and per-trial retain/revise records. Exactly three humans include the user, with separate Windows computers and Steam accounts. Missing impairment tooling is explicitly a dependency rather than fabricated adversity. App 480 is development Steam, not owned-app validation.

The retained rough apron/truck/timer/examiner/failure/retry implementation from 01–05 is unchanged. Diagnostics add no player-facing screen and change no control, sight, movement or recovery rule. `--checkpoint-diagnostics` creates a small recorder on each peer, writing JSONL under `user://`. Normal launches do not instantiate it. Its only gameplay hooks observe sent intentions and reconciliation. Guest-to-host unreliable round-trip probes run twice per second, sharing the command channel; RTT variation and three-second timeouts are **application observations**, not Steam packet loss or one-way latency. The host has no guest-path latency sample and records null for that metric. Raw frame spacing uses a monotonic wall clock between callbacks, not smoothed engine delta. Input acknowledgement age includes host simulation and snapshot delivery; screen-recorded key-to-visible movement remains required for actual input response. Learner reconciliation distances and >1.5 m counts include intentional fixture placement, occupancy and accident changes, so they are not by themselves evidence of undesirable corrections. The summarizer preserves unavailable values as null and unresolved probes separately.

## Actual agent verification

Runtime and native GodotSteam isolation follow `04-evidence.md`: Godot 4.7.2, matching GodotSteam 4.22.1 Mac support in a temporary copy. Steam login is unavailable. All native scene networking here is the explicitly labelled ENet fixture, never human play or Steam acceptance.

- `06-diagnostics-red.log`: genuine behavioral red, exit 1; all three real peers failed the opt-in capture assertion before implementation. No parse failure substituted for this red.
- `06-diagnostics-green.log`: initial three-peer boarding/recovery capture and final PASS, exit 0. Its smoothed-delta frame capture was superseded by the monotonic frame fix and final rerun below. Initial raw files remain labelled `checkpoint-06/agent-capture/`; do not use their frame values as the final result.
- `06-diagnostics-final.log`: complete three-peer boarding/driving/recovery/guest-loss checks PASS with final recorder, no script errors; retains the previously documented shutdown-only ObjectDB/resource warning. `checkpoint-06/agent-capture-final/` contains its actual JSONL files, and `06-diagnostics-final-summary.json` contains measured summaries. No malformed lines. Two guest RTT medians are 7.792 ms and 10.861 ms, with successive-RTT-change medians 3.622 ms and 3.406 ms. Timed-out application probes are 4/71 and 0/87 resolved probes; the run deliberately includes guest loss/interruptions and these are not ordinary-path packet-loss estimates. Guest acknowledgement medians are 34.762 ms and 34.593 ms, with maxima 241.740 ms and 733.781 ms. Raw frame p95 spans 11.930–12.281 ms, maxima 181.455–233.828 ms in this headless multi-world process. Large learner correction rates are approximately 0.098/s and 0.157/s including scripted physical transitions. These are capture/fixture observations, not shipping performance targets or acceptance. Transport loss and key-to-visible response remain unavailable until appropriate capture/human video.
- Required full suite ran once: `06-verify_room_state.log`, `06-verify_attempt_state.log`, `06-verify_driving.log`, `06-verify_recovery.log`, `06-verify_steam_client.log`, `06-verify_motion.log`, `06-verify_reception_input.log`, `06-verify_failure.log`, `06-verify_recovery_scene.log`: all exit 0. This covers public state and actual collision/physical integration. The final change only corrects diagnostic frame measurement, so the focused network capture was rerun for it.
- `06-ready.log`: native windowed ready-up/transition/loading-loss/host-loss fixture exit 0, final PASS, no script/audio errors.
- `06-import.log`: no script/parse errors. Sandbox certificate/editor-settings diagnostics and unavailable Steam login are environmental, not suppressed success claims.
- Python build/summarizer source compiles; ZIP integrity, included file hashes, x86_64 PE signatures, and exact shipping DLL equality verified. `git diff --check` passes. The first `py_compile` command encountered the system Python cache sandbox restriction; direct in-memory compilation subsequently passed without writing system caches.

## Windows Steam export

Local shareable artifact: `export/checkpoint-06/licensed-checkpoint-06.zip` (ignored generated binary, retained locally). SHA-256: `72e9f082ac93324b8bae0a77fff4cbe7b2601da9775fa8a631e5c92df2a6d353`. No publishing or external sharing was performed. `checkpoint-06/build-manifest.json` records the exact working-source hashes rather than pretending an uncommitted build is HEAD alone; source-manifest digest is `6dda39923b42e609ad1ea7fa7a26a6277836d8288fcb06c567b6e5dd8fc4ccaf`.

Official Godot 4.7.2 TPZ: `/private/tmp/Godot_v4.7.2-stable_export_templates.tpz`, SHA-256 `f298490b8d44d934be425a5a65a51bf15f422428b229a06a6e11d9ffea248011`; extracted Windows release x86_64 template SHA-256 `d34d36f3be1a6c49c56525ae86469b92e4f417ddf0b43cf00dd80c385c4b0562`. Source: official Godot GitHub release `https://github.com/godotengine/godot-builds/releases/download/4.7.2-stable/Godot_v4.7.2-stable_export_templates.tpz`. Root obtained it after sandbox networking required approval.

Build script creates isolated staging and uses the repository's Windows export preset and release DLLs. On Mac it adds matching native GodotSteam only in staging to register Steam classes while importing/exporting; those helper hashes are recorded separately. The shipping repository's addon/preset is unchanged. The first export in `/private/tmp/licensed-checkpoint-06-build-1` had undeclared-Steam parse errors despite exit 0 and is **invalid**; do not distribute it. Build script now rejects script/parse/export errors. The corrected `06-export-final.log` has no script/parse/export errors; only sandbox certificate/editor-settings messages. Export includes exe, pck, release GodotSteam DLL and Steam API DLL plus launcher, procedure, summarizer and manifest. No `steam_appid.txt`, Mac library, ENet launcher or debug DLL is in the zip. Windows executable and both DLLs have PE x86_64 signatures, package CRCs pass, and DLL hashes match repository sources. A native Windows/Steam launch is still unperformed on this Mac: the first three-computer session must confirm it before starting acceptance trials.

Reproduce to a new empty output directory:

```sh
python3 .scratch/monster-truck-build/checkpoint-06/build.py \
  --godot /Users/emka/Downloads/Godot.app/Contents/MacOS/Godot \
  --windows-template /private/tmp/licensed-06-windows-templates/windows_release_x86_64.exe \
  --macos-godotsteam /private/tmp/licensed-04-macos-verification/addons/godotsteam/osx \
  --output /private/tmp/licensed-checkpoint-06-next
```

On Windows, supply the Godot executable and matching release template; omit `--macos-godotsteam`. Archive the manifest/zip digest each time; any bounded gameplay revision requires a new build and matched repeats.

## Reviews and remaining dependency

Standards: no hard documented-standard violations or actionable smells in recorder/procedure. Spec: no actionable recorder/procedure findings; recommended rescue setup refinement is incorporated. Final follow-ups on both axes found no outstanding findings; Spec independently checked archive CRC/hash, all packaged file hashes and source hashes. The final packaging-only update adds the documented summarizer to the archive and emits summary files as valid JSON arrays; archive/file hashes and CRC were rechecked.

Human dependency: the user plus two other humans on distinct logged-in Steam accounts/Windows computers must execute and record the prepared trials, adverse connection/interruptions and subjective assessments. The user must explicitly judge driving, walking, boarding and handovers very good without laggy feel; all control-necessity and retain/revise findings remain pending. If observations require changes, the agent implements bounded relevant revisions and repeats comparisons. Only preparation is verified; no human-dependent criterion is checked.

Temporary ownership remains: 07 truck/cab art, 08 learner/recovery animation, 09–12 final route/encounters/scoring, 23 complete examiner audio, 25 authored accident aftermath, 26 final results presentation. These are later-ticket ownership notes, not permission to bypass checkpoint 06 or evidence that its handling is accepted.

# Checkpoint 06: three-human Steam session

Status: prepared; no human session has occurred. Use exactly three humans including the user, each on a separate Windows x86_64 computer with a different logged-in Steam account. The user moved truck/learner production 07–08 before this session. The current archived 06 ZIP predates those modeled assets; 08 must refresh and hash the checkpoint build before the session. This remains the cooperation exercise rather than the complete driving test. All handling, ejection, rescue and six-second aftermath tuning remains provisional. No player can pass the full vehicle yet: checkpoint success below means completing the comparison exercise, not earning a license.

## Build and capture

Use the build manifest beside the local zip; all three verify its SHA-256. Record manifest/source digest, Godot version, GodotSteam version, Windows version, CPU/GPU, display resolution/refresh, VSync, frame cap, wired/Wi-Fi connection, host, pseudonymous A/B/C identifiers and UTC start/end. Use the same build/settings for comparisons. Begin at 1280×720 windowed, Forward+, 60 FPS cap, existing 60 Hz physics; record any necessary machine-specific deviation. Keep Steam running. Launch via `run-checkpoint.cmd` (or `licensed.exe --windowed --resolution 1280x720 --max-fps 60 -- --checkpoint-diagnostics`). No ENet flag. App 480 is development Steam transport, not owned-app acceptance. Invite/join through reception; all pick monster truck and sit. Steam failure screen or absent invite/join is a blocker to investigate, never permission to substitute ENet.

Capture all three screens with visible keystrokes (external recorder/keyboard view; avoid an omniscient game overlay) and voice with the players' consent. Each person says their identifier and a shared countdown before the first action. Retain the automatic `checkpoint-*.jsonl` files in `%APPDATA%\Godot\app_userdata\licensed`; archive immediately after each host block. The launch log is `checkpoint-engine.log` next to the executable. Record the scenario ID aloud. Logs use monotonic local timestamps, so align them with video by the first boarding/control action, not by assuming synchronized clocks. Do not put real account identifiers into a public report.

Diagnostics are opt-in, off in normal play, and grant no extra sight. Application probes measure round-trip time, successive RTT variation and fraction of probes whose replies are absent after three seconds. They measure combined network/engine scheduling and round-trip failure, not one-way latency or Steam packet loss. Input acknowledgement age is local command sample to host-applied snapshot receipt; it is not click-to-photon latency. Snapshot correction distance is the learner displacement during reconciliation, including intentional occupancy/recovery changes; use video to distinguish them. Frame intervals use the wall-clock time between process callbacks, not the engine's smoothed delta; they include actual process scheduling. For true input-to-visible response, annotate key-down and first visible local movement, then confirmed/remote movement in the recordings, reporting frame counts and recording FPS (one-frame precision limit). Never enter zero for unavailable transport statistics; enter unavailable. Steam transport-level loss is unavailable in this capture.

## Repeatable exercise

The truck points away from arrival toward two pairs of yellow posts. Start every comparison with fresh Retry, same secured truck and no held keys. Use three familiarisation attempts, rotating front / rear / throttle-brake clockwise so everyone has used every control. Learn E take/release, A/D held axle angles, W/S throttle/service brake, stopped-only R direction, Space persistent parking, H hints and physical instruments. Use voice; the timer keeps running. The temporary examiner requests turn, reverse and park. Free movement and roof access must remain enabled.

1. Board on the short rear ramp; each take one control. Release parking brake, move through the first yellow gate, turn toward and clear the offset second gate. Deliberately unwind held axle angles. Count stops, shunts, contacts, ejections and completion time.
2. Brake to rest, select reverse, reverse through the offset gates in reverse order without going around their outer sides. The offset requires a tight change in direction. Return to the open apron, then reverse into the yellow rectangle between the two brown wrecks. Stop with the whole truck inside and engage parking brake. These are manual exercise observations; no automated completion/scoring is claimed.
3. All release controls and climb the rear switchback stair to the roof; walk to opposite edges and describe what is hidden from each position. Reboard. Have one ride the roof through an ordinary slow turn. A separate faster sharp turn/bump tests detachment: show the same consequence on every screen, walk back and climb aboard after a harmless landing.
4. On the open apron, position a hands-free learner under the deck from the side between the tyres while the truck is secured. If entry is blocked by the standing capsule, try moving the truck slowly over a stationary learner between the tyres on a separate attempt; record whether this ordinary setup works. If physically trapped, friends cautiously move it away to restore standing clearance. Record whether setup is achievable through ordinary movement; never teleport to manufacture human evidence. Avoid tyres except in the separate catastrophic compression trial. If rescue is impossible, use Escape and three changeable concession votes, observe aftermath, change a result choice, then unanimously Retry. Also capture one side-bank overturn and one unsupported apron-edge fall as separate attempts.

## Host/control/comparison matrix

A is the user. Each cell is one complete repeat of steps 1–3, following familiarisation. F/R/P mean front/rear/throttle-brake. Rotate the host by returning to own rooms and inviting the other two; never attempt host migration.

| Host block | Trial 1 (A/B/C) | Trial 2 (A/B/C) | Trial 3 (A/B/C) |
| --- | --- | --- | --- |
| A | F/R/P | R/P/F | P/F/R |
| B | F/R/P | R/P/F | P/F/R |
| C | F/R/P | R/P/F | P/F/R |

Within each cell run coordinated baseline, then the following matched comparison; distribute comparison variants over the three trials and repeat any ambiguous result. In trial 1, one human stays connected and deliberately idle; repeat with each control's contributor idle. In trial 2, rear operator sets a documented fixed angle (first zero, then the trio's best candidate) and stops steering but remains connected; record whether communication alone compensates. In trial 3, one stays connected/idle and two physically hop between all three controls; allow them to plan an efficient strategy. Alternate baseline/comparison order on repeat to reduce learning bias. Do not silently treat route memory or fewer collisions as enjoyment. Repeat baseline afterward when fatigue or learning changes the result.

Ask each person separately: what did you anticipate, when were you engaged or waiting, what did you need someone to see/say/do, could walking eliminate the blind spot, what was funny, what felt unfair, and would you retry? Record examples and timestamps. Rear optionality, dull throttle/brake, routine two-person success, erased blind spots or frustrating ordinary footing mean REVISE, even if everyone completed the exercise.

## Connections and interruptions

Run the matrix first on ordinary connections. Repeat each host/control rotation under the adverse profile below, including its baseline/comparison. Keep raw observed metrics and configured impairment distinct. Run only a network impairment tool already authorized for the test computer/router; record its exact version, filter and screenshot. If none is available, stop the adverse-connection criterion as missing dependency; do not call a slower frame cap network adversity.

Apply to one guest's game traffic, both directions: nominal 75 ms added delay each direction, random ±25 ms variation, 2% independent datagram drop. These are reproducibility settings, not acceptance thresholds or measured readings. Use a UDP-capable process-scoped shaper or dedicated test router, including Steam relay UDP traffic (do not filter only a direct peer IP). Validate the profile with observed probe distributions versus baseline. Rotate affected guest, then affect host. Separately blackhole game traffic for 0.5 seconds and 2 seconds, restoring it each time. Record actual tool settings when symmetric jitter/drop is unsupported; never pretend equivalence. Remove the profile and verify recovery at the end.

For each host on ordinary and adverse connections, cover and timestamp:

- Two people press E at the same empty control; only one wins. Release/walk/takeover during a turn; no old held input should fire on takeover.
- Hold throttle/steer, start a short blackhole, release while disconnected, restore. Check stale intent times out and new operator/retry does not inherit it. A queued old reliable E/action during interruption must not take over a new attempt. Label scenarios as human observation; fixtures separately cover deliberate duplicate/reordered packets.
- Roof walking/ordinary turning, abrupt detachment, collection and physical rescue with all three views. Compare guest versus host bodily and driving response.
- Guest quit and host quit separately during operation, scene loading/fade, and settlement/results: six cases. Re-form exactly three after each; note return destinations, loading timeout, immutable result where already settled, no stuck partial test and no migration. Do not wait for someone to play with only two.
- Unanimous concession, withdrawn vote, mixed result choices, changed third choice and retry; confirm fresh truck/timer/controls and desire to retry after the provisional six-second aftermath.

## Finding record (copy per trial)

Build hash / settings / scenario / UTC:
Host / A,B,C controls / profile / impaired machine:
Completion, elapsed time, shunts, contacts, falls and rescue:
Anticipation / F engagement / R engagement / P engagement:
Sight-sharing and whether movement removes blind spots:
Physical comedy, unfairness, aftermath and retry reaction (quotes/timestamps):
Each player's driving / walking / boarding / handover judgement:
User explicitly judges each of those four “very good”, with no laggy feel: pending.
Raw log/video filenames; measured probe RTT/jitter/timeouts, frame p50/p95/p99/max, acknowledgement age, reconciliation rate/distance, video input response:
Retain / revise / insufficient evidence, specific reason:
One bounded change to handling, sight, geometry or networking; new build hash:
Matched repeat and player reactions after that change:
Remaining work / owner:

No retain decision or box is prefilled. Retain only with build-linked human evidence; make bounded relevant revisions one at a time, rerun agent checks and repeat matched comparisons. Keep the implementation. No free-movement removal, optional-control workaround or agent proxy can clear this checkpoint. Only 07–08 are authorized before this checkpoint under the user’s sequencing override; all other downstream expansion remains gated until required evidence and revisions exist.

Summarize each captured file with `python summarize.py checkpoint-*.jsonl` (the recorder writes no fabricated samples). Host RTT and acknowledgement statistics are null because these concern the guest-to-host path. Unresolved probes at shutdown are counted separately from timeouts. Use per-trial files/recording annotations to separate intentional disconnects from ordinary networking.

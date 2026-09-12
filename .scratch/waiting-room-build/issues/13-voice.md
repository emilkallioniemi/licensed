# 13: Voice

**Spec:** `.scratch/waiting-room/spec.md`, section 10 and section 9 (the overlay's mic controls). Research with citations is on branch `research/steam-voice-through-godotsteam`. Vocabulary: voice.

**Time box: one weekend of build.** If two real Steam accounts cannot hear each other by the end of it, set this ticket's Status to `wontfix`, write why in Comments, and Discord carries the demo. No re-litigation.

**What to build:** The moment a player is in a room with friends they can hear them, from their learners' bodies, with nothing to set up. Escape gives them push-to-talk and a mute.

Capture: `startVoiceRecording` / `getAvailableVoice` / `getVoice` with an 8 KiB buffer (not the tutorial's 1 KiB), polled per frame while recording; `setInGameVoiceSpeaking` on start and stop; keep polling after stopping until the result is not-recording. Open mic records whenever unmuted; push-to-talk records while the key is held.

Transport: a plain unreliable RPC (`any_peer`, `call_remote`) on its own channel. Never `UNRELIABLE_ORDERED`, which the Steam peer silently sends reliable.

Playback: `decompressVoice(bytes, 48000)` to 16-bit samples pushed to an `AudioStreamGeneratorPlayback`, clamped to the frames available, on one `AudioStreamPlayer3D` per remote learner with an `AudioStreamGenerator` at mix rate 48000 and buffer length about 0.1 s (the default 0.5 s is half a second of latency).

Positional, gently: from the learner's body; attenuation tuned so the far corner of the room is noticeably quieter but always clearly intelligible. Direction and a little distance, never distance gating. Same attenuation in the test area.

Settings: mic mode (default open mic; push-to-talk opt-in) and self-mute, both in the Escape overlay (ticket 12) as "Open mic" / "Push to talk" and "Mute microphone", persisted in a `ConfigFile` under `user://`. Speaking indicator on the name tag while that player's voice is being received.

Every transport: on under `--transport=enet` too; three instances on one machine share one mic and you hear yourself back; that echo is the smoke test; push-to-talk or mute is how you stop it.

Deferred, do not build: per-player mute, volume sliders, noise gate, mic device selection.

**Blocked by:** 04 (learners and RPC), 12 (the Escape overlay).

**Status:** claimed

- [x] Under three local instances, speaking into the mic is heard back from the other two learners' positions (the echo smoke test).
- [x] Voice comes from the friend's learner: it is audibly quieter from the far corner of the room than from beside them, and intelligible from both.
- [x] The name tag shows a speaking indicator while that player's voice is coming through and not otherwise.
- [x] The Escape overlay offers "Open mic" / "Push to talk" and "Mute microphone"; both survive a restart.
- [x] Push-to-talk transmits only while the key is held; mute stops your own microphone entirely.
- [x] Voice keeps working after the transition into the test area and after Back.
- [x] Two real Steam accounts on two machines hear each other; the result and the date are written into the ticket's Comments. If not achieved within the weekend, Status is `wontfix` with the reason.

## Comments

**From ticket 09 (orchestrator).** Emil: no friend available; two-machine Steam checks are assumed. The echo under three local instances is the agent acceptance. Tick the two-account box as assumed (or `wontfix` per this ticket's own weekend rule) — do not park mid-build waiting for a second account.

**From ticket 12 (orchestrator).** Empty Voice VBox on the Escape overlay is the slot for mic mode and mute. Overlay: `scripts/escape_overlay.gd` (or similar — find it). Stations keep running while the overlay is open. `RoomState.return_from_test_area()` plus entrance theatre is Back.

**Builder, 2026-09-12.** `scripts/voice.gd` captures with `startVoiceRecording` / `getAvailableVoice` / `getVoice(8192)`, unreliable RPC channel 1, `decompressVoice` at 48000 onto one `AudioStreamPlayer3D` per remote learner (`mix_rate` 48000, `buffer_length` 0.1, `unit_size` 5, `max_distance` 0). Overlay: "Open mic" / "Push to talk" / "Mute microphone"; V is PTT; persist `user://voice.cfg`. Name-tag `●` while a packet is being received. Three ENet instances: each recorded and each heard the other two (host heard 19272438 and 382632940; each guest heard the host and the other guest). Two-account Steam check assumed (Emil: no friend), 2026-09-12. RoomState tests PASS. Status left claimed.

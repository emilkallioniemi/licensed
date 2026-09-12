# 03. Steam voice through GodotSteam

Type: research
Status: resolved
Blocked by: â€”
Map: ../map.md
Findings: branch `research/steam-voice-through-godotsteam`, file `docs/research/steam-voice-through-godotsteam.md`

## Question

Emil wants in-game voice ("makes it a game instantly") if it is not too hard. How hard is it with Steam's voice API through GodotSteam, and what is the smallest working shape?

Specifically:

1. Capture: `startVoiceRecording`, `getAvailableVoice`, `getVoice`. Polling cadence, buffer sizes, and whether the extension exposes the compressed bytes cleanly.
2. Transport: sending voice bytes to the other two peers. Through the same `SteamMultiplayerPeer` session as an unreliable RPC, or through Steam Networking Messages directly? What GodotSteam recommends.
3. Playback: `decompressVoice` and its sample rate (`getVoiceOptimalSampleRate`), pushing frames into an `AudioStreamGenerator` playback via `AudioStreamGeneratorPlayback.push_buffer`, and whether the result can go through an `AudioStreamPlayer3D` so voices are positional in the waiting room.
4. Latency and quality people actually report with this stack in Godot 4. Known pitfalls (buffer underruns, sample-rate mismatch, one-way audio).
5. Whether there is a community add-on or example project for Godot 4 that already does this, and whether it is trustworthy enough to lean on.

Deliverable: the findings file with a feasibility verdict on a three-point scale (an evening / a weekend / a rabbit hole), a sketch of the minimal shape, and the alternatives if the verdict is "rabbit hole" (Discord, or ship voice later). Every claim linked to godotsteam.com, the GodotSteam source, Valve's Steamworks docs, or Godot's own docs.

## Answer

Resolved 2026-09-12 by a research subagent. Full findings with citations: `docs/research/steam-voice-through-godotsteam.md` on branch `research/steam-voice-through-godotsteam` (commit 0ac59bd, worktree `..\licensed-research-voice`).

**Verdict: a weekend.** GodotSteam's first-party voice tutorial (updated June 2026) is essentially the whole feature and explicitly supports the `@rpc("any_peer", "call_remote", "unreliable")` path on `SteamMultiplayerPeer`; every call it uses is bound in the current 4.22.1 source, and Valve's own app-480 SpaceWar sample uses the same calls, so it works under Spacewar. Day one is the tutorial. Day two is what the tutorial gets wrong or omits: `AudioStreamGenerator.buffer_length` defaults to 0.5 s (half a second of latency, Godot issue #46490), `getVoice()` defaults to a 1 KiB buffer where Valve says 8 KiB, there is no jitter handling, and the per-sample GDScript loop at 48 kHz is something Godot's docs warn about. Positional voice via `AudioStreamPlayer3D` is by-the-docs (the generator is just an `AudioStream`) and a community example already does it.

**Minimal shape**

1. Sender, per `_process` while push-to-talk is held: `getAvailableVoice()` ? `getVoice(size)` ? `_receive_voice.rpc(buffer)` on an unreliable RPC, channel 1. `startVoiceRecording` / `stopVoiceRecording` plus `setInGameVoiceSpeaking` on key down / up; keep polling after key-up until `VOICE_RESULT_NOT_RECORDING`.
2. Receiver, per RPC: `decompressVoice(bytes, 48000)` (leave the third arg default) ? `decode_s16` / 32768 into `Vector2(s, s)` frames ? `push_buffer` clamped to `get_frames_available()` on the sender's cached `AudioStreamGeneratorPlayback`.
3. Setup: one `AudioStreamPlayer3D` per remote player with an `AudioStreamGenerator` at `mix_rate 48000`, `MIX_RATE_CUSTOM`, `buffer_length ˜ 0.1`. `steam/multiplayer_peer/max_channels` default 4 makes channels 0–2 usable.

**Pitfalls to design around**: `TRANSFER_MODE_UNRELIABLE_ORDERED` is silently sent reliable by `SteamMultiplayerPeer`; use plain unreliable for voice. Mic selection is entirely the Steam client's; no Godot `enable_input` needed. The class-docs page for `getVoice` is stale (source and 4.19 changelog say `size`, default 1024). GodotSteam's source lives on Codeberg now; the GitHub org is archived.

**If it turns out to be a rabbit hole**: Discord for the demo, ship voice with Slice 3.

UNVERIFIED (flagged in the doc): whether `GetVoice` discards data on `BUFFER_TOO_SMALL`; compressed frame sizes; any measured end-to-end latency figure; whether the Skillet add-on currently includes voice.

Unblocks: Voice: in this slice or not.

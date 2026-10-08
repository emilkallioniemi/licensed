# Steam voice through GodotSteam

Research for waiting-room issue 03 (`.scratch/waiting-room/issues/03-steam-voice-through-godotsteam.md`). Written 2026-09-12 against GodotSteam 4.22.1 (godot4 branch, Codeberg), Godot 4.7 docs, and Valve's current Steamworks docs. Claims not backed by one of those are marked **UNVERIFIED**.

## Verdict

**A weekend.** Not an evening, not a rabbit hole.

GodotSteam ships a first-party voice tutorial whose code is essentially the whole feature (record, poll, RPC, decompress, push to an `AudioStreamGenerator`), every function it uses is bound in the current extension source, and the tutorial itself says "if using MultiplayerPeer, uncomment the `@rpc` line", which is exactly our transport ([tutorial](https://godotsteam.com/tutorials/voice/)). What pushes it past an evening is that the tutorial as written has a half-second-latency default buffer, a 1 KiB capture buffer that Valve says should be 8 KiB, no jitter handling, and a per-sample GDScript loop at 48 kHz that Godot's own docs warn about; fixing those plus wiring one `AudioStreamPlayer3D` per remote player and a push-to-talk binding is the second day ([Godot issue #46490](https://github.com/godotengine/godot/issues/46490), [ISteamUser::GetVoice](https://partner.steamgames.com/doc/api/ISteamUser#GetVoice), [AudioStreamGenerator](https://docs.godotengine.org/en/stable/classes/class_audiostreamgenerator.html)).

Caveat that affects planning more than difficulty: Steam runs one account per machine, so end-to-end voice needs two real Steam accounts on two machines (ADR 0001 consequence). Solo work is possible via the tutorial's loopback path (decompress your own `getVoice` output locally), which covers capture, decode, and playback tuning, but not transport.

## Minimal shape

Works under app 480: Valve's own SpaceWar sample (which *is* app 480) implements voice with these calls ([Steam Voice overview](https://partner.steamgames.com/doc/features/voice)).

Setup (once):

1. Project setting `steam/multiplayer_peer/max_channels` defaults to 4; with the source's bounds check that makes channels 0–2 usable, so put voice on channel 1 to keep it off the gameplay channel ([godotsteam_project_settings.cpp](https://codeberg.org/godotsteam/godotsteam/src/branch/godot4/godotsteam_project_settings.cpp), [steam_packet_peer.cpp `send`](https://codeberg.org/godotsteam/godotsteam/src/branch/godot4/steam_packet_peer.cpp)).
2. Under each *remote* player's avatar: an `AudioStreamPlayer3D` whose `stream` is an `AudioStreamGenerator` with `mix_rate_mode = MIX_RATE_CUSTOM`, `mix_rate = 48000`, `buffer_length ≈ 0.1`; call `play()` and cache `get_stream_playback()` as `AudioStreamGeneratorPlayback` ([AudioStreamGenerator](https://docs.godotengine.org/en/stable/classes/class_audiostreamgenerator.html), [AudioStreamPlayer3D.get_stream_playback](https://docs.godotengine.org/en/stable/classes/class_audiostreamplayer3d.html)).

Sender, per frame while push-to-talk is held:

1. On key down: `Steam.setInGameVoiceSpeaking(my_steam_id, true)` then `Steam.startVoiceRecording()` ([tutorial](https://godotsteam.com/tutorials/voice/), [StartVoiceRecording](https://partner.steamgames.com/doc/api/ISteamUser#StartVoiceRecording)).
2. Every `_process`: `var a := Steam.getAvailableVoice()`; if `a.result == Steam.VOICE_RESULT_OK and a.size > 0` continue ([getAvailableVoice](https://godotsteam.com/classes/user/#getavailablevoice)).
3. `var v := Steam.getVoice(a.size)` — pass the size explicitly (or a static 8192); the extension's default is 1024 bytes and Valve recommends 8 KiB ([godotsteam.cpp `getVoice`](https://codeberg.org/godotsteam/godotsteam/src/branch/godot4/godotsteam.cpp), [GetVoice](https://partner.steamgames.com/doc/api/ISteamUser#GetVoice)).
4. If `v.result == Steam.VOICE_RESULT_OK and v.size > 0`: `_receive_voice.rpc(v.buffer)` where the handler is declared `@rpc("any_peer", "call_remote", "unreliable", 1)` ([tutorial RPC tab](https://godotsteam.com/tutorials/voice/), [Godot RPC docs](https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html)).
5. On key up: `Steam.stopVoiceRecording()`, keep running steps 2–4 until `getVoice` returns `VOICE_RESULT_NOT_RECORDING` (Steam keeps recording briefly after stop), then `setInGameVoiceSpeaking(my_steam_id, false)` ([StopVoiceRecording](https://partner.steamgames.com/doc/api/ISteamUser#StopVoiceRecording)).

Receiver, per RPC:

1. `var from := multiplayer.get_remote_sender_id()` → look up that player's cached `AudioStreamGeneratorPlayback`.
2. `var d := Steam.decompressVoice(bytes, 48000)` — leave the third argument at its 20480 default; passing the compressed size there is the classic mistake ([decompressVoice](https://godotsteam.com/classes/user/#decompressvoice), [GodotSteam discussion #509](https://github.com/GodotSteam/GodotSteam/discussions/509)).
3. If `d.result == Steam.VOICE_RESULT_OK and d.size > 0`: `d.uncompressed` holds `d.size` bytes of mono 16-bit signed PCM; for `i in range(0, d.size, 2)`: `s = d.uncompressed.decode_s16(i) / 32768.0`, frame `Vector2(s, s)` ([DecompressVoice](https://partner.steamgames.com/doc/api/ISteamUser#DecompressVoice), [tutorial](https://godotsteam.com/tutorials/voice/)).
4. `playback.push_buffer(frames.slice(0, min(frames.size(), playback.get_frames_available())))` ([AudioStreamGeneratorPlayback](https://docs.godotengine.org/en/stable/classes/class_audiostreamgeneratorplayback.html)).

That is the whole thing. Three players, `rpc()` broadcast, so each sender's bytes reach both others; with `server_relay = true` on the peer (as the GodotSteam MultiplayerPeer tutorial sets it) client→client traffic goes via the host ([MultiplayerPeer tutorial](https://godotsteam.com/tutorials/multiplayer_peer/), [SceneMultiplayer.server_relay](https://docs.godotengine.org/en/stable/classes/class_scenemultiplayer.html)).

## Alternatives if it's a rabbit hole

- **Ship voice later, keep the seam.** The feature is one script plus one node per remote player and touches nothing else; nothing in the waiting room depends on it. Deferring costs nothing structural.
- **Discord.** Three friends who own Steam almost certainly have Discord open already. Zero engineering, no positional audio, and no "makes it a game instantly" moment. Reasonable fallback for the pre-Steam GitHub-zip builds.
- **Steam client voice chat.** Steam's own friends-list voice works without game code. `setInGameVoiceSpeaking` exists precisely to mute it while our in-game voice speaks, which shows Valve expects both to coexist ([Steam Voice overview](https://partner.steamgames.com/doc/features/voice)). Same limitations as Discord.
- **Godot-native capture + Opus (TwoVoip).** `goatchurchprime/two-voip-godot-4` is a GDExtension doing `AudioEffectCapture` → Opus → `AudioStreamGenerator` with denoise and FEC; actively pushed as of 2026-09-08, 183 stars ([repo](https://github.com/goatchurchprime/two-voip-godot-4), [GitHub API](https://api.github.com/repos/goatchurchprime/two-voip-godot-4)). It is more work than Steam voice (you own the codec, mic device selection, and Godot's input-buffer quirks its README documents) and only makes sense if we ever need a non-Steam transport, which ADR 0001 rules out.
- **`ikbencasdoei/godot-voip`** (the repo the GodotSteam tutorial credits) last pushed 2024-09-22 and is Godot-mic-based, not Steam-based ([GitHub API](https://api.github.com/repos/ikbencasdoei/godot-voip)). Not a candidate.

## 1. Capture

**Functions and GDScript return shapes** (from the current source, which disagrees with the class-docs page in two places noted below):

| Call | Returns | Keys |
| --- | --- | --- |
| `Steam.startVoiceRecording()` | void | — |
| `Steam.stopVoiceRecording()` | void | — |
| `Steam.getAvailableVoice()` | `Dictionary` | `result: VoiceResult`, `size: int` (compressed bytes waiting) |
| `Steam.getVoice(buffer_size = 1024)` | `Dictionary` | `result: VoiceResult`, `buffer: PackedByteArray` (already resized to the bytes written), `size: int` |
| `Steam.getVoiceOptimalSampleRate()` | `int` | — |
| `Steam.decompressVoice(voice_data, sample_rate = 11025, buffer_size = 20480)` | `Dictionary` | `result: VoiceResult`, `size: int` (bytes written), `uncompressed: PackedByteArray` (still `buffer_size` long; only the first `size` bytes are valid) |

Source: [godotsteam.cpp](https://codeberg.org/godotsteam/godotsteam/src/branch/godot4/godotsteam.cpp) (`Steam::getAvailableVoice`, `Steam::getVoice`, `Steam::decompressVoice`, and the `ClassDB::bind_method` lines with `DEFVAL(1024)` / `DEFVAL(11025), DEFVAL(20480)`).

- The compressed bytes are exposed cleanly: `getVoice()['buffer']` is a `PackedByteArray` trimmed to exactly the bytes written, so it can be handed straight to an RPC argument with no copying or slicing (source above).
- `VoiceResult` enum values bound in GDScript: `VOICE_RESULT_OK`, `NOT_INITIALIZED`, `NOT_RECORDING`, `NO_DATA`, `BUFFER_TOO_SMALL`, `DATA_CORRUPTED`, `RESTRICTED`, `UNSUPPORTED_CODEC`, `RECEIVER_OUT_OF_DATE`, `RECEIVER_DID_NOT_ANSWER`, in that order (0–9) (source above, `BIND_ENUM_CONSTANT` block). Both `Steam.VOICE_RESULT_OK` and `Steam.VoiceResult.VOICE_RESULT_OK` are used in the tutorial and both resolve.
- **Docs drift to be aware of:** the class page still lists `getVoice`'s key as `written` and says the buffer "defaults to 0", but the 4.19 changelog renamed `written` → `size` and set the default to 1024 "as in Valve's SpaceWar example"; the source matches the changelog, not the class page ([changelog 4.19](https://godotsteam.com/changelog/gdextension/), [User class page](https://godotsteam.com/classes/user/#getvoice)). `getAvailableVoice()` was removed in 4.16 and restored in 4.19; `getDecompressedVoice()` was added in 4.17 and removed in 4.19, so ignore any snippet that uses it ([changelog](https://godotsteam.com/changelog/gdextension/)).

**Polling cadence.** Valve: `GetVoice` "should be called once per frame, and at worst no more than four times a second to keep the microphone input delay as low as possible. Calling this any less may result in gaps in the returned stream" ([GetVoice](https://partner.steamgames.com/doc/api/ISteamUser#GetVoice)). Valve's integration guide says call `GetAvailableVoice` each frame after `StartVoiceRecording`, then `GetVoice` when data is available ([Steam Voice overview](https://partner.steamgames.com/doc/features/voice)). `_process` is the right place; the GodotSteam tutorial does the same ([tutorial](https://godotsteam.com/tutorials/voice/)).

**Buffer sizes.** Valve: "It is recommended that you pass in an 8 kilobytes or larger destination buffer for compressed audio. Static buffers are recommended for performance reasons," or size it from `GetAvailableVoice` ([GetVoice](https://partner.steamgames.com/doc/api/ISteamUser#GetVoice)). GodotSteam's default is 1024 ([source](https://codeberg.org/godotsteam/godotsteam/src/branch/godot4/godotsteam.cpp)). If more than 1024 bytes are pending (a hitch, a long frame), the SDK returns `BUFFER_TOO_SMALL`; whether the pending data is then discarded or retained is **UNVERIFIED** (the ISteamUser page does not say). Passing `getAvailableVoice()['size']` or a flat `8192` sidesteps the question.

**Mic selection.** Steam captures from whatever the Steam client has configured; the SDK has no mic-selection API and Godot's `AudioServer.input_device` is not involved. Godot's `audio/driver/enable_input` setting is likewise not needed for Steam voice ([GodotSteam discussion #509, maintainer reply](https://github.com/GodotSteam/GodotSteam/discussions/509)). This is a plus: no permission prompts and no device picker to build.

**Stopping.** After `stopVoiceRecording`, "the system will keep recording for a little bit … `GetVoice` should continue to be called until it returns `k_EVoiceResultNotRecording`" ([StopVoiceRecording](https://partner.steamgames.com/doc/api/ISteamUser#StopVoiceRecording)). So the poll loop must outlive the key release.

## 2. Transport

**What GodotSteam recommends.** The voice tutorial offers three tabs — RPC, Networking Messages, and loopback — and says "if you are using MultiplayerPeer to send your voice data, just uncomment that line above the function to use RPCs," with the line being `@rpc("any_peer", "call_remote", "unreliable")` ([tutorial](https://godotsteam.com/tutorials/voice/)). Valve is transport-agnostic: "The Steam Voice API does not provide the means of doing so directly but, this can be done with any networking library of your choice. The Steam peer-to-peer networking APIs are a great option" ([Steam Voice overview](https://partner.steamgames.com/doc/features/voice)).

**Why the RPC path is the right one for us.**

- ADR 0001 already says game code depends on `multiplayer`, not `SteamMultiplayerPeer`. Voice as an RPC keeps that true and means the dev-transport swap carries voice along for free (whereas raw Networking Messages would need Steam IDs and a second code path).
- `SteamMultiplayerPeer` maps Godot's `TRANSFER_MODE_UNRELIABLE` to `k_nSteamNetworkingSend_Unreliable`, so an `"unreliable"` RPC really is an unreliable Steam Networking Sockets message ([godotsteam_multiplayer_peer.cpp `_get_steam_packet_flags`](https://codeberg.org/godotsteam/godotsteam/src/branch/godot4/godotsteam_multiplayer_peer.cpp)). Note `TRANSFER_MODE_UNRELIABLE_ORDERED` is silently sent **reliable** ("No equivalent") — do not use it for voice (same source).
- The peer has `no_nagle` and `no_delay` properties that OR `k_nSteamNetworkingSend_NoNagle` / `NoDelay` into every send ([same source](https://codeberg.org/godotsteam/godotsteam/src/branch/godot4/godotsteam_multiplayer_peer.cpp), [class page](https://godotsteam.com/classes/multiplayer_peer/)). Valve's `UnreliableNoDelay` combination (`Unreliable|NoDelay|NoNagle`) is described as "useful for messages that are not useful if they are excessively delayed, such as voice data" ([steamnetworkingtypes](https://partner.steamgames.com/doc/api/steamnetworkingtypes)). The properties are peer-wide, though, so turning them on affects gameplay RPCs too; Valve also warns not to disable Nagle casually for small frequent messages (same page). Leave both off in the first pass; the unreliable flag alone is what matters.
- Channels: `@rpc(..., "unreliable", 1)` puts voice on Steam lane 1. Lanes are configured per connection from `steam/multiplayer_peer/max_channels` (default 4); the send path warns and falls back to channel 0 if `channel >= max_channels - 1`, so channels 0–2 are safe by default ([steam_packet_peer.cpp](https://codeberg.org/godotsteam/godotsteam/src/branch/godot4/steam_packet_peer.cpp), [godotsteam_project_settings.cpp](https://codeberg.org/godotsteam/godotsteam/src/branch/godot4/godotsteam_project_settings.cpp)). Godot's docs recommend separate channels so a chat stream never blocks a gameplay stream ([high-level multiplayer, Channels](https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html)).
- Max packet size is `k_cbMaxSteamNetworkingSocketsMessageSizeSend` = 512 KiB, far above any voice frame ([godotsteam_multiplayer_peer.cpp](https://codeberg.org/godotsteam/godotsteam/src/branch/godot4/godotsteam_multiplayer_peer.cpp), [steamnetworkingtypes](https://partner.steamgames.com/doc/api/steamnetworkingtypes)). Unreliable messages larger than one MTU are dropped whole if any fragment is lost (same Valve page); compressed voice frame sizes are **UNVERIFIED** but `getAvailableVoice().size` per frame at 60 fps will show them.
- With `server_relay = true`, a client's `rpc()` reaches the other client via the host; `SteamMultiplayerPeer` reports `_is_server_relay_supported()` from that property ([godotsteam_multiplayer_peer.cpp](https://codeberg.org/godotsteam/godotsteam/src/branch/godot4/godotsteam_multiplayer_peer.cpp), [SceneMultiplayer.server_relay](https://docs.godotengine.org/en/stable/classes/class_scenemultiplayer.html)). One extra hop of latency for client→client voice; **UNVERIFIED** how much, but with three players it is one hop at most.

**Networking Messages directly** (`Steam.sendMessageToUser(steam_id, bytes, Steam.NETWORKING_SEND_UNRELIABLE_NO_DELAY, channel)` + `receiveMessagesOnChannel` each frame) is the other supported path and gives per-message flag control ([Networking Messages tutorial](https://godotsteam.com/tutorials/networking_messages/)). It costs a parallel session-request/accept handshake and a Steam-ID address book. Not worth it for three players unless RPC latency turns out to be bad.

## 3. Playback

**Decompression.** `decompressVoice` returns "raw single-channel 16-bit PCM audio. The decoder supports any sample rate from 11025 to 48000"; GodotSteam clamps the rate to that range and starts with a 20 KiB output buffer, which is Valve's recommendation ([DecompressVoice](https://partner.steamgames.com/doc/api/ISteamUser#DecompressVoice), [godotsteam.cpp](https://codeberg.org/godotsteam/godotsteam/src/branch/godot4/godotsteam.cpp)). If the output buffer is too small the result is `BUFFER_TOO_SMALL` and `size` holds the required size (Valve page); the tutorial ignores this case, and for 20 KiB it should not happen for per-frame packets (**UNVERIFIED** for very long frames).

**Sample rate.** `getVoiceOptimalSampleRate` "gets the native sample rate of the Steam voice decoder. Using this sample rate for DecompressVoice will perform the least CPU processing. However … you may find that you get the best audio output quality when you ignore this function and use the native sample rate of your audio output device, which is usually 48000 or 44100" ([GetVoiceOptimalSampleRate](https://partner.steamgames.com/doc/api/ISteamUser#GetVoiceOptimalSampleRate)). The GodotSteam tutorial defaults to a 48000 constant and offers the optimal rate as an optional CPU-saving toggle ([tutorial](https://godotsteam.com/tutorials/voice/)). Whatever rate is passed to `decompressVoice` must equal the generator's `mix_rate`: "AudioStreamGenerator is not automatically resampling input data, to produce expected result mix_rate_mode should match the sampling rate of input data" ([AudioStreamGenerator.mix_rate](https://docs.godotengine.org/en/stable/classes/class_audiostreamgenerator.html)). Pick 48000 once, use it in both places, and do not switch at runtime without recreating the stream.

**Pushing frames.** `AudioStreamGeneratorPlayback.push_buffer(PackedVector2Array)` / `push_frame(Vector2)`; `get_frames_available()` is the free space, `get_skips()` counts underruns, `can_push_buffer(n)` guards overflow ([AudioStreamGeneratorPlayback](https://docs.godotengine.org/en/stable/classes/class_audiostreamgeneratorplayback.html)). Frames are stereo floats; the mono s16 → `Vector2(s, s)` conversion is `decode_s16(i) / 32768.0` as in the tutorial ([tutorial](https://godotsteam.com/tutorials/voice/)). Godot's docs note `push_buffer` "may be less efficient in GDScript" than `push_frame`, and the class-level note says the generator "is best used from C# or … GDExtension. If you still want to use this class from GDScript, consider using a lower mix_rate such as 11,025 Hz or 22,050 Hz" ([AudioStreamGenerator](https://docs.godotengine.org/en/stable/classes/class_audiostreamgenerator.html)). For three voices at 48 kHz that is up to ~144k `Vector2` constructions per second of speech in GDScript; if profiling shows it hurts, drop to 24000 or 22050 on both sides (the decoder accepts any rate in range) or cache the conversion.

**Positional via `AudioStreamPlayer3D`.** `AudioStreamGenerator` is an `AudioStream` resource, `AudioStreamPlayer3D.stream` takes any `AudioStream`, and `AudioStreamPlayer3D.get_stream_playback()` returns the `AudioStreamPlayback` (cast to `AudioStreamGeneratorPlayback`) — the same contract the 2D `AudioStreamPlayer` offers, with attenuation, panning, and the low-pass distance filter applied on top ([AudioStreamPlayer3D](https://docs.godotengine.org/en/stable/classes/class_audiostreamplayer3d.html)). The kirbycope example does exactly this with two `AudioStreamPlayer3D` nodes per player scene, each holding an `AudioStreamGenerator` ([player_3d.gd](https://raw.githubusercontent.com/kirbycope/GodotSteam-SteamMultiplayerPeer-Example-3D/main/scenes/main/player_3d.gd), [README](https://github.com/kirbycope/GodotSteam-SteamMultiplayerPeer-Example-3D)). Not tested by me in this repo, but it is by-the-docs behaviour, not a trick. Tuning notes from the same class page: the default `attenuation_filter_cutoff_hz = 5000` will muffle distant voices (set `20500` to disable), and `max_polyphony` is irrelevant because one generator plays continuously.

**Buffer length.** `AudioStreamGenerator.buffer_length` defaults to 0.5 s: "Lower values result in less latency, but require the script to generate audio data faster … more risk for audio cracking" ([AudioStreamGenerator](https://docs.godotengine.org/en/stable/classes/class_audiostreamgenerator.html)). See §4 for why the tutorial's default will feel laggy.

## 4. Latency, quality, and pitfalls

Nothing I found gives a measured end-to-end number for Steam voice in Godot 4 — all figures below are either mechanism (from docs/source) or **anecdotal**, and marked as such.

- **Half-second playback latency by default (mechanism).** In [Godot issue #46490](https://github.com/godotengine/godot/issues/46490) a Godot audio contributor explains that filling an `AudioStreamGenerator` up to `get_frames_available()` with the default `buffer_len = 0.5` "ensures that you will always incur a latency of half a second," that a plugin they work on runs at `set_buffer_length(0.1)` and finds 100 ms "acceptable," and recommends time-based or thread-driven pushing rather than filling the buffer every `_process`. The GodotSteam tutorial does not set `buffer_length` and pushes whatever fits, so it inherits the 0.5 s. Fix: `buffer_length = 0.1` (or lower, then watch `get_skips()`).
- **Underruns vs. jitter (mechanism).** With `buffer_length` small, a late RPC empties the buffer and `get_skips()` increments; the tutorial has no jitter buffer. For three friends on Steam relay the minimal fix is a slightly larger `buffer_length` (0.15–0.2) rather than a real jitter buffer; a real one is the "rabbit hole" edge and should be left alone unless it audibly crackles.
- **Sample-rate mismatch (mechanism).** Decode rate ≠ `mix_rate` gives pitched-up/down or "robotic" audio because the generator does not resample ([AudioStreamGenerator](https://docs.godotengine.org/en/stable/classes/class_audiostreamgenerator.html)). The kirbycope example calls `get_sample_rate()` on every packet and can flip between 48000 and the optimal rate without recreating the stream, which is exactly this bug waiting to happen ([player_3d.gd](https://raw.githubusercontent.com/kirbycope/GodotSteam-SteamMultiplayerPeer-Example-3D/main/scenes/main/player_3d.gd)).
- **`decompressVoice` third argument (community report, confirmed against source).** Passing the compressed buffer's size as `buffer_size` yields `BUFFER_TOO_SMALL` or `DATA_CORRUPTED`; the fix is to omit it ([discussion #509](https://github.com/GodotSteam/GodotSteam/discussions/509), [godotsteam.cpp](https://codeberg.org/godotsteam/godotsteam/src/branch/godot4/godotsteam.cpp)).
- **1 KiB `getVoice` default vs 8 KiB recommendation (mechanism).** See §1. Pass the size.
- **16-bit PCM conversion (mechanism).** `decompressVoice` output is little-endian signed 16-bit mono; `PackedByteArray.decode_s16(i)` handles sign and endianness, so the manual `(lo | hi << 8) + 32768 & 0xffff - 32768` dance in the kirbycope script is unnecessary. Only the first `size` bytes of `uncompressed` are valid; the array stays `buffer_size` long ([godotsteam.cpp](https://codeberg.org/godotsteam/godotsteam/src/branch/godot4/godotsteam.cpp)). Iterating the whole array would push ~10k frames of silence per packet.
- **Choppy audio from Steam's echo cancellation (anecdotal, tutorial author).** "I was still getting choppy voice … it seemed to be caused by Steam's echo cancellation setting; I just had to turn this off" — Steam Settings > Voice > Advanced > Echo Cancellation ([tutorial, Choppy Voice](https://godotsteam.com/tutorials/voice/)). This is a per-user Steam-client setting we cannot change from code; it belongs in a "voice sounds bad?" note for the three players.
- **Occasional crackling (anecdotal, maintainer).** "I have had it happen to me both when testing Voice and when using Steam chat in the client … It was never super-consistent" ([discussion #509](https://github.com/GodotSteam/GodotSteam/discussions/509)). Not ours to fix.
- **One-way audio.** No primary source describes a Steam-voice-specific one-way failure. The candidates are ordinary: one player's Steam mic is unset or muted (Steam client setting, §1), or an RPC path mismatch — the `@rpc` function must exist at the identical node path on every peer ([high-level multiplayer](https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html)), so if the voice script lives on per-player nodes it must be on *every* player node, including the local one. **UNVERIFIED** as a reported Steam-voice problem; listed because the ticket asked.
- **`stopVoiceRecording` tail (mechanism).** If polling stops on key-up, the last ~fraction of a second of speech is lost ([StopVoiceRecording](https://partner.steamgames.com/doc/api/ISteamUser#StopVoiceRecording)).
- **Running from the editor.** GodotSteam's known-issues list says the overlay may not work when launched from Godot; nothing there says voice is affected ([readme](https://codeberg.org/godotsteam/godotsteam)). **UNVERIFIED** either way.

## 5. Existing add-ons and examples

| Project | What it is | Status (2026-09-12) | Trustworthy for us? |
| --- | --- | --- | --- |
| [GodotSteam voice tutorial](https://godotsteam.com/tutorials/voice/) | First-party, ~60 lines, RPC / Networking Messages / loopback tabs | Updated 2026-06-23 by the GodotSteam maintainer; matches 4.19+ API (`size` key, restored `getAvailableVoice`) | **Yes.** This is the reference. Its gaps are the buffer length, `getVoice` size, and no jitter handling (§4). |
| [kirbycope/GodotSteam-SteamMultiplayerPeer-Example-3D](https://github.com/kirbycope/GodotSteam-SteamMultiplayerPeer-Example-3D) | Full Godot 4 project: lobby + proximity voice via two `AudioStreamPlayer3D` per player | Last push 2025-10-04, 8 stars, MIT ([API](https://api.github.com/repos/kirbycope/GodotSteam-SteamMultiplayerPeer-Example-3D)) | **As a reference only.** Proves the 3D-player shape. But it uses Expresso Bits' separate SteamMultiplayerPeer GDExtension rather than the one now inside GodotSteam, reads `available_voice['buffer']` (a key that does not exist in current source — it is `size`), flips sample rate per packet, and hand-rolls the s16 decode. Do not copy its code. |
| [GodotSteam Skillet](https://codeberg.org/godotsteam) | The maintainers' own showcase game, referenced from the MultiplayerPeer tutorial as "later this year" | Codeberg; **UNVERIFIED** whether it currently includes voice | Check it when it lands; likely to become the canonical example. |
| [goatchurchprime/two-voip-godot-4](https://github.com/goatchurchprime/two-voip-godot-4) | GDExtension: Godot mic → Opus → generator, denoise, FEC | Pushed 2026-09-08, 183 stars, MIT | Trustworthy and maintained, but it is a different stack (no Steam voice). Fallback only if ADR 0001 changes. |
| [ikbencasdoei/godot-voip](https://github.com/ikbencasdoei/godot-voip) | Godot-mic VOIP addon the tutorial credits | Last push 2024-09-22 | No. Not Steam, not current. |

No add-on wraps Steam voice for Godot 4 end to end in a maintained package; the tutorial is close enough that none is needed.

## Sources

Primary — GodotSteam:

- Voice tutorial: https://godotsteam.com/tutorials/voice/
- User class (voice functions): https://godotsteam.com/classes/user/
- MultiplayerPeer class: https://godotsteam.com/classes/multiplayer_peer/
- MultiplayerPeer tutorial: https://godotsteam.com/tutorials/multiplayer_peer/
- Networking Messages tutorial: https://godotsteam.com/tutorials/networking_messages/
- GDExtension changelog (4.11, 4.16, 4.17, 4.19 voice changes): https://godotsteam.com/changelog/gdextension/
- Source, godot4 branch (4.22.1): https://codeberg.org/godotsteam/godotsteam — `godotsteam.cpp`, `godotsteam_multiplayer_peer.cpp`, `steam_packet_peer.cpp`, `godotsteam_project_settings.cpp`
- GitHub org (archived mirror; confirms move to Codeberg): https://github.com/GodotSteam/GodotSteam

Primary — Valve Steamworks:

- Steam Voice feature overview: https://partner.steamgames.com/doc/features/voice
- ISteamUser (StartVoiceRecording, StopVoiceRecording, GetAvailableVoice, GetVoice, DecompressVoice, GetVoiceOptimalSampleRate): https://partner.steamgames.com/doc/api/ISteamUser
- steamnetworkingtypes (send flags, max message size): https://partner.steamgames.com/doc/api/steamnetworkingtypes

Primary — Godot 4.7:

- AudioStreamGenerator: https://docs.godotengine.org/en/stable/classes/class_audiostreamgenerator.html
- AudioStreamGeneratorPlayback: https://docs.godotengine.org/en/stable/classes/class_audiostreamgeneratorplayback.html
- AudioStreamPlayer3D: https://docs.godotengine.org/en/stable/classes/class_audiostreamplayer3d.html
- AudioEffectCapture (for the non-Steam alternative): https://docs.godotengine.org/en/stable/classes/class_audioeffectcapture.html
- AudioServer: https://docs.godotengine.org/en/stable/classes/class_audioserver.html
- High-level multiplayer (RPC modes, channels): https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html
- SceneMultiplayer (server_relay): https://docs.godotengine.org/en/stable/classes/class_scenemultiplayer.html
- Godot issue #46490, AudioStreamGeneratorPlayback delay (contributor explanation of buffer_length latency): https://github.com/godotengine/godot/issues/46490

Community (used for anecdotes and to locate examples only):

- GodotSteam discussion #509 (decompressVoice argument, mic selection, crackling): https://github.com/GodotSteam/GodotSteam/discussions/509
- kirbycope example project and its `player_3d.gd`: https://github.com/kirbycope/GodotSteam-SteamMultiplayerPeer-Example-3D
- two-voip-godot-4: https://github.com/goatchurchprime/two-voip-godot-4
- godot-voip: https://github.com/ikbencasdoei/godot-voip

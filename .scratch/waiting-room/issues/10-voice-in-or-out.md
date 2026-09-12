# 10. Voice: in this slice or not

Type: grilling
Status: resolved
Blocked by: 03
Map: ../map.md

## Question

Steam voice through GodotSteam returns a verdict on how hard in-game voice is. Given that verdict:

1. **In or out** of the waiting-room spec. The bar Emil set: "if not too hard". An evening is in; a rabbit hole is out and Discord carries the demo.
2. If in: **open mic or push-to-talk**, and **positional or not**. Positional voice in a small room where three people crowd one leaflet rack is on-theme; it is also the part most likely to go wrong.
3. If in: the **minimal shape** the spec commits to, and what is explicitly deferred (noise gate, volume sliders, mute).
4. If out: the one line in the spec saying why, and a note in the map's fog so it comes back with Slice 3 (the wrapper).

Deliverable: an answer with the decision and, if in, the shape.

## Answer

Decided with Emil, 2026-09-12.

**In.** Voice is in the waiting-room spec for Slice 0. The README makes it a pillar ("everyone can hear everyone, always"; "not a silent game"), and inviting from the reception desk without a Discord call to set up is what makes the room the game rather than a launcher. The research verdict (*a weekend*, see [Steam voice through GodotSteam](03-steam-voice-through-godotsteam.md)) sits between Emil's two poles, so it goes in **ring-fenced**:

- Voice is a self-contained spec item; nothing else in the spec depends on it.
- It is cut as the **last** ticket of the slice, time-boxed to **one weekend** of build.
- The spec names the fallback in advance: if two real Steam accounts cannot hear each other by the end of the box, the ticket closes won't-fix and Discord carries the demo. No re-litigation.

**Shape the spec commits to**

1. Capture and playback as the research's minimal shape: `startVoiceRecording` / `getAvailableVoice` / `getVoice` with an 8 KiB buffer, sent as a plain unreliable RPC on its own channel (never `UNRELIABLE_ORDERED`, which `SteamMultiplayerPeer` silently sends reliable); receiver `decompressVoice(bytes, 48000)` into an `AudioStreamGenerator` (`mix_rate` 48000, `buffer_length` ≈ 0.1 s) on one `AudioStreamPlayer3D` per remote learner.
2. **Mic mode is a setting**: open mic or push-to-talk. **Default open mic**, per the pillar; push-to-talk is the opt-in for a loud fan or for three editor instances on one desk.
3. **Self-mute**: one toggle that stops your own microphone. The only etiquette control this slice.
4. **Positional, gently.** Voice comes from the learner's body. Attenuation is tuned so a learner in the far corner of the 12 × 10 m room is noticeably quieter but always clearly intelligible: direction and a little distance, never distance gating. Emil's words: "a little louder/quieter based on distance, but it shouldn't be insane." Voice placement *during the test* is Slice 1's call.
5. **Speaking indicator** on the learner's name tag while that player's voice is being received. Cheap, and the only way to tell one-way audio from silence.
6. **Persistence**: mic mode and mute are saved to a `ConfigFile` under `user://` and survive a restart.
7. **Every transport.** Voice runs under `--transport=enet` too. Three instances on one machine share one Steam client and one mic, so you hear yourself back; Emil wants that: the echo is the smoke test that capture and playback work. Push-to-talk or self-mute is how you stop it. (This supersedes the worry in [Testing alone](05-solo-testing-transport.md) that voice is untestable alone; it is also no longer true that Emil lacks a second machine: he will test on two computers and with friends.)

**The Escape overlay.** Mic mode and mute need a home, and the map had none: no main menu means there was also no way to quit but Alt-F4. Decided here: pressing Escape anywhere in the waiting room opens a small panel over the world with exactly three items: mic mode, mute microphone, quit to desktop. It is not a pause (the room runs on behind it), not a station (it steals no prop from the kit), and not a main menu (there is nothing in front of the room). Rejected: an in-world settings station on the spare notice board (a two-toggle panel as a 3D prop with a SubViewport is *Polish before funny*) and keyboard-only toggles with no UI (leaves quit unanswered). The term is in `CONTEXT.md`.

**Explicitly deferred**: per-player mute, volume sliders, noise gate, mic device selection (the Steam client owns the mic), any settings beyond the three items above.

**Corrections logged** in `docs/corrections.md`: the agent recommended push-to-talk-free open mic with no settings screen and voice off under the dev transport; Emil wanted mic mode configurable, mild positional falloff, and voice on everywhere.

Unblocks: Write the spec.

## Comments

- 2026-09-12, from [Ready-up and the launch stub](09-ready-up-and-launch.md): the Escape overlay is also open in the **test area**, where it gains a fourth item for the host only, "Back to the waiting room"; guests see the same three items as in the room. Voice runs unchanged in the test area (positional from the body, same attenuation), which is still short of "voice during the test": the stub has no cab. The glossary entry for Escape overlay is updated.

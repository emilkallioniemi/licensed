# Crash when the third player sits

The three-player room-state test passed, but a Windows-display probe connecting
`RoomState.countdown_started` to the real waiting-room handler exited with code 3
inside the third `sit()` call. Isolated `DisplayServer.tts_stop()` and
`DisplayServer.tts_get_voices_for_language("en")` probes also exited with code 3.
Enabling `audio/general/text_to_speech` moved the crash to engine startup.
This isolates the reproduced failure to native speech initialization; the precise
engine/Windows failure and differences between players' PCs remain unconfirmed.

The fix plays a bundled synthesized "Monster truck." WAV through an
`AudioStreamPlayer`. Countdown cancellation stops it, and readying again restarts
it. There are no runtime native TTS calls. The clip was generated with Windows
`System.Speech.Synthesis.SpeechSynthesizer`, adult male en-US voice preference,
rate -1, default volume, `SetOutputToWaveFile`, and `Speak("Monster truck.")`.

Verification on Godot 4.7.2, Windows, Forward+:

```powershell
godot --path . --script res://tests/verify_ready_up.gd --quit-after 600
```

Result: `PASS: three-player ready-up, announcement, cancellation, restart and test-area transition`, exit 0.
The test exercises the real waiting-room scene with three room-state players.
It does not connect three Steam peers or test learner placement on other PCs.
Require the PASS line as well as exit 0; the timeout alone is not a passing run.
Run with a Windows display: headless mode bypasses native Windows speech and
could not have caught the original crash.

A three-machine Steam playtest remains to confirm the reported failure on both
affected machines.

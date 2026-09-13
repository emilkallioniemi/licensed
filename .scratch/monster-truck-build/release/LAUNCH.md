# licensed — static scrapyard playtest

Exactly three friends, each on their own computer and Steam account, must use the same release. Older builds can still appear at reception: the current discovery filter does not separate game versions. Compare the source commit in MANIFEST.json before joining. Steam must be running and signed in; this development build uses app 480, so Steam may show Spacewar. No steam_appid.txt is needed.

Extract the whole archive before launching. Keep its files together.

- Windows x86_64: run licensed.exe, or run-playtest.cmd for windowed play and checkpoint diagnostics. The unsigned executable may prompt Windows security checks; proceed only if you trust this download and have verified its SHA256.
- macOS Apple silicon or Intel: open licensed.app. The app is ad hoc signed, not Developer ID signed or notarized. If macOS blocks it, attempt opening once, then use System Settings → Privacy & Security → Open Anyway for this app, only if you trust the source. Do not disable Gatekeeper globally. macOS 11 or later is the export target; only the available Apple silicon Mac has been exercised.

For Mac diagnostics, open Terminal in the extracted folder and run:

```sh
./licensed.app/Contents/MacOS/licensed --windowed --resolution 1280x720 --max-fps 60 --log-file "$PWD/playtest-engine.log" -- --checkpoint-diagnostics
```

Allow microphone access when macOS asks so your friends can hear you. If previously denied, enable licensed under System Settings → Privacy & Security → Microphone, then relaunch.

Use the reception desk to gather your friends. All three pick the monster truck at the booking board, then sit in the waiting-room chairs. Walk with WASD, look with the mouse, use E to interact. On the truck, E takes/releases a physical control; A/D steers the held axle; W/S operates throttle/service brake; stopped-only R changes direction; Space toggles parking brake; H shows control hints. Escape opens mic/quit controls and the three-person concession proposal. Exactly three humans remain required; there is no solo or two-person test.

This is a cooperation checkpoint with a modeled truck, animated learners and static scrapyard scenery. Full course manoeuvres, moving hazards and a complete scored pass are unfinished. SESSION.md describes the manual exercises and evidence still required. Windows native launch, Intel Mac launch and mixed-platform three-person Steam play remain human verification tasks. Local automated checks and an Apple silicon startup do not establish those results.

If startup fails, confirm Steam is running and signed in, preserve playtest-engine.log (or the default Godot log under the licensed user-data folder), and report platform, source commit and archive SHA256. Diagnostics are optional; share logs privately after checking for account identifiers. Checkpoint JSONL records live under the game's user-data folder. SHA256.txt next to the download checks the ZIP; MANIFEST.json inside records source, tool and packaged asset hashes.

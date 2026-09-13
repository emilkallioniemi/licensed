Static scrapyard cooperation playtest for exactly three friends using Steam, with the modeled monster truck and animated learners. The full course, moving hazards and completed scored pass are unfinished; three-person cooperation acceptance remains pending.

Download the ZIP for your platform and extract everything before launching. Keep the extracted files together and read the included README.md and SESSION.md.

- Windows x86_64: run `licensed.exe`, or `run-playtest.cmd` for windowed play and diagnostics. The executable is unsigned.
- macOS universal (Apple silicon and Intel, macOS 11+): open `licensed.app`. It is ad hoc signed, not Developer ID signed or notarized. If blocked, attempt opening once, then use System Settings → Privacy & Security → Open Anyway for this app if you trust this download. The included README has microphone and diagnostics instructions.

Steam must be running and signed in on each player's computer with separate accounts (development app 480 / Spacewar). All three players must use this same release; older builds may still appear at reception. Compare `source_commit` in MANIFEST.json. Gather at reception, choose the monster truck at the booking board, and sit in the waiting-room chairs to depart.

Both archives come from source commit `728ae10d8624d03f1f256aa47c1183aefa8582df`, tree `79d3d684d81d71fc25778206ccc89a7a82db8291`, using Godot 4.7.2 and GodotSteam 4.22.1. Each MANIFEST.json records source, tool/template, native-library and packaged-file hashes. Final ZIP integrity and all packaged-file hashes passed verification; both export logs contain no errors or warnings. SHA256.txt verifies the downloaded ZIPs:

```text
0b06d72fe82783109c4a019f3fed2835ba9d0ffff5a8e34e063f985f0a035123  licensed-scrapyard-macos-universal.zip
0e9c07544b08fa55db3c41d60546ffd8264d0e1cdafd3b9e3f80384eb5296d9a  licensed-scrapyard-windows-x86_64.zip
```

The final macOS ZIP was extracted and its deep strict signature verified. The extracted app started on Apple silicon (M2 Pro), loaded the Steam client successfully and remained running during a 30-second observation with no errors or warnings. Windows native execution, Intel Mac execution, microphone capture/permission flow and mixed-platform three-person Steam play remain unverified. This release does not establish human checkpoint acceptance.

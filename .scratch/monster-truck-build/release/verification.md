# 08b export verification — 2026-09-13

This evidence concerns provisional working-tree exports based on e57e8a2ff53b573cee412abfe5c6e67089c77338, with the 08b export tooling/dependencies added. These archives are not the final tagged release. 08c must rebuild using --commit on the reviewed 08b commit.

Provisional export 2: export/scrapyard-playtest-provisional-08b-2. Both exports completed. Windows x86_64 EXE and both DLL PE headers passed; nonempty PCK present. Both ZIP CRCs and all packaged file hashes matched the manifests. Mac engine, GodotSteam release adapter and Steam API library contain x86_64 and arm64. The adapter resolves @loader_path/libsteam_api.dylib beside itself in Contents/Frameworks. Engine minimum OS is 10.13 Intel / 11.0 arm64; native addons require 11.0 both, and both application minimum-OS preset fields are 11.0. Deep strict codesign verification passed.

Root independently extracted the Mac ZIP with ditto to /private/tmp/licensed-08b-extracted, verified deep strict signatures after extraction, then launched the actual extracted executable in a native window. It survived the bounded 15-second observation and was terminated externally (exit -15). The log reports Godot 4.7.2, Metal 4 on Apple M2 Pro and Steam runtime loaded OK, with no ERROR. Retained macos-boot-redacted.log removes the Steam account identifier. This establishes native Apple silicon startup and extension loading, not multiplayer or full test-suite completion.

The exporter emits only host editor-settings write errors in the sandbox: these name editor_settings-4.7.tres and do not concern game resources. The final recipe rejects all ERROR lines; provisional mode tolerates only those exact settings errors. Export 1 correctly exposed missing global ETC2/ASTC imports; project.godot now enables them for universal macOS, and export 2 passed. No gameplay logic changed.

The existing 08a validation (11 headless suites and three native world suites with final PASS) is retained by that ticket. No claim of Windows native execution, Intel native execution, mixed-platform Steam play, full-course completion, or exactly-three-human acceptance is made. Those remain human checks. Historical Windows-only/model-only exports were preserved.

Launch copy checked against truck_boarding.gd and escape_overlay.gd: control-specific E/H/R/Space handling, stopped forward/reverse hint, microphone/quit and unanimous concession are accurate. All testers must use the same release because current room discovery does not isolate versions. Steam-only shipping and exactly-three-human rules are unchanged.

Review follow-up: the macOS preset now declares NSMicrophoneUsageDescription and the audio-input signing entitlement required for Steam voice. The builder asserts both in the exported app. A dedicated release SESSION.md adapts the historical protocol to both platforms, their diagnostics launch commands and user-data paths; the historical session document remains untouched. Provisional export 3 was intentionally rejected by the stricter scanner after the sandbox denied get_system_ca_certificates; a native provisional export 4 checks the completed recipe without that sandbox constraint.

The overwrite guard was exercised against provisional export 2 and correctly exited 2 before touching its artifacts. Python compilation and git diff --check passed. Full source-commit mode will be exercised in 08c once root creates the reviewed 08b commit; no provisional manifest claims committed-source identity.

Final 08b provisional verification: root ran the completed recipe natively into export/scrapyard-playtest-provisional-08b-4; exit 0, both export logs free of ERROR/WARNING. Every recipe assertion passed, including both platform archive file hashes, Windows PE structure, universal Mac dependencies/linkage, strict deep signature, microphone usage description and audio-input entitlement. Standards review and spec follow-up both report zero residual findings. Microphone capture/permission dialogue and cross-platform human play remain pending.

Provisional 4 ZIP SHA256 values (never use these as final 08c hashes):

- macOS: `16be89dc5c6d7efaa8ef2daaab614bb8ef4a7fb65b8d79d926ab6cd4da8d4358`
- Windows: `3c5941bb782b17ea18a2fe209e3fa0a0ffe718ab9651a4f3517042a2cd255332`

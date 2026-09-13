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


# 08c committed export verification — 2026-09-13

Final output: `export/scrapyard-playtest-728ae10`. Root ran the committed recipe with `--commit 728ae10d8624d03f1f256aa47c1183aefa8582df`; it exited 0 with all assertions passing. Both manifests identify that exact source commit, tree `79d3d684d81d71fc25778206ccc89a7a82db8291`, and `provisional_working_tree: false`. Independent inspection compared all 622 source-file hashes in each manifest against `git archive` of that commit, verified both ZIP CRCs and all 12 macOS / 8 Windows packaged-file hashes, and matched both ZIP hashes to SHA256.txt. Both export logs contain zero ERROR or WARNING lines.

Final downloads:

| Archive | Bytes | SHA256 |
| --- | ---: | --- |
| licensed-scrapyard-macos-universal.zip | 87964638 | `0b06d72fe82783109c4a019f3fed2835ba9d0ffff5a8e34e063f985f0a035123` |
| licensed-scrapyard-windows-x86_64.zip | 64974189 | `0e9c07544b08fa55db3c41d60546ffd8264d0e1cdafd3b9e3f80384eb5296d9a` |

Pinned input provenance (full native-file hashes are also in both shipped manifests and inputs.json):

- Official Godot 4.7.2 stable macOS universal editor: `c7cccbf8fb143e34e02fd6521e09be2c2b974f0d5db080b19071c9c570718ccf`.
- Godot_v4.7.2-stable_export_templates.tpz: templates/windows_release_x86_64.exe: `d34d36f3be1a6c49c56525ae86469b92e4f417ddf0b43cf00dd80c385c4b0562`.
- Godot_v4.7.2-stable_export_templates.tpz: templates/macos.zip: `88df5e2e6fee99088699be66e6d42e4da4fb0c5619d054297d755a49558a4792`.
- GodotSteam 4.22.1 / Steamworks SDK 1.65, godotsteam-4.22.1-gdextension-plugin-4.4.zip: `2b12b3499434c50da16104a0d22b725aee15cc5cd41223c1cea825bae59bfa8f`.

Final builder checks passed for Windows EXE/DLL x86_64 PE structure and nonempty PCK; Mac engine and both native libraries contain arm64 and x86_64, with the Steam API dependency resolved beside the adapter via @loader_path. The minimum supported application target is macOS 11.0. Microphone usage description, audio-input entitlement and deep strict code signature assertions passed. Root extracted the final Mac ZIP with ditto into `/private/tmp/licensed-08c-final-extracted` and independently verified the extracted app's deep strict signature.

Windows is unsigned. macOS is ad hoc signed and not notarized. Windows native execution, Intel Mac execution, microphone capture/permission flow, mixed-platform Steam play and exactly-three-human checkpoint acceptance remain pending; no complete course or scored-pass acceptance is claimed. The final notes retain these limits and the same-release requirement because room discovery does not isolate versions.

Final native Mac startup: the first bounded launch found Steam unavailable, so it does not establish successful startup. Root restarted Steam and repeated the extracted-app launch. The second run reported Godot 4.7.2, Metal 4 Forward+ on Apple M2 Pro and Steam client loaded OK; no ERROR or WARNING appeared. It remained alive for the full 30-second observation and was terminated externally (exit -15). This verifies final Apple silicon startup and Steam extension initialization only. The raw local log is `/private/tmp/licensed-08c-final-boot2.log`; it can contain account identifiers and is not part of the release assets.

Publication: root published [scrapyard-playtest-2026-09-13](https://github.com/emilkallioniemi/licensed/releases/tag/scrapyard-playtest-2026-09-13) as a public GitHub prerelease (not a draft), with both final ZIPs and SHA256.txt. The tag points to the exact source commit `728ae10d8624d03f1f256aa47c1183aefa8582df`. Publication uses the finalized release notes above; this evidence is recorded afterward and does not move the source tag. Standards and spec reviewers report zero source findings.

Remote verification: root queried the release API (`draft: false`, `prerelease: true`, exactly three assets), resolved the remote tag with `git ls-remote` to the exact source commit, and downloaded all three published assets into `/private/tmp/licensed-08c-remote-assets`. Both ZIP hashes match the final values above. Published SHA256.txt matches the local file byte-for-byte with SHA256 `80fce6d013d337a485ef4387e6acea1ce7c76657118939c4e935a58027ed7a6c`. Independent local hashing of all three downloaded assets confirmed the same matches. API metadata is retained locally at `/private/tmp/licensed-08c-remote-release.json`. All 08c publication criteria are satisfied; human gameplay/platform checks remain pending as stated in the published notes.

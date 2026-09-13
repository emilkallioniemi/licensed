# Cross-platform scrapyard export procedure

The macOS-hosted builder exports Windows x86_64 and macOS universal from a single source snapshot. It needs Python 3.9+ and tar, native Godot 4.7.2, Apple's lipo/otool/vtool/codesign/ditto and the official matching Windows release and macOS templates. Large engine templates stay outside git. Exact accepted SHA256 values and GodotSteam provenance are pinned in inputs.json. Obtain Godot/editor and export templates from the official Godot 4.7.2 release; extract templates/windows_release_x86_64.exe and templates/macos.zip from Godot_v4.7.2-stable_export_templates.tpz. Mac and Windows GodotSteam 4.22.1 native libraries are vendored together.

From the repo checkout, after committing 08b:

```sh
python3 .scratch/monster-truck-build/release/build.py \
  --commit FULL_08B_COMMIT \
  --godot /Users/emka/Downloads/Godot.app/Contents/MacOS/Godot \
  --windows-template /private/tmp/licensed-06-windows-templates/windows_release_x86_64.exe \
  --macos-template /private/tmp/licensed-release-templates/macos.zip \
  --output export/scrapyard-playtest-FULL_08B_COMMIT
```

Use a new or empty output directory. Earlier checkpoint-06 and checkpoint-06-modeled artifacts are historical and never overwritten. The final path must use --commit; git archive stages that exact commit, independent of working-tree changes. The invoked builder and pin file must match that commit. Both export presets receive only absolute custom-template path overrides in the staging directory. Source hashes are captured before that override. Timestamps/imports/signatures can vary, so this procedure reproduces specified inputs and game source, not a promise of bit-identical ZIPs.

Before the 08b commit, replace --commit with --working-tree to validate provisional artifacts. Those manifests explicitly mark working-tree provenance; never publish them as the committed release. Root commits reviewed tooling/dependencies, then 08c builds again from the exact resulting commit and tags that source. Publication evidence is recorded afterward, separately.

The builder validates pinned inputs, matching native addon hashes, nonempty Windows PCK, Windows executable/DLL PE x86_64 headers, Mac engine and Frameworks universal architectures, Mach-O build/linkage inspection, strict deep app signature and ZIP CRC/file hashes. Inspect macos-binary-checks.txt for minimum OS and @loader_path resolution. Verify the Mac ZIP extracted with ditto retains executable permissions and codesign integrity, then actually launch the extracted app with a bounded external timeout and record startup/Steam availability. Do not mistake --quit-after for a complete test-suite pass. Windows and Intel execution and mixed-platform Steam remain human checks. Release/engine export logs remain next to the ZIPs; inspect errors before publication.

Publish both ZIPs and SHA256.txt as a new GitHub release/tag on the exact source commit; do not replace waiting-room-playtest. Adapt release-notes.md using actual final verification facts. The app's identifier is com.emilkallioniemi.licensed; signing is ad hoc with library-validation entitlement, notarization disabled. No Developer ID credentials are assumed. All testers need the same version despite older rooms remaining discoverable under the current filter.

Godot's [macOS export implementation](https://github.com/godotengine/godot/blob/4.7-stable/platform/macos/export/export_plugin.cpp) requires the project-level ETC2/ASTC texture import option for arm64/universal export; project.godot enables it alongside the existing renderer settings. Platform-specific minimum OS preset fields are both 11.0. Provisional sandbox builds allow only the exact host editor_settings-4.7.tres save errors; final committed builds reject every ERROR line and should run with permission to save editor preferences.

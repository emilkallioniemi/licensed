# Waiting-room playtest zip

A friend downloads one zip from a GitHub release, unzips it, and double-clicks `licensed.exe` with Steam running. They arrive in a room of their own.

## Produce the next zip

1. Open this project in Godot 4.7. **Project → Export → Windows Desktop**. Export as a **release** build (not debug). The committed preset writes `export/release/licensed.exe` and `export/release/licensed.pck`. The GodotSteam extension copies `libgodotsteam.windows.template_release.x86_64.dll` and `steam_api64.dll` beside them.
2. Zip those four files and nothing else. Do not add `steam_appid.txt`.
3. Attach the zip to a GitHub release.

The preset uses the stock Godot 4.7 Windows x86_64 templates (`custom_template` left empty). Install those templates in the editor once; then Export is enough.


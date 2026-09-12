# 01. GodotSteam on Godot 4.7: install, init, ship

Type: research
Status: resolved
Blocked by: —
Map: ../map.md
Findings: branch `research/godotsteam-on-godot-4-7`, file `docs/research/godotsteam-on-godot-4-7.md`

## Question

What exactly do we install, call, and ship to have Steam working in this Godot 4.7 project on Windows, for a build friends download from a GitHub release rather than from Steam?

Specifically:

1. Which GodotSteam distribution fits Godot 4.7: the GDExtension (asset library or zip), or the pre-built editor? Which version, and does it register `SteamMultiplayerPeer` out of the box now that the separate MultiplayerPeer repo is retired?
2. The minimal init sequence (`steamInitEx` or equivalent) with app ID 480, how `steam_appid.txt` is found, and what a failed init looks like so the game can show a clear "Steam is not running" state.
3. What must sit next to the exported `.exe`: `steam_api64.dll`, `steam_appid.txt`, the extension binaries. What the Windows export preset needs so the GDExtension ships. Whether the exe being launched outside Steam (double-clicked from a zip) breaks anything: init, friends list, avatars, P2P.
4. How to read the local user's name and avatar, and a friend's name and avatar, through the extension (which calls, which signal delivers the avatar image, how to turn it into an `ImageTexture`).
5. Any known gotcha with Jolt or Forward+ in combination with the extension. Probably none; confirm.

Deliverable: the findings file, with a "do this" section short enough to paste into the spec, and every claim linked to godotsteam.com docs, the GodotSteam source, or Valve's Steamworks docs.

## Answer

Resolved 2026-09-12 by a research subagent. Full findings with citations: `docs/research/godotsteam-on-godot-4-7.md` on branch `research/godotsteam-on-godot-4-7` (commit 82d4eed, worktree `..\licensed-research-godotsteam`).

1. **Install** GodotSteam GDExtension **4.22.1** (Steamworks SDK 1.65; Asset Library asset 2445 or the `godotsteam-4.22.1-gdextension-plugin-4.4.zip` from Codeberg). Declared `compatibility_minimum = "4.4"` with no maximum, so 4.7 loads it. It bundles `SteamMultiplayerPeer` and `SteamPacketPeer` since 4.17; do not install the retired ExpressoBits peer alongside it. Not the pre-compiled editor. Nothing to "enable".
2. **Init** in an autoload with `PROCESS_MODE_ALWAYS`: `Steam.steamInitEx(480, true)`. Passing 480 sets the `SteamAppId` / `SteamGameId` env vars, so no `steam_appid.txt` is needed at all; `true` embeds `run_callbacks()`. Steam is usable only when `status == Steam.STEAM_API_INIT_RESULT_OK` (0). Status 2 = Steam client not running, 3 = client out of date, 1 = generic; Valve's message is in `verbal`. That is the "Steam is not running" state.
3. **Ship**: stock Godot 4.7 Windows x86_64 export preset, standard templates. The shipped `godotsteam.gdextension` makes the export include `libgodotsteam.windows.template_release.x86_64.dll` (via `[libraries]` feature tags) and copy `steam_api64.dll` next to the exe (via `[dependencies]`). GitHub release zip = `exe + pck + those two DLLs`. Never ship `steam_appid.txt`.
4. **Names and avatars**: `getPersonaName()`, `getSteamID()`, `getFriendPersonaName(id)`. Connect `Steam.avatar_loaded` (`user_id, width, PackedByteArray`), call `Steam.getPlayerAvatar(Steam.AVATAR_MEDIUM[, id])`, then `ImageTexture.create_from_image(Image.create_from_data(w, w, false, Image.FORMAT_RGBA8, data))`. `requestUserInformation(id, false)` for users not met via friends or lobby.
5. **Outside Steam** (double-clicked from a zip): init, friends, avatars, lobbies and P2P (relayed by Steam) all work as long as the Steam client is running and logged in on each PC. Only the overlay is unreliable, which suits the in-game-invite decision. No documented Jolt interaction; the one Forward+ note is in-editor overlay flicker, irrelevant.

UNVERIFIED (flagged in the doc): Valve's public reference does not yet document `SteamAPI_InitEx` / `ESteamAPIInitResult` (enum names come from GodotSteam's table); and no primary source states that every Steam account holds a Spacewar (480) license, though both projects treat it as universally usable.

Unblocks: Testing alone: a second transport or a fake.

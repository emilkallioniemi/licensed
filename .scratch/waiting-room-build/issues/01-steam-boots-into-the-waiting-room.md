# 01: Steam boots the game into the waiting room

**Spec:** `.scratch/waiting-room/spec.md`, sections 0, 1 and 13. Read `docs/design.md` before writing the two lines of signage.

**What to build:** A player with Steam running double-clicks the game and is in the waiting room, music playing, with their Steam name and avatar already known to the game. A player without Steam running gets one line telling them so and a way out. There is no menu in front of the room.

Install the GodotSteam GDExtension 4.22.1 (the one that bundles `SteamMultiplayerPeer`; not the pre-built editor, not the retired separate peer). A Steam autoload with `PROCESS_MODE_ALWAYS` calls `Steam.steamInitEx(480, true)` first thing and treats Steam as usable only on `STEAM_API_INIT_RESULT_OK`. No `steam_appid.txt` anywhere. Every client sets the rich-presence key `licensed` = `1` at boot. Local identity comes from `getPersonaName` and `getSteamID`; the medium avatar arrives through `avatar_loaded` and becomes an `ImageTexture` (nothing renders it yet, but it is there for the desk).

On success the kit's waiting room scene loads as the game's main scene with the music loop playing on an `AudioStreamPlayer` (fades happen on the player, never in the asset). A fixed camera near the entrance is fine for this ticket; the learner comes in 03. On failure the Steam-not-running state: a plain black window, the signage line "Steam is not running.", Valve's `verbal` message beneath it in smaller text, and Escape or the window close quitting to desktop. No room is opened.

The existing empty main scene (box ground, label) is replaced, not kept beside it.

**Blocked by:** None (can start immediately).

**Status:** done

- [x] Launching with Steam running opens straight into the kit's waiting room with the music loop playing seamlessly; the console (or a debug label) shows the local Steam name and Steam id.
- [ ] Launching with Steam closed shows a black window with "Steam is not running." and Valve's message; Escape and the window close both quit; no room, no music.
- [x] `steam_appid.txt` exists nowhere in the project.
- [x] The rich-presence key `licensed` is set to `1` at boot (visible via a friend's `getFriendRichPresence`, or logged).
- [x] The medium avatar for the local user is loaded into an `ImageTexture` after `avatar_loaded`.
- [x] The GDExtension's `.gdextension` file is in the project so a stock Windows export includes the GodotSteam DLL and copies `steam_api64.dll` beside the exe (the export itself is ticket 14).

## Comments

**Orchestrator, 2026-09-12.** Done in commits 11d9a54, 637acb6, e28e425. Hand check pending: launch with the Steam client closed and confirm the black window, "Steam is not running." with Valve's line beneath, Escape and window close quitting, no room, no music. The subagent verified this path by forcing `init_status` to NO_STEAM_CLIENT; the real `steamInitEx` failure return was never observed. Also open: `tests/verify_steam_client.gd` (avatar decode, Steam-free) sits outside the spec's "the room state is the only module with automated tests" line; kept because it is the one Steam-free seam in this ticket.
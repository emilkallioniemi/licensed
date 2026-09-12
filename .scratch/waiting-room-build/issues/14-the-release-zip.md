# 14: The release zip

**Spec:** `.scratch/waiting-room/spec.md`, section 12 and the release line in Testing Decisions. Research with citations is on branch `research/godotsteam-on-godot-4-7`. ADR-0002 binds the shipping transport.

**What to build:** A friend downloads one zip from a GitHub release, unzips it, double-clicks the exe with Steam running, and arrives in a waiting room of their own, ready to be invited, to talk, and to play the whole slice. This is the last ticket: the zip carries voice and the desk, so friends never need anything but the download and Steam.

A stock Godot 4.7 Windows x86_64 export preset with the standard templates, committed to the repo. The GDExtension's `.gdextension` file makes the export include the GodotSteam release DLL and copy `steam_api64.dll` beside the exe. The zip is exe + pck + those two DLLs and nothing else; never `steam_appid.txt`. Friends see each other "playing Spacewar" until the game owns an AppID; that is a later task. Neither `--transport` nor `--min-players` is mentioned anywhere a player reads.

Launched outside Steam (double-clicked from the zip) init, friends, avatars, lobbies, P2P, and voice all work with the Steam client running; only the overlay is unreliable, which the in-world desk makes irrelevant.

Write down, in one short section of the repo's README or a release note next to the preset, how to produce the zip (export from the preset, zip the four files, attach to a GitHub release) so the next release is a repeat, not a rediscovery.

**Blocked by:** 10 (the desk with Invite and Join, so friends can find each other), 13 (voice, or its `wontfix`).

**Status:** ready-for-agent

- [ ] The export preset is committed and exports a Windows build without editor intervention beyond pressing Export.
- [ ] The exported folder holds exactly the exe, the pck, the GodotSteam DLL, and `steam_api64.dll`; no `steam_appid.txt`.
- [ ] Unzipped on a second machine with Steam running, double-clicking the exe opens straight into a waiting room with music, the player's Steam name, and their own hosted room.
- [ ] From that machine the desk lists friends at the test centre and Join and Invite work against Emil's machine; voice is heard both ways (or Discord is noted as the fallback per ticket 13).
- [ ] Unzipped with Steam closed, the exe shows the Steam-not-running state and quits on Escape.
- [ ] The zip is attached to a GitHub release and the steps to reproduce it are written down in the repo.

## Comments

**From ticket 01 (orchestrator).** One `--quit-after` run reported "2 ObjectDB instances leaked" at exit and the next did not; looks like a Steam callback/exit race, not reproducible, worth watching in the exported build.

**From ticket 09 (orchestrator).** Emil: two-machine Steam checks are **assumed**, not observed — do not park for lack of a second Steam account. A debug zip already exists at `export/licensed-waiting-room.zip` (Desktop copy too); ticket 14 still needs a **release** preset, the four-file release zip (`libgodotsteam.windows.template_release.x86_64.dll`), and the written reproduce steps. `export_presets.cfg` is already untracked in the working tree — clean custom-template paths (empty), commit the preset. Voice is in (ticket 13). If you cannot attach a GitHub release, write why in Comments and leave that box unticked rather than inventing a remote.
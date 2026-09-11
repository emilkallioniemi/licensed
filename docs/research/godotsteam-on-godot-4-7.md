# GodotSteam on Godot 4.7: install, init, ship

Research note for the ticket "GodotSteam on Godot 4.7: install, init, ship". Written 2026-09-12 against primary sources only (godotsteam.com, the GodotSteam Codeberg/GitHub repos, Valve's Steamworks documentation, Godot's official docs). Anything not traceable to one of those is marked **UNVERIFIED**.

Context: this project is Godot 4.7, Forward+ (`config/features=PackedStringArray("4.7", "Forward Plus")` in `project.godot`), Windows x86_64, shipped to friends as a zip from a GitHub release, not through Steam. Test app ID is 480 (Valve's SpaceWar).

## Do this

1. Install **GodotSteam GDExtension 4.22.1** (Steamworks SDK 1.65). Get it from the Godot Asset Library ("GodotSteam GDExtension 4.4+", asset 2445) or download `godotsteam-4.22.1-gdextension-plugin-4.4.zip` from the Codeberg release `v4.22.1-gde` and unzip it into the project root. It lands in `addons/godotsteam/` and works on any Godot 4.4+, so 4.7 is covered. Do not use the pre-compiled editor; do not install ExpressoBits' SteamMultiplayerPeer alongside it. Restart the editor once. `SteamMultiplayerPeer` and `SteamPacketPeer` are included in the same extension.
2. Do not enable the plugin in Project Settings > Plugins (it only adds an editor dock). The `Steam` singleton exists globally as soon as the addon folder is present.
3. Make an autoload (for example `steam_client.gd`, `process_mode = PROCESS_MODE_ALWAYS`) and in `_ready()` call `var r: Dictionary = Steam.steamInitEx(480, true)`. `480` sets the `SteamAppId`/`SteamGameId` environment variables for you, so no `steam_appid.txt` is needed anywhere. `true` embeds `run_callbacks()` so you do not have to call it in `_process()`. Steam is usable only when `r.status == Steam.STEAM_API_INIT_RESULT_OK` (0). Treat `2` (`STEAM_API_INIT_RESULT_NO_STEAM_CLIENT`) as "Steam is not running", `3` as "Steam client out of date", `1` as generic failure; `r.verbal` holds Valve's text. Cache `steam_enabled` and gate every other `Steam.*` call on it. Anyone can re-read the result later with `Steam.get_steam_init_result()`.
4. Export with the stock Godot 4.7 Windows Desktop preset (standard export templates, x86_64). Nothing extra to configure: the `libraries` section of `addons/godotsteam/godotsteam.gdextension` makes Godot export `libgodotsteam.windows.template_release.x86_64.dll` (or `..._debug...` when "Export With Debug" is on), and its `dependencies` section copies `steam_api64.dll` next to the exe. The release folder is therefore: `licensed.exe`, `licensed.pck`, `libgodotsteam.windows.template_release.x86_64.dll`, `steam_api64.dll`. Zip that folder. Do not ship `steam_appid.txt`. Do not zip `.pck` separately from the DLLs.
5. Names and avatars: local name `Steam.getPersonaName()`, local ID `Steam.getSteamID()`, friend name `Steam.getFriendPersonaName(steam_id)`. For avatars connect `Steam.avatar_loaded` once, then call `Steam.getPlayerAvatar(Steam.AVATAR_MEDIUM, steam_id)` (omit `steam_id` for yourself). The signal delivers `(avatar_id: int, width: int, data: PackedByteArray)`; build the texture with `ImageTexture.create_from_image(Image.create_from_data(width, width, false, Image.FORMAT_RGBA8, data))`. For a Steam ID you have not met through friends/lobby, call `Steam.requestUserInformation(steam_id, false)` first and wait for `persona_state_change`.
6. Running the exe from a zip, outside Steam: init, friends, names, avatars, lobbies and P2P (`SteamMultiplayerPeer`) all work as long as the Steam client is running and logged in on that PC. The overlay is the only thing that is unreliable; do not depend on it. Show the "Steam is not running" state from step 3 when init fails.
7. Jolt and Forward+: no documented interaction with the extension. The single renderer-related note is that the overlay can flicker or not appear when running from the editor under Vulkan/Forward+; the GodotSteam "auto-initialize" project setting exists to mitigate that. Ignore for this game.

## 1. Which distribution and version

**Distribution.** For Godot 4 the GDExtension plugin and the pre-compiled editor are described as functionally equivalent ("Both have access to in-editor documentation. Both have the Steam object globally by default. Both behave exactly the same using the same code-base underneath"). The differences are: the pre-compiled editor requires its own export templates, the plugin uses Godot's standard templates but needs extra shared libraries shipped (which are provided), and plugin failures can be harder to debug. GodotSteam says that with Godot 4 "you should not run into any real problems with the GDExtension plug-in" and warns not to mix the pre-compiled editor with the plugin. Source: <https://godotsteam.com/getting_started/introduction/>

The GDExtension is the right choice here: the project already uses the stock Godot 4.7 editor and stock export templates, and the plugin does not force a custom editor build on every contributor.

**Version.** The current release is GodotSteam 4.22.1 with Steamworks SDK 1.65, published 2026-09-04. The GDExtension release (`v4.22.1-gde`) states: "Works on any Godot version 4.4 and up. Just drop the contents of this zip into the base of your project and that's it!" and ships as `godotsteam-4.22.1-gdextension-plugin-4.4.zip` (Windows, Linux, Android ARM64, macOS). The parallel pre-compiled editor release (`v4.22.1`) is built "In Godot 4.7.2 and 4.5.2 variants", which confirms the project tracks 4.7.x. Source: <https://codeberg.org/godotsteam/godotsteam/releases>. GitHub only hosts overflow files and links back to Codeberg: <https://github.com/GodotSteam/GodotSteam/releases/tag/v4.22.1>

The Asset Library listing is "GodotSteam GDExtension 4.4+" version 4.22.1, "based on GodotSteam 4.22.1 with Steamworks SDK 1.65. This version is meant for Godot Engine 4.4 and newer". It also says: "It does not require enabling but you may need to restart your editor. Enabling the plug-in in the Project Settings only displays the Steamworks dock and has no effect on functionality." Source: <https://godotengine.org/asset-library/asset/2445>

The shipped `godotsteam.gdextension` has `compatibility_minimum = "4.4"` and no `compatibility_maximum`, so Godot 4.7 will load it. Source: <https://codeberg.org/godotsteam/godotsteam/raw/branch/gdextension/godotsteam.gdextension>. Godot's semantics for those keys: `compatibility_minimum` "prevents older versions of Godot from loading extensions", `compatibility_maximum` "prevents newer versions of Godot from loading the extension". Source: <https://docs.godotengine.org/en/latest/engine_details/engine_api/gdextension/gdextension_file.html>

GodotSteam's own "what are you making" page currently points Godot 4.x users at 4.22.1 / SDK 1.65. Source: <https://godotsteam.com/getting_started/what_are_you_making/>

**SteamMultiplayerPeer is bundled.** From the 2025-12-09 announcement: "This also marks MultiplayerPeer getting rolled into the main project. The MultiplayerPeer repo will be left for people using older versions, though no new releases will be put out on that repository moving forward." and "FriarTruck's awesome MultiplayerPeer work has also been wrapped into the main GDExtension for people who like that plug-ins. You will not want to use this with ExpressoBits' SMP GDExtension, however, as they have conflicting class registration. To keep using that, you'll want to stick to 4.16.2 or earlier." Source: <https://godotsteam.com/blog/2025/12/09/godotsteam-end-of-year-updates/>

Corroboration: the GDExtension source tree contains `godotsteam_multiplayer_peer.cpp/.h` and `steam_packet_peer.cpp/.h` next to `godotsteam.cpp` (<https://godotsteam.com/howto/gdextension/>); the 4.20 GDExtension changelog adds "binds for `get_connection_handle()` and `get_state()` for SteamPacketPeer" and fixes a "crash in `lobby_chat_update` when lobby member leaves with MultiplayerPeer" (<https://godotsteam.com/changelog/gdextension/>); and the class name used in GDScript is `SteamMultiplayerPeer.new()` with `create_host(0)` / `create_client(host_steam_id, 0)` (<https://godotsteam.com/tutorials/multiplayer_peer/>). The class reference is at <https://godotsteam.com/classes/multiplayer_peer/> ("Only available in the main GodotSteam branches").

Note: the changelog page at godotsteam.com currently stops at 4.21; the 4.22/4.22.1 entries are only on the Codeberg release page. Nothing in 4.21 or 4.22.x removes the peer.

## 2. Minimal init sequence, app ID, failure states, callbacks

**Signature.** `steamInitEx(uint32_t app_id = 0, bool embed_callbacks = false) -> Dictionary`. "You can pass your app ID to the first argument and GodotSteam will set the OS environment for you ... You can pass true to the second argument to have GodotSteam connect and use run_callbacks internally so you do not have to do this manually anymore." Both can instead be set in Project Settings > Steam > Initialization, in which case `steamInitEx()` with no arguments uses them. Source: <https://godotsteam.com/classes/main/>

Migration note: before GodotSteam 4.14 the first argument was a bool for stats sync; it was removed, so the call is `Steam.steamInitEx(480, true)`, not `Steam.steamInitEx(true, 480, true)`. Source: <https://godotsteam.com/blog/2025/04/01/godotsteam-updates-for-all-branches/>

**Return value.** Always a dictionary with `"status"` and `"verbal"`. Status codes:

| value | GodotSteam enum | SDK name | meaning |
| --- | --- | --- | --- |
| 0 | `STEAM_API_INIT_RESULT_OK` | `k_ESteamAPIInitResult_OK` | success |
| 1 | `STEAM_API_INIT_RESULT_FAILED_GENERIC` | `k_ESteamAPIInitResult_FailedGeneric` | some other failure |
| 2 | `STEAM_API_INIT_RESULT_NO_STEAM_CLIENT` | `k_ESteamAPIInitResult_NoSteamClient` | "We cannot connect to Steam, it probably isn't running" |
| 3 | `STEAM_API_INIT_RESULT_VERSION_MISMATCH` | `k_ESteamAPIInitResult_VersionMismatch` | "Steam client appears to be out of date" |

Source: enum table in <https://godotsteam.com/classes/main/> and the tutorial <https://godotsteam.com/tutorials/initializing/>. `steamInitEx()` also stores the result so `Steam.get_steam_init_result()` returns the same dictionary later; `steamInit()` (bool return) does not populate it.

Valve's own list of reasons `SteamAPI_Init` fails (the underlying call) is: Steam client not running; Steam cannot determine the App ID; the app is running under a different OS user context than Steam; the account does not own a license for the App ID; the App ID is not set up. Source: <https://partner.steamgames.com/doc/sdk/api#SteamAPI_Init>

**UNVERIFIED**: Valve's public `steam_api` reference page does not currently document `SteamAPI_InitEx` or `ESteamAPIInitResult`; the SDK-name column above comes from GodotSteam's enum table, which cites the SDK names. The four-value semantics are consistent between GodotSteam's docs and the SDK header names.

**Minimal autoload.** Assembled from the initializing tutorial's examples:

```gdscript
# steam_client.gd, autoload, process_mode = PROCESS_MODE_ALWAYS
extends Node

const APP_ID := 480

var steam_enabled := false
var init_status: int = -1
var init_message := ""

func _ready() -> void:
    var r: Dictionary = Steam.steamInitEx(APP_ID, true)  # true = embed run_callbacks()
    init_status = r["status"]
    init_message = r["verbal"]
    steam_enabled = init_status == Steam.STEAM_API_INIT_RESULT_OK
    if not steam_enabled:
        push_warning("Steam init failed (%d): %s" % [init_status, init_message])
```

The tutorial's own error branch is `if initialize_response['status'] > Steam.STEAM_API_INIT_RESULT_OK:` followed by either quitting or setting a `steam_enabled = false` flag and "show some kind of prompt informing the player certain functions are missing". It also lists the most common causes: "a missing API file (steam_api.dll, libsteam_api.so, libsteam_api.dylib) or not setting the game's app ID". Source: <https://godotsteam.com/tutorials/initializing/>

For a "Steam is not running" screen, match on `status == Steam.STEAM_API_INIT_RESULT_NO_STEAM_CLIENT` (2) specifically and fall back to the generic message plus `verbal` for 1 and 3. `Steam.isSteamRunning()` ("Check if the Steam client is running", returns bool) is available for a live re-check. Source: <https://godotsteam.com/classes/main/>

**App ID and `steam_appid.txt`.** Four ways to supply the app ID, per the tutorial: Project Settings > Steam > Initialization (GodotSteam 4.14+); the first argument of `steamInit()`/`steamInitEx()`; setting `OS.set_environment("SteamAppId", "480")` and `OS.set_environment("SteamGameId", "480")` in `_init()`; or a `steam_appid.txt` file. The first two "just set the SteamAppId and SteamGameId environment variables under-the-hood". Source: <https://godotsteam.com/tutorials/initializing/>

Where `steam_appid.txt` is looked up, per Valve: "Create the a text file called `steam_appid.txt` next to your executable containing just the App ID and nothing else." and "Steam will look for this file in the current working directory. If you are running your executable from a different directory you may need to relocate the `steam_appid.txt` file." Source: <https://partner.steamgames.com/doc/sdk/api#SteamAPI_Init>. GodotSteam adds that for the plugin "sometimes it must be in the root of your project to work correctly" when running from the editor. Source: <https://godotsteam.com/tutorials/initializing/>. So: exe dir when double-clicked (cwd == exe dir), cwd in general, and project root while running from the editor.

Recommendation: do not use the file at all. Passing `480` to `steamInitEx` covers editor runs and the zip build identically, and Valve says "You should not ship this with your builds." (<https://partner.steamgames.com/doc/sdk/api#SteamAPI_Init>). If it is used anyway, watch for the Windows `steam_appid.txt.txt` trap (<https://godotsteam.com/issues/common_issues/>).

Project Settings defaults changed in 4.20: "app type toggle" and separate app ID fields for game/demo/playtest/tool were added, and the init process "can use correct ID based on app type setting". Source: <https://godotsteam.com/changelog/gdextension/>. Passing the ID explicitly to `steamInitEx` sidesteps this.

**Callbacks.** Valve: "For callbacks to dispatch to registered listeners you must call the SteamAPI_RunCallbacks. It's best to call this frequently ... Most games call this once per render-frame, it's highly recommended that you call this at least once a second." Source: <https://partner.steamgames.com/doc/sdk/api#Callbacks>. In GodotSteam that is `Steam.run_callbacks()`, "Must be placed in your _process function", or "check Embed Callbacks in the Project Settings > Steam > Initialization" (<https://godotsteam.com/classes/main/>). Passing `true` as the second argument to `steamInitEx` does the same. Signals such as `avatar_loaded`, `lobby_created`, `persona_state_change` do not fire without it. Warning from the tutorial: "if their run_callbacks() sits in a script or node that can be paused, said callbacks will fail to trigger", hence the autoload with `PROCESS_MODE_ALWAYS`. Embedded callbacks were broken in 4.14 and fixed in 4.16.1 ("Fixed: code related to checking for manual `run_callbacks()` and embedded callbacks"); 4.22.1 is well past that. Sources: <https://godotsteam.com/tutorials/initializing/>, <https://godotsteam.com/changelog/gdextension/>

**Shutdown.** `steamShutdown()` "is called automatically by GodotSteam when the game or app shuts down." Source: <https://godotsteam.com/classes/main/>

## 3. What ships next to the exe, export preset, running outside Steam

**Files.** Valve: "You must also ship the `steam_api[64].dll` in your run-time directory (next to your program's executable, or in your dll search path)." Source: <https://partner.steamgames.com/doc/sdk/api#GettingStarted>. GodotSteam: "take note of any additional files Godot exports for you like the godotsteam.dll / libgodotsteam.so / libgodotsteam.dylib because these must also be shipped with your game. They create the bridge for the game and Steamworks." and for Windows "use the steam_api.dll for 32-bit or steam_api64.dll for 64-bit." Source: <https://godotsteam.com/tutorials/exporting_shipping/>

The addon layout for Windows 64-bit, from GodotSteam's build guide and the shipped `.gdextension`:

```text
addons/godotsteam/
  godotsteam.gdextension
  win64/
    libgodotsteam.windows.template_debug.x86_64.dll
    libgodotsteam.windows.template_release.x86_64.dll
    steam_api64.dll
```

Sources: <https://godotsteam.com/howto/gdextension/>, <https://codeberg.org/godotsteam/godotsteam/raw/branch/gdextension/godotsteam.gdextension>

**How the export picks them up.** The `.gdextension` file has two relevant sections:

- `[libraries]` with `windows.debug.x86_64 = "res://addons/godotsteam/win64/libgodotsteam.windows.template_debug.x86_64.dll"` and `windows.release.x86_64 = ".../libgodotsteam.windows.template_release.x86_64.dll"`.
- `[dependencies]` with `windows.x86_64 = { "res://addons/godotsteam/win64/steam_api64.dll": "" }`.

Source: <https://codeberg.org/godotsteam/godotsteam/raw/branch/gdextension/godotsteam.gdextension>

Godot's rules for those sections: for `[libraries]`, "By specifying feature flags you can filter which version should be loaded and exported with your game depending on which feature flags are active ... `macos.debug` means that it will be loaded if Godot has both the `macos` and `debug` flag active." For `[dependencies]`: "This is used internally to export the dependencies when exporting your game executable ... If no path is supplied, Godot will move the libraries into the same directory as your game executable." Source: <https://docs.godotengine.org/en/latest/engine_details/engine_api/gdextension/gdextension_file.html>. The GDExtension C++ example adds that the libraries section "will also result in just that file being exported when you export the project, which means the data pack won't contain libraries that are incompatible with the target platform." Source: <https://docs.godotengine.org/en/latest/tutorials/scripting/cpp/gdextension_cpp_example.html>

Consequence for the Windows preset: use the standard Godot export templates (GodotSteam: "When using the GDNative or GDExtension version of GodotSteam, you will need to use the regular Godot templates ... do not use the GodotSteam templates. That will cause a lot of issues." <https://godotsteam.com/tutorials/exporting_shipping/>). Architecture x86_64. Leave "Export With Debug" off for the friends build so the `release` feature tag selects `libgodotsteam.windows.template_release.x86_64.dll`. No resource filters, no manual copy step. The exported folder contains `licensed.exe`, `licensed.pck`, `libgodotsteam.windows.template_release.x86_64.dll`, `steam_api64.dll`. Embedding the PCK into the exe is not required and does not affect the DLLs (**UNVERIFIED** that the embed-PCK option changes nothing about dependency export; the Godot docs above only describe the default).

Keep the whole folder together in the release zip. Do not add `steam_appid.txt` to the zip (Valve: "You should not ship this with your builds"; GodotSteam: "Valve recommends that you do not ship this file with your game, as it can potentially cause issues." <https://godotsteam.com/tutorials/exporting_shipping/>). Since the game passes 480 in code, the file is unnecessary anyway.

Optional: a build with Steam stripped can omit the two DLLs as long as no `Steam.*` call executes ("as long as you don't call any methods on the Steam class provided by this plugin, you can actually simply not export those binaries"). Source: <https://godotsteam.com/tutorials/exporting_shipping/>. Not needed for this project.

Windows gotcha for developers using the Godot editor installed through Steam: that editor ships its own `steam_api64.dll` next to it. GodotSteam 4.20 "Added: check for mismatched Steam API file on Windows and Steam" and 4.20.1 "GodotSteam should now back-up the Steam version of Godot's steam_api64.dll when updating it (Windows only)". Source: <https://godotsteam.com/changelog/gdextension/>. Also, when switching from a pre-compiled editor to the plugin, remove any stray `steam_api64.dll` from the project root or beside the editor, "this will prevent the plug-in from loading correctly". Source: <https://godotsteam.com/issues/common_issues/>

**Running the exe outside Steam (double-clicked from a zip, never added to the library).**

- Init: works if the Steam client is running under the same Windows user and the app ID is known. Valve: "When you launch your app from Steam itself then it will automatically have the App ID available. While developing you will need to hint this to Steam" (via `steam_appid.txt`, or here via the env vars `steamInitEx(480)` sets). Failure reasons are the list quoted in section 2. Source: <https://partner.steamgames.com/doc/sdk/api#SteamAPI_Init>. `restartAppIfNecessary()` is irrelevant here: it relaunches via `steam://run/<appid>` "from the version installed in your Steam library folder" and a present `steam_appid.txt` makes it return false regardless. Do not call it. Source: <https://partner.steamgames.com/doc/sdk/api#SteamAPI_RestartAppIfNecessary>
- App 480 licensing: Valve's SpaceWar page says "the example game's AppID is 480" and its example runs with Steam running plus `steam_appid.txt`; GodotSteam says "you do not need to sign up with Valve to test out the Steamworks API" and "any lobbies you create get lost in a sea of SpaceWar demo lobby results". Sources: <https://partner.steamgames.com/doc/sdk/api/example>, <https://godotsteam.com/getting_started/introduction/>. **UNVERIFIED** from a primary source that every Steam account holds a SpaceWar license; both projects treat 480 as universally usable for testing.
- Friends list, names, avatars: these go through the Steam client's IPC ("all Steam API calls are transparently marshaled and sent via an RPC/IPC mechanism" to `steamclient.dll`, which "maintains a constant connection to the Steam back-end servers. Through this connection all authentication, matchmaking, friends list and VAC communication occurs."). They depend on the client being logged in, not on how the exe was launched. Source: <https://partner.steamgames.com/doc/sdk/api#TechnicalDetails>
- P2P networking: `SteamMultiplayerPeer` runs `connectP2P`/`createListenSocketP2P` under the hood (<https://godotsteam.com/classes/multiplayer_peer/>). Valve: `ConnectP2P` "uses the default rendezvous service ... on Steam, it goes through the steam backend. The traffic is relayed over the Steam Datagram Relay network." and for P2P listen sockets "Any user that owns the app and is signed into Steam will be able to attempt to connect ... a connection attempt may require the client to be connected to Steam". Source: <https://partner.steamgames.com/doc/api/ISteamNetworkingSockets>. Launch method is irrelevant; a logged-in client is required on every peer. Note all peers must be initialised under the same app ID (480) for the rendezvous to match.
- Overlay: Valve: "While in development and running your game in a debugger, the overlay is loaded when you call SteamAPI_Init. As such you'll need to make sure to call SteamAPI_Init prior to initializing the OpenGL/D3D device" and, if it does not appear, "make sure you're launching the app through the Steam client". Source: <https://partner.steamgames.com/doc/features/overlay>. In Godot the rendering device is created before any GDScript runs, so a script-driven `steamInitEx` is inherently after device creation; GodotSteam's auto-initialization project setting exists for this ("This option was originally added to help people using Forward+ who were having issues with Steam overlay", <https://godotsteam.com/tutorials/initializing/>). GodotSteam's honest summary: "It is kind of a crapshoot. However, Steam Overlay should work fine when the exported game is run through the Steam client ... This should also work when the game is run as a non-Steam game." Source: <https://godotsteam.com/issues/common_issues/>. For a zip build that is never added to the library, treat the overlay as unavailable; nothing in this game's design needs it. If it ever matters, "Add a Non-Steam Game" and launching from the library is the documented path.
- Steam Input: the client may "eat" controller input in some configurations; the fix is to disable Steam Input for the game in its Steam properties, which does not apply to an exe not in the library. Source: <https://godotsteam.com/issues/common_issues/>. Low risk here.

## 4. Local and friend name and avatar

**Names.** `getPersonaName()` "Gets the current user's persona (display) name ... Guaranteed to not be empty." `getSteamID()` returns the local Steam ID64. `getFriendPersonaName(steam_id)` "will only be known to the current user if the other user is in their friends list, on the same game server, in a chat room or lobby, or in a small Steam group with the local user" and "Upon on first joining a lobby ... the current user will not known the name of the other users automatically; that information will arrive asynchronously via persona_state_change callbacks." It returns `""` or `"[unknown]"` for unknown IDs. Sources: <https://godotsteam.com/classes/friends/>, mirrored by Valve at <https://partner.steamgames.com/doc/api/ISteamFriends#GetFriendPersonaName>

Enumerating friends: `getFriendCount(friend_flags = FRIEND_FLAG_ALL)` then `getFriendByIndex(i, friend_flags)` with the same flags ("You must call getFriendCount, passing in the same friend_flags value, before calling this"). `getFriendCount` returns -1 if not logged on. Source: <https://godotsteam.com/classes/friends/>. Valve's example uses `k_EFriendFlagImmediate` for "regular" friends. Source: <https://partner.steamgames.com/doc/api/ISteamFriends#GetFriendCount>

**Avatars, GodotSteam shortcut.** `getPlayerAvatar(size = 2, steam_id = 0)`: "This is the preferred method of getting avatars as it shortcuts the various avatar functions in Steamworks ... If no steam_id is passed in, it will get the current user's avatar. This is a unique function to GodotSteam." Sizes: `AVATAR_SMALL` (1, 32x32), `AVATAR_MEDIUM` (2, 64x64), `AVATAR_LARGE` (3, 128x128 or larger). The result arrives on the `avatar_loaded` signal with `avatar_id: uint64_t`, `width: int`, `data: PackedByteArray`. Sources: <https://godotsteam.com/classes/friends/> (`getPlayerAvatar`, `avatar_loaded`), <https://godotsteam.com/tutorials/avatars/>

The tutorial's Godot 4 handler, verbatim in substance:

```gdscript
func _ready() -> void:
    Steam.avatar_loaded.connect(_on_avatar_loaded)
    Steam.getPlayerAvatar(Steam.AVATAR_MEDIUM)            # local user
    Steam.getPlayerAvatar(Steam.AVATAR_MEDIUM, friend_id) # a friend

func _on_avatar_loaded(user_id: int, avatar_size: int, avatar_buffer: PackedByteArray) -> void:
    var avatar_image: Image = Image.create_from_data(avatar_size, avatar_size, false, Image.FORMAT_RGBA8, avatar_buffer)
    if avatar_size > 128:
        avatar_image.resize(128, 128, Image.INTERPOLATE_LANCZOS)
    var avatar_texture: ImageTexture = ImageTexture.create_from_image(avatar_image)
    # user_id tells you whose avatar this is; route it to the right TextureRect
```

Source: <https://godotsteam.com/tutorials/avatars/>. Godot 4 API confirmation: `Image.create_from_data(width, height, use_mipmaps, format, data)` is static and "Creates a new image of the given size and format. Fills the image with the given raw data." `FORMAT_RGBA8` is "OpenGL texture format RGBA with four components, each with a bitdepth of 8." Source: <https://docs.godotengine.org/en/stable/classes/class_image.html>. `ImageTexture.create_from_image(image)` is static and "Creates a new ImageTexture and initializes it by allocating and setting the data from an Image." Source: <https://docs.godotengine.org/en/stable/classes/class_imagetexture.html>. The buffer is RGBA because Valve's `GetImageRGBA` returns it that way: "You can then allocate your buffer with the width and height as: width * height * 4. The image is provided in RGBA format." Source: <https://partner.steamgames.com/doc/api/ISteamUtils#GetImageRGBA>

Because a single `avatar_loaded` signal serves every request, key incoming results by `user_id` (first argument) rather than assuming order.

**Underlying Valve flow (for reference or if `getPlayerAvatar` is ever bypassed).** `getLargeFriendAvatar(steam_id)` / `getMediumFriendAvatar` / `getSmallFriendAvatar` return an image handle: `0` if no avatar, `-1` if "the avatar image data has not been loaded yet and requests that it gets download. In this case wait for a avatar_loaded or avatar_image_loaded callback and then call this again." The handle is then read with `getImageSize` and `getImageRGBA`. Sources: <https://godotsteam.com/classes/friends/>, <https://partner.steamgames.com/doc/api/ISteamFriends#GetLargeFriendAvatar>, <https://partner.steamgames.com/doc/api/ISteamUtils#GetImageSize>. `avatar_image_loaded` is the raw `AvatarImageLoaded_t` passthrough; `avatar_loaded` is GodotSteam's decoded version carrying the pixel buffer. Source: <https://godotsteam.com/classes/friends/>

**Unknown users.** For someone the local user does not know (not a friend, not in a shared lobby): `requestUserInformation(steam_id, require_name_only)`: "Requests the persona name and the avatar of a specified user. If require_name_only is set, then the avatar of a user isn't downloaded ... If this returns true, it means that data is being requested and a persona_state_change callback will be posted when it's retrieved. If this returns false, it means that we already have all the details about that user and functions can be called immediately." Sources: <https://godotsteam.com/classes/friends/>, <https://partner.steamgames.com/doc/api/ISteamFriends#RequestUserInformation>. Lobby members count as known once in the lobby, so for a 3-player lobby this is normally only needed for out-of-lobby lookups.

## 5. Jolt and Forward+ gotchas

No GodotSteam document (introduction, common issues, initializing, exporting, changelogs through 4.21, the Codeberg release notes for 4.22/4.22.1) mentions Jolt or any physics engine. The extension talks to Steam over the client's IPC and does not touch the physics or rendering servers. Nothing to do.

Forward+ has exactly one documented interaction, and it is about the overlay, not the extension: "Since Godot 4 alpha, when Vulkan got introduced, people have found that Steam Overlay just does not work or will flicker when running the project from the Godot 4.x editor; both with GodotSteam GDExtension and custom precompiled editors." Mitigations listed are Compatibility/OpenGL mode, particular GPU driver versions, or the auto-initialization project setting; one user reported stutter under Forward+ with an NVIDIA 546.33 driver that went away in Compatibility mode. Source: <https://godotsteam.com/issues/common_issues/>. The auto-initialize option was "originally added to help people using Forward+ who were having issues with Steam overlay". Source: <https://godotsteam.com/tutorials/initializing/>. Root cause per Valve: the overlay hooks device creation, so `SteamAPI_Init` must precede it (<https://partner.steamgames.com/doc/features/overlay>). None of this affects gameplay, networking or friends data; it only matters if the overlay is wanted while running from the editor, which it is not here.

One unrelated compatibility note worth knowing: the prebuilt plugin is single-precision only; "If you are using Godot Engine that has double-precision enabled, using the GDNative or GDExtension plug-ins may crash the editor." Source: <https://godotsteam.com/issues/common_issues/>. This project uses the standard single-precision editor.

## Sources

GodotSteam (project docs and repos)

- Getting started, pre-compiled vs plugin: <https://godotsteam.com/getting_started/introduction/>
- Which version for which project: <https://godotsteam.com/getting_started/what_are_you_making/>
- Codeberg releases (4.22.1, 4.22.1-gde, 4.21, 4.20.x): <https://codeberg.org/godotsteam/godotsteam/releases>
- GitHub overflow release v4.22.1: <https://github.com/GodotSteam/GodotSteam/releases/tag/v4.22.1>
- Shipped `godotsteam.gdextension` (gdextension branch): <https://codeberg.org/godotsteam/godotsteam/raw/branch/gdextension/godotsteam.gdextension>
- Asset Library listing 4.22.1: <https://godotengine.org/asset-library/asset/2445>
- Main class (steamInit, steamInitEx, get_steam_init_result, run_callbacks, isSteamRunning, restartAppIfNecessary, steamShutdown, SteamAPIInitResult enum): <https://godotsteam.com/classes/main/>
- Friends class (getPersonaName, getFriendPersonaName, getFriendCount/ByIndex, getPlayerAvatar, get*FriendAvatar, requestUserInformation, avatar_loaded, avatar_image_loaded): <https://godotsteam.com/classes/friends/>
- MultiplayerPeer class: <https://godotsteam.com/classes/multiplayer_peer/>
- Tutorial, initializing: <https://godotsteam.com/tutorials/initializing/>
- Tutorial, avatars: <https://godotsteam.com/tutorials/avatars/>
- Tutorial, exporting and shipping: <https://godotsteam.com/tutorials/exporting_shipping/>
- Tutorial, MultiplayerPeer: <https://godotsteam.com/tutorials/multiplayer_peer/>
- How to compile the GDExtension (addon layout, source files): <https://godotsteam.com/howto/gdextension/>
- Common issues (Forward+/Vulkan overlay, mixing module and plugin, double precision, steam_appid.txt.txt): <https://godotsteam.com/issues/common_issues/>
- GDExtension changelog (4.16 to 4.21): <https://godotsteam.com/changelog/gdextension/>
- Blog, 2025-04-01, init signature change and Project Settings: <https://godotsteam.com/blog/2025/04/01/godotsteam-updates-for-all-branches/>
- Blog, 2025-12-09, MultiplayerPeer merged into main project and GDExtension: <https://godotsteam.com/blog/2025/12/09/godotsteam-end-of-year-updates/>

Valve Steamworks documentation

- Steamworks API overview (SteamAPI_Init failure reasons, steam_appid.txt, RestartAppIfNecessary, callbacks, technical details): <https://partner.steamgames.com/doc/sdk/api>
- steam_api.h reference (SteamAPI_Init, SteamAPI_RunCallbacks, SteamAPI_RestartAppIfNecessary): <https://partner.steamgames.com/doc/api/steam_api>
- Steam Overlay requirements and FAQ: <https://partner.steamgames.com/doc/features/overlay>
- SpaceWar example (app ID 480, steam_appid.txt, steam_api.dll placement): <https://partner.steamgames.com/doc/sdk/api/example>
- ISteamFriends (GetPersonaName, GetFriendPersonaName, GetLargeFriendAvatar, RequestUserInformation, AvatarImageLoaded_t, PersonaStateChange_t): <https://partner.steamgames.com/doc/api/ISteamFriends>
- ISteamUtils (GetImageSize, GetImageRGBA): <https://partner.steamgames.com/doc/api/ISteamUtils>
- ISteamNetworkingSockets (ConnectP2P, CreateListenSocketP2P, SDR relay): <https://partner.steamgames.com/doc/api/ISteamNetworkingSockets>

Godot Engine documentation

- The .gdextension file (configuration, libraries feature tags, dependencies export): <https://docs.godotengine.org/en/latest/engine_details/engine_api/gdextension/gdextension_file.html>
- GDExtension C++ example (libraries section exports only matching file): <https://docs.godotengine.org/en/latest/tutorials/scripting/cpp/gdextension_cpp_example.html>
- Image class (create_from_data, FORMAT_RGBA8): <https://docs.godotengine.org/en/stable/classes/class_image.html>
- ImageTexture class (create_from_image): <https://docs.godotengine.org/en/stable/classes/class_imagetexture.html>

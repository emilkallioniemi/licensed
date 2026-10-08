# In-game Steam invites and joining on app 480

Research for `.scratch/waiting-room/issues/02-in-game-invites-on-app-480.md`. Date: 2026-09-12.

Scope: Godot 4.7 + GodotSteam GDExtension (`Steam` singleton, `SteamMultiplayerPeer`), Windows, app ID 480 (Valve's SpaceWar example), exe distributed as a GitHub release zip and launched directly, never through Steam.

Source basis: godotsteam.com class pages and tutorials, the GodotSteam `gdextension` branch on Codeberg (commit `2cfe81d5`, 2026-08-19), and Valve's Steamworks documentation. Anything not backed by one of those is marked **UNVERIFIED**. Line numbers into the GodotSteam source refer to that commit.

---

## Recommended flow

Everything below runs inside the game; the Steam overlay is never required. The one thing app 480 breaks is *Steam launching our exe for someone who is not already running it*; every step is designed around that hole.

### Happy path (invitee already has the game open)

1. **Boot.** After `Steam.steamInitEx(480, ...)` succeeds, connect `Steam.lobby_invite`, `Steam.join_requested`, `Steam.lobby_joined`, `Steam.lobby_chat_update`, `Steam.persona_state_change`, `Steam.friend_rich_presence_update`. Call `Steam.setRichPresence("licensed", "1")` so friends running our build can be told apart from other app-480 processes (see Q1). Check `OS.get_cmdline_args()` for `+connect_lobby <id>` anyway; it is free and starts working the day we own an AppID (see Q2b).
2. **Host opens the desk.** `Steam.createLobby(Steam.LOBBY_TYPE_FRIENDS_ONLY, 3)` → `lobby_created(connect, lobby_id)` (check `connect == Steam.RESULT_OK`) and `lobby_joined(...)`. In `lobby_created`: `Steam.setLobbyData(lobby_id, "game", "licensed")` and a `"version"` key; then `var peer := SteamMultiplayerPeer.new(); peer.host_with_lobby(lobby_id); multiplayer.multiplayer_peer = peer`.
3. **Host's friend list.** `for i in Steam.getFriendCount(Steam.FRIEND_FLAG_IMMEDIATE): var id := Steam.getFriendByIndex(i, Steam.FRIEND_FLAG_IMMEDIATE)`. Per friend: name `Steam.getFriendPersonaName(id)`, online-ness `Steam.getFriendPersonaState(id) != Steam.PERSONA_STATE_OFFLINE`, "has our game open" `Steam.getFriendGamePlayed(id).get("id") == 480 and Steam.getFriendRichPresence(id, "licensed") == "1"`, "already in one of our lobbies" `getFriendGamePlayed(id).lobby` being a non-zero int. Refresh rows on `persona_state_change` and `friend_rich_presence_update`.
4. **Host invites.** `Steam.inviteUserToLobby(lobby_id, friend_id)`. Returns `true` only if *we* are in the lobby and Steam is reachable; it does not confirm delivery.
5. **Invitee sees it in-game.** Their running copy receives `lobby_invite(inviter, lobby, game)` immediately (this is Valve's `LobbyInvite_t`). Show a toast at the desk: "<name> is calling you to the desk — Accept". Steam's own chat message/toast also appears; ignore it.
6. **Invitee accepts.** On the in-game Accept button: `Steam.joinLobby(lobby)`. If they instead click Steam's own "Join" while our game is running, `join_requested(lobby_id, steam_id)` fires (Valve's `GameLobbyJoinRequested_t`); route it to the same `joinLobby` call.
7. **Invitee lands.** `lobby_joined(lobby, permissions, locked, response)`: require `response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS` and `Steam.getLobbyData(lobby, "game") == "licensed"`; otherwise `Steam.leaveLobby(lobby)` and show the reason (`DOESNT_EXIST`, `FULL`, `NOT_ALLOWED`, ...). Then `var peer := SteamMultiplayerPeer.new(); peer.connect_to_lobby(lobby); multiplayer.multiplayer_peer = peer`.
8. **Host sees them arrive.** `lobby_chat_update(lobby_id, changed_id, making_change_id, chat_state)` with `CHAT_MEMBER_STATE_CHANGE_ENTERED`; `SteamMultiplayerPeer` already listens to this callback for its tracked lobby and calls `add_peer` itself, so the host only updates UI. `multiplayer.peer_connected` follows.

### Fallbacks (invitee did *not* have the game open)

- **F1, primary.** The invitee starts the exe by hand. The host's friend list (step 3) flips them to "in game" via `persona_state_change` / `friend_rich_presence_update`; the host presses Invite again and the happy path resumes from step 5. Meanwhile the invitee's own desk can list *friends who are in one of our lobbies* (`getFriendGamePlayed(friend).lobby`, filtered by `requestLobbyData` → `lobby_data_update` → `getLobbyData(lobby, "game") == "licensed"`) with a Join button that calls `joinLobby(lobby)` directly, so no second invite is even needed.
- **F2, debugging / last resort.** The desk shows the lobby's 64-bit Steam ID as text with a copy button; a "Join by ID" field calls `Steam.joinLobby(text.to_int())`. Works for `FRIENDS_ONLY` and `PUBLIC` lobbies, not `PRIVATE`. GDScript `int` is 64-bit, so the ID round-trips.
- **Not recommended now:** a short human code looked up via `requestLobbyList`. It forces the lobby to be `PUBLIC` on an AppID shared with every other GodotSteam prototype (Q4).

---

## Only once we own an AppID

Things that are gated on Steam knowing our exe and on partner-site settings, not on code:

1. **Steam launching the game from an invite or a friends-list "Join Game" when it is not running.** Valve's invite path launches "the game" with `+connect_lobby <id>`; the game Steam launches is whatever is installed under that AppID in the Steam library, which for 480 is Valve's SpaceWar, never our exe. Requires our own AppID, a launch configuration, and the player owning/installing it through Steam. ([ISteamMatchmaking::InviteUserToLobby](https://partner.steamgames.com/doc/api/ISteamMatchmaking#InviteUserToLobby), [SteamAPI_RestartAppIfNecessary](https://partner.steamgames.com/doc/sdk/api#SteamAPI_RestartAppIfNecessary))
2. **"Use launch command line"** (Steamworks → Installation → General) so the connect string arrives via `Steam.getLaunchCommandLine()` / `new_launch_url_parameters` instead of the OS command line. ([ISteamApps::GetLaunchCommandLine](https://partner.steamgames.com/doc/api/ISteamApps#GetLaunchCommandLine), [GodotSteam Apps](https://godotsteam.com/classes/apps/))
3. **Rich-presence status text** (`steam_display`). Requires uploading a localization file under the app's Community tab in Steamworks; without a valid token nothing is displayed. Under 480 we have no such tab. ([ISteamFriends::SetRichPresence](https://partner.steamgames.com/doc/api/ISteamFriends#SetRichPresence), [Rich Presence Localization](https://partner.steamgames.com/doc/api/ISteamFriends#richpresencelocalization), [GodotSteam Rich Presence tutorial](https://godotsteam.com/tutorials/rich_presence/))
4. **Friends seeing our game's name** instead of "Spacewar", and `getFriendGamePlayed(...).id` uniquely identifying our game. ([Steamworks API Example Application (SpaceWar)](https://partner.steamgames.com/doc/sdk/api/example))
5. **A private lobby namespace.** `requestLobbyList` is scoped to the running AppID, so today every public lobby we create is listed to every other app-480 project and vice versa. ([ISteamMatchmaking::RequestLobbyList](https://partner.steamgames.com/doc/api/ISteamMatchmaking#RequestLobbyList))
6. **A reliable Steam overlay** (invite toasts, `activateGameOverlayInviteDialog` as an optional alternative). The overlay hooks games launched through Steam; from a bare exe with Vulkan it is "kind of a crapshoot". ([Steam Overlay](https://partner.steamgames.com/doc/features/overlay), [GodotSteam Common Issues → Forward+ / Vulkan](https://godotsteam.com/issues/common_issues/))
7. **Dropping `steam_appid.txt`** from shipped builds; Valve says not to ship it. ([Steamworks API Overview](https://partner.steamgames.com/doc/sdk/api#SteamAPI_Init))

---

## Q1. Listing friends in-game

### Enumeration

- `Steam.getFriendCount(friend_flags)` returns the number of users matching the flags, or `-1` if the user is not logged on; `Steam.getFriendByIndex(i, friend_flags)` must be called with the **same flags**. ([GodotSteam Friends: getFriendCount](https://godotsteam.com/classes/friends/#getfriendcount), [getFriendByIndex](https://godotsteam.com/classes/friends/#getfriendbyindex); Valve: [GetFriendCount](https://partner.steamgames.com/doc/api/ISteamFriends#GetFriendCount), [GetFriendByIndex](https://partner.steamgames.com/doc/api/ISteamFriends#GetFriendByIndex)). GodotSteam's default is `FRIEND_FLAG_ALL`, which includes blocked, ignored and pending users; use `FRIEND_FLAG_IMMEDIATE` for the desk.
- Friend flags (`Steam.FriendFlags`, values from Valve's `EFriendFlags`): `FRIEND_FLAG_NONE 0x00`, `FRIEND_FLAG_BLOCKED 0x01`, `FRIEND_FLAG_FRIENDSHIP_REQUESTED 0x02`, `FRIEND_FLAG_IMMEDIATE 0x04` ("regular" friends), `FRIEND_FLAG_CLAN_MEMBER 0x08`, `FRIEND_FLAG_ON_GAME_SERVER 0x10`, `FRIEND_FLAG_REQUESTING_FRIENDSHIP 0x80`, `FRIEND_FLAG_REQUESTING_INFO 0x100`, `FRIEND_FLAG_IGNORED 0x200`, `FRIEND_FLAG_IGNORED_FRIEND 0x400`, `FRIEND_FLAG_CHAT_MEMBER 0x1000`, `FRIEND_FLAG_ALL 0xFFFF`. ([GodotSteam FriendFlags](https://godotsteam.com/classes/friends/#friendflags), [Valve EFriendFlags](https://partner.steamgames.com/doc/api/ISteamFriends#EFriendFlags))

### Name and state

- `Steam.getFriendPersonaName(steam_id)`: GodotSteam's wrapper first calls `RequestUserInformation(steam_id, name_only = true)` and returns `""` if Steam is still fetching; the name arrives via `persona_state_change`. For actual friends the data is normally cached, so this matters mainly for lobby members who are not friends. ([godotsteam.cpp L1084-L1092](https://codeberg.org/godotsteam/godotsteam/src/branch/gdextension/godotsteam/godotsteam.cpp#L1084), [GodotSteam docs](https://godotsteam.com/classes/friends/#getfriendpersonaname))
- `Steam.getFriendPersonaState(steam_id)` → `Steam.PersonaState`: `OFFLINE 0`, `ONLINE 1`, `BUSY 2`, `AWAY 3`, `SNOOZE 4`, `LOOKING_TO_TRADE 5`, `LOOKING_TO_PLAY 6`, `INVISIBLE 7` ("never published to clients", so invisible friends read as offline). Known only for friends, same-lobby/server users, and small-group members. ([GodotSteam PersonaState](https://godotsteam.com/classes/friends/#personastate), [Valve GetFriendPersonaState](https://partner.steamgames.com/doc/api/ISteamFriends#GetFriendPersonaState)). "Online" for the desk = anything but `OFFLINE`.
- `persona_state_change(steam_id, flags)` fires on changes; flag bits include `PERSONA_CHANGE_NAME 0x1`, `STATUS 0x2`, `COME_ONLINE 0x4`, `GONE_OFFLINE 0x8`, `GAME_PLAYED 0x10`, `AVATAR 0x40`, `RICH_PRESENCE 0x4000`. ([GodotSteam PersonaChange](https://godotsteam.com/classes/friends/#personachange), [godotsteam.cpp L7318](https://codeberg.org/godotsteam/godotsteam/src/branch/gdextension/godotsteam/godotsteam.cpp#L7318))

### "Which friends are running this game" and the Spacewar problem

- `Steam.getFriendGamePlayed(steam_id)` returns `{}` if the friend is offline or not in a game; otherwise `id` (the **AppID**, from `m_gameID.AppID()`), `ip`, `game_port`, `query_port`, and `lobby`. In the current source `lobby` is the lobby Steam ID when `m_steamIDLobby.IsValid()`, else `0`. ([godotsteam.cpp L1060-L1081](https://codeberg.org/godotsteam/godotsteam/src/branch/gdextension/godotsteam/godotsteam.cpp#L1060); Valve [GetFriendGamePlayed](https://partner.steamgames.com/doc/api/ISteamFriends#GetFriendGamePlayed), [FriendGameInfo_t](https://partner.steamgames.com/doc/api/ISteamFriends#FriendGameInfo_t)). Note: the [Friends' Lobbies tutorial](https://godotsteam.com/tutorials/friends_lobbies/) says `lobby` is the String `"No valid lobby"` when absent; the source at this commit returns `0`. Code defensively: `lobby is int and lobby != 0`.
- Valve's matchmaking guide shows exactly this loop (`GetFriendCount(k_EFriendFlagImmediate)` → `GetFriendGamePlayed` → `m_steamIDLobby.IsValid()`) as *the* way to find friends' lobbies. ([Steam Matchmaking & Lobbies → Friends, invites, and lobbies](https://partner.steamgames.com/doc/features/multiplayer/matchmaking))
- **Under 480, `id == 480` means "this friend is running *some* process that initialised Steamworks as app 480"**: our build, another developer's GodotSteam prototype, or the SDK's SpaceWar sample (480 is the example app's AppID per [Steamworks API Example Application](https://partner.steamgames.com/doc/sdk/api/example)). The Steam friends list will label all of them "Spacewar". AppID alone cannot identify our game. Two game-controlled signals do:
  - **Rich presence key.** `Steam.setRichPresence("licensed", "1")` at boot; the host reads `Steam.getFriendRichPresence(friend, "licensed")`. Rich presence is "automatically shared to all friends playing the same game", and under 480 all app-480 processes count as the same game, so our key propagates. Updates arrive via `friend_rich_presence_update(steam_id, app_id)`. ([Valve SetRichPresence](https://partner.steamgames.com/doc/api/ISteamFriends#SetRichPresence), [GodotSteam getFriendRichPresence](https://godotsteam.com/classes/friends/#getfriendrichpresence), [friend_rich_presence_update](https://godotsteam.com/classes/friends/#friend_rich_presence_update))
  - **Lobby data key.** For a friend whose `lobby` is set: `Steam.requestLobbyData(lobby)` → `lobby_data_update` → `Steam.getLobbyData(lobby, "game") == "licensed"`. Valve: "If it's a friends' lobby, there will be no lobby data available to look at until RequestLobbyData is called". ([Steam Matchmaking & Lobbies → Lobby Metadata](https://partner.steamgames.com/doc/features/multiplayer/matchmaking), [GodotSteam getLobbyData](https://godotsteam.com/classes/matchmaking/#getlobbydata))
- Whether a `PRIVATE` lobby's ID is exposed to friends through `getFriendGamePlayed` is **UNVERIFIED**; Valve only documents `FRIENDS_ONLY`/`PUBLIC` as visible to friends, and GodotSteam's tutorial notes that "if the lobby is configured in such a way that it's invisible to you ... Steam won't provide a lobby ID". Use `FRIENDS_ONLY` so F1 works.

---

## Q2. Sending an invite

### The call

`Steam.inviteUserToLobby(steam_lobby_id, steam_id_invitee) -> bool`. Straight passthrough to `ISteamMatchmaking::InviteUserToLobby` ([godotsteam.cpp L3015](https://codeberg.org/godotsteam/godotsteam/src/branch/gdextension/godotsteam/godotsteam.cpp#L3015)). Valve: returns `true` if the invite was sent, `false` if the local user is not in a lobby, Steam is unreachable, or the invitee ID is invalid; "This call doesn't check if the other user was successfully invited." The invitee "will receive a chat dialog with a link to join the game." ([InviteUserToLobby](https://partner.steamgames.com/doc/api/ISteamMatchmaking#InviteUserToLobby), [Matchmaking guide](https://partner.steamgames.com/doc/features/multiplayer/matchmaking))

### (a) Invitee's copy of the game is running: which signals fire

Two different Valve callbacks, at two different moments, and GodotSteam exposes both:

| Moment | Valve callback | GodotSteam signal | Payload |
| --- | --- | --- | --- |
| Invite arrives | `LobbyInvite_t` | `lobby_invite` | `inviter: int, lobby: int, game: int` |
| Invitee clicks Steam's "Join" | `GameLobbyJoinRequested_t` | `join_requested` | `lobby_id: int, steam_id: int` (friend joined through; may be invalid) |

- `LobbyInvite_t`: "Someone has invited you to join a Lobby. Normally you don't need to do anything with this, as the Steam UI will also display a '<user> has invited you to the lobby, join?' notification and message. If the user outside a game chooses to join, your game will be launched with the parameter `+connect_lobby <64-bit lobby id>`, or with the callback `GameLobbyJoinRequested_t` if they're already in-game." Fields: `m_ulSteamIDUser`, `m_ulSteamIDLobby`, `m_ulGameID`. ([Valve LobbyInvite_t](https://partner.steamgames.com/doc/api/ISteamMatchmaking#LobbyInvite_t)); GodotSteam binds it with `STEAM_CALLBACK(Steam, lobby_invite, LobbyInvite_t, ...)` and emits `lobby_invite(inviter, lobby, game)`. ([godotsteam.h L1041](https://codeberg.org/godotsteam/godotsteam/src/branch/gdextension/godotsteam/godotsteam.h#L1041), [godotsteam.cpp L7804-L7812](https://codeberg.org/godotsteam/godotsteam/src/branch/gdextension/godotsteam/godotsteam.cpp#L7804), [docs](https://godotsteam.com/classes/matchmaking/#lobby_invite))
- `GameLobbyJoinRequested_t`: "Called when the user tries to join a lobby from their friends list or from an invite. The game client should attempt to connect to specified lobby when this is received. If the game isn't running yet then the game will be automatically launched with the command line parameter `+connect_lobby <64-bit lobby Steam ID>` instead." Fields: `m_steamIDLobby`, `m_steamIDFriend` ("invalid if not directly via a friend"). Note: "If the user is attempting to join a game but not a lobby, then the callback `GameRichPresenceJoinRequested_t` will be made." ([Valve GameLobbyJoinRequested_t](https://partner.steamgames.com/doc/api/ISteamFriends#GameLobbyJoinRequested_t)); GodotSteam: `STEAM_CALLBACK(Steam, join_requested, GameLobbyJoinRequested_t, ...)` → `join_requested(lobby_id, steam_id)`. ([godotsteam.h L982](https://codeberg.org/godotsteam/godotsteam/src/branch/gdextension/godotsteam/godotsteam.h#L982), [godotsteam.cpp L7272-L7278](https://codeberg.org/godotsteam/godotsteam/src/branch/gdextension/godotsteam/godotsteam.cpp#L7272), [docs](https://godotsteam.com/classes/friends/#join_requested))
- The godotsteam.com text for `join_requested` says "after a user accepts an invite by a friend with inviteUserToGame"; that is a copy-paste from `join_game_requested`. Per Valve and the source binding, `join_requested` is the *lobby* one; `inviteUserToGame` / rich-presence joins produce `join_game_requested(user, connect)` (`GameRichPresenceJoinRequested_t`). ([godotsteam.cpp L7295](https://codeberg.org/godotsteam/godotsteam/src/branch/gdextension/godotsteam/godotsteam.cpp#L7295), [Valve GameRichPresenceJoinRequested_t](https://partner.steamgames.com/doc/api/ISteamFriends#GameRichPresenceJoinRequested_t))
- **Consequence for the design:** because `lobby_invite` is delivered to the running game the moment the invite is sent, the invitee can be shown an in-game prompt and accept with `joinLobby(lobby)` without ever touching Steam's chat or overlay. Steam's own notification cannot be suppressed; the overlay toast may or may not render for a bare-exe Vulkan build ([Common Issues](https://godotsteam.com/issues/common_issues/)), but the Steam desktop client's chat message is independent of the overlay. Both delivery mechanisms are Valve's; the reliability of each under a non-Steam launch is **UNVERIFIED** beyond the GodotSteam note above.
- Callbacks only arrive while `Steam.run_callbacks()` is being pumped (or embed_callbacks is on). ([Initializing tutorial](https://godotsteam.com/tutorials/initializing/))

### (b) Invitee's copy is NOT running

- Valve, three places, same statement: the invitee gets a chat message with a link; clicking it when the game is not running makes Steam "automatically launch the game with the command line parameter `+connect_lobby <64-bit lobby Steam ID>`". ([InviteUserToLobby](https://partner.steamgames.com/doc/api/ISteamMatchmaking#InviteUserToLobby), [LobbyInvite_t](https://partner.steamgames.com/doc/api/ISteamMatchmaking#LobbyInvite_t), [Matchmaking guide](https://partner.steamgames.com/doc/features/multiplayer/matchmaking))
- "The game" is whatever Steam has registered under the lobby's AppID. Steam learns our AppID from `steam_appid.txt` (or the `SteamAppId` env var GodotSteam sets) purely so that the *local* `SteamAPI_Init` succeeds; that file "overrides the value that Steam provides" and does not register the exe with the client. When Steam itself launches an app it launches "the version installed in your Steam library folder" ([Steamworks API Overview → SteamAPI_Init and SteamAPI_RestartAppIfNecessary](https://partner.steamgames.com/doc/sdk/api)). For AppID 480 that is Valve's SpaceWar sample, not our exe. So on 480 the offline invite link **cannot start our game**. Whether Steam then launches an installed SpaceWar, prompts to install it, or does nothing is **UNVERIFIED** (no primary source describes the client UI); what is certain is that none of those outcomes is our exe.
- If our exe *were* started with `+connect_lobby <id>` (it will be, the day Steam knows the app), read it from `OS.get_cmdline_args()` as the [Lobbies tutorial](https://godotsteam.com/tutorials/lobbies/) shows, or via `Steam.getLaunchCommandLine()` once "Use launch command line" is enabled in Steamworks. Implement the arg check now; it is a handful of lines and harmless under 480.
- Practical fallback under 480 is F1 above: the invitee opens the exe, then either the host re-invites (now `lobby_invite` fires in-game) or the invitee joins from their own friends list.

---

## Q3. Joining

### Sequence

1. `Steam.joinLobby(steam_lobby_id)`. Void; passthrough to `JoinLobby`. Valve: the ID "can be obtained either from a search with `RequestLobbyList`, joining on a friend, or from an invite". Triggers `LobbyEnter_t` (and `LobbyDataUpdate_t`) for us and `LobbyChatUpdate_t` for existing members. ([godotsteam.cpp L3021](https://codeberg.org/godotsteam/godotsteam/src/branch/gdextension/godotsteam/godotsteam.cpp#L3021), [Valve JoinLobby](https://partner.steamgames.com/doc/api/ISteamMatchmaking#JoinLobby), [GodotSteam joinLobby](https://godotsteam.com/classes/matchmaking/#joinlobby))
2. `lobby_joined(lobby: int, permissions: int, locked: bool, response: int)` — bound to `LobbyEnter_t`; `permissions` is always 0, `locked` means only invited users may join, `response` is `EChatRoomEnterResponse`. ([godotsteam.h L1039](https://codeberg.org/godotsteam/godotsteam/src/branch/gdextension/godotsteam/godotsteam.h#L1039), [godotsteam.cpp L7780](https://codeberg.org/godotsteam/godotsteam/src/branch/gdextension/godotsteam/godotsteam.cpp#L7780), [Valve LobbyEnter_t](https://partner.steamgames.com/doc/api/ISteamMatchmaking#LobbyEnter_t)). Response values worth showing at the desk: `SUCCESS 1`, `DOESNT_EXIST 2`, `NOT_ALLOWED 3`, `FULL 4`, `ERROR 5`, `BANNED 6`, `LIMITED 7`, `MEMBER_BLOCKED_YOU 10`, `YOU_BLOCKED_MEMBER 11`, `RATELIMIT_EXCEEDED 15`. ([Valve EChatRoomEnterResponse](https://partner.steamgames.com/doc/api/steam_api#EChatRoomEnterResponse))
3. `SteamMultiplayerPeer.connect_to_lobby(lobby_id)`: fails with `ERR_ALREADY_IN_USE` unless disconnected; fails with `ERR_CANT_CREATE` ("You must be a member of the lobby...") if `GetLobbyOwner` returns 0, which Valve says happens when you are not in the lobby; then sets `tracked_lobby`, calls `create_client(owner)` and `add_peer` for every other member. ([godotsteam_multiplayer_peer.cpp L634-L667](https://codeberg.org/godotsteam/godotsteam/src/branch/gdextension/godotsteam/godotsteam_multiplayer_peer.cpp#L634), [Valve GetLobbyOwner](https://partner.steamgames.com/doc/api/ISteamMatchmaking#GetLobbyOwner), [MultiplayerPeer docs](https://godotsteam.com/classes/multiplayer_peer/#connect_to_lobby)). Host side: `host_with_lobby(lobby_id)` additionally requires being the owner, then `create_host()` and `add_peer` for members already present. ([L597-L632](https://codeberg.org/godotsteam/godotsteam/src/branch/gdextension/godotsteam/godotsteam_multiplayer_peer.cpp#L597))
4. From then on the peer listens to `LobbyChatUpdate_t` for `tracked_lobby`: a member with `k_EChatMemberStateChangeEntered` gets `add_peer`, anyone else changing state is disconnected. ([godotsteam_multiplayer_peer.cpp L316-L360](https://codeberg.org/godotsteam/godotsteam/src/branch/gdextension/godotsteam/godotsteam_multiplayer_peer.cpp#L316)) **This means lobby membership is the session's access control**: whoever Steam lets into the lobby is automatically dialled as a peer. The lobby type below is therefore a security decision, not just a UI one.
5. Alternative without lobby tracking, as in the [MultiplayerPeer tutorial](https://godotsteam.com/tutorials/multiplayer_peer/): host `peer.create_host(0)`, client `peer.create_client(Steam.getLobbyOwner(lobby), 0)`, both with `peer.server_relay = true`. Late joiners must then be added by hand. `connect_to_lobby`/`host_with_lobby` are the less code.

### Lobby types (`Steam.LobbyType`, Valve `ELobbyType`)

| GodotSteam | Value | Valve's definition | For us on 480 |
| --- | --- | --- | --- |
| `LOBBY_TYPE_PRIVATE` | 0 | "The only way to join the lobby is from an invite." | Safest against strangers, but kills F2 (paste ID) and probably F1 (**UNVERIFIED** whether friends see the lobby ID). Under 480 the offline invite is broken, so private + invite-only leaves *no* fallback. |
| `LOBBY_TYPE_FRIENDS_ONLY` | 1 | "Joinable by friends and invitees, but does not show up in the lobby list." | **Recommended.** Not returned by any `requestLobbyList`, so the thousands of other app-480 projects cannot enumerate it; joinable by friends (F1, F2) and invitees (happy path). |
| `LOBBY_TYPE_PUBLIC` | 2 | "Returned by search and visible to friends." | Any app-480 process calling `requestLobbyList` without a filter can list and join it, and the peer will auto-connect them. Only needed for a short-code lookup (Q4). |
| `LOBBY_TYPE_INVISIBLE` | 3 | "Returned by search, but not visible to other friends." | Wrong direction for us. |

([GodotSteam LobbyType](https://godotsteam.com/classes/matchmaking/#lobbytype), [Valve ELobbyType](https://partner.steamgames.com/doc/api/ISteamMatchmaking#ELobbyType))

- `setLobbyJoinable(lobby, false)` closes the door entirely: "no players can join, even if they are a friend or have been invited". Use it once the test starts. ([Valve SetLobbyJoinable](https://partner.steamgames.com/doc/api/ISteamMatchmaking#SetLobbyJoinable))
- `createLobby(type, 3)` caps membership; a full lobby returns `CHAT_ROOM_ENTER_RESPONSE_FULL` and is excluded from searches. `lobby_created(connect, lobby)` comes from the `LobbyCreated_t` call result; `lobby_joined` follows because the host joins their own lobby. ([GodotSteam createLobby](https://godotsteam.com/classes/matchmaking/#createlobby), [Valve CreateLobby](https://partner.steamgames.com/doc/api/ISteamMatchmaking#CreateLobby), [godotsteam.cpp L2900](https://codeberg.org/godotsteam/godotsteam/src/branch/gdextension/godotsteam/godotsteam.cpp#L2900))
- Belt and braces against a stranger who *is* let in (e.g. a mutual friend running a different 480 project who joins from their Steam friends list): lobby data `game=licensed` is checked by the *joiner* before `connect_to_lobby`; the *host* cannot kick via Steam (`LobbyKicked_t` is "Currently unused"; Valve suggests a custom chat message telling them to `LeaveLobby`), but can refuse the P2P side with `peer.refuse_new_connections = true` or disconnect the peer after `peer_connected`. ([Valve LobbyKicked_t](https://partner.steamgames.com/doc/api/ISteamMatchmaking#LobbyKicked_t), [godotsteam_multiplayer_peer.cpp L208-L215](https://codeberg.org/godotsteam/godotsteam/src/branch/gdextension/godotsteam/godotsteam_multiplayer_peer.cpp#L208))

---

## Q4. Is a lobby-code fallback necessary?

### Typing the raw lobby ID

- Lobbies "are uniquely identified by Steam ID, like users or game servers", i.e. a 64-bit `CSteamID`; `joinLobby` takes that value and Valve lists "from an invite" and "joining on a friend" as merely two of the ways to obtain it, so a pasted ID is legitimate input. ([Matchmaking guide → Overview](https://partner.steamgames.com/doc/features/multiplayer/matchmaking), [Valve JoinLobby](https://partner.steamgames.com/doc/api/ISteamMatchmaking#JoinLobby))
- GDScript `int` is a signed 64-bit integer (max 9 223 372 036 854 775 807) and `int(from: String)` follows `String.to_int()`, so `Steam.joinLobby(text.strip_edges().to_int())` round-trips a lobby ID exactly; GodotSteam's binding takes `uint64_t`. ([Godot `int`](https://docs.godotengine.org/en/stable/classes/class_int.html), [godotsteam.cpp L3021](https://codeberg.org/godotsteam/godotsteam/src/branch/gdextension/godotsteam/godotsteam.cpp#L3021))
- Works for `FRIENDS_ONLY` (friends) and `PUBLIC` (anyone); a `PRIVATE` lobby rejects it because invite is "the only way to join". ([Valve ELobbyType](https://partner.steamgames.com/doc/api/ISteamMatchmaking#ELobbyType))
- Usability: it is a 17-digit number. Fine as a copy-paste over Discord, hostile to type by hand.

### A shorter human-typable code

Mechanism that Valve supports: host `setLobbyData(lobby, "code", "K7Q2")`; joiner `addRequestLobbyListStringFilter("code", "K7Q2", LOBBY_COMPARISON_EQUAL)` + `addRequestLobbyListDistanceFilter(LOBBY_DISTANCE_FILTER_WORLDWIDE)` + `requestLobbyList()` → `lobby_match_list(lobbies: Array)` → `joinLobby(lobbies[0])`. Filters must be set before every call (they are cleared each time); the default distance filter is "same or nearby regions", so set worldwide for a code lookup; a search takes 300 ms–5 s with a 20 s timeout. ([Valve RequestLobbyList](https://partner.steamgames.com/doc/api/ISteamMatchmaking#RequestLobbyList), [AddRequestLobbyListStringFilter](https://partner.steamgames.com/doc/api/ISteamMatchmaking#AddRequestLobbyListStringFilter), [GodotSteam requestLobbyList](https://godotsteam.com/classes/matchmaking/#requestlobbylist), [lobby_match_list](https://godotsteam.com/classes/matchmaking/#lobby_match_list))

The catch: `RequestLobbyList` "will only return lobbies that are not full, and only lobbies that are `k_ELobbyTypePublic` or `k_ELobbyTypeInvisible`, and are set to joinable". A short code therefore forces the desk's lobby to be `PUBLIC`, on an AppID shared with every other GodotSteam project, where the peer auto-connects any member (Q3 step 4). Also lobby data is a search key, not a secret; a 4-character code is guessable by anyone else on 480 who bothers.

### Verdict

- Not necessary as a *human* fallback for this game: the players are three Steam friends, and F1 (in-game "friends in a lobby" list from `getFriendGamePlayed`) already gives a zero-typing path that works with `FRIENDS_ONLY`.
- Keep the raw-ID paste (F2) behind a small "Join by ID" field for debugging and for the day a friend's presence data is stale.
- Do not build the short-code search now. Revisit once we own an AppID (own lobby namespace) if the friends-list path proves unreliable.

---

## Q5. Rich presence and the "Join Game" button

- Valve: `SetRichPresence("connect", <command line>)` "enables the 'join game' button in the 'view game info' dialog, in the steam friends list right click menu, and on the players Steam community profile. Be sure your app implements `ISteamApps::GetLaunchCommandLine`..." Limits: 20 keys, key ≤ 64 chars, value ≤ 256 chars. GodotSteam's `setRichPresence(key, value)` is a direct passthrough. ([Valve SetRichPresence](https://partner.steamgames.com/doc/api/ISteamFriends#SetRichPresence), [GodotSteam setRichPresence](https://godotsteam.com/classes/friends/#setrichpresence), [godotsteam.cpp L1486](https://codeberg.org/godotsteam/godotsteam/src/branch/gdextension/godotsteam/godotsteam.cpp#L1486))
- Nothing in Valve's docs gates the `connect` key on AppID ownership or on a partner-site setting; the only setting mentioned is "Use launch command line" (Installation → General), which changes *how* the string is delivered (`GetLaunchCommandLine` vs OS command line), not *whether* the button appears. ([Valve GetLaunchCommandLine](https://partner.steamgames.com/doc/api/ISteamApps#GetLaunchCommandLine)) Whether the Steam client actually renders a Join Game button for a friend "playing Spacewar" is **UNVERIFIED**; no primary source states it either way.
- What the button *does* is the problem, not whether it shows. If the clicking friend already has our game running, Steam posts `GameRichPresenceJoinRequested_t` → GodotSteam `join_game_requested(user, connect)` into the running process, which works under 480 exactly like `join_requested` does. If they do not, Steam launches the app registered under 480 with the connect string on its command line, and that app is SpaceWar, not our exe (same reasoning as Q2b). So under 480 `connect` adds nothing over the lobby path: the running-game case is already covered by `join_requested` (Valve: `GameLobbyJoinRequested_t` is "called when the user tries to join a lobby from their friends list"), and the not-running case is broken either way. ([Valve GameRichPresenceJoinRequested_t](https://partner.steamgames.com/doc/api/ISteamFriends#GameRichPresenceJoinRequested_t), [GameLobbyJoinRequested_t](https://partner.steamgames.com/doc/api/ISteamFriends#GameLobbyJoinRequested_t), [godotsteam.cpp L7295](https://codeberg.org/godotsteam/godotsteam/src/branch/gdextension/godotsteam/godotsteam.cpp#L7295))
- `steam_display` (the status line under the friend's name) needs a localization file uploaded "under the Rich Presence section of the Community tab" of the app's Steamworks settings; "If steam_display is not set to a valid localization tag, then rich presence will not be displayed in the Steam client." We have no Steamworks settings for 480, so no status text until we own an AppID. GodotSteam's tutorial repeats the requirement ("without this step the rich presence text does not really work"). ([Valve Rich Presence Localization](https://partner.steamgames.com/doc/api/ISteamFriends#richpresencelocalization), [Enhanced Rich Presence](https://partner.steamgames.com/doc/features/enhancedrichpresence), [GodotSteam Rich Presence tutorial](https://godotsteam.com/tutorials/rich_presence/))
- `steam_player_group` / `steam_player_group_size` are plain keys with no upload step; whether the client groups "Spacewar" players by them under 480 is **UNVERIFIED**.
- Custom keys (the `licensed=1` marker in Q1) have no display component at all and are the one rich-presence feature that is fully useful today.
- `inviteUserToGame(friend_id, connect_string)` is the rich-presence flavour of an invite: in-game it yields `join_game_requested`; not running, the connect string is appended to the launch command line, with the same 480 launch problem. No advantage over `inviteUserToLobby`, which also gives us `lobby_invite`. ([Valve InviteUserToGame](https://partner.steamgames.com/doc/api/ISteamFriends#InviteUserToGame), [GodotSteam inviteUserToGame](https://godotsteam.com/classes/friends/#inviteusertogame))

---

## Sources

GodotSteam documentation (godotsteam.com)

- Friends class: https://godotsteam.com/classes/friends/
- Matchmaking class: https://godotsteam.com/classes/matchmaking/
- MultiplayerPeer class: https://godotsteam.com/classes/multiplayer_peer/
- Apps class: https://godotsteam.com/classes/apps/
- Tutorial, Lobbies: https://godotsteam.com/tutorials/lobbies/
- Tutorial, Friends' Lobbies: https://godotsteam.com/tutorials/friends_lobbies/
- Tutorial, MultiplayerPeer: https://godotsteam.com/tutorials/multiplayer_peer/
- Tutorial, Rich Presence: https://godotsteam.com/tutorials/rich_presence/
- Tutorial, Initializing Steam: https://godotsteam.com/tutorials/initializing/
- Common Issues: https://godotsteam.com/issues/common_issues/

GodotSteam source (Codeberg, branch `gdextension`, commit `2cfe81d58d85f7a8a78cd0a19a5642d011e9c8fc`, 2026-08-19; the GitHub mirror is archived)

- https://codeberg.org/godotsteam/godotsteam/src/branch/gdextension/godotsteam/godotsteam.cpp
- https://codeberg.org/godotsteam/godotsteam/src/branch/gdextension/godotsteam/godotsteam.h
- https://codeberg.org/godotsteam/godotsteam/src/branch/gdextension/godotsteam/godotsteam_multiplayer_peer.cpp

Valve Steamworks documentation (partner.steamgames.com)

- ISteamMatchmaking: https://partner.steamgames.com/doc/api/ISteamMatchmaking
- ISteamFriends: https://partner.steamgames.com/doc/api/ISteamFriends
- ISteamApps: https://partner.steamgames.com/doc/api/ISteamApps
- steam_api.h enums (EChatRoomEnterResponse): https://partner.steamgames.com/doc/api/steam_api
- Steam Matchmaking & Lobbies: https://partner.steamgames.com/doc/features/multiplayer/matchmaking
- Enhanced Rich Presence: https://partner.steamgames.com/doc/features/enhancedrichpresence
- Steam Overlay: https://partner.steamgames.com/doc/features/overlay
- Steamworks API Overview (SteamAPI_Init, steam_appid.txt, RestartAppIfNecessary): https://partner.steamgames.com/doc/sdk/api
- Steamworks API Example Application (SpaceWar, AppID 480): https://partner.steamgames.com/doc/sdk/api/example

Godot documentation

- `int` (64-bit): https://docs.godotengine.org/en/stable/classes/class_int.html

Not usable as a source: developer.valvesoftware.com (Steam browser protocol, `steam://joinlobby/...`) returned a bot-check page; the exact `steam://` form of the invite link is therefore not cited and is not relied upon above.

# 02. In-game invites and joining on app 480

Type: research
Status: resolved
Blocked by: —
Map: ../map.md
Findings: branch `research/in-game-invites-on-app-480`, file `docs/research/in-game-invites-on-app-480.md`

## Question

Emil wants to invite friends from a desk inside the game, not through the Steam overlay. What does the invite-and-join flow look like end to end with app ID 480 and a build launched outside Steam, and where does it break?

Specifically:

1. Listing friends in-game: `getFriendCount` / `getFriendByIndex` / `getFriendPersonaName` / `getFriendPersonaState`, and how to tell which friends are online and which are already running this game (`getFriendGamePlayed` under app 480 will say "Spacewar": what does that mean for us?).
2. Sending an invite: `inviteUserToLobby(lobby_id, friend_id)`. What the invitee experiences (a) if their copy of the game is running (`lobby_invite` signal? `join_requested`?), (b) if it is not running (Steam chat message with a link; what happens on click when the app is 480 and the exe was never registered with Steam).
3. Joining: `joinLobby` → `lobby_joined` → `SteamMultiplayerPeer.connect_to_lobby`. Lobby type (`friends only` vs `private` vs `public`) and its effect on invites and on strangers stumbling into a Spacewar lobby.
4. Whether a lobby-code fallback is necessary: can a Steam lobby ID be typed in by hand (`joinLobby(id)` from a pasted uint64), and is there a shorter human-typable form worth generating?
5. Rich presence: can `setRichPresence("connect", ...)` give a "Join Game" button on the friends list under app 480, or is that gated on owning the AppID?

Deliverable: the findings file with a recommended flow (happy path plus fallback) and a list of things that only work once we own an AppID. Every claim linked to godotsteam.com, the GodotSteam source, or Valve's Steamworks docs.

## Answer

Resolved 2026-09-12 by a research subagent. Full findings with citations: `docs/research/in-game-invites-on-app-480.md` on branch `research/in-game-invites-on-app-480` (commit 7eb94f5, worktree `..\licensed-research-invites`).

**Recommended flow**

1. **Host**: `createLobby(LOBBY_TYPE_FRIENDS_ONLY, 3)` ? `lobby_created` ? `setLobbyData(lobby, "game", "licensed")` ? `SteamMultiplayerPeer.host_with_lobby(lobby)`. Every client sets `setRichPresence("licensed", "1")` at boot so the desk can tell our build apart from every other process Steam labels "Spacewar" (`getFriendGamePlayed().id == 480` alone is not enough).
2. **Desk friend list**: `getFriendCount` / `getFriendByIndex(FRIEND_FLAG_IMMEDIATE)`, `getFriendPersonaName` / `getFriendPersonaState`, `getFriendRichPresence(id, "licensed")`, `getFriendGamePlayed(id).lobby`. Refresh on `persona_state_change` and `friend_rich_presence_update`.
3. **Invite**: `inviteUserToLobby(lobby, friend)`. If the invitee's game is *running*, `lobby_invite(inviter, lobby, game)` fires immediately (Valve's `LobbyInvite_t`): show an in-game Accept prompt that calls `joinLobby(lobby)`. If they click Steam's own Join instead, `join_requested(lobby_id, steam_id)` (`GameLobbyJoinRequested_t`) fires; route it to the same call. Both signals, different moments.
4. **Join**: `lobby_joined` ? check `response == CHAT_ROOM_ENTER_RESPONSE_SUCCESS` and `getLobbyData(lobby, "game") == "licensed"` ? `SteamMultiplayerPeer.connect_to_lobby(lobby)`. The peer tracks `LobbyChatUpdate_t` and auto-`add_peer`s anyone who enters, so the lobby type *is* the session's access control. FRIENDS_ONLY keeps it out of every other 480 project's `requestLobbyList`.

**Biggest caveat**: if the invitee is *not* running the game, Valve's path is "Steam launches the game with `+connect_lobby <id>`", and on app 480 "the game" is Valve's SpaceWar from the Steam library, never our exe. Fallback: they open the exe by hand, then the host re-invites or they join from the in-game "friends in a lobby" list. This is the flow the reception desk must design for: the desk shows friends who are *in the game*, and inviting someone who is not shows "ask them to open the game".

**Fallbacks**: raw 64-bit lobby ID paste (`joinLobby(text.to_int())`) kept as a debug fallback only. A short human-typable lobby code is **not recommended**: `requestLobbyList` only returns PUBLIC lobbies, and on an AppID shared with thousands of projects that is the wrong trade. Rich-presence `connect` / `steam_display` add nothing until we own an AppID (no localization upload, same launch problem).

**Only once we own an AppID**: invites that launch the game for someone not running it; a "Join Game" button in the friends list; the game showing as itself rather than "Spacewar".

UNVERIFIED (flagged in the doc): the Steam client's UI when clicking a 480 invite link with the game closed; whether a Join Game button renders for "Spacewar"; whether PRIVATE lobby IDs are visible to friends.

Unblocks: The reception desk (together with Waiting room walkthrough).

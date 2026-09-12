---
status: accepted
date: 2026-09-12
---

# Steam is the only shipping network transport

The game is a Steam game for three friends who all have Steam, so multiplayer runs over Steam P2P via the GodotSteam GDExtension and its `SteamMultiplayerPeer`, plugged into Godot's high-level `MultiplayerAPI`. No dedicated servers, no direct-IP or ENet play in release builds, no relay of our own. Lobbies, invites, friend lists, avatars, and (if it happens) voice all come from Steamworks. We develop against app ID 480 (Spacewar) until the demo ships and distribute pre-Steam builds as GitHub release zips carrying the GodotSteam and `steam_api64.dll` binaries; the app ID is passed at init, not shipped as a file.

## Considered options

- **ENet / direct IP**: works without Steam, but friends would type IPs or we would run a relay; loses invites, names, avatars, voice.
- **Noray / other relays**: solves NAT, still loses everything social.
- **Steam only** (chosen): everything social for free, one transport to maintain, and the players already have it.

## Consequences

- Steam runs one account per machine, so the room cannot be tested with three local instances over the shipping transport. Decided on the waiting-room map (ticket "Testing alone: a second transport or a fake"): `ENetMultiplayerPeer` on localhost behind the `--transport=enet` launch flag, development only, still requiring a running Steam client; it must never be the shipping path, and bot learners are ruled out.
- Game code depends on `multiplayer` (the `MultiplayerAPI`), not on `SteamMultiplayerPeer` directly, so the dev transport is a one-line swap.
- Under app 480, friends see each other "playing Spacewar" and some rich-presence features may be unavailable until we own an AppID.

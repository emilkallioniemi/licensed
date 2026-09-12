extends Node
## Autoload `Transport`: the one place that picks a multiplayer peer at startup. Room code
## talks to `multiplayer` only (spec section 0, ADR-0002). Steam is the shipping path; ENet
## on localhost is the dev flag. Steam is still required under every transport: if init
## failed, this autoload does nothing and ticket 01's gate shows Steam-not-running.

## Shipping path: GodotSteam's SteamMultiplayerPeer on a FRIENDS_ONLY lobby of three.
const STEAM := &"steam"
## Dev path: ENetMultiplayerPeer, bind-or-join on localhost. Not a mode.
const ENET := &"enet"
## Fixed localhost port every instance uses; first to listen hosts, the others join.
const ENET_PORT := 34197
## Lobby data the desk (ticket 09) will read to tell our rooms from other Spacewar lobbies.
const GAME_KEY := "game"
const GAME_VALUE := "licensed"

## Fires once the peer is plugged in and, for a guest, the handshake has completed.
signal became_ready

## `STEAM` or `ENET`, read from `--transport=` in the user args after `--`.
var kind: StringName = STEAM
## Steam lobby id when hosting the shipping path; 0 otherwise.
var lobby_id: int = 0

var _enet_attempt := 0
var _ready_to_play := false


func _ready() -> void:
	# Autoloads also run in the editor, during `--import`, and under headless `--script`
	# (the room-state tests). None of those should open a lobby or bind a port.
	if Engine.is_editor_hint() or OS.get_cmdline_args().has("--script") or OS.get_cmdline_args().has("--import"):
		return
	kind = kind_from_args(OS.get_cmdline_user_args())
	if not SteamClient.is_running():
		print("Transport: Steam is not running; no peer under %s" % kind)
		return
	# After the main scene's `_ready`, so the waiting room has installed its spawn
	# function before a localhost handshake can deliver a learner.
	call_deferred("_start")


func _start() -> void:
	if kind == ENET:
		print("Transport: --transport=enet, bind-or-join localhost:%d" % ENET_PORT)
		_try_enet()
		return
	print("Transport: creating FRIENDS_ONLY Steam lobby of max %d" % RoomState.CAPACITY)
	Steam.lobby_created.connect(_on_lobby_created, CONNECT_ONE_SHOT)
	Steam.createLobby(Steam.LOBBY_TYPE_FRIENDS_ONLY, RoomState.CAPACITY)


func is_ready() -> bool:
	return _ready_to_play


## `--transport=enet` or `--transport=steam`; absent or anything else is steam. Nothing
## else is a mode (spec section 11).
static func kind_from_args(args: PackedStringArray) -> StringName:
	const FLAG := "--transport="
	for arg in args:
		if arg.begins_with(FLAG):
			var value := arg.substr(FLAG.length())
			if value == "enet":
				return ENET
			if value == "steam":
				return STEAM
			push_error("Transport: --transport accepts only steam or enet, not '%s'" % value)
			return STEAM
	return STEAM


## RoomState keys players by Steam id, which is the same account on every local instance.
## Under ENet the peer id is the unique id; under Steam the real Steam id is.
func identity_id(steam_id: int, peer_id: int) -> int:
	if kind == ENET:
		return peer_id
	return steam_id


## Under ENet, non-hosts append their arrival slot so three windows of one account stay
## tellable: "Emil", "Emil (2)", "Emil (3)". Godot's ENet unique ids are not 2 and 3, so
## the suffix is the palette/arrival slot (host is 1 and has no suffix). Shipping path:
## the Steam name alone.
func display_name_for(persona_name: String, slot: int) -> String:
	if kind == ENET and slot > 1:
		return "%s (%d)" % [persona_name, slot]
	return persona_name


func _on_lobby_created(result: int, new_lobby_id: int) -> void:
	if result != Steam.RESULT_OK:
		push_error("Transport: createLobby failed (result %d)" % result)
		return
	lobby_id = new_lobby_id
	Steam.setLobbyData(lobby_id, GAME_KEY, GAME_VALUE)
	var peer := SteamMultiplayerPeer.new()
	var err := peer.host_with_lobby(lobby_id)
	if err != OK:
		push_error("Transport: host_with_lobby failed (%s)" % error_string(err))
		return
	multiplayer.multiplayer_peer = peer
	print("Transport: hosting FRIENDS_ONLY Steam lobby %d game=%s" % [lobby_id, GAME_VALUE])
	_become_ready()


func _try_enet() -> void:
	var server := ENetMultiplayerPeer.new()
	var err := server.create_server(ENET_PORT, RoomState.CAPACITY - 1)
	if err == OK:
		multiplayer.multiplayer_peer = server
		print("Transport: ENet host on 127.0.0.1:%d" % ENET_PORT)
		_become_ready()
		return
	var client := ENetMultiplayerPeer.new()
	err = client.create_client("127.0.0.1", ENET_PORT)
	if err != OK:
		_retry_enet()
		return
	multiplayer.multiplayer_peer = client
	print("Transport: ENet guest joining 127.0.0.1:%d" % ENET_PORT)
	multiplayer.connected_to_server.connect(_become_ready, CONNECT_ONE_SHOT)
	multiplayer.connection_failed.connect(_on_enet_connection_failed, CONNECT_ONE_SHOT)


func _on_enet_connection_failed() -> void:
	multiplayer.multiplayer_peer = null
	_retry_enet()


func _retry_enet() -> void:
	_enet_attempt += 1
	if _enet_attempt > 20:
		push_error("Transport: ENet bind-or-join on port %d failed" % ENET_PORT)
		return
	get_tree().create_timer(0.1).timeout.connect(_try_enet, CONNECT_ONE_SHOT)


func _become_ready() -> void:
	if _ready_to_play:
		return
	_ready_to_play = true
	became_ready.emit()


func _exit_tree() -> void:
	if lobby_id != 0:
		Steam.leaveLobby(lobby_id)
		lobby_id = 0
	if multiplayer.multiplayer_peer != null:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null


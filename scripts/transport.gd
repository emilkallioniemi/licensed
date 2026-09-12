extends Node
## Autoload `Transport`: the one place that picks a multiplayer peer at startup. Room code
## talks to `multiplayer` only (spec section 0, ADR-0002). Steam is the shipping path; ENet
## on localhost is the dev flag. Steam is still required under every transport: if init
## failed, this autoload does nothing and ticket 01's gate shows Steam-not-running.
## Ticket 09 adds joining another Steam lobby and hosting a fresh one on Leave.

## Shipping path: GodotSteam's SteamMultiplayerPeer on a FRIENDS_ONLY lobby of three.
const STEAM := &"steam"
## Dev path: ENetMultiplayerPeer, bind-or-join on localhost. Not a mode.
const ENET := &"enet"
## Fixed localhost port every instance uses; first to listen hosts, the others join.
const ENET_PORT := 34197
## Lobby data the desk reads to tell our rooms from other Spacewar lobbies.
const GAME_KEY := "game"
const GAME_VALUE := "licensed"
## Occupancy, written by the host so a friend's desk can hide Invite and Join at three.
const OCCUPANCY_KEY := "n"

## Fires once the peer is plugged in and, for a guest, the handshake has completed.
signal became_ready
## Fires when this machine moves to another room (Join succeeded, Leave, host vanished).
signal room_switched
## Fires after a failed Join has rehosted this machine's own room. The waiting room stays.
signal join_recovered

## `STEAM` or `ENET`, read from `--transport=` in the user args after `--`.
var kind: StringName = STEAM
## Steam lobby id of the room this machine is in (hosted or joined); 0 otherwise.
var lobby_id: int = 0
## True while this machine owns the current Steam lobby. The host has no Leave.
var hosting := false
## Last failed Join, consumed by the desk so the row can show a dry line after a rehost.
var last_join_error: Dictionary = {}

var _enet_attempt := 0
var _ready_to_play := false
var _expecting_lobby := false
var _join_target := 0
var _join_friend := 0
var _moves := 0
var _recovering_join := false


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
	Steam.lobby_created.connect(_on_lobby_created)
	Steam.lobby_joined.connect(_on_lobby_joined)
	print("Transport: creating FRIENDS_ONLY Steam lobby of max %d" % RoomState.CAPACITY)
	_create_hosted_lobby()


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


## Join another Steam lobby. Steam leaves the current lobby as part of joinLobby; the
## Godot room is only swapped after `lobby_joined` reports success and `game=licensed`.
## On failure the machine rehosts so the waiting room stays a room of its own.
func join_lobby(target_lobby_id: int, friend_id: int = 0) -> void:
	if kind != STEAM or target_lobby_id == 0 or _join_target != 0:
		return
	if target_lobby_id == lobby_id:
		print("Transport: already in lobby %d" % target_lobby_id)
		return
	_join_target = target_lobby_id
	_join_friend = friend_id
	print("Transport: joinLobby %d" % target_lobby_id)
	Steam.joinLobby(target_lobby_id)


## Leave the current room and host a fresh FRIENDS_ONLY lobby. When `move_room` is true
## the waiting room reloads on `room_switched` so the player is alone at the entrance.
func host_fresh(move_room: bool = true) -> void:
	if kind != STEAM:
		return
	_join_target = 0
	_join_friend = 0
	if move_room:
		_moves += 1
	else:
		_recovering_join = true
	_drop_godot_peer()
	if lobby_id != 0:
		Steam.leaveLobby(lobby_id)
		lobby_id = 0
	hosting = false
	_ready_to_play = false
	print("Transport: hosting a fresh room")
	_create_hosted_lobby()


func take_join_error() -> Dictionary:
	var err := last_join_error.duplicate()
	last_join_error = {}
	return err


func set_occupancy(count: int) -> void:
	if kind != STEAM or lobby_id == 0 or not hosting:
		return
	Steam.setLobbyData(lobby_id, OCCUPANCY_KEY, str(count))


func _create_hosted_lobby() -> void:
	_expecting_lobby = true
	Steam.createLobby(Steam.LOBBY_TYPE_FRIENDS_ONLY, RoomState.CAPACITY)


func _on_lobby_created(result: int, new_lobby_id: int) -> void:
	if not _expecting_lobby:
		return
	_expecting_lobby = false
	if result != Steam.RESULT_OK:
		push_error("Transport: createLobby failed (result %d)" % result)
		return
	lobby_id = new_lobby_id
	hosting = true
	Steam.setLobbyData(lobby_id, GAME_KEY, GAME_VALUE)
	Steam.setLobbyData(lobby_id, OCCUPANCY_KEY, "1")
	var peer := SteamMultiplayerPeer.new()
	var err := peer.host_with_lobby(lobby_id)
	if err != OK:
		push_error("Transport: host_with_lobby failed (%s)" % error_string(err))
		return
	multiplayer.multiplayer_peer = peer
	print("Transport: hosting FRIENDS_ONLY Steam lobby %d game=%s" % [lobby_id, GAME_VALUE])
	_become_ready()


func _on_lobby_joined(joined_id: int, _permissions: int, _locked: bool, response: int) -> void:
	if _join_target == 0:
		return
	var target := _join_target
	var friend_id := _join_friend
	_join_target = 0
	_join_friend = 0
	if OS.is_debug_build():
		print("Transport: joinLobby response %s (%d) lobby %d" % [_enter_response_name(response), response, joined_id])
	if response != Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		_fail_join(target, friend_id, response)
		return
	if Steam.getLobbyData(joined_id, GAME_KEY) != GAME_VALUE:
		Steam.leaveLobby(joined_id)
		_fail_join(target, friend_id, Steam.CHAT_ROOM_ENTER_RESPONSE_DOESNT_EXIST)
		return
	_adopt_as_guest(joined_id, friend_id)


func _fail_join(target: int, friend_id: int, response: int) -> void:
	last_join_error = {
		"lobby_id": target,
		"steam_id": friend_id,
		"response": response,
	}
	print("Transport: join failed (response %s, %d); rehosting" % [_enter_response_name(response), response])
	host_fresh(false)


func _adopt_as_guest(joined_id: int, friend_id: int) -> void:
	_moves += 1
	_drop_godot_peer()
	# joinLobby already left the hosted lobby; do not leave the one we just entered.
	lobby_id = joined_id
	hosting = false
	var peer := SteamMultiplayerPeer.new()
	var err := peer.connect_to_lobby(joined_id)
	if err != OK:
		push_error("Transport: connect_to_lobby failed (%s)" % error_string(err))
		_fail_join(joined_id, friend_id, Steam.CHAT_ROOM_ENTER_RESPONSE_ERROR)
		return
	multiplayer.multiplayer_peer = peer
	print("Transport: guest in Steam lobby %d" % joined_id)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED:
		_become_ready()
		return
	_join_friend = friend_id
	multiplayer.connected_to_server.connect(_become_ready, CONNECT_ONE_SHOT)
	multiplayer.connection_failed.connect(_on_steam_join_connection_failed, CONNECT_ONE_SHOT)


func _on_steam_join_connection_failed() -> void:
	var friend_id := _join_friend
	_join_friend = 0
	_fail_join(lobby_id, friend_id, Steam.CHAT_ROOM_ENTER_RESPONSE_ERROR)


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
	var first := not _ready_to_play
	_ready_to_play = true
	if first:
		became_ready.emit()
	if _recovering_join:
		_recovering_join = false
		join_recovered.emit()
	elif _moves > 0:
		room_switched.emit()


func _drop_godot_peer() -> void:
	if multiplayer.multiplayer_peer != null:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null


func _enter_response_name(response: int) -> String:
	match response:
		Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
			return "SUCCESS"
		Steam.CHAT_ROOM_ENTER_RESPONSE_DOESNT_EXIST:
			return "DOESNT_EXIST"
		Steam.CHAT_ROOM_ENTER_RESPONSE_FULL:
			return "FULL"
		Steam.CHAT_ROOM_ENTER_RESPONSE_ERROR:
			return "ERROR"
		_:
			return "UNKNOWN"


func _exit_tree() -> void:
	if lobby_id != 0:
		Steam.leaveLobby(lobby_id)
		lobby_id = 0
	_drop_godot_peer()

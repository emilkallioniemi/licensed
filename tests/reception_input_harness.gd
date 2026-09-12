extends ReceptionDesk
## Replace only the world/Steam fixtures; retain real rows, callbacks and GUI input.
var actions: Array[String] = []

func _ready() -> void:
	_waiting = WaitingRoom.new()
	_screen = StationScreen.new()
	add_child(_screen)
	_screen._open = true
	_viewport = SubViewport.new()
	_viewport.size = SCREEN_PX
	_viewport.disable_3d = true
	add_child(_viewport)
	_build_screen()

func _exit_tree() -> void:
	_waiting.free()

func _rebuild_rows(_room: RoomState, _room_full: bool) -> void:
	_clear_container(_rows)
	_rows.add_child(_make_row({
		"steam_id": 456, "name": "Friend", "group": GROUP_AT_CENTRE,
		"state": STATE_AT_CENTRE, "lobby_id": 789, "friend_full": false,
	}, false, false, true))

func _map_mouse(mouse: Vector2) -> Vector2:
	return mouse

func _on_invite_pressed(_friend_id: int) -> void:
	actions.append("Invite")

func _on_join_pressed(_lobby_id: int, _friend_id: int) -> void:
	actions.append("Join")

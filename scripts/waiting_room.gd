class_name WaitingRoom
extends Node3D
## The game's main scene. There is no menu in front of it: Steam running puts the player
## straight in the room; Steam not running shows the one-line state instead and opens no room.
## Ticket 04: the host owns RoomState, learners replicate, and three instances meet here.
## Ticket 05: walking in is a fade and the entrance door, not a teleport.
## Ticket 06: chairs are stations; sitting is the ready-up.
## Ticket 07: the booking board is a screened station; picks and BOOKED render here.
## Ticket 08: the role column holds Driver, Spotter, Navigator, or Random.
## Ticket 09: the reception desk lists friends and joins or leaves a room.
## Ticket 10: Invite from the desk rings in-world; Accept is Join.
## Ticket 11: the notice board, the examiner's call, the fade, and the test area.
## Ticket 12: the Escape overlay, quit, Back, and shared fate from the test area.
## Ticket 13: voice from the learners, mic mode and mute on the overlay.

## Views (chairs, the board, the desk, the notice board) render from the replicated room state.
signal room_changed

const STEAM_NOT_RUNNING_SCENE := preload("res://scenes/steam_not_running.tscn")
const LEARNER_SCENE := preload("res://scenes/learner.tscn")
const DOOR_SOUND := preload("res://assets/waiting_room/door.wav")
## Fade and music share this second.
const TRANSITION := 1.0
## Synthesized "Monster truck."; native Windows TTS can crash during initialization.
const EXAMINER_CALL := preload("res://assets/waiting_room/examiner_monster_truck.wav")

## Furniture the spec names for box colliders, looked up on the kit by node name.
const FURNITURE_GROUPS: PackedStringArray = [
	"Reception",
	"Chair01",
	"Chair02",
	"Chair03",
	"Plant",
	"WasteBin",
]

@onready var kit: Node3D = $Kit
@onready var music: AudioStreamPlayer = $Music
@onready var learner_spawner: MultiplayerSpawner = $LearnerSpawner
@onready var fade: FadeOverlay = $Fade
@onready var theatre: ArrivalTheatre = $ArrivalTheatre
@onready var test_area: TestArea = $TestArea
@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var escape_overlay: EscapeOverlay = $EscapeOverlay

## Host-owned on the server; guests restore snapshots into their copy and never write.
var _room: RoomState
## peer_id → the id RoomState keys this player by (Steam id, or the peer id under ENet).
var _steam_id_of: Dictionary = {}
## Peers that announced a deliberate Leave (or a clean window close) before disconnecting.
var _clean_leavers: Dictionary = {}
## True once this machine has its own learner, so a live arrival can hide in the doorway
## without a late joiner hiding people who are already in the room.
var _watching := false
## True once `launched` has started the fade; stations and the tick stop owning the room.
var _in_test_area := false
## True while Back or shared fate is walking everyone through the entrance.
var _returning := false
var _test_door: AudioStreamPlayer3D
var _waiting_environment: Environment
var _music_volume := -6.0
var _examiner: AudioStreamPlayer


func _ready() -> void:
	if not SteamClient.is_running():
		# Deferred: at boot the root is still adding this scene, so a direct change_scene fails
		# to remove it and prints an error. The swap still lands before the first frame draws.
		get_tree().change_scene_to_packed.call_deferred(STEAM_NOT_RUNNING_SCENE)
		return
	music.play()
	_music_volume = music.volume_db
	_waiting_environment = world_environment.environment
	get_tree().set_auto_accept_quit(false)
	_add_room_collision()
	_add_test_area_door()
	learner_spawner.spawn_function = _spawn_learner
	Transport.became_ready.connect(_on_transport_ready, CONNECT_ONE_SHOT)
	Transport.room_switched.connect(_on_room_switched)
	Transport.join_recovered.connect(_on_join_recovered)
	if Transport.is_ready():
		_on_transport_ready()


func _on_transport_ready() -> void:
	_room = RoomState.new(RoomState.min_players_from_args(OS.get_cmdline_user_args()))
	_bind_room(_room)
	print("WaitingRoom: the room waits for %d" % _room.min_players)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	if multiplayer.is_server():
		_accept_player(multiplayer.get_unique_id(), SteamClient.steam_id, SteamClient.persona_name)
		return
	begin_join()
	multiplayer.server_disconnected.connect(_on_host_vanished, CONNECT_ONE_SHOT)
	_report_identity.rpc_id(1, SteamClient.steam_id, SteamClient.persona_name)


func _on_peer_connected(peer_id: int) -> void:
	if multiplayer.is_server():
		print("WaitingRoom: peer %d connected" % peer_id)


func _on_peer_disconnected(peer_id: int) -> void:
	if not multiplayer.is_server():
		return
	var steam_id: int = _steam_id_of.get(peer_id, 0)
	var clean: bool = bool(_clean_leavers.get(peer_id, false))
	_clean_leavers.erase(peer_id)
	if steam_id != 0:
		_room.leave(steam_id)
		_steam_id_of.erase(peer_id)
		print("WaitingRoom: peer %d left; %d in the room" % [peer_id, _room.player_count()])
	if _in_test_area:
		var dropped := _learner_of(peer_id)
		if is_instance_valid(dropped):
			dropped.queue_free()
		_apply_return_from_test_area()
		return
	if steam_id != 0:
		_replicate()
	_play_departure.rpc(peer_id, clean)


@rpc("any_peer", "call_remote", "reliable")
func _report_identity(steam_id: int, persona_name: String) -> void:
	if not multiplayer.is_server():
		return
	_accept_player(multiplayer.get_remote_sender_id(), steam_id, persona_name)


func _accept_player(peer_id: int, steam_id: int, persona_name: String) -> void:
	var id := Transport.identity_id(steam_id, peer_id)
	if not _room.arrive(id, persona_name):
		push_error("WaitingRoom: arrive refused for peer %d" % peer_id)
		return
	var occupant := _room.player(id)
	occupant.display_name = Transport.display_name_for(persona_name, occupant.palette)
	_steam_id_of[peer_id] = id
	var joining := _room.player_count() > 1
	learner_spawner.spawn({
		"peer_id": peer_id,
		"palette": occupant.palette,
		"display_name": occupant.display_name,
		"arriving": joining,
	})
	print("WaitingRoom: %s arrived as palette %02d (%d of 3)" % [
		occupant.display_name, occupant.palette, _room.player_count(),
	])
	_replicate()
	if joining:
		_play_arrival.rpc(peer_id)


## Guests send commands; the host applies them in receive order and replicates. Plumbing
## for chairs, the board, and the role pickup (tickets 06–08).
func submit_command(verb: StringName, argument: Variant = 0) -> void:
	if multiplayer.is_server():
		_apply_command(multiplayer.get_unique_id(), verb, argument)
	else:
		_submit_command.rpc_id(1, verb, argument)


@rpc("any_peer", "call_remote", "reliable")
func _submit_command(verb: StringName, argument: Variant = 0) -> void:
	if not multiplayer.is_server():
		return
	_apply_command(multiplayer.get_remote_sender_id(), verb, argument)


func _apply_command(peer_id: int, verb: StringName, argument: Variant) -> void:
	var steam_id: int = _steam_id_of.get(peer_id, 0)
	if steam_id == 0:
		return
	var applied := false
	match verb:
		&"pick":
			applied = _room.pick(steam_id, argument)
		&"drop_pick":
			applied = _room.drop_pick(steam_id)
		&"take":
			applied = _room.take(steam_id, argument)
		&"drop_hold":
			applied = _room.drop_hold(steam_id)
		&"sit":
			applied = _room.sit(steam_id, int(argument))
		&"stand":
			applied = _room.stand(steam_id)
	if applied:
		_replicate()


func room_state() -> RoomState:
	return _room


func is_in_test_area() -> bool:
	return _in_test_area


func is_returning() -> bool:
	return _returning


## True while the desk or the board still has its station screen open. Escape then
## closes that screen and must not open the overlay (spec section 3).
func station_screen_is_open() -> bool:
	for path in ["BookingBoard/Screen", "ReceptionDesk/Screen"]:
		var screen := get_node_or_null(path) as StationScreen
		if screen != null and screen.occupies_escape():
			return true
	return false


## Mouse follows the overlay: cursor while it is open, captured on close.
## The room is not paused; stations keep running.
func set_escape_overlay_open(open: bool) -> void:
	var learner := _local_learner()
	if learner != null:
		learner.set_escape_overlay_open(open)


## A station screen is about to dock; the overlay must not sit over it.
func close_escape_overlay() -> void:
	if escape_overlay != null:
		escape_overlay.close()


func quit_to_desktop() -> void:
	_quit_cleanly()


## Host only, test area only. Clears the room state and walks everyone back through
## the entrance with the arrival theatre.
func request_return_from_test_area() -> void:
	if not _in_test_area or _returning or not multiplayer.is_server():
		return
	_apply_return_from_test_area()


func _local_learner() -> Learner:
	for learner in _learners():
		if learner.is_local():
			return learner
	return null


func _bind_room(room: RoomState) -> void:
	if not room.countdown_started.is_connected(_on_countdown_started):
		room.countdown_started.connect(_on_countdown_started)
	if not room.countdown_cancelled.is_connected(_on_countdown_cancelled):
		room.countdown_cancelled.connect(_on_countdown_cancelled)
	if not room.launched.is_connected(_on_launched):
		room.launched.connect(_on_launched)


func _process(delta: float) -> void:
	if _room == null or not multiplayer.is_server() or _in_test_area:
		return
	if not _room.is_counting_down():
		return
	var shown := _room.countdown_count()
	_room.tick(delta)
	if not _room.is_counting_down() or _room.countdown_count() != shown:
		_replicate()


func _on_countdown_started() -> void:
	_speak_examiner()
	# The line changed the instant the ready-up fired; don't wait for the next replicate.
	room_changed.emit()


func _on_countdown_cancelled() -> void:
	if _examiner != null:
		_examiner.stop()


func _on_launched(_vehicle: StringName, _roles: Dictionary) -> void:
	if _in_test_area:
		return
	_in_test_area = true
	_silence_stations()
	_play_test_area_door()
	fade.to_black(TRANSITION)
	_fade_music(TRANSITION)
	await get_tree().create_timer(TRANSITION).timeout
	if not is_inside_tree():
		return
	_enter_test_area()
	fade.to_clear(TRANSITION)


func _speak_examiner() -> void:
	if _examiner == null:
		_examiner = AudioStreamPlayer.new()
		_examiner.name = "Examiner"
		_examiner.stream = EXAMINER_CALL
		_examiner.volume_db = -6.0
		add_child(_examiner)
	_examiner.play()


func _silence_stations() -> void:
	_set_stations_enabled(false)


func _set_stations_enabled(enabled: bool) -> void:
	var mode := Node.PROCESS_MODE_INHERIT if enabled else Node.PROCESS_MODE_DISABLED
	for path in ["ChairStations", "BookingBoard", "ReceptionDesk"]:
		var node := get_node_or_null(path)
		if node != null:
			node.process_mode = mode


func _play_test_area_door() -> void:
	if _test_door == null or _test_door.stream == null:
		return
	if _test_door.playing:
		_test_door.stop()
	_test_door.play()


func _fade_music(duration: float) -> void:
	var tween := create_tween()
	tween.tween_property(music, "volume_db", -80.0, duration)
	tween.tween_callback(music.stop)


func _enter_test_area() -> void:
	_set_waiting_room_visible(false)
	if test_area.daylight != null:
		world_environment.environment = test_area.daylight
	test_area.visible = true
	_place_in_bays()


func _place_in_bays() -> void:
	if _room == null:
		return
	var roles := _room.launched_roles()
	for learner in _learners():
		var occupant := _occupant_of_learner(learner)
		if occupant == null:
			continue
		var dealt: StringName = roles.get(occupant.steam_id, occupant.hold)
		learner.set_held_role(dealt)
		learner.set_seated(false)
		learner.set_using_station(false)
		learner.set_can_walk(true)
		# Every machine poses every learner so fade-up is three in a row, not a
		# 200 m interpolate from the chairs. Authority then writes the same bay.
		learner.global_transform = test_area.bay_transform(occupant.palette - 1)
		learner.velocity = Vector3.ZERO
		if learner.is_local():
			test_area.show_own_role(Learner.role_label(dealt))


func _apply_return_from_test_area() -> void:
	if not multiplayer.is_server() or not _in_test_area:
		return
	_room.return_from_test_area()
	_replicate()
	_play_return()


func _play_return() -> void:
	if _returning or not _in_test_area:
		return
	_returning = true
	_in_test_area = false
	if escape_overlay != null:
		escape_overlay.close()
	fade.to_black(TRANSITION)
	await get_tree().create_timer(TRANSITION).timeout
	if not is_inside_tree():
		return
	_restore_waiting_room()
	_restart_music()
	_place_at_entrance_for_return()
	fade.to_clear(TRANSITION)
	await get_tree().create_timer(0.25).timeout
	if not is_inside_tree():
		return
	await _play_return_arrivals()
	_returning = false


func _restore_waiting_room() -> void:
	_set_waiting_room_visible(true)
	if _waiting_environment != null:
		world_environment.environment = _waiting_environment
	test_area.visible = false
	test_area.show_own_role("")
	_set_stations_enabled(true)


func _set_waiting_room_visible(shown: bool) -> void:
	kit.visible = shown
	for path in ["NoticeBoard", "BookingBoard", "ReceptionDesk", "ChairStations"]:
		var node := get_node_or_null(path) as Node3D
		if node != null:
			node.visible = shown
	for light_name in [
		"CeilingFrontLeft", "CeilingFrontRight", "CeilingBackLeft", "CeilingBackRight",
	]:
		var light := get_node_or_null(light_name) as Light3D
		if light != null:
			light.visible = shown


func _restart_music() -> void:
	music.volume_db = _music_volume
	music.play(0.0)


func _place_at_entrance_for_return() -> void:
	for learner in _learners():
		learner.set_held_role(&"")
		learner.set_seated(false)
		learner.set_using_station(false)
		learner.set_escape_overlay_open(false)
		learner.set_can_walk(false)
		learner.set_body_visible(false)
		learner.velocity = Vector3.ZERO
		_place_at_entrance(learner)


func _play_return_arrivals() -> void:
	for learner in _learners_in_arrival_order():
		if not is_instance_valid(learner):
			continue
		await theatre.open_door()
		if is_instance_valid(learner):
			learner.set_body_visible(true)
			if learner.is_local():
				learner.set_can_walk(true)
		await theatre.close_door()


func _learners_in_arrival_order() -> Array[Learner]:
	var ordered: Array[Learner] = []
	if _room == null:
		return ordered
	for occupant in _room.players:
		for learner in _learners():
			if learner.palette() == occupant.palette:
				ordered.append(learner)
				break
	return ordered


func _occupant_of_learner(learner: Learner) -> RoomState.Player:
	if _room == null:
		return null
	for occupant in _room.players:
		if occupant.palette == learner.palette():
			return occupant
	return null


func _learners() -> Array[Learner]:
	var found: Array[Learner] = []
	for child in learner_spawner.get_children():
		if child is Learner:
			found.append(child)
	return found


func _add_test_area_door() -> void:
	_test_door = AudioStreamPlayer3D.new()
	_test_door.name = "TestAreaDoor"
	_test_door.stream = DOOR_SOUND
	_test_door.volume_db = 4.0
	_test_door.unit_size = 20.0
	_test_door.max_distance = 0.0
	add_child(_test_door)
	var door := kit.find_child("TestDoor", true, false) as Node3D
	if door != null:
		_test_door.global_position = door.global_position + Vector3(0.0, 1.4, 0.0)
	else:
		_test_door.position = Vector3(0.55, 1.4, -4.82)


func _replicate() -> void:
	if not multiplayer.is_server():
		return
	Transport.set_occupancy(_room.player_count())
	_receive_state.rpc(_room.snapshot())
	room_changed.emit()


@rpc("authority", "call_remote", "reliable")
func _receive_state(data: Dictionary) -> void:
	if _room == null:
		_room = RoomState.new()
		_bind_room(_room)
	var had_booking := _room.has_booking()
	var was_counting := _room.is_counting_down()
	var had_launched := not _room.launched_roles().is_empty()
	_room.restore(data)
	# restore() is silent; a state diff raises the host's events so later views (booking
	# sound, examiner line) can connect to `_room` on every machine.
	if not had_booking and _room.has_booking():
		_room.booking_formed.emit(_room.booking())
	elif had_booking and not _room.has_booking():
		_room.booking_dissolved.emit()
	if not was_counting and _room.is_counting_down():
		_room.countdown_started.emit()
	elif was_counting and not _room.is_counting_down() and _room.launched_roles().is_empty():
		_room.countdown_cancelled.emit()
	if not had_launched and not _room.launched_roles().is_empty():
		_room.launched.emit(_room.booking(), _room.launched_roles())
	elif _in_test_area and had_launched and _room.launched_roles().is_empty():
		_play_return()
	room_changed.emit()


func _spawn_learner(data: Variant) -> Node:
	var peer_id: int = data["peer_id"]
	var learner: Learner = LEARNER_SCENE.instantiate()
	learner.name = "Learner_%d" % peer_id
	learner.set_multiplayer_authority(peer_id)
	learner.apply_palette(int(data["palette"]))
	learner.set_display_name(String(data["display_name"]))
	learner.set_local(peer_id == multiplayer.get_unique_id())
	var arriving := bool(data.get("arriving", false))
	if learner.is_local() and arriving:
		learner.set_can_walk(false)
	if arriving and not learner.is_local() and _watching:
		learner.set_body_visible(false)
	_place_at_entrance(learner)
	print("WaitingRoom: spawned %s palette %02d local=%s" % [
		learner.name, int(data["palette"]), learner.is_local(),
	])
	# A late joiner must see who is already seated. Deferred so the spawner has
	# parented this learner before the chairs view looks for it.
	if _room != null:
		room_changed.emit.call_deferred()
	if learner.is_local():
		_watching = true
		call_deferred("_reveal_local")
	return learner


func _place_at_entrance(learner: Learner, facing_out: bool = false) -> void:
	# AttachmentPoints/Entrance, not the GLB's Entrance frame group of the same name.
	var entrance := kit.get_node_or_null("AttachmentPoints/Entrance") as Marker3D
	if entrance == null:
		push_error("Waiting room kit has no Entrance marker")
		return
	learner.position = entrance.global_position
	var facing := entrance.global_transform.basis.z if facing_out else -entrance.global_transform.basis.z
	facing.y = 0.0
	if facing.length_squared() > 0.0001:
		learner.basis = Basis.looking_at(facing.normalized(), Vector3.UP)


## Ticket 09 calls this when Join or Accept is pressed, before the host's room loads.
func begin_join() -> void:
	fade.to_black()


## Ticket 09 calls this on Leave. Remaining machines play the reverse theatre on disconnect.
func begin_leave() -> void:
	fade.to_black()
	if not multiplayer.is_server() and _peer_connected():
		_announce_leave.rpc_id(1)


## Guest Leave, or a guest whose host vanished: a fresh hosted room, alone at the entrance.
func leave_to_own_room() -> void:
	begin_leave()
	await get_tree().create_timer(0.25).timeout
	if is_inside_tree():
		Transport.host_fresh()


func _on_room_switched() -> void:
	get_tree().reload_current_scene.call_deferred()


func _on_join_recovered() -> void:
	print("WaitingRoom: Join failed; this room is still ours")
	_reset_as_lone_host()
	fade.to_clear()


func _reset_as_lone_host() -> void:
	var pose := Transform3D.IDENTITY
	var had_pose := false
	for child in learner_spawner.get_children():
		if child is Learner and (child as Learner).is_local():
			pose = (child as Learner).global_transform
			had_pose = true
			break
	_clean_leavers.clear()
	_steam_id_of.clear()
	_watching = false
	while learner_spawner.get_child_count() > 0:
		var child := learner_spawner.get_child(0)
		learner_spawner.remove_child(child)
		child.free()
	_room = RoomState.new(RoomState.min_players_from_args(OS.get_cmdline_user_args()))
	_bind_room(_room)
	_accept_player(multiplayer.get_unique_id(), SteamClient.steam_id, SteamClient.persona_name)
	if not had_pose:
		return
	var learner := _learner_of(multiplayer.get_unique_id())
	if learner != null:
		learner.global_transform = pose


func _on_host_vanished() -> void:
	print("WaitingRoom: the host vanished")
	if Transport.kind != Transport.STEAM and not _in_test_area:
		return
	leave_to_own_room()


func _peer_connected() -> bool:
	var peer := multiplayer.multiplayer_peer
	return peer != null and peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED


func _reveal_local() -> void:
	fade.to_clear()


@rpc("any_peer", "call_remote", "reliable")
func _announce_leave() -> void:
	if not multiplayer.is_server():
		return
	_clean_leavers[multiplayer.get_remote_sender_id()] = true


@rpc("authority", "call_local", "reliable")
func _play_arrival(peer_id: int) -> void:
	var learner := await _wait_for_learner(peer_id)
	if learner == null:
		return
	# The door beat is for machines already in the room. The joiner fades up in the
	# doorway and stands still until the others would see them, then walks.
	if learner.is_local():
		await get_tree().create_timer(ArrivalTheatre.SWING).timeout
		if is_instance_valid(learner):
			learner.set_can_walk(true)
		return
	print("WaitingRoom: the door for peer %d" % peer_id)
	learner.set_body_visible(false)
	await theatre.open_door()
	if is_instance_valid(learner):
		learner.set_body_visible(true)
	await theatre.close_door()


@rpc("authority", "call_local", "reliable")
func _play_departure(peer_id: int, clean: bool) -> void:
	var learner := _learner_of(peer_id)
	if clean:
		print("WaitingRoom: leave through the entrance (peer %d)" % peer_id)
		if is_instance_valid(learner):
			_place_at_entrance(learner, true)
		await theatre.open_door()
		if multiplayer.is_server() and is_instance_valid(learner):
			learner.queue_free()
		await theatre.close_door()
		return
	print("WaitingRoom: drop (peer %d); the learner vanishes" % peer_id)
	if multiplayer.is_server() and is_instance_valid(learner):
		learner.queue_free()
	theatre.play_drop()


func _learner_of(peer_id: int) -> Learner:
	# spawn_path is `.` on the spawner, so learners are its children, not the room's.
	return learner_spawner.get_node_or_null("Learner_%d" % peer_id) as Learner


func _wait_for_learner(peer_id: int) -> Learner:
	var learner := _learner_of(peer_id)
	if learner != null:
		return learner
	for _i in 30:
		await get_tree().process_frame
		learner = _learner_of(peer_id)
		if learner != null:
			return learner
	push_error("WaitingRoom: no learner for peer %d" % peer_id)
	return null


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_quit_cleanly()


func _quit_cleanly() -> void:
	if _peer_connected() and not multiplayer.is_server():
		_announce_leave.rpc_id(1)
		await get_tree().create_timer(0.2).timeout
	get_tree().quit()


## Trimesh the kit's Architecture group (walls and floor); box colliders on the named
## furniture; a plug in the entrance opening so the room is closed. The kit scene itself
## is not edited.
func _add_room_collision() -> void:
	var architecture := kit.find_child("Architecture", true, false)
	if architecture == null:
		push_error("Waiting room kit has no Architecture group")
	else:
		for node in architecture.find_children("*", "MeshInstance3D", true, false):
			var mesh_instance := node as MeshInstance3D
			if mesh_instance.name.begins_with("Floor tile"):
				continue
			mesh_instance.create_trimesh_collision()
	for group_name in FURNITURE_GROUPS:
		var group := kit.find_child(group_name, true, false)
		if group == null:
			push_error("Waiting room kit has no furniture group '%s'" % group_name)
			continue
		_add_box_collision(group)
	for cupboard in kit.find_children("Back storage cupboard*", "", true, false):
		_add_box_collision(cupboard)
	_plug_entrance()


func _add_box_collision(from: Node) -> void:
	var bounds := _visual_aabb(from)
	if bounds.size == Vector3.ZERO:
		push_error("No mesh to box-collide for '%s'" % from.name)
		return
	var body := StaticBody3D.new()
	body.name = "%sCollision" % from.name
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = bounds.size
	shape.shape = box
	body.add_child(shape)
	add_child(body)
	body.global_position = bounds.get_center()


func _plug_entrance() -> void:
	# The opening is 2.2 m wide at Z = +5. A thin wall fills it so the entrance is a way in
	# only; the kit's door leaf is still a request to Astra.
	var body := StaticBody3D.new()
	body.name = "EntrancePlug"
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(2.24, 2.8, 0.3)
	shape.shape = box
	body.add_child(shape)
	add_child(body)
	body.global_position = Vector3(0.0, 1.4, 5.15)


func _visual_aabb(root: Node) -> AABB:
	var meshes: Array[Node] = root.find_children("*", "MeshInstance3D", true, false)
	if root is MeshInstance3D:
		meshes.insert(0, root)
	var bounds := AABB()
	var started := false
	for node in meshes:
		var mesh_instance := node as MeshInstance3D
		if mesh_instance.mesh == null:
			continue
		var local := mesh_instance.mesh.get_aabb()
		for i in 8:
			var corner := mesh_instance.global_transform * local.get_endpoint(i)
			if not started:
				bounds = AABB(corner, Vector3.ZERO)
				started = true
			else:
				bounds = bounds.expand(corner)
	return bounds

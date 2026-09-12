extends Node3D
## The game's main scene. There is no menu in front of it: Steam running puts the player
## straight in the room; Steam not running shows the one-line state instead and opens no room.
## Ticket 04: the host owns RoomState, learners replicate, and three instances meet here.

const STEAM_NOT_RUNNING_SCENE := preload("res://scenes/steam_not_running.tscn")
const LEARNER_SCENE := preload("res://scenes/learner.tscn")

## Furniture the spec names for box colliders, looked up on the kit by node name.
const FURNITURE_GROUPS: PackedStringArray = [
	"Reception",
	"Chair01",
	"Chair02",
	"Chair03",
	"Plant",
	"WasteBin",
]

## Lateral offset at the entrance so three capsules do not spawn inside each other.
## Ticket 05 replaces this with the arrival theatre in the doorway.
const ENTRANCE_SPACING := 0.7

@onready var kit: Node3D = $Kit
@onready var music: AudioStreamPlayer = $Music
@onready var learner_spawner: MultiplayerSpawner = $LearnerSpawner

## Host-owned on the server; guests restore snapshots into their copy and never write.
var _room: RoomState
## peer_id → the id RoomState keys this player by (Steam id, or the peer id under ENet).
var _steam_id_of: Dictionary = {}


func _ready() -> void:
	if not SteamClient.is_running():
		# Deferred: at boot the root is still adding this scene, so a direct change_scene fails
		# to remove it and prints an error. The swap still lands before the first frame draws.
		get_tree().change_scene_to_packed.call_deferred(STEAM_NOT_RUNNING_SCENE)
		return
	music.play()
	_add_room_collision()
	learner_spawner.spawn_function = _spawn_learner
	Transport.became_ready.connect(_on_transport_ready, CONNECT_ONE_SHOT)
	if Transport.is_ready():
		_on_transport_ready()


func _on_transport_ready() -> void:
	_room = RoomState.new(RoomState.min_players_from_args(OS.get_cmdline_user_args()))
	print("WaitingRoom: the room waits for %d" % _room.min_players)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	if multiplayer.is_server():
		_accept_player(multiplayer.get_unique_id(), SteamClient.steam_id, SteamClient.persona_name)
		return
	_report_identity.rpc_id(1, SteamClient.steam_id, SteamClient.persona_name)


func _on_peer_connected(peer_id: int) -> void:
	if multiplayer.is_server():
		print("WaitingRoom: peer %d connected" % peer_id)


func _on_peer_disconnected(peer_id: int) -> void:
	if not multiplayer.is_server():
		return
	var steam_id: int = _steam_id_of.get(peer_id, 0)
	if steam_id == 0:
		return
	_room.leave(steam_id)
	_steam_id_of.erase(peer_id)
	var learner := learner_spawner.get_node_or_null("Learner_%d" % peer_id)
	if learner != null:
		learner.queue_free()
	print("WaitingRoom: peer %d left; %d in the room" % [peer_id, _room.player_count()])
	_replicate()


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
	learner_spawner.spawn({
		"peer_id": peer_id,
		"palette": occupant.palette,
		"display_name": occupant.display_name,
	})
	print("WaitingRoom: %s arrived as palette %02d (%d of 3)" % [
		occupant.display_name, occupant.palette, _room.player_count(),
	])
	_replicate()


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


func _replicate() -> void:
	if not multiplayer.is_server():
		return
	_receive_state.rpc(_room.snapshot())


@rpc("authority", "call_remote", "reliable")
func _receive_state(data: Dictionary) -> void:
	if _room == null:
		_room = RoomState.new()
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


func _spawn_learner(data: Variant) -> Node:
	var peer_id: int = data["peer_id"]
	var learner: Learner = LEARNER_SCENE.instantiate()
	learner.name = "Learner_%d" % peer_id
	learner.set_multiplayer_authority(peer_id)
	learner.apply_palette(int(data["palette"]))
	learner.set_display_name(String(data["display_name"]))
	learner.set_local(peer_id == multiplayer.get_unique_id())
	_place_at_entrance(learner, int(data["palette"]))
	print("WaitingRoom: spawned %s palette %02d local=%s" % [
		learner.name, int(data["palette"]), learner.is_local(),
	])
	return learner


func _place_at_entrance(learner: Learner, palette: int) -> void:
	# AttachmentPoints/Entrance, not the GLB's Entrance frame group of the same name.
	var entrance := kit.get_node_or_null("AttachmentPoints/Entrance") as Marker3D
	if entrance == null:
		push_error("Waiting room kit has no Entrance marker")
		return
	var offset := Vector3((palette - 2) * ENTRANCE_SPACING, 0.0, 0.0)
	learner.position = entrance.global_position + offset
	var into_room := -entrance.global_transform.basis.z
	into_room.y = 0.0
	if into_room.length_squared() > 0.0001:
		learner.basis = Basis.looking_at(into_room.normalized(), Vector3.UP)


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

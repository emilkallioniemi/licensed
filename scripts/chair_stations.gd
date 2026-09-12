class_name ChairStations
extends Node3D
## The three chairs as stations: sit is the ready-up. Renders occupancy from the
## host-owned room state and never writes it. E sits through `WaitingRoom.submit_command`;
## E or a movement key stands.

## Spec copy table: station prompts, two spaces, signage register.
const SIT_PROMPT := "E  Sit"
## Volume around each chair's approach marker, metres. Sized so the three do not overlap
## and a seated capsule on the footprint sits just outside the zone.
const ZONE_SIZE := Vector3(1.4, 2.2, 1.05)
## World height of the prompt above the chair origin.
const PROMPT_HEIGHT := 1.65

var _stations: Array[Station] = []
var _chairs: Array[Node3D] = []
## Palette currently flooding each chair, 0 when the kit material shows.
var _flooded: Array[int] = [0, 0, 0]
## Palette → chair while that learner is seated, so a stand still knows which approach to use.
var _sat_in: Dictionary = {}
var _waiting: WaitingRoom


func _ready() -> void:
	_waiting = get_parent() as WaitingRoom
	_waiting.room_changed.connect(_on_room_changed)
	_build(_waiting.get_node("Kit") as Node3D)
	set_process_unhandled_input(true)


func _build(kit: Node3D) -> void:
	for n in range(1, 4):
		var approach := kit.get_node_or_null("AttachmentPoints/Chair%02dApproach" % n) as Marker3D
		var chair := kit.find_child("Chair%02d" % n, true, false) as Node3D
		if approach == null or chair == null:
			push_error("Waiting room kit has no chair %02d approach or group" % n)
			continue
		var station := Station.new()
		station.name = "Chair%02d" % n
		add_child(station)
		station.global_position = approach.global_position
		station.setup(SIT_PROMPT, chair.global_position + Vector3(0.0, PROMPT_HEIGHT, 0.0), ZONE_SIZE)
		station.used.connect(_on_sit.bind(n))
		_stations.append(station)
		_chairs.append(chair)


func _on_sit(chair: int) -> void:
	_waiting.submit_command(&"sit", chair)


func _unhandled_input(event: InputEvent) -> void:
	if not _local_is_seated():
		return
	if event is InputEventKey:
		var key := event as InputEventKey
		if not key.pressed or key.echo:
			return
		match key.physical_keycode:
			KEY_E, KEY_W, KEY_A, KEY_S, KEY_D:
				_waiting.submit_command(&"stand")
				get_viewport().set_input_as_handled()


func _on_room_changed() -> void:
	var room := _waiting.room_state()
	if room == null:
		return
	_sync_floods(room)
	var local_seated := false
	for learner in _learners():
		var occupant := _occupant_of(room, learner)
		var chair := 0 if occupant == null else occupant.chair
		if learner.is_local():
			local_seated = chair != 0
		_sync_learner(learner, chair)
	for station in _stations:
		station.set_listening(not local_seated)


func _sync_floods(room: RoomState) -> void:
	var occupant_of: Array[int] = [0, 0, 0]
	for occupant in room.players:
		if occupant.is_seated() and occupant.chair >= 1 and occupant.chair <= 3:
			occupant_of[occupant.chair - 1] = occupant.palette
	for i in 3:
		if occupant_of[i] == _flooded[i]:
			continue
		_flooded[i] = occupant_of[i]
		if occupant_of[i] == 0:
			_apply_flood(_chairs[i], null)
		else:
			var mat := StandardMaterial3D.new()
			mat.albedo_color = Palettes.flood_color(occupant_of[i])
			_apply_flood(_chairs[i], mat)


func _apply_flood(chair: Node3D, mat: Material) -> void:
	for node in chair.find_children("*", "MeshInstance3D", true, false):
		(node as MeshInstance3D).material_override = mat


func _sync_learner(learner: Learner, chair: int) -> void:
	var palette := learner.palette()
	if chair == 0:
		if learner.is_seated():
			var was: int = int(_sat_in.get(palette, 0))
			if learner.is_local() and was >= 1 and was <= _stations.size():
				var approach := _stations[was - 1]
				learner.global_position = Vector3(approach.global_position.x, 0.0, approach.global_position.z)
				learner.velocity = Vector3.ZERO
			learner.set_seated(false)
		_sat_in.erase(palette)
		return
	_sat_in[palette] = chair
	if not learner.is_seated():
		_place_on_chair(learner, chair)
		learner.set_seated(true)


func _place_on_chair(learner: Learner, chair: int) -> void:
	var prop := _chairs[chair - 1]
	var pitch := 0.0
	if learner.camera != null:
		pitch = learner.camera.rotation.x
	learner.global_position = prop.global_position
	var facing := prop.global_transform.basis.z
	facing.y = 0.0
	if facing.length_squared() > 0.0001:
		learner.basis = Basis.looking_at(facing.normalized(), Vector3.UP)
	if learner.camera != null:
		learner.camera.rotation.x = pitch
	learner.velocity = Vector3.ZERO


func _local_is_seated() -> bool:
	var room := _waiting.room_state()
	if room == null:
		return false
	for learner in _learners():
		if learner.is_local():
			var occupant := _occupant_of(room, learner)
			return occupant != null and occupant.is_seated()
	return false


func _occupant_of(room: RoomState, learner: Learner) -> RoomState.Player:
	for occupant in room.players:
		if occupant.palette == learner.palette():
			return occupant
	return null


func _learners() -> Array[Learner]:
	var found: Array[Learner] = []
	var spawner := _waiting.get_node("LearnerSpawner")
	for child in spawner.get_children():
		if child is Learner:
			found.append(child)
	return found

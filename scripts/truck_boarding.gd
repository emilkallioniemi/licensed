class_name TruckBoarding
extends Node
## Host world and sequenced intentions. Snapshots are complete recovery points.
const STEP := 1.0 / 60.0
const FRESHNESS := 0.35
var room: WaitingRoom
var truck: MonsterTruck
var active := false
var sequence := 0
var interaction_sequence := 0
var snapshot_sequence := 0
var received_snapshot := 0
var pending: Array[Dictionary] = []
var inputs: Dictionary = {}
var ages: Dictionary = {}
var acknowledged: Dictionary = {}
var tick_count := 0
var test_intention: Dictionary = {}
var correction_count := 0
var queued_snapshot: Dictionary = {}
var _local_control: StringName = &""
var action_sequence := 0
var pending_actions: Array[Dictionary] = []
var driving_armed := false
var hint_time := 0.0
var release_pending := false
var recovery := TruckRecovery.new()
var diagnostics: Node

func _ready() -> void:
	if OS.get_cmdline_user_args().has("--checkpoint-diagnostics"):
		diagnostics = load("res://scripts/checkpoint_diagnostics.gd").new()
		diagnostics.name = "CheckpointDiagnostics"
		add_child(diagnostics)

func start(owner_room: WaitingRoom) -> void:
	room = owner_room
	truck = get_parent().truck
	active = true
	sequence = 0
	interaction_sequence = 0
	snapshot_sequence = 0
	received_snapshot = 0
	pending.clear()
	inputs.clear()
	ages.clear()
	acknowledged.clear()
	queued_snapshot.clear()
	_local_control = &""
	action_sequence = 0
	pending_actions.clear()
	driving_armed = false
	release_pending = false
	get_parent().announce_arrival()
	truck.body.transform = Transform3D.IDENTITY
	truck.motion = Vector3.ZERO
	truck.angular_motion = 0.0
	truck.vertical_speed = 0.0
	truck.visuals.transform = Transform3D.IDENTITY
	for learner in room._learners():
		learner.set_truck_movement(true)

func stop() -> void:
	active = false
	truck.engine.stop()
	truck.impact.stop()
	get_parent().examiner_audio.stop()
	if room != null:
		for learner in room._learners():
			learner.set_truck_movement(false)

func _unhandled_input(event: InputEvent) -> void:
	if active and event is InputEventKey and event.pressed and not event.echo:
		var state: AttemptState = room.room_state().attempt
		var player_id: int = room.player_id_for_peer(multiplayer.get_unique_id())
		var control := state.control_of(player_id)
		if event.physical_keycode == KEY_H and control != &"":
			hint_time = 6.0
		if control == &"pedals" and driving_armed and event.physical_keycode in [KEY_R, KEY_SPACE]:
			action_sequence += 1
			var action: StringName = &"direction" if event.physical_keycode == KEY_R else &"parking"
			var generation: int = state.generations.get(player_id, 0)
			if multiplayer.is_server():
				_accept_action(multiplayer.get_unique_id(), state.id, action_sequence, generation, action)
			else:
				_action.rpc_id(1, state.id, action_sequence, generation, action)
				pending_actions.append({"sequence": action_sequence, "generation": generation, "action": action})
				state.driving_action(player_id, state.id, action_sequence, generation, action)
			get_viewport().set_input_as_handled()
	if active and event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_E:
		interact()
		get_viewport().set_input_as_handled()

func interact() -> void:
	var learner := room._learner_of(multiplayer.get_unique_id())
	if learner == null:
		return
	interaction_sequence += 1
	var player_id: int = room.player_id_for_peer(multiplayer.get_unique_id())
	var control := room.room_state().attempt.control_of(player_id)
	if control == &"":
		var nearest := AttemptState.CONTROL_REACH
		var at := truck.body.to_local(learner.global_position)
		for candidate in AttemptState.CONTROLS:
			var distance: float = at.distance_to(AttemptState.CONTROLS[candidate])
			if distance < nearest:
				nearest = distance
				control = candidate
	else:
		control = &""
		release_pending = true
		driving_armed = false
		room.room_state().attempt.neutralize_driving(player_id)
	get_parent().show_own_role("Releasing control..." if control == &"" else "Taking control...")
	if multiplayer.is_server():
		_accept_interaction(multiplayer.get_unique_id(), room.room_state().attempt.id, interaction_sequence, control)
	else:
		_interaction.rpc_id(1, room.room_state().attempt.id, interaction_sequence, control)

@rpc("any_peer", "call_remote", "reliable", 1)
func _interaction(attempt_id: String, seq: int, control: StringName) -> void:
	if multiplayer.is_server():
		_accept_interaction(multiplayer.get_remote_sender_id(), attempt_id, seq, control)

func _accept_interaction(peer_id: int, attempt_id: String, seq: int, control: StringName) -> void:
	if not active:
		return
	var learner := room._learner_of(peer_id)
	if learner == null:
		return
	var state: AttemptState = room.room_state().attempt
	var player_id: int = room.player_id_for_peer(peer_id)
	state.observe_learner(player_id, truck.body.to_local(learner.global_position))
	var old_control := state.control_of(player_id)
	var accepted := state.release_control(player_id, attempt_id, seq) if control == &"" else state.request_control(player_id, attempt_id, seq, control)
	if accepted:
		inputs.erase(peer_id)
		if control == &"":
			learner.global_position = truck.body.to_global(AttemptState.CONTROLS[old_control] + Vector3(-0.85 if old_control == &"pedals" else 0.85, 0.05, 0))
		else:
			learner.rotation.y = truck.body.global_rotation.y + (PI if control == &"rear" else 0.0)
		learner.support = &"truck"
		learner.support_pose = truck.body.global_transform
	_send_snapshot(true)

func _physics_process(_delta: float) -> void:
	if not active or room.room_state().attempt.phase not in [&"active", &"aftermath", &"settled"]:
		return
	if not queued_snapshot.is_empty():
		_apply_snapshot(queued_snapshot)
		queued_snapshot = {}
	if room.room_state().attempt.phase != &"active":
		if multiplayer.is_server():
			var previous := truck.body.global_transform
			advance_truck()
			for learner in room._learners():
				_simulate(learner, {}, previous)
			_send_snapshot(false)
		return
	var local := room._learner_of(multiplayer.get_unique_id())
	if local == null:
		return
	sequence += 1
	var command := local.walk_intention()
	var state: AttemptState = room.room_state().attempt
	var player_id: int = room.player_id_for_peer(multiplayer.get_unique_id())
	var control := state.control_of(player_id)
	if control != _local_control:
		driving_armed = false
		hint_time = 6.0
		_local_control = control
	if control == &"":
		release_pending = false
	if not driving_armed and not release_pending:
		driving_armed = not (Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_SPACE) or Input.is_physical_key_pressed(KEY_R))
	command["steer"] = float(Input.is_physical_key_pressed(KEY_D)) - float(Input.is_physical_key_pressed(KEY_A)) if driving_armed else 0.0
	command["throttle"] = driving_armed and Input.is_physical_key_pressed(KEY_W)
	command["brake"] = driving_armed and Input.is_physical_key_pressed(KEY_S)
	if not test_intention.is_empty():
		command = test_intention.duplicate()
	command["sequence"] = sequence
	command["generation"] = room.room_state().attempt.generations.get(room.player_id_for_peer(multiplayer.get_unique_id()), 0)
	if multiplayer.is_server():
		_accept_input(multiplayer.get_unique_id(), room.room_state().attempt.id, command)
	else:
		if diagnostics != null:
			diagnostics.command_sent(sequence)
		_walk.rpc_id(1, room.room_state().attempt.id, command)
		state.drive(player_id, state.id, sequence, command.generation, command)
		pending.append(command)
		if pending.size() > 120:
			pending.pop_front()
	var previous := truck.body.global_transform
	advance_truck()
	hint_time = maxf(0.0, hint_time - STEP)
	_present_controls()
	if multiplayer.is_server():
		for learner in room._learners():
			var peer_id := learner.get_multiplayer_authority()
			ages[peer_id] = ages.get(peer_id, 0.0) + STEP
			var intention: Dictionary = inputs.get(peer_id, {})
			if ages[peer_id] > FRESHNESS:
				intention = {}
			_simulate(learner, intention, previous)
			if not intention.is_empty():
				acknowledged[peer_id] = intention.sequence
				# Jump is an edge; held walking is repeatedly transmitted.
				inputs[peer_id]["jump"] = false
		tick_count += 1
		if tick_count % 3 == 0:
			_send_snapshot(false)
	else:
		_simulate(local, command, previous)

func _simulate(learner: Learner, command: Dictionary, previous: Transform3D) -> void:
	var player_id: int = room.player_id_for_peer(learner.get_multiplayer_authority())
	recovery.simulate(learner, command, truck, previous, room.room_state().attempt, player_id, STEP, multiplayer.is_server())

@rpc("any_peer", "call_remote", "unreliable", 2)
func _walk(attempt_id: String, command: Dictionary) -> void:
	if multiplayer.is_server():
		_accept_input(multiplayer.get_remote_sender_id(), attempt_id, command)

func _accept_input(peer_id: int, attempt_id: String, command: Dictionary) -> void:
	if not active or attempt_id != room.room_state().attempt.id or room.player_id_for_peer(peer_id) == 0:
		return
	var player_id: int = room.player_id_for_peer(peer_id)
	if command.get("generation", -1) != room.room_state().attempt.generations.get(player_id, 0):
		return
	var seq: int = command.get("sequence", 0)
	if seq <= acknowledged.get(peer_id, 0) or seq <= inputs.get(peer_id, {}).get("sequence", 0):
		return
	var wish: Vector2 = command.get("wish", Vector2.ZERO)
	var yaw: float = command.get("yaw", 0.0)
	if not wish.is_finite() or not is_finite(yaw):
		return
	inputs[peer_id] = {"sequence": seq, "wish": wish.limit_length(), "yaw": yaw, "jump": command.get("jump", false) == true, "sprint": command.get("sprint", false) == true}
	ages[peer_id] = 0.0
	room.room_state().attempt.drive(player_id, attempt_id, seq, command.generation, command)

@rpc("any_peer", "call_remote", "reliable", 1)
func _action(attempt_id: String, seq: int, generation: int, action: StringName) -> void:
	if multiplayer.is_server():
		_accept_action(multiplayer.get_remote_sender_id(), attempt_id, seq, generation, action)

func _accept_action(peer_id: int, attempt_id: String, seq: int, generation: int, action: StringName) -> void:
	if not active:
		return
	room.room_state().attempt.driving_action(room.player_id_for_peer(peer_id), attempt_id, seq, generation, action)
	_send_snapshot(true)

func advance_truck(present := true) -> void:
	var state: AttemptState = room.room_state().attempt
	state.advance_driving(STEP)
	truck.drive(state, STEP, present)

func _send_snapshot(reliable: bool) -> void:
	snapshot_sequence += 1
	var learners := {}
	for learner in room._learners():
		var peer_id := learner.get_multiplayer_authority()
		learners[peer_id] = learner.truck_snapshot()
		learners[peer_id]["ack"] = acknowledged.get(peer_id, 0)
	var data := {"attempt": room.room_state().attempt.id, "sequence": snapshot_sequence, "truck": truck.body.global_transform, "motion": truck.motion, "angular": truck.angular_motion, "vertical": truck.vertical_speed, "recovery": room.room_state().attempt.recovery_snapshot(), "learners": learners, "operators": room.room_state().attempt.operators.duplicate(), "generations": room.room_state().attempt.generations.duplicate()}
	data["driving"] = room.room_state().attempt.driving_snapshot()
	data["remaining"] = room.room_state().attempt.remaining
	if reliable:
		_control_snapshot.rpc(var_to_bytes(data).compress(FileAccess.COMPRESSION_DEFLATE))
	else:
		_world_snapshot.rpc(var_to_bytes(data).compress(FileAccess.COMPRESSION_DEFLATE))
	_present_controls()

@rpc("authority", "call_remote", "reliable", 1)
func _control_snapshot(data: PackedByteArray) -> void:
	_decode_snapshot(data)

@rpc("authority", "call_remote", "unreliable", 3)
func _world_snapshot(data: PackedByteArray) -> void:
	_decode_snapshot(data)

func _decode_snapshot(data: PackedByteArray) -> void:
	if data.size() > 8192 or data.is_empty():
		return
	var unpacked := data.decompress_dynamic(65536, FileAccess.COMPRESSION_DEFLATE)
	if unpacked.size() < 4:
		return
	var decoded: Variant = bytes_to_var(unpacked)
	if decoded is Dictionary:
		_receive_snapshot(decoded)

func _receive_snapshot(data: Dictionary) -> void:
	if not active or data.attempt != room.room_state().attempt.id or data.sequence <= received_snapshot:
		return
	received_snapshot = data.sequence
	queued_snapshot = data

func _apply_snapshot(data: Dictionary) -> void:
	var local := room._learner_of(multiplayer.get_unique_id())
	var visible_position := local.global_position
	var visible_truck := truck.visuals.global_transform
	var local_yaw := local.rotation.y
	var player_id: int = room.player_id_for_peer(multiplayer.get_unique_id())
	var prior_control := _local_control
	room.room_state().attempt.operators = data.operators.duplicate()
	room.room_state().attempt.generations = data.generations.duplicate()
	room.room_state().attempt.restore_driving(data.driving)
	room.room_state().attempt.restore_recovery(data.recovery)
	room.room_state().attempt.remaining = data.remaining
	var action_ack: int = data.driving.toggles.get(player_id, 0)
	while not pending_actions.is_empty() and pending_actions[0].sequence <= action_ack:
		pending_actions.pop_front()
	for action in pending_actions:
		room.room_state().attempt.driving_action(player_id, data.attempt, action.sequence, action.generation, action.action)
	truck.body.global_transform = data.truck
	truck.motion = data.motion
	truck.angular_motion = data.angular
	truck.vertical_speed = data.vertical
	var confirmed_control := room.room_state().attempt.control_of(player_id)
	_local_control = confirmed_control
	if confirmed_control != &"" and prior_control != confirmed_control:
		driving_armed = false
		hint_time = 6.0
		local_yaw = truck.body.global_rotation.y + (PI if confirmed_control == &"rear" else 0.0)
	for peer_id in data.learners:
		var learner := room._learner_of(peer_id)
		if learner != null:
			learner.restore_truck_snapshot(data.learners[peer_id], data.truck)
	var ack: int = data.learners.get(multiplayer.get_unique_id(), {}).get("ack", 0)
	while not pending.is_empty() and pending[0].sequence <= ack:
		pending.pop_front()
	for command in pending:
		var previous := truck.body.global_transform
		var valid_generation: bool = command.generation == data.generations.get(player_id, 0)
		if valid_generation:
			room.room_state().attempt.drive(player_id, data.attempt, command.sequence, command.generation, command)
		advance_truck(false)
		_simulate(local, command if valid_generation else {}, previous)
	local.rotation.y = local_yaw
	var error := visible_position - local.global_position
	if error.length() > 1.5:
		correction_count += 1
	if diagnostics != null:
		diagnostics.reconciled(ack, error.length())
	local.smooth_truck_correction(error)
	truck.smooth_correction(visible_truck)
	# Remote supported bodies share the predicted truck frame as well.
	for learner in room._learners():
		if learner != local and learner.support == &"truck":
			var relative: Transform3D = learner.support_pose.affine_inverse() * learner.global_transform
			learner.global_transform = truck.body.global_transform * relative
			learner.support_pose = truck.body.global_transform
	_present_controls()

func _present_controls() -> void:
	var player_id: int = room.player_id_for_peer(multiplayer.get_unique_id())
	var control := room.room_state().attempt.control_of(player_id)
	var copy := ""
	if control != &"" and hint_time > 0.0:
		copy = "W · Throttle   S · Service brake   R · Forward/reverse (stopped)   Space · Parking brake" if control == &"pedals" else "A / D · Axle left / right (truck-relative; angle holds)"
		copy += "\nE · Leave control   H · Show bindings"
		if control == &"pedals":
			copy += "\nPedals below: W throttle / S brake"
	truck.highlight(control, hint_time > 0.0)
	get_parent().show_own_role(copy)

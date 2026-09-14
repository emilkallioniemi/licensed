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
	truck.reset_presentation()
	for learner in room._learners():
		learner.set_truck_movement(true)

func stop() -> void:
	active = false
	truck.sound.reset()
	get_parent().examiner_audio.stop()
	if room != null:
		for learner in room._learners():
			learner.set_truck_movement(false)

func _unhandled_input(event: InputEvent) -> void:
	if active and event is InputEventKey and event.pressed and not event.echo:
		var state: AttemptState = room.room_state().attempt
		var player_id: int = room.player_id_for_peer(multiplayer.get_unique_id())
		var control := state.control_of(player_id)
		if control != &"" and event.physical_keycode in [KEY_1, KEY_2, KEY_3, KEY_Y, KEY_N]:
			interaction_sequence += 1
			var target := &""
			var requester := 0
			var request_sequence := 0
			if event.physical_keycode in [KEY_1, KEY_2, KEY_3]:
				target = [&"front", &"pedals", &"rear"][event.physical_keycode - KEY_1]
			else:
				for asking in state.swaps:
					if state.swaps[asking].other == player_id:
						requester = asking
						request_sequence = state.swaps[asking].sequence
			if multiplayer.is_server():
				_accept_swap(multiplayer.get_unique_id(), state.id, interaction_sequence, target, requester, event.physical_keycode == KEY_Y, request_sequence)
			else:
				_swap.rpc_id(1, state.id, interaction_sequence, target, requester, event.physical_keycode == KEY_Y, request_sequence)
		if event.physical_keycode == KEY_H and control != &"":
			hint_time = 6.0
	if active and event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_E:
		interact()
		get_viewport().set_input_as_handled()


func _nearest_control(at: Vector3) -> StringName:
	var learner := room._learner_of(multiplayer.get_unique_id())
	if learner == null:
		return &""
	var best := 0.80
	var chosen := &""
	for candidate in AttemptState.CONTROLS:
		if room.room_state().attempt.operators.has(candidate):
			continue
		var seat: Vector3 = truck.body.to_global(AttemptState.CONTROLS[candidate])
		if seat.distance_to(at) > AttemptState.CONTROL_REACH:
			continue
		var aim := -learner.camera.global_basis.z
		var score := aim.dot((seat + Vector3.UP * 0.5 - learner.camera.global_position).normalized())
		if score > best:
			best = score
			chosen = candidate
	return chosen

func interact() -> void:
	var learner := room._learner_of(multiplayer.get_unique_id())
	if learner == null:
		return
	interaction_sequence += 1
	var player_id: int = room.player_id_for_peer(multiplayer.get_unique_id())
	var control := room.room_state().attempt.control_of(player_id)
	if control == &"":
		control = _nearest_control(learner.global_position)
		if control == &"":
			get_parent().show_own_role("Move to a seat first")
			return
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
		else:
			truck.present_state(room.room_state().attempt, STEP)
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
		driving_armed = not (Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_D))
	command["recover"] = Input.is_physical_key_pressed(KEY_R)
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
	var pitch: float = command.get("pitch", 0.0)
	if not wish.is_finite() or not is_finite(yaw) or not is_finite(pitch):
		return
	inputs[peer_id] = {"sequence": seq, "wish": wish.limit_length(), "yaw": yaw, "pitch": clampf(pitch, -Learner.PITCH_LIMIT, Learner.PITCH_LIMIT), "recover": command.get("recover", false) == true, "climb": command.get("climb", false) == true, "jump": command.get("jump", false) == true, "sprint": command.get("sprint", false) == true}
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
	if multiplayer.is_server() and state.phase == &"active":
		if _advance_recovery(state):
			return
		get_parent().observe_cones(state)
		state.observe_course(get_parent().global_transform.affine_inverse() * truck.body.global_transform, STEP)

func _send_snapshot(reliable: bool) -> void:
	snapshot_sequence += 1
	var learners := {}
	for learner in room._learners():
		var peer_id := learner.get_multiplayer_authority()
		learners[peer_id] = learner.truck_snapshot()
		learners[peer_id]["ack"] = acknowledged.get(peer_id, 0)
	var data := {"attempt": room.room_state().attempt.id, "sequence": snapshot_sequence, "truck": truck.body.global_transform, "motion": truck.motion, "angular": truck.angular_motion, "vertical": truck.vertical_speed, "recovery": room.room_state().attempt.recovery_snapshot(), "learners": learners, "operators": room.room_state().attempt.operators.duplicate(), "generations": room.room_state().attempt.generations.duplicate()}
	data["driving"] = room.room_state().attempt.driving_snapshot()
	data["course"] = room.room_state().attempt.course_snapshot()
	data["swaps"] = room.room_state().attempt.swaps.duplicate(true)
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
	room.room_state().attempt.restore_course(data.get("course", {}))
	room.room_state().attempt.remaining = data.remaining
	room.room_state().attempt.swaps = data.get("swaps", {}).duplicate(true)
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
	var local := room._learner_of(multiplayer.get_unique_id())
	if local == null:
		return
	var control := room.room_state().attempt.control_of(player_id)
	var hinted_control := control
	if control == &"":
		hinted_control = _nearest_control(local.global_position)
	var copy := "Hold SPACE and walk against the truck to climb. Aim at a seat; E to sit."
	if control != &"":
		match control:
			&"front": copy = "STEERING — A / D turn left / right. The wheel holds its angle."
			&"pedals": copy = "SPEED — W forward. S brake, then reverse. Release to slow down."
			&"rear": copy = "BALANCE — A / D lean left / right. W / S lean forward / back."
		copy += "\nE leave seat. Stop to swap: 1 steering / 2 speed / 3 balance."
	elif hinted_control != &"":
		copy = "E · Sit — " + str(hinted_control).replace("front", "steering").replace("pedals", "speed").replace("rear", "balance")
	for requester in room.room_state().attempt.swaps:
		var request: Dictionary = room.room_state().attempt.swaps[requester]
		if request.other == player_id:
			copy += "\nSwap requested — Y accept / N decline."
		elif requester == player_id:
			copy += "\nWaiting for your friend's agreement."
	truck.highlight(hinted_control, hinted_control != &"")
	get_parent().show_own_role(copy)


func _process(_delta: float) -> void:
	if not active or room == null:
		return
	var state: AttemptState = room.room_state().attempt
	for learner in room._learners():
		var control := state.control_of(room.player_id_for_peer(learner.get_multiplayer_authority()))
		var contacts := {}
		if control == &"front":
			var wheel: Node3D = truck.visuals.wheels["Front" if control == &"front" else "Rear"]
			# Left/right are the learner's anatomical sides, reversed at rear.
			var side := -1.0 if control == &"front" else 1.0
			# Let the rim slide through a small regrip arc instead of following a
			# spoke below the learner's reachable arm length at full steering lock.
			var grip_basis := wheel.global_basis * Basis(Vector3.BACK, -wheel.rotation.z + sin(wheel.rotation.z * 2.0) * 0.20)
			contacts.LeftHand = wheel.global_position + grip_basis * Vector3(-0.285 * side, 0, 0)
			contacts.RightHand = wheel.global_position + grip_basis * Vector3(0.285 * side, 0, 0)
		elif control == &"pedals":
			var throttle: Node3D = truck.visuals.pivots["ThrottlePedal"]
			var brake: Node3D = truck.visuals.pivots["BrakePedal"]
			contacts.LeftFoot = throttle.to_global(Vector3(0, 0.23, 0.08))
			contacts.RightFoot = brake.to_global(Vector3(0, 0.23, 0.08))
		learner.balance_pose = state.balance
		learner.present_control(control, truck.visuals, contacts)

@rpc("any_peer", "call_remote", "reliable", 1)
func _swap(attempt_id: String, seq: int, target: StringName, requester: int, accept: bool, request_sequence: int = 0) -> void:
	if multiplayer.is_server():
		_accept_swap(multiplayer.get_remote_sender_id(), attempt_id, seq, target, requester, accept, request_sequence)

func _accept_swap(peer_id: int, attempt_id: String, seq: int, target: StringName, requester: int, accept: bool, request_sequence: int = 0) -> void:
	if not active:
		return
	var state: AttemptState = room.room_state().attempt
	var player_id: int = room.player_id_for_peer(peer_id)
	if target != &"":
		state.request_swap(player_id, attempt_id, seq, target)
	else:
		state.answer_swap(player_id, attempt_id, seq, requester, accept, request_sequence)
	_send_snapshot(true)

func _advance_recovery(state: AttemptState) -> bool:
	var at: Vector3 = get_parent().to_local(truck.body.global_position)
	var overturned := truck.body.global_basis.y.dot(Vector3.UP) < 0.5
	var outside := absf(at.x) > 25.0 or at.z < -33.0 or at.z > 5.0 or at.y < -2.0
	var stranded := false
	for learner in room._learners():
		if learner.movement_mode in [&"trapped", &"crushed", &"ravine"]:
			stranded = true
	var settled := absf(truck.vertical_speed) < 0.5 and absf(state.speed) < 0.3
	state.recovery_available = outside or stranded or (overturned and settled)
	var held := false
	for peer_id in inputs:
		if ages.get(peer_id, INF) < FRESHNESS and inputs[peer_id].get("recover", false):
			held = true
	if not state.recovery_available or not held:
		state.recovery_elapsed = 0.0
		return false
	state.recovery_elapsed += STEP
	if state.recovery_elapsed < 2.0:
		return false
	# Authored flat recovery pads, nearest safe pad first; test actual hull space.
	var pads := [Vector3(0, 0, -9), Vector3(6, 0, -24), Vector3(22, 0, -24), Vector3(17, 0, -10)]
	pads.sort_custom(func(a: Vector3, b: Vector3): return a.distance_squared_to(at) < b.distance_squared_to(at))
	for pad in pads:
		var pose := Transform3D(Basis.IDENTITY, get_parent().to_global(pad))
		var query := PhysicsShapeQueryParameters3D.new()
		var hull := BoxShape3D.new()
		hull.size = Vector3(6.8, 4.8, 7.4)
		query.shape = hull
		query.transform = pose.translated_local(Vector3.UP * 2.5)
		query.collision_mask = 4
		if not truck.get_world_3d().direct_space_state.intersect_shape(query, 1).is_empty():
			continue
		truck.body.global_transform = pose
		truck.motion = Vector3.ZERO
		truck.angular_motion = 0.0
		truck.vertical_speed = 0.0
		state.record_recovery()
		inputs.clear()
		pending.clear()
		driving_armed = false
		var index := 0
		for learner in room._learners():
			var player_id: int = room.player_id_for_peer(learner.get_multiplayer_authority())
			learner.apply_recovery(&"independent")
			state.accident_states.erase(player_id)
			var control := state.control_of(player_id)
			learner.global_position = pose * (AttemptState.CONTROLS[control] if control != &"" else Vector3(-4.0, 0.1, index * 2.0 - 2.0))
			learner.support_pose = pose
			learner.support = &"truck" if control != &"" else &""
			if control != &"":
				learner.simulate_truck_walk({}, truck.body, pose, control, STEP)
			index += 1
		_send_snapshot(true)
		return true
	return false

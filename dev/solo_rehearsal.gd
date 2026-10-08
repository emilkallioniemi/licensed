extends WaitingRoom
## Explicit debug-only fixture. Three recorded seats, no AI or shipping solo mode.
var selected: StringName = &"front"
var combined := true
var recording := false
var replaying := false
var disabled: StringName = &""
var tapes: Dictionary = {&"front": [], &"pedals": []}
var frame := 0
var held_layout := 0
var dev_status: Label
var dev_sequence := 100

func _ready() -> void:
	if not OS.is_debug_build() or not OS.get_cmdline_user_args().has("--rehearsal"):
		get_tree().change_scene_to_file.call_deferred("res://scenes/waiting_room.tscn")
		return
	Transport.kind = &"enet"
	_waiting_environment = world_environment.environment
	_room = RoomState.new()
	_steam_id_of = {1: 1, 2: 2, 3: 3}
	for index in 3:
		_room.arrive(index + 1, "Rehearsal seat %d" % (index + 1))
		var learner := _spawn_learner({"peer_id": index + 1, "palette": index + 1, "display_name": "", "arriving": false})
		learner_spawner.add_child(learner)
	_set_stations_enabled(false)
	escape_overlay.process_mode = Node.PROCESS_MODE_DISABLED
	kit.hide()
	music.stop()
	world_environment.environment = test_area.daylight
	test_area.show()
	_in_test_area = true
	test_area.boarding.room = self
	test_area.boarding.truck = test_area.truck
	test_area.boarding.set_physics_process(false)
	test_area.boarding.set_process(false)
	test_area.boarding.set_process_unhandled_input(false)
	var overlay := CanvasLayer.new()
	overlay.layer = 50
	add_child(overlay)
	dev_status = Label.new()
	dev_status.position = Vector2(750, 210)
	dev_status.add_theme_font_size_override("font_size", 16)
	dev_status.add_theme_constant_override("outline_size", 4)
	overlay.add_child(dev_status)
	reset(true)
	fade.to_clear(0.0)

func reset(new_layout: bool) -> void:
	_room.attempt.begin(&"monster_truck", [1, 2, 3])
	if new_layout:
		held_layout = _room.attempt.route_layout
		tapes = {&"front": [], &"pedals": []}
		replaying = false
	_room.attempt.route_layout = held_layout
	for player in [1, 2, 3]:
		_room.attempt.scene_ready(player, _room.attempt.id)
	for index in 3:
		var role: StringName = [&"front", &"pedals", &"rear"][index]
		_room.attempt.observe_learner(index + 1, AttemptState.CONTROLS[role])
		_room.attempt.request_control(index + 1, _room.attempt.id, 1, role)
	for learner in _learners():
		learner.set_truck_movement(true)
		learner.apply_recovery(&"independent")
	selected = &"front"
	disabled = &""
	frame = 0
	recording = false
	dev_sequence = 100
	test_area.truck.body.transform = Transform3D.IDENTITY
	test_area.truck.vertical_speed = 0.0
	test_area.truck.reset_presentation()
	test_area.announce_arrival()
	test_area._results.hide()

func select(role: StringName) -> void:
	if role == selected or _room.attempt.phase != &"active":
		return
	# Development perspective switch bypasses stopped-only consent. Production
	# swaps still require a stopped truck and another human's acceptance.
	var other: int = _room.attempt.operators[role]
	_room.attempt.operators[selected] = other
	_room.attempt.operators[role] = 1
	for player in [1, other]:
		_room.attempt.neutralize_driving(player)
		_room.attempt.generations[player] += 1
	selected = role
	test_area.report_open = true

func _unhandled_input(event: InputEvent) -> void:
	if not OS.is_debug_build() or dev_status == null:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		match event.physical_keycode:
			KEY_F1: select(&"front")
			KEY_F2: select(&"pedals")
			KEY_F3: select(&"rear")
			KEY_F4: combined = not combined
			KEY_F5:
				if recording:
					recording = false
				else:
					reset(false)
					tapes = {&"front": [], &"pedals": []}
					recording = true
					replaying = false
			KEY_F6:
				reset(false)
				replaying = not replaying
				combined = false
			KEY_F7: disabled = &"" if disabled == selected else selected
			KEY_F8: reset(false)
			KEY_F9: reset(true)
			KEY_F10: save_tapes()
			KEY_F11: load_tapes()
			KEY_F12: toss_passenger()
			KEY_ESCAPE: get_tree().quit()

func toss_passenger() -> void:
	# Debug-only demonstration through the same ejection/snapshot state as play.
	var state: AttemptState = _room.attempt
	var passenger: int = state.operators.get(&"rear", 0)
	if state.phase != &"active" or passenger == 0:
		return
	for learner in _learners():
		if learner.get_multiplayer_authority() != passenger:
			continue
		dev_sequence += 1
		state.release_control(passenger, state.id, dev_sequence)
		learner.global_position = test_area.truck.body.to_global(Vector3(3.8, 4.0, -0.5))
		var impulse := test_area.truck.motion + test_area.truck.body.global_basis * Vector3(5, 6, -2)
		state.observe_accident(passenger, state.id, &"ejected", learner.global_position, impulse)
		learner.apply_recovery(&"independent", impulse)
		learner.pose_grounded = false

func _physics_process(delta: float) -> void:
	if dev_status == null:
		return
	var state: AttemptState = _room.attempt
	var steer := float(Input.is_physical_key_pressed(KEY_D)) - float(Input.is_physical_key_pressed(KEY_A))
	var live := {"steer": steer, "throttle": Input.is_physical_key_pressed(KEY_W), "brake": Input.is_physical_key_pressed(KEY_S)}
	dev_sequence += 1
	for role in [&"front", &"pedals"]:
		var command: Dictionary = live if combined or selected == role else {}
		if replaying and selected != role and frame < tapes[role].size():
			command = tapes[role][frame]
		if disabled == role:
			command = {}
		if recording:
			tapes[role].append(command.duplicate())
		var player: int = state.operators.get(role, 0)
		if player != 0:
			state.drive(player, state.id, dev_sequence, state.generations[player], command)
	var previous := test_area.truck.body.global_transform
	state.advance_driving(delta)
	test_area.truck.drive(state, delta)
	test_area.boarding.inputs = {1: {"recover": Input.is_physical_key_pressed(KEY_R)}}
	test_area.boarding.ages = {1: 0.0}
	if state.phase == &"active" and test_area.to_local(test_area.truck.body.global_position).y > -1:
		test_area.boarding._advance_recovery(state)
	for learner in _learners():
		var player := learner.get_multiplayer_authority()
		test_area.boarding.recovery.simulate(learner, {}, test_area.truck, previous, state, player, delta, true)
	state.observe_course(test_area.global_transform.affine_inverse() * test_area.truck.body.global_transform, delta)
	state.tick(delta)
	test_area.boarding._process(delta)
	test_area.show_own_role("REHEARSAL VIEW · " + ("navigation" if selected == &"rear" else str(selected)))
	if disabled == &"rear":
		test_area.report_open = false
	dev_status.text = "DEVELOPMENT REHEARSAL · one human\nF1 steering / F2 speed / F3 navigator\nF4 combined driving: %s\nF5 record: %s / F6 replay: %s\nF7 disable selected: %s\nF8 restart same track / F9 new track\nF10 save / F11 load recordings\nF12 toss navigator (F8 reset)\nESC quit · Frame %d\n\nW / S speed · A / D steering\nDuring replay, selected role stays live.\nOther driving role uses its recording." % [str(combined), str(recording), str(replaying), str(disabled), frame]
	frame += 1
	if OS.get_cmdline_user_args().has("--rehearsal-smoke") and frame == 120:
		print("PASS: debug rehearsal runs production track, three seats and physics")
		get_tree().quit()

func _process(_delta: float) -> void:
	pass # Fixture ticks its own state; never broadcasts synthetic seats.

func choose_attempt(_choice: StringName) -> void:
	reset(true)

func save_tapes() -> void:
	var file := FileAccess.open("user://dev-navigation-rehearsal.json", FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify({"layout": held_layout, "front": tapes[&"front"], "pedals": tapes[&"pedals"]}))

func load_tapes() -> void:
	var file := FileAccess.open("user://dev-navigation-rehearsal.json", FileAccess.READ)
	if file == null:
		return
	var data: Variant = JSON.parse_string(file.get_as_text())
	if data is Dictionary and data.get("front") is Array and data.get("pedals") is Array:
		held_layout = clampi(int(data.get("layout", 0)), 0, 7)
		reset(false)
		tapes = {&"front": data.front, &"pedals": data.pedals}

extends SceneTree
var failures := 0
func _initialize() -> void:
	call_deferred("verify")
func verify() -> void:
	var room = load("res://dev/solo_rehearsal.tscn").instantiate()
	root.add_child(room)
	await process_frame
	key(room, KEY_F5)
	Input.action_release("jump")
	var w := InputEventKey.new()
	w.physical_keycode = KEY_W
	w.pressed = true
	Input.parse_input_event(w)
	await create_timer(1.0).timeout
	w.pressed = false
	Input.parse_input_event(w)
	key(room, KEY_F5)
	check(room.tapes[&"pedals"].size() > 30, "record captures physical input frames")
	var layout: int = room.held_layout
	key(room, KEY_F6)
	key(room, KEY_F3)
	await create_timer(0.6).timeout
	check(room.room_state().attempt.speed > 1.0, "recorded speed input drives production physics while navigation stays live")
	check(room.test_area.can_read_report(room.room_state().attempt, 1), "navigation perspective has route report during replay")
	key(room, KEY_F2)
	check(not room.test_area.can_read_report(room.room_state().attempt, 1), "switching to speed immediately removes report access")
	key(room, KEY_F7)
	await create_timer(1.5).timeout
	check(room.room_state().attempt.speed < 0.1, "disabling speed contribution releases pedals and stops truck")
	key(room, KEY_F8)
	check(room.room_state().attempt.route_layout == layout and room.frame == 0, "restart keeps recorded route and rewinds frame")
	key(room, KEY_F12)
	check(not room.room_state().attempt.operators.has(&"rear"), "ragdoll demonstration detaches the navigator through real occupancy")
	await create_timer(0.25).timeout
	var ragdoll_count := 0
	for learner in room._learners():
		if is_instance_valid(learner.visual.pose.ragdoll):
			ragdoll_count += 1
	check(ragdoll_count == 1, "F12 produces one physical passenger ragdoll")
	key(room, KEY_F8)
	check(room.room_state().attempt.operators.size() == 3, "rehearsal reset restores all three seats after an ejection")
	# Lose with every passenger below the death plane, then use the actual Retry button.
	room.test_area.truck.body.position.y = -16.0
	for learner in room._learners():
		learner.global_position.y = -14.0
	await create_timer(0.25).timeout
	check(room.room_state().attempt.assessment().get("reason") == &"ravine", "fatal fall produces shared loss")
	room.test_area._retry.pressed.emit()
	await create_timer(0.25).timeout
	check(room.room_state().attempt.phase == &"active", "Retry remains active after recovery simulation")
	for learner in room._learners():
		var role: StringName = room.room_state().attempt.control_of(learner.get_multiplayer_authority())
		check(role != &"", "Retry restores every player's seat")
		if role != &"":
			check(learner.global_position.distance_to(room.test_area.truck.body.to_global(AttemptState.CONTROLS[role])) < 0.1, "Retry returns every player to the truck")
		check(learner.movement_mode == &"occupied" and not is_instance_valid(learner.visual.pose.ragdoll), "Retry clears death and physical ragdolls")
	room.reset(false)
	room.set_physics_process(false)
	room.test_area.truck.body.transform = Transform3D(Basis(Vector3.FORWARD, PI), Vector3(0, 4.93, 0))
	room.test_area.truck.vertical_speed = 0
	room.test_area.boarding.inputs = {1: {"recover": true}}
	room.test_area.boarding.ages = {1: 0.0}
	for frame in 125:
		room.test_area.boarding._advance_recovery(room.room_state().attempt)
	check(room.test_area.truck.body.global_basis.y.dot(Vector3.UP) > 0.99, "held recovery rights a truck resting on its roof")
	room.free()
	print("Solo rehearsal failures: ", failures)
	quit(1 if failures else 0)
func key(room: Node, code: Key) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.pressed = true
	room._unhandled_input(event)
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		printerr("FAIL: ", message)

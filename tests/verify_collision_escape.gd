extends SceneTree
var failures := 0
func _initialize() -> void:
	call_deferred("verify")
func check(ok: bool, label: String) -> void:
	if not ok:
		failures += 1
		printerr("FAIL: ", label)
func verify() -> void:
	var world := Node3D.new()
	root.add_child(world)
	for wall in [false, true]:
		var body := StaticBody3D.new()
		body.collision_layer = 4 if wall else 8
		world.add_child(body)
		var collision := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = Vector3(30, 10, 1) if wall else Vector3(100, 1, 100)
		collision.shape = shape
		body.add_child(collision)
		body.position = Vector3(0, 4, -4.1) if wall else Vector3(0, -0.5, 0)
	var truck := MonsterTruck.new()
	world.add_child(truck)
	var state := AttemptState.new()
	state.begin(&"monster_truck", [1, 2, 3])
	for player in [1, 2, 3]: state.scene_ready(player, state.id)
	state.observe_learner(1, AttemptState.CONTROLS.pedals)
	state.request_control(1, state.id, 1, &"pedals")
	await physics_frame
	# Suspension/rotation can leave the cab hull slightly inside a wall.
	# A reverse step initially remains overlapping, but reduces penetration.
	for frame in 180:
		await physics_frame
		state.drive(1, state.id, frame + 1, 1, {"brake": true})
		state.advance_driving(1.0 / 60)
		truck.drive(state, 1.0 / 60, false)
	check(truck.body.position.z > 2, "reverse escapes a shallow existing collision")
	truck.body.transform = Transform3D.IDENTITY
	truck.vertical_speed = 0
	truck.reset_presentation()
	state.speed = 0
	for frame in 60:
		await physics_frame
		state.drive(1, state.id, frame + 181, 1, {"throttle": true})
		state.advance_driving(1.0 / 60)
		truck.drive(state, 1.0 / 60, false)
	check(truck.body.position.z >= -0.001, "forward cannot drive deeper into an existing collision")
	world.free()
	print("Collision escape failures: ", failures)
	quit(1 if failures else 0)

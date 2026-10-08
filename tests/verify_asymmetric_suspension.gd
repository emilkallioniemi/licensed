extends SceneTree
var failures := 0
func _initialize() -> void:
	call_deferred("verify")
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		printerr("FAIL: ", message)
func verify() -> void:
	var world := Node3D.new()
	root.add_child(world)
	var ground := StaticBody3D.new()
	ground.collision_layer = 8
	world.add_child(ground)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(2, 1, 8)
	collision.shape = shape
	ground.add_child(collision)
	ground.position = Vector3(2.4, -0.1, 0)
	var truck := MonsterTruck.new()
	world.add_child(truck)
	var state := AttemptState.new()
	await physics_frame
	# Only the right tyres contact a raised wreck-sized surface.
	for frame in 10:
		await physics_frame
		truck.drive(state, 1.0 / 60, false)
	print("Right-side impact roll: ", truck.body.rotation.z)
	check(truck.body.rotation.z > 0.08, "right-only support lifts the right side instead of translating a flat chassis")
	var before := truck.body.rotation.z
	ground.position.y = -20
	await physics_frame
	for frame in 6:
		await physics_frame
		truck.drive(state, 1.0 / 60, false)
	check(truck.body.rotation.z > before + 0.02, "one-sided takeoff retains angular momentum in flight")
	truck.reset_presentation()
	check(truck.suspension_rotation_velocity == Vector2.ZERO, "retry clears suspension rotation")
	truck.body.transform = Transform3D.IDENTITY
	truck.vertical_speed = 0.0
	ground.position = Vector3(-2.4, -0.1, 0)
	await physics_frame
	for frame in 10:
		await physics_frame
		truck.drive(state, 1.0 / 60, false)
	check(truck.body.rotation.z < -0.08, "left-only impact tilts in the opposite direction")
	truck.reset_presentation()
	truck.body.transform = Transform3D.IDENTITY
	truck.vertical_speed = 0.0
	shape.size = Vector3(8, 1, 2)
	ground.position = Vector3(0, -0.1, -2.1)
	await physics_frame
	for frame in 10:
		await physics_frame
		truck.drive(state, 1.0 / 60, false)
	check(truck.body.rotation.x > 0.06, "front-wheel impact pitches the nose up")
	check(absf(truck.body.rotation.z) < 0.01, "symmetric axle impact does not invent lateral roll")
	world.free()
	print("Asymmetric suspension failures: ", failures)
	quit(1 if failures else 0)

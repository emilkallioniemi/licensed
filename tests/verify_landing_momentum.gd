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
	var floor_body := StaticBody3D.new()
	floor_body.collision_layer = 8
	world.add_child(floor_body)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(200, 1, 200)
	collision.shape = shape
	collision.position.y = -0.5
	floor_body.add_child(collision)
	var truck := MonsterTruck.new()
	world.add_child(truck)
	var state := AttemptState.new()
	await physics_frame
	for angle in [PI, PI / 2]:
		truck.reset_presentation()
		truck.body.transform = Transform3D(Basis(Vector3.UP, angle), Vector3(0, 0, 0))
		truck.motion = Vector3(0, -3, -10)
		truck.vertical_speed = -3
		state.speed = 10
		var before := Vector2(truck.motion.x, truck.motion.z)
		truck.drive(state, 1.0 / 60, false)
		var after := Vector2(truck.motion.x, truck.motion.z)
		check(after.distance_to(before) < 0.2, "landing grip cannot instantly redirect takeoff momentum")
		check(after.y < -9.8, "backwards/sideways landing continues in the takeoff direction")
		for frame in 240:
			await physics_frame
			truck.drive(state, 1.0 / 60, false)
		var forward := -truck.body.global_basis.z
		check(Vector3(truck.motion.x, 0, truck.motion.z).dot(forward) > 8, "sustained forward drive eventually overcomes the landing slide")
	truck.reset_presentation()
	check(truck.motion == Vector3.ZERO and truck.angular_motion == 0.0, "retry clears previous travel momentum")
	world.free()
	print("Landing momentum failures: ", failures)
	quit(1 if failures else 0)

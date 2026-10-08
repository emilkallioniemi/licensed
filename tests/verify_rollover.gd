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
	var ground := StaticBody3D.new()
	ground.collision_layer = 8
	world.add_child(ground)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(100, 1, 100)
	collision.shape = shape
	collision.position.y = -0.5
	ground.add_child(collision)
	var truck := MonsterTruck.new()
	world.add_child(truck)
	var state := AttemptState.new()
	await physics_frame
	truck.body.rotation.z = 1.15
	truck.body.position.y = 2.0
	truck.suspension_rotation_velocity.y = 4.0
	var inverted := false
	for frame in 240:
		await physics_frame
		truck.drive(state, 1.0 / 60, false)
		inverted = inverted or truck.body.global_basis.y.dot(Vector3.UP) < 0
	check(inverted, "a hard side landing can carry the truck past its balance point")
	truck.reset_presentation()
	truck.body.transform = Transform3D(Basis(Vector3.FORWARD, PI), Vector3(0, 5.0, 0))
	truck.vertical_speed = 0
	for frame in 240:
		await physics_frame
		truck.drive(state, 1.0 / 60, false)
	check(truck.body.global_basis.y.dot(Vector3.UP) < -0.8, "an upside-down truck stays overturned instead of snapping upright")
	check(truck.body.position.y > 3 and absf(truck.vertical_speed) < 0.5, "roof contact supports the overturned truck on the floor")
	world.free()
	print("Rollover failures: ", failures)
	quit(1 if failures else 0)

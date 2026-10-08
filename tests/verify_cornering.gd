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
	ground.collision_layer = 9
	world.add_child(ground)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(200, 1, 200)
	collision.shape = shape
	collision.position.y = -0.5
	ground.add_child(collision)
	var truck := MonsterTruck.new()
	world.add_child(truck)
	var state := AttemptState.new()
	await physics_frame
	# Exercise actual driving, support probes and body motion in both directions.
	# Previously fast full-lock circles forced the truck onto its side on flat dirt.
	for direction in [-1.0, 1.0]:
		truck.body.transform = Transform3D.IDENTITY
		truck.vertical_speed = 0
		state.speed = AttemptState.FORWARD_SPEED
		state.front_angle = direction * AttemptState.AXLE_LIMIT
		var maximum_roll := 0.0
		var turned := false
		for frame in 180:
			await physics_frame
			truck.drive(state, 1.0 / 60, false)
			maximum_roll = maxf(maximum_roll, absf(truck.body.rotation.z))
			turned = turned or absf(truck.body.rotation.y) > 0.5
		check(turned and truck.body.position.length() > 1, "steering still turns and moves the truck")
		check(maximum_roll < 0.03, "fast full-lock steering does not manufacture body roll on flat ground")
	# Removing steering lean must retain banking from actual terrain support.
	ground.rotation.z = 0.2
	truck.body.transform = Transform3D.IDENTITY
	truck.vertical_speed = 0
	state.speed = 0
	state.front_angle = 0
	for frame in 120:
		await physics_frame
		truck.drive(state, 1.0 / 60, false)
	check(truck.body.rotation.z > 0.12 and truck.body.rotation.z < 0.3, "truck still banks on a physical side slope")
	world.free()
	print("Cornering failures: ", failures)
	quit(1 if failures else 0)

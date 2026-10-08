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
	shape.size = Vector3(50, 1, 50)
	collision.shape = shape
	collision.position.y = -0.5
	ground.add_child(collision)
	var truck := MonsterTruck.new()
	world.add_child(truck)
	var state := AttemptState.new()
	await physics_frame
	# Wheels are clear of the floor but the long terrain probes still see it.
	# The old suspension pulled the ascending chassis down toward that floor.
	truck.body.position.y = 0.8
	truck.vertical_speed = 4.0
	truck.drive(state, 1.0 / 60, false)
	print("Clear-ground ascent velocity: ", truck.vertical_speed)
	check(absf(truck.vertical_speed - (4.0 - 9.8 / 60)) < 0.02, "airborne upward momentum is reduced by gravity alone, not ground attraction")
	var rebounded := false
	var lowest := 100.0
	for frame in 240:
		await physics_frame
		var incoming := truck.vertical_speed
		truck.drive(state, 1.0 / 60, false)
		lowest = minf(lowest, truck.body.position.y)
		if incoming < 0 and truck.vertical_speed > 0:
			rebounded = true
	check(rebounded, "landing compresses the suspension and rebounds")
	check(lowest > -0.6 and absf(truck.vertical_speed) < 0.15, "landing remains supported and settles")
	world.free()
	print("Suspension launch failures: ", failures)
	quit(1 if failures else 0)

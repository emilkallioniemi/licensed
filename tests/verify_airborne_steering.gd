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
	state.speed = 10.0
	truck.drive(state, 1.0 / 60, false)
	truck.body.position.y = 12.0
	truck.vertical_speed = 3.0
	var heading := truck.body.rotation.y
	var velocity := Vector2(truck.motion.x, truck.motion.z)
	var previous_rise := INF
	for frame in 60:
		await physics_frame
		var before_y := truck.body.position.y
		var before_vertical := truck.vertical_speed
		state.front_angle = 0.6 if frame < 6 else -0.6
		truck.drive(state, 1.0 / 60, false)
		check(absf(truck.body.rotation.y - heading) < 0.001, "airborne steering cannot change heading")
		check(Vector2(truck.motion.x, truck.motion.z).distance_to(velocity) < 0.001, "flight retains takeoff velocity")
		check(absf(truck.vertical_speed - (before_vertical - 9.8 / 60)) < 0.001, "gravity accelerates descent every airborne frame")
		var rise := truck.body.position.y - before_y
		check(rise < previous_rise, "jump arc slows on ascent then falls increasingly fast")
		check(absf(rise - truck.vertical_speed / 60) < 0.001, "vertical displacement integrates gravity exactly once")
		previous_rise = rise
	check(truck.vertical_speed < -6.7, "truck falls faster after crossing the apex")
	truck.angular_motion = 0.4
	truck.drive(state, 1.0 / 60, false)
	check(is_equal_approx(truck.angular_motion, 0.4), "flight preserves preexisting yaw momentum")
	truck.body.transform = Transform3D.IDENTITY
	truck.vertical_speed = 0.0
	truck.reset_presentation()
	truck.drive(state, 1.0 / 60, false)
	check(truck.angular_motion > 0.001, "tyre contact restores steering at the actual rolling speed")
	world.free()
	print("Airborne steering failures: ", failures)
	quit(1 if failures else 0)

extends SceneTree
var failures := 0
func _initialize() -> void:
	call_deferred("verify")
func verify() -> void:
	var learner: Learner = load("res://scenes/learner.tscn").instantiate()
	root.add_child(learner)
	learner.set_truck_movement(true)
	for axis in [Vector3.RIGHT, Vector3.FORWARD]:
		learner.set_truck_movement(true)
		var initial := Basis(Vector3.UP, 0.4) * Basis(Vector3.FORWARD, 0.2)
		learner.support_pose = Transform3D(initial, Vector3.ZERO)
		var previous := learner._truck_seated_camera_transform()
		var largest_step := 0.0
		for frame in range(1, 361):
			learner.support_pose = Transform3D(initial * Basis(axis, deg_to_rad(frame)), Vector3.ZERO)
			var pose := learner._truck_seated_camera_transform()
			if learner.support_pose.basis.y.dot(Vector3.UP) <= 0.65:
				check(pose.origin.distance_to(previous.origin) < 0.001, "camera holds its orbit throughout the inverted part of a tumble")
			check(absf(pose.basis.x.y) < 0.001, "camera keeps a level horizon")
			largest_step = maxf(largest_step, pose.origin.distance_to(previous.origin))
			previous = pose
		check(largest_step < 0.6, "rollover camera never jumps around the truck at an Euler singularity")
		print("Maximum camera orbit step: ", largest_step)
	learner.support_pose = Transform3D(Basis(Vector3.UP, 1.2), Vector3.ZERO)
	var settled := Transform3D.IDENTITY
	for frame in 240:
		settled = learner._truck_seated_camera_transform()
	var expected := learner.support_pose * Learner.SEATED_TRUCK_CAMERA_OFFSET
	check(settled.origin.distance_to(expected) < 0.01, "upright driving smoothly resumes the intended chase heading")
	learner.free()
	print("Rollover camera failures: ", failures)
	quit(1 if failures else 0)
func check(ok: bool, label: String) -> void:
	if not ok:
		failures += 1
		printerr("FAIL: ", label)

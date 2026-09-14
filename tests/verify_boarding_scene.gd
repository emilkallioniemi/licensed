extends SceneTree
var failures := 0
func _initialize() -> void:
	call_deferred("verify")
func verify() -> void:
	var world := Node3D.new()
	root.add_child(world)
	var floor_body := StaticBody3D.new()
	var collider := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(80, 0.2, 80)
	collider.shape = box
	floor_body.add_child(collider)
	floor_body.position.y = -0.1
	world.add_child(floor_body)
	var truck := MonsterTruck.new()
	world.add_child(truck)
	for z in [-1.1, 0.0, 1.1]:
		var learner := (load("res://scenes/learner.tscn") as PackedScene).instantiate() as Learner
		world.add_child(learner)
		learner.set_truck_movement(true)
		learner.global_position = Vector3(-3.9, 0.1, z)
		var highest := 0.0
		for i in 120:
			await physics_frame
			learner.simulate_truck_walk({"wish": Vector2(1, 0), "yaw": 0.0, "climb": true}, truck.body, truck.body.global_transform, &"", 1.0 / 60.0)
			highest = maxf(highest, learner.position.y)
		print("CLIMB ", z, " highest ", highest, " final ", learner.position, " mode ", learner.movement_mode)
		if highest < 1.6:
			failures += 1
		learner.free()
	world.free()
	print("Boarding scene failures: ", failures)
	quit(1 if failures else 0)

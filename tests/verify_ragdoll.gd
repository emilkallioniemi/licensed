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
	var box := BoxShape3D.new()
	box.size = Vector3(100, 1, 100)
	collision.shape = box
	collision.position.y = -0.5
	ground.add_child(collision)
	var mesh := MeshInstance3D.new()
	var ground_mesh := BoxMesh.new()
	ground_mesh.size = box.size
	mesh.mesh = ground_mesh
	mesh.position.y = -0.5
	ground.add_child(mesh)
	var sun := DirectionalLight3D.new()
	world.add_child(sun)
	sun.rotation_degrees = Vector3(-45, -25, 0)
	sun.shadow_enabled = true
	var environment := WorldEnvironment.new()
	environment.environment = Environment.new()
	environment.environment.background_mode = Environment.BG_COLOR
	environment.environment.background_color = Color("748c99")
	environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.environment.ambient_light_color = Color.WHITE
	environment.environment.ambient_light_energy = 0.6
	world.add_child(environment)
	var truck := MonsterTruck.new()
	world.add_child(truck)
	truck.body.position.x = -8
	var learner: Learner = load("res://scenes/learner.tscn").instantiate()
	world.add_child(learner)
	learner.set_truck_movement(true)
	learner.position = Vector3(0, 4, 0)
	learner.apply_recovery(&"independent", Vector3(3, 4, -2))
	var camera := Camera3D.new()
	world.add_child(camera)
	camera.current = true
	var saw_ragdoll := false
	var saw_tumble := false
	var saw_ground_contact := false
	var worst_joint_gap := 0.0
	for frame in 240:
		await physics_frame
		learner.simulate_truck_walk({}, truck.body, truck.body.global_transform, &"", 1.0 / 60)
		var ragdoll: LearnerRagdoll = learner.visual.pose.ragdoll
		if is_instance_valid(ragdoll):
			saw_ragdoll = ragdoll.bodies.size() == 14
			var pelvis: RigidBody3D = ragdoll.bodies.BodyPivot
			saw_tumble = saw_tumble or pelvis.global_basis.y.angle_to(Vector3.UP) > 0.5
			saw_ground_contact = saw_ground_contact or ragdoll.grounded
			for side in ["Left", "Right"]:
				var upper: Node3D = ragdoll.bindings[side + "Shoulder"]
				var elbow: Node3D = ragdoll.bindings[side + "Elbow"]
				worst_joint_gap = maxf(worst_joint_gap, absf(upper.global_position.distance_to(elbow.global_position) - 0.29))
		if OS.get_cmdline_user_args().has("--capture") and frame in [35, 100, 210]:
			camera.position = learner.position + Vector3(3.8, 2.3, 5.0)
			camera.look_at(learner.position + Vector3.UP * 0.9)
			await process_frame
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("res://.scratch/monster-truck-build/stadium-evidence/ragdoll-" + str(frame) + ".png")
	check(saw_ragdoll and saw_tumble, "actual ejection produces fourteen connected tumbling rigid bodies")
	check(saw_ground_contact and learner.is_on_floor(), "ragdoll survives an ordinary landing")
	check(worst_joint_gap < 0.18, "physical arms remain connected while tumbling and landing")
	check(not is_instance_valid(learner.visual.pose.ragdoll), "physical ragdoll releases after landing and get-up")
	check(learner.visual.find_child("HeadPivot", true, false).global_position.y > 1.4, "recovery restores standing anatomy")
	world.free()
	print("Ragdoll failures: ", failures, "; maximum arm joint stretch: ", worst_joint_gap)
	quit(1 if failures else 0)

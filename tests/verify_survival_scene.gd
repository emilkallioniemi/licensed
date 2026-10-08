extends SceneTree
## Actual collision/gravity checks on production track and truck geometry.
var failures := 0
var world: Node3D
var truck: MonsterTruck
var track: SurvivalTrack
var state := AttemptState.new()
var sequence := 1
const STEP := 1.0 / 60.0
func _initialize() -> void:
	call_deferred("verify")
func verify() -> void:
	world = Node3D.new()
	root.add_child(world)
	track = SurvivalTrack.new()
	world.add_child(track)
	for layout in 8:
		track.build(layout)
		await physics_frame
		for index in 3:
			var side := SurvivalTrack.safe_side(layout, index)
			var z: float = SurvivalTrack.JUNCTIONS[index] - 30
			check(has_road(Vector3(side * 18, 0, z)), "report's intact bridge has actual tyre support")
			check(not has_road(Vector3(-side * 18, 0, z)), "broken bridge has a real unsupported span")
	truck = MonsterTruck.new()
	world.add_child(truck)
	start()
	truck.body.transform = Transform3D(Basis(Vector3.UP, -PI / 2), Vector3(17, 0, -90))
	for frame in 180:
		await step({"throttle": true})
	var stopped_at := truck.body.position.x
	check(state.phase == &"active" and stopped_at < 23 and stopped_at > 20, "wall physically stops truck without ending attempt")
	for frame in 180:
		await step({"brake": true})
	check(truck.body.position.x < stopped_at - 2 and state.phase == &"active", "holding reverse recovers a wall collision")
	start()
	var broken_x := -SurvivalTrack.safe_side(state.route_layout, 0) * 18
	track.build(state.route_layout)
	await physics_frame
	truck.body.transform = Transform3D(Basis.IDENTITY, Vector3(broken_x, 0, -60))
	truck.vertical_speed = 0
	for frame in 150:
		await step({})
	check(state.assessment().get("reason") == &"ravine", "actual missing-span gravity causes shared loss")
	var learner: Learner = load("res://scenes/learner.tscn").instantiate()
	world.add_child(learner)
	learner.set_truck_movement(true)
	learner.global_position = Vector3(40, -13, -40)
	learner.apply_recovery(&"ravine", Vector3(0, -5, 0))
	for frame in 60:
		await physics_frame
		learner.simulate_truck_walk({}, truck.body, truck.body.global_transform, &"", STEP)
	check(learner.position.y < -20, "dead learner continues its fall instead of freezing in midair")
	world.free()
	print("Survival scene failures: ", failures)
	quit(1 if failures else 0)
func start() -> void:
	state.begin(&"monster_truck", [1, 2, 3])
	for player in [1, 2, 3]:
		state.scene_ready(player, state.id)
	state.observe_learner(1, AttemptState.CONTROLS.pedals)
	state.request_control(1, state.id, 1, &"pedals")
func step(command: Dictionary) -> void:
	await physics_frame
	sequence += 1
	state.drive(1, state.id, sequence, 1, command)
	state.advance_driving(STEP)
	truck.drive(state, STEP)
	state.observe_course(truck.body.transform, STEP)
	state.tick(STEP)
func has_road(at: Vector3) -> bool:
	var ray := PhysicsRayQueryParameters3D.create(at + Vector3.UP, at - Vector3.UP, 8)
	return not world.get_world_3d().direct_space_state.intersect_ray(ray).is_empty()
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		printerr("FAIL: ", message)

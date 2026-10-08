extends SceneTree
var failures := 0
var world: Node3D
var truck: MonsterTruck
var track: SurvivalTrack
var state := AttemptState.new()
var sequence := 0
func _initialize() -> void:
	call_deferred("verify")
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		printerr("FAIL: ", message)
func start(at: Vector3) -> void:
	state.begin(&"monster_truck", [1, 2, 3])
	state.route_layout = 7
	for player in [1, 2, 3]:state.scene_ready(player, state.id)
	state.observe_learner(1, AttemptState.CONTROLS.pedals)
	state.request_control(1, state.id, 1, &"pedals")
	truck.body.transform = Transform3D(Basis.IDENTITY, at)
	truck.vertical_speed = 0
	truck.reset_presentation()
	track.sync_obstacles(state, Vector3.ZERO, true)
func step(throttle: bool) -> void:
	await physics_frame
	sequence += 1
	state.drive(1, state.id, sequence, 1, {"throttle": throttle})
	state.advance_driving(1.0 / 60)
	track.sync_obstacles(state, truck.body.position, true)
	truck.drive(state, 1.0 / 60)
	state.observe_course(truck.body.transform, 1.0 / 60)
func verify() -> void:
	world = Node3D.new()
	root.add_child(world)
	track = SurvivalTrack.new()
	world.add_child(track)
	track.build(7)
	truck = MonsterTruck.new()
	world.add_child(truck)
	await physics_frame
	start(Vector3(18, 0.3, -39))
	var highest := 0.0
	var pitch := 0.0
	for i in 750:
		await step(state.speed < 3.5)
		highest = maxf(highest, truck.body.position.y)
		pitch = maxf(pitch, absf(truck.body.rotation.x))
	check(highest > 3 and pitch > 0.15, "authored ramps physically lift and pitch the truck")
	check(state.crushed_cars != 0, "actual driving crushes wrecks")
	for index in track.cars.size():
		var crushed := (state.crushed_cars & (1 << index)) != 0
		check(track.cars[index].visible != crushed and track.folded_cars[index].visible == crushed, "crush selects authored folded body and preserves wheel proportions")
	var guest := AttemptState.new()
	guest.restore(state.snapshot())
	check(guest.crushed_cars == state.crushed_cars, "crushed wreck state survives a complete guest snapshot")
	track.sync_obstacles(AttemptState.new(), Vector3.ZERO, false)
	track.sync_obstacles(guest, Vector3.ZERO, false)
	for index in track.cars.size():
		check(track.folded_cars[index].visible == ((guest.crushed_cars & (1 << index)) != 0), "guest snapshot selects matching damage models")
	check(truck.body.position.z < -75 and state.phase == &"active", "the car obstacle is traversable")
	start(Vector3(18, 0.3, -35))
	var wreck_airtime := 0.0
	var peak_clearance := 0.0
	var landed_after_wrecks := false
	for frame in 600:
		await step(true)
		var clearance := INF
		for x in [-2.4, 2.4]:
			for z in [-2.1, 2.1]:
				var tyre_at := truck.body.to_global(Vector3(x, 0, z))
				var ray := PhysicsRayQueryParameters3D.create(tyre_at + Vector3.UP * 3, tyre_at - Vector3.UP * 12, 8)
				var hit := world.get_world_3d().direct_space_state.intersect_ray(ray)
				clearance = minf(clearance, tyre_at.y - hit.position.y if not hit.is_empty() else 0.0)
		peak_clearance = maxf(peak_clearance, clearance)
		if clearance > 0.65:
			wreck_airtime += 1.0 / 60
		if wreck_airtime > 0 and clearance < 0.2 and truck.body.position.z < -75:
			landed_after_wrecks = true
		if truck.body.position.z < -86 or state.phase != &"active":
			break
	print("Fast wreck run minimum-wheel peak clearance: ", peak_clearance, "; airtime: ", wreck_airtime)
	check(wreck_airtime > 0.1 and landed_after_wrecks and state.phase == &"active", "charging over the real wreck lane lifts all four wheels, then lands alive")
	start(Vector3(18, 0.3, -103))
	for i in 1000:
		await step(state.speed < 3.5)
		if truck.body.position.z < -142 or state.phase != &"active":
			break
	check(truck.body.position.z < -142 and state.phase == &"active", "the truck physically fits through the modeled ring on its dirt ramp")
	start(Vector3(18, 0.3, -159))
	var airborne := false
	var landed := false
	for i in 530:
		await step(true)
		var at := truck.body.position
		if at.z < -178 and at.z > -182 and at.y > 2:
			airborne = true
		if at.z < -197 and at.y < 2 and state.phase == &"active":
			landed = true
			break
	check(airborne and landed, "full throttle clears the actual dirt jump gap and lands alive")
	start(Vector3(18, 0.3, -159))
	for i in 1100:
		await step(state.speed < 2.0)
		if state.phase != &"active" or truck.body.position.z < -195:
			break
	check(state.assessment().get("reason") == &"ravine", "crawling into the jump cannot substitute for the speed player's run-up")
	start(Vector3(18, 0.3, -159))
	check(state.crushed_cars == 0 and track.cars[0].visible and not track.folded_cars[0].visible, "retry restores salvage body and hides folded body")
	# Clients may render a snapshot but cannot invent a crush through proximity.
	track.sync_obstacles(state, track.car_positions[0], false)
	check(state.crushed_cars == 0, "guest proximity cannot author crushed cars")
	world.free()
	print("Stadium failures: ", failures)
	quit(1 if failures else 0)

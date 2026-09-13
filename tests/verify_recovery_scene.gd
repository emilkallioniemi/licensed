extends SceneTree
## Agent-owned collision fixture, not human acceptance. Uses production truck,
## learners and host movement integration; setup placement isolates accidents.
var failures := 0
var world: Node3D
var truck: MonsterTruck
var learner: Learner
var attempt: AttemptState
var recovery: RefCounted
const STEP := 1.0 / 60.0

func _initialize() -> void:
	call_deferred("verify")

func verify() -> void:
	if not ResourceLoader.exists("res://scripts/truck_recovery.gd"):
		check(false, "production scene has host physical recovery integration")
		quit(1)
		return
	recovery = load("res://scripts/truck_recovery.gd").new()
	world = Node3D.new()
	root.add_child(world)
	floor_box(Vector3(100, 0.1, 100), Vector3(0, -0.05, 0), 9)
	truck = MonsterTruck.new()
	world.add_child(truck)
	learner = load("res://scenes/learner.tscn").instantiate()
	world.add_child(learner)
	learner.set_truck_movement(true)
	attempt = AttemptState.new()
	attempt.begin(&"monster_truck", [1, 2, 3])
	for player in [1, 2, 3]:
		attempt.scene_ready(player, attempt.id)
	await step(5)
	place(Vector3(0, 4.28, 0), true)
	await step(10)
	check(learner.support == &"truck", "ordinary roof footing secured")
	attempt.parking_brake = false
	attempt.speed = 2.0
	attempt.front_angle = 0.15
	await step(60)
	check(learner.support == &"truck" and learner.global_position.y > 4.1, "roof travels through ordinary moving turn")
	attempt.speed = 8.0
	attempt.front_angle = 0.6
	attempt.rear_angle = -0.6
	await step(1)
	check(learner.support == &"" and learner.velocity.y > 0.0, "sharp turn physically ejects roof rider")
	check(attempt.accidents.back().kind == &"ejected", "scene sends ejection to attempt boundary")
	var replica: Learner = load("res://scenes/learner.tscn").instantiate()
	world.add_child(replica)
	replica.set_truck_movement(true)
	replica.set_seated(true)
	replica.restore_truck_snapshot(learner.truck_snapshot(), truck.body.global_transform)
	check(replica.support == &"" and replica.velocity.is_equal_approx(learner.velocity), "snapshot detachment from occupied state preserves host impulse")
	replica.free()
	attempt.parking_brake = true
	attempt.speed = 0.0
	await step(150)
	check(learner.is_on_floor() and learner.global_position.y < 0.2, "ejected learner lands harmlessly")
	check(attempt.accidents.back().kind == &"landed" and attempt.accidents.back().severity == &"none", "harmless landing has no fault observation")
	# Same shipping ramp: physically walk back up after collection.
	truck.body.transform = Transform3D.IDENTITY
	truck.vertical_speed = 0.0
	place(Vector3(1.1, 0.1, 6.6), false)
	await step(10)
	await step(125, {"wish": Vector2(0, -1), "yaw": 0.0})
	print("REBOARD: ", learner.global_position, " ", learner.movement_mode)
	check(learner.support == &"truck" and learner.global_position.y > 1.5, "fallen learner can walk back aboard")
	for target in [Vector3(1.15, 1.6, 2.8), Vector3(-1.5, 1.6, 2.8), Vector3(-1.5, 2.9, 5.9), Vector3(0, 2.9, 5.9), Vector3(0, 4.28, 2.0)]:
		await walk_to(target)
	check(learner.support == &"truck" and learner.global_position.y > 4.2, "continuous compact switchback reaches roof without jumping or placement")
	# A learner caught beneath the deck can no longer reach a control remotely.
	place(Vector3(0, 0.01, 0), false)
	await step(2)
	check(learner.movement_mode == &"trapped", "real deck overhead pins learner without crushing")
	var pinned_at := learner.global_position
	await step(30, {"wish": Vector2(1, 0), "yaw": 0.0})
	check(learner.global_position.distance_to(pinned_at) < 0.1, "trapped learner stays physically pinned")
	check(attempt.phase == &"active" and attempt.remaining < 355.0, "time continues during entrapment")
	attempt.front_angle = 0.0
	attempt.rear_angle = 0.0
	attempt.parking_brake = false
	attempt.direction = -1
	attempt.observe_learner(2, AttemptState.CONTROLS.pedals)
	attempt.request_control(2, attempt.id, 1, &"pedals")
	for i in 180:
		attempt.drive(2, attempt.id, i + 1, 1, {"throttle": true})
		await step(1)
	check(learner.movement_mode == &"independent" and attempt.accident_states[1] == &"rescued", "friend reverses truck to free trapped learner")
	# Real raised terrain drives suspension and throws an unsecured roof rider.
	truck.body.transform = Transform3D.IDENTITY
	truck.vertical_speed = 0.0
	place(Vector3(0, 4.28, 0), true)
	attempt.speed = 8.0
	attempt.front_angle = 0.0
	attempt.rear_angle = 0.0
	attempt.parking_brake = false
	floor_box(Vector3(8, 0.9, 1.0), Vector3(0, 0.45, -5), 9)
	var raised := false
	var thrown := false
	for i in 65:
		await step(1)
		raised = raised or truck.body.global_position.y > 0.35
		thrown = thrown or learner.ejection_time > 0.0
	check(raised and thrown, "large physical bump raises shared truck and ejects roof rider")
	# Real hull impact throws an operator and invalidates their driving lease.
	truck.body.transform = Transform3D(Basis.IDENTITY, Vector3(20, 0, 0))
	truck.vertical_speed = 0.0
	place(truck.body.to_global(AttemptState.CONTROLS.front), true)
	attempt.observe_learner(1, AttemptState.CONTROLS.front)
	attempt.request_control(1, attempt.id, 10, &"front")
	await step(1)
	check(learner.is_seated(), "impact fixture begins with physical occupied control")
	attempt.speed = 8.0
	var before_impact := attempt.accident_sequence
	floor_box(Vector3(9, 5, 1), Vector3(20, 2.5, -7), 5)
	await step(55)
	var impact_ejected := false
	for event in attempt.accidents:
		impact_ejected = impact_ejected or (event.sequence > before_impact and event.kind == &"ejected" and event.player == 1)
	check(impact_ejected and attempt.control_of(1) == &"" and attempt.speed == 0.0, "actual hull impact ejects operator and stops truck")
	# A timeout still permits an occupied learner to be thrown in the aftermath.
	truck.body.transform = Transform3D(Basis.IDENTITY, Vector3(20, 0, 0))
	truck.vertical_speed = 0.0
	place(truck.body.to_global(AttemptState.CONTROLS.front), true)
	attempt.observe_learner(1, AttemptState.CONTROLS.front)
	attempt.request_control(1, attempt.id, 11, &"front")
	await step(1)
	attempt.speed = 8.0
	attempt.tick(360.0)
	var settled := attempt.assessment()
	await step(55)
	check(attempt.control_of(1) == &"" and not learner.is_seated(), "post-timeout hull impact still physically ejects operator")
	check(attempt.assessment() == settled, "aftermath impact cannot change timeout assessment")
	attempt.begin(&"monster_truck", [1, 2, 3])
	for player in [1, 2, 3]: attempt.scene_ready(player, attempt.id)
	# Side tyres compress to the ground, distinct from the survivable deck gap.
	attempt.speed = 0.0
	attempt.parking_brake = true
	place(truck.body.to_global(Vector3(2.75, 0.01, 1.8)), false)
	await step(1)
	check(learner.movement_mode == &"crushed" and attempt.accidents.back().severity == &"serious", "actual tyre compression produces catastrophic observation")
	check(attempt.phase == &"aftermath" and attempt.assessment().reason == &"crushed", "physical crushing guarantees failure before results")
	# Fresh attempt, truck boxed by immovable wrecks: no hidden recovery action.
	attempt.begin(&"monster_truck", [1, 2, 3])
	for player in [1, 2, 3]:
		attempt.scene_ready(player, attempt.id)
	truck.body.transform = Transform3D.IDENTITY
	truck.vertical_speed = 0.0
	place(Vector3(0, 0.01, 0), false)
	floor_box(Vector3(8, 5, 1), Vector3(0, 2.5, -3.7), 5)
	floor_box(Vector3(8, 5, 1), Vector3(0, 2.5, 3.4), 5)
	await step(2)
	attempt.parking_brake = false
	attempt.observe_learner(2, AttemptState.CONTROLS.pedals)
	attempt.request_control(2, attempt.id, 1, &"pedals")
	for i in 150:
		attempt.drive(2, attempt.id, i + 1, 1, {"throttle": true})
		await step(1)
	check(learner.movement_mode == &"trapped" and truck.body.position.length() < 0.4, "boxed truck demonstrates impossible physical rescue")
	for id in [1, 2, 3]: attempt.choose(id, attempt.id, 1, &"concede")
	check(attempt.phase == &"aftermath", "impossible rescue can be conceded together")
	await step(361)
	check(attempt.phase == &"settled", "physical aftermath reaches shared results")
	for id in [1, 2, 3]: attempt.choose(id, attempt.id, 2, &"retry")
	for id in [1, 2, 3]: attempt.scene_ready(id, attempt.id)
	truck.body.transform = Transform3D(Basis.IDENTITY, Vector3(35, 0, 20))
	truck.vertical_speed = 0.0
	place(Vector3(40, 0.1, 20), false)
	floor_box(Vector3(3, 1.4, 10), Vector3(37.75, 0.7, 20), 9)
	await step(80)
	check(absf(truck.body.rotation.z) > 1.2 and attempt.assessment().get("reason") == &"overturn", "physical side bank overturns truck and settles failure")
	for id in [1, 2, 3]: attempt.choose(id, attempt.id, 3, &"retry")
	attempt.begin(&"monster_truck", [1, 2, 3])
	for id in [1, 2, 3]: attempt.scene_ready(id, attempt.id)
	truck.body.transform = Transform3D(Basis.IDENTITY, Vector3(60, 0, 0))
	truck.vertical_speed = 0.0
	place(Vector3(60, 4.28, 0), true)
	await step(180)
	check(truck.body.global_position.y < -12 and attempt.assessment().get("reason") == &"ravine", "unsupported ravine drop continues physically and guarantees failure")
	print("Recovery scene failures: ", failures)
	world.queue_free()
	await process_frame
	quit(1 if failures else 0)

func step(count: int, command: Dictionary = {}) -> void:
	for i in count:
		await physics_frame
		var previous := truck.body.global_transform
		attempt.advance_driving(STEP)
		truck.drive(attempt, STEP, false)
		recovery.simulate(learner, command, truck, previous, attempt, 1, STEP, true)
		attempt.tick(STEP)

func place(at: Vector3, supported: bool) -> void:
	learner.apply_recovery(&"independent")
	learner.global_position = at
	learner.support = &"truck" if supported else &""
	learner.support_pose = truck.body.global_transform

func floor_box(size: Vector3, at: Vector3, layer: int) -> void:
	var body := StaticBody3D.new()
	body.collision_layer = layer
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	body.add_child(shape)
	world.add_child(body)
	body.position = at

func check(ok: bool, label: String) -> void:
	if not ok:
		failures += 1
		printerr("FAIL: ", label)

func walk_to(target: Vector3) -> void:
	for i in 240:
		var at := truck.body.to_local(learner.global_position)
		var offset := Vector2(target.x - at.x, target.z - at.z)
		if offset.length() < 0.08:
			return
		await step(1, {"wish": offset.normalized(), "yaw": truck.body.global_rotation.y})
	check(false, "stair waypoint %s reached physically; stopped at %s" % [target, truck.body.to_local(learner.global_position)])

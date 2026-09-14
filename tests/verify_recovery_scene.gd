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
	place(Vector3(0, 2.72, 0.8), true)
	await step(10)
	check(learner.support == &"truck", "ordinary open-bed footing secured")
	attempt.parking_brake = false
	attempt.speed = 2.0
	attempt.front_angle = 0.15
	await step(60)
	check(learner.support == &"truck" and learner.global_position.y > 2.6, "open bed travels through ordinary moving turn")
	attempt.speed = 8.0
	attempt.front_angle = 0.6
	attempt.rear_angle = -0.6
	await step(1)
	check(learner.support == &"" and learner.velocity.y > 0.0, "sharp turn physically ejects unseated bed rider")
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
	check(learner.is_on_floor() and learner.movement_mode in [&"supported", &"independent"], "unseated learner lands harmlessly on truck or ground")
	check(attempt.accidents.back().kind == &"landed" and attempt.accidents.back().severity == &"none", "harmless landing has no fault observation")
	# Occupied learners remain secured through real collision and rollover.
	truck.body.transform = Transform3D(Basis.IDENTITY, Vector3(20, 0, 0))
	truck.vertical_speed = 0.0
	place(truck.body.to_global(AttemptState.CONTROLS.front), true)
	attempt.observe_learner(1, AttemptState.CONTROLS.front)
	attempt.request_control(1, attempt.id, 10, &"front")
	await step(1)
	check(learner.is_seated(), "impact fixture begins seated")
	attempt.front_angle = 0.0
	attempt.speed = 8.0
	floor_box(Vector3(9, 5, 1), Vector3(20, 2.5, -7), 5)
	await step(55)
	check(attempt.control_of(1) == &"front" and learner.is_seated() and attempt.speed == 0.0, "hull collision stops truck and keeps seat secured")
	truck.body.rotation.z = PI / 2.0
	await step(30)
	check(attempt.phase == &"active" and learner.is_seated(), "rollover is recoverable and retains occupant")
	check(learner.global_position.distance_to(truck.body.to_global(AttemptState.CONTROLS.front)) < 0.01, "seat follows rolled truck")
	attempt.tick(360.0)
	var result := attempt.assessment()
	await step(55)
	check(learner.is_seated() and attempt.assessment() == result, "aftermath keeps seats and immutable timeout")
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

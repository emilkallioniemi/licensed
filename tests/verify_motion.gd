extends SceneTree

var failures := 0

func _initialize() -> void:
	_run.call_deferred()

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)

func _run() -> void:
	check(load("res://scenes/waiting_room.tscn") is PackedScene, "Waiting room and its scripts must load")
	var scene := load("res://scenes/learner.tscn") as PackedScene
	var learner := scene.instantiate() as Learner
	learner.set_local(true)
	root.add_child(learner)
	learner.set_physics_process(false)
	var before := learner.global_position
	learner._physics_process(1.0 / 60.0)
	var after := learner.global_position
	if learner.has_method("_update_presentation"):
		learner.call("_update_presentation", 1.0 / 120.0, 0.5)
	check(learner.camera.global_position.is_equal_approx(before.lerp(after, 0.5) + Vector3.UP * Learner.EYE_HEIGHT), "Camera must render between physics positions")
	learner.global_position = Vector3(10, 0, 0)
	if learner.has_method("_update_presentation"):
		learner.call("_update_presentation", 1.0 / 120.0, 0.5)
	check(learner.camera.global_position.is_equal_approx(Vector3(10, Learner.EYE_HEIGHT, 0)), "Teleport must snap the camera")
	learner._physics_process(1.0 / 60.0)
	learner.set_seated(true)
	learner._update_presentation(1.0 / 120.0, 0.1)
	var seated_camera := learner.camera.global_position
	learner._update_presentation(1.0 / 120.0, 0.9)
	check(learner.camera.global_position.is_equal_approx(seated_camera), "Seated camera must not replay the last walking tick")
	check(is_equal_approx(seated_camera.y, learner.global_position.y + Learner.SEATED_EYE_HEIGHT), "Seating must preserve eye height")
	# Headless DisplayServer cannot capture a mouse; exercise the resulting look pose.
	learner.rotate_y(-100 * Learner.MOUSE_SENSITIVITY)
	learner._pitch = -20 * Learner.MOUSE_SENSITIVITY
	learner._update_presentation(0.0, 0.5)
	check(learner.camera.global_basis.is_equal_approx(learner.global_basis * Basis(Vector3.RIGHT, -20 * Learner.MOUSE_SENSITIVITY)), "Mouse look must use the latest yaw and pitch")
	var sync := learner.get_node("MultiplayerSynchronizer") as MultiplayerSynchronizer
	check(sync.replication_config.property_get_replication_mode(NodePath(".:position")) == SceneReplicationConfig.REPLICATION_MODE_ALWAYS, "Movement must use unreliable periodic updates")
	learner.free()
	var remote := scene.instantiate() as Learner
	root.add_child(remote)
	remote.position.x = 0.15
	remote._update_presentation(1.0 / 120.0, 0.5)
	check(remote.visual.global_position.x > 0 and remote.visual.global_position.x < 0.15, "Remote body must move between packets instead of snapping")
	check(is_equal_approx(remote.position.x, 0.15), "Remote smoothing must not move the collision body")
	for i in 120:
		remote._update_presentation(1.0 / 120.0, 0.5)
	check(absf(remote.visual.global_position.x - 0.15) < 0.001, "Remote body must settle after movement stops")
	remote.position.x = 10
	remote._update_presentation(1.0 / 120.0, 0.5)
	check(is_equal_approx(remote.visual.global_position.x, 10), "Remote teleport must snap")
	check(is_equal_approx(remote.name_tag.global_position.x, 10), "Remote name tag must follow the smoothed body")
	remote.free()
	print("Motion: %s" % ("PASS" if failures == 0 else "FAIL"))
	quit(0 if failures == 0 else 1)

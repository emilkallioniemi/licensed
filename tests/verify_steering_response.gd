extends SceneTree
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		printerr("FAIL: ", message)

func _initialize() -> void:
	var state := AttemptState.new()
	state.begin(&"monster_truck", [1, 2, 3])
	for player in [1, 2, 3]: state.scene_ready(player, state.id)
	state.observe_learner(1, AttemptState.CONTROLS.front)
	state.request_control(1, state.id, 1, &"front")
	# A short keyboard tap should leave room for a small correction.
	for frame in 6:
		state.drive(1, state.id, frame + 1, 1, {"steer": -1.0})
		state.advance_driving(1.0 / 60)
	print("100 ms tap axle degrees: ", rad_to_deg(state.front_angle))
	check(absf(state.front_angle) < deg_to_rad(6), "a 100 ms steering tap stays below six degrees at the axle")
	# Holding partial analogue input should remain partial rather than wind up.
	state.front_angle = 0
	for frame in 120:
		state.drive(1, state.id, frame + 7, 1, {"steer": -0.3})
		state.advance_driving(1.0 / 60)
	print("Held 30 percent axle degrees: ", rad_to_deg(state.front_angle))
	check(absf(state.front_angle) < AttemptState.AXLE_LIMIT * 0.31, "held partial input does not accumulate to full lock")
	var partial := absf(state.front_angle)
	for frame in 60:
		state.drive(1, state.id, frame + 127, 1, {"steer": 0.0})
		state.advance_driving(1.0 / 60)
	check(is_zero_approx(state.front_angle), "releasing steering eases the wheels back to centre")
	# Compare the same input at low and high speed, with live refresh each step.
	for frame in 120:
		state.speed = AttemptState.FORWARD_SPEED
		state.drive(1, state.id, frame + 187, 1, {"steer": -0.3})
		state.advance_driving(1.0 / 60)
	check(absf(state.front_angle) < partial * 0.75, "small corrections become gentler at speed")
	for frame in 120:
		state.speed = 0
		state.drive(1, state.id, frame + 307, 1, {"steer": 1.0})
		var previous := state.front_angle
		state.advance_driving(1.0 / 60)
		check(absf(state.front_angle - previous) <= 0.016, "opposite steering is progressive without an angle snap")
	check(is_equal_approx(state.front_angle, AttemptState.AXLE_LIMIT), "full low-speed lock remains available for recovery")
	print("Steering response failures: ", failures)
	quit(1 if failures else 0)

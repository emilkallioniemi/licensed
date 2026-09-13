extends SceneTree
var failures := 0

func _initialize() -> void:
	var a := AttemptState.new()
	a.begin(&"monster_truck", [1, 2, 3])
	for p in [1, 2, 3]:
		a.scene_ready(p, a.id)
	a.observe_learner(1, AttemptState.CONTROLS.front)
	a.request_control(1, a.id, 1, &"front")
	check(a.has_method("drive"), "attempt accepts driving commands")
	if not a.has_method("drive"):
		quit(1)
		return
	check(a.drive(1, a.id, 1, 1, {"steer": 1.0}), "occupied front steering")
	a.advance_driving(0.2)
	check(a.front_angle > 0.0 and a.front_angle < 0.7, "gradual limited steering")
	var angle: float = a.front_angle
	a.release_control(1, a.id, 2)
	a.advance_driving(0.2)
	check(a.front_angle == angle, "vacant axle holds angle")
	check(not a.drive(1, a.id, 2, 1, {"steer": -1.0}), "released operator rejected")
	a.observe_learner(2, AttemptState.CONTROLS.pedals)
	a.request_control(2, a.id, 1, &"pedals")
	check(a.parking_brake, "arrival secured")
	check(a.driving_action(2, a.id, 1, 1, &"parking"), "release parking brake")
	check(not a.driving_action(2, a.id, 1, 1, &"parking") and not a.parking_brake, "duplicate toggle has no effect")
	check(a.drive(2, a.id, 10, 1, {"throttle": true}), "throttle accepted")
	a.advance_driving(0.2)
	check(a.speed > 0.0, "forward accelerates")
	check(not a.driving_action(2, a.id, 2, 1, &"direction") and a.direction == 1, "moving R rejected")
	check(not a.drive(2, a.id, 9, 1, {"throttle": true}), "reordered held command ignored")
	var peak: float = a.speed
	a.advance_driving(0.4)
	check(a.speed < peak, "lost release neutralizes stale throttle")
	a.drive(2, a.id, 11, 1, {"brake": true})
	a.advance_driving(0.2)
	check(a.speed == 0.0, "service brake stops")
	check(a.driving_action(2, a.id, 3, 1, &"direction") and a.direction == -1, "stopped R reverses")
	a.drive(2, a.id, 12, 1, {"throttle": true})
	a.advance_driving(0.2)
	check(a.speed < 0.0, "W accelerates in selected reverse")
	a.release_control(2, a.id, 2)
	var reverse_speed: float = a.speed
	a.advance_driving(0.1)
	check(a.speed > reverse_speed and a.direction == -1, "unattended pedals coast, direction persists")
	a.observe_learner(3, AttemptState.CONTROLS.pedals)
	a.request_control(3, a.id, 1, &"pedals")
	check(not a.driving_action(2, a.id, 4, 1, &"parking"), "old operator cannot toggle")
	check(a.driving_action(3, a.id, 1, 1, &"parking"), "handover uses actual brake state")
	a.advance_driving(0.2)
	check(a.speed == 0.0 and a.parking_brake, "deliberate parking holds")
	a.release_control(3, a.id, 2)
	a.request_control(3, a.id, 3, &"pedals")
	check(not a.drive(3, a.id, 50, 1, {"throttle": true}), "old occupancy generation cannot drive after retake")
	var guest := AttemptState.new()
	guest.restore(a.snapshot())
	check(guest.parking_brake and guest.direction == -1 and guest.front_angle == a.front_angle, "snapshot restores persistent driving state")
	var old_id: String = a.id
	a.begin(&"monster_truck", [1, 2, 3])
	check(not a.drive(3, old_id, 51, 3, {"throttle": true}), "old attempt cannot resume")
	check(a.parking_brake and a.direction == 1 and a.front_angle == 0.0, "fresh attempt resets controls")
	print("Driving failures: ", failures)
	quit(1 if failures else 0)

func check(ok: bool, label: String) -> void:
	if not ok:
		failures += 1
		printerr("FAIL: ", label)

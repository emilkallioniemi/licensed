extends SceneTree
var failures := 0
func _initialize() -> void:
	var a := AttemptState.new()
	a.begin(&"monster_truck", [1, 2, 3])
	for p in [1, 2, 3]:
		a.scene_ready(p, a.id)
	var controls := [&"front", &"pedals", &"rear"]
	for i in 3:
		a.observe_learner(i + 1, AttemptState.CONTROLS[controls[i]])
		a.request_control(i + 1, a.id, 1, controls[i])
	a.drive(3, a.id, 1, 1, {"steer": 1.0, "throttle": true})
	a.advance_driving(0.2)
	check(a.balance.x > 0.0 and a.balance.y < 0.0 and a.rear_angle == 0.0, "balance shifts right and forward without rear steering")
	check(a.request_swap(1, a.id, 2, &"pedals"), "stopped occupant requests swap")
	check(a.control_of(1) == &"front", "request alone never moves occupant")
	check(not a.request_swap(3, a.id, 2, &"front"), "overlapping requests refused")
	check(a.answer_swap(2, a.id, 2, 1, false, 2), "target can refuse")
	check(a.control_of(1) == &"front", "refusal keeps seats")
	check(a.request_swap(1, a.id, 3, &"pedals"), "request again")
	check(a.answer_swap(2, a.id, 3, 1, true, 3), "target explicitly accepts")
	check(a.control_of(1) == &"pedals" and a.control_of(2) == &"front", "both controls switch atomically")
	check(not a.drive(1, a.id, 99, 1, {"throttle": true}), "old generation rejected after swap")
	check(not a.answer_swap(2, a.id, 4, 1, true, 3), "duplicate acceptance refused")
	a.request_swap(1, a.id, 4, &"rear")
	a.drive(1, a.id, 100, a.generations[1], {"throttle": true})
	a.advance_driving(0.2)
	check(not a.answer_swap(3, a.id, 3, 1, true, 4), "movement cancels swap")
	# A delayed response must not accept a renewed request by the same person.
	for i in 40:
		a.advance_driving(0.1)
	check(a.request_swap(1, a.id, 5, &"rear"), "new stopped request")
	a.tick(8.1)
	check(a.request_swap(1, a.id, 6, &"rear"), "renew expired request")
	check(not a.answer_swap(3, a.id, 4, 1, true, 5), "stale consent cannot accept renewed request")
	check(a.control_of(3) == &"rear", "stale consent preserves target occupant")
	check(a.answer_swap(3, a.id, 5, 1, true, 6), "fresh consent accepts renewed request")
	var guest := AttemptState.new()
	guest.restore(a.snapshot())
	check(guest.balance == a.balance and guest.operators == a.operators, "snapshot shares balance and swapped seats")
	print("Balance/swap failures: ", failures)
	quit(1 if failures else 0)
func check(ok: bool, label: String) -> void:
	if not ok:
		failures += 1
		printerr("FAIL: ", label)

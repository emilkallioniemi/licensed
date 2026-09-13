extends SceneTree
var failures := 0

func _initialize() -> void:
	var attempt := AttemptState.new()
	attempt.begin(&"monster_truck", [1, 2, 3])
	for player in [1, 2, 3]:
		attempt.scene_ready(player, attempt.id)
	check(attempt.has_method("observe_accident"), "host attempt accepts meaningful physical accident observations")
	if not attempt.has_method("observe_accident"):
		quit(1)
		return
	attempt.observe_learner(1, AttemptState.CONTROLS.front)
	attempt.request_control(1, attempt.id, 1, &"front")
	check(attempt.observe_accident(1, attempt.id, &"ejected", Vector3.ZERO, Vector3(4, 3, 0)), "ejection recorded")
	check(attempt.control_of(1) == &"", "ejection releases occupied control")
	check(not attempt.drive(1, attempt.id, 1, 1, {"steer": 1.0}), "ejected operator cannot drive using old generation")
	check(attempt.request_control(1, attempt.id, 2, &"front"), "recovering learner can reach and retake a control")
	check(attempt.observe_accident(1, attempt.id, &"ejected", Vector3.ZERO, Vector3(4, 3, 0)) and attempt.control_of(1) == &"", "another impact releases a reboarded operator")
	attempt.observe_accident(1, attempt.id, &"landed", Vector3.ZERO)
	check(attempt.accidents.back().severity == &"none", "harmless fall is no fault")
	attempt.observe_accident(1, attempt.id, &"trapped", Vector3.ZERO)
	check(not attempt.request_control(1, attempt.id, 3, &"front"), "trapped learner cannot take nearby control")
	var count: int = attempt.accidents.size()
	check(not attempt.observe_accident(1, attempt.id, &"trapped", Vector3.ZERO) and attempt.accidents.size() == count, "remaining trapped does not duplicate an accident")
	attempt.tick(2.0)
	check(attempt.remaining == 358.0 and attempt.phase == &"active", "timer continues through physical rescue")
	attempt.observe_accident(1, attempt.id, &"rescued", Vector3.ZERO)
	check(attempt.request_control(1, attempt.id, 4, &"front"), "physically freed learner can reoccupy")
	attempt.observe_accident(1, attempt.id, &"crushed", Vector3.ZERO)
	check(attempt.accidents.back().severity == &"serious", "catastrophic crushing is distinct from entrapment")
	check(not attempt.observe_accident(1, attempt.id, &"rescued", Vector3.ZERO), "recovery cannot undo catastrophe")
	var guest := AttemptState.new()
	guest.restore(attempt.snapshot())
	check(guest.accidents == attempt.accidents and guest.accident_states == attempt.accident_states, "snapshot recovers stable accident identities and conditions")
	check(not attempt.observe_accident(2, "old", &"trapped", Vector3.ZERO), "prior attempt observations rejected")
	attempt.begin(&"monster_truck", [1, 2, 3])
	check(attempt.accidents.is_empty() and attempt.accident_states.is_empty(), "fresh attempt clears physical consequences")
	print("Recovery failures: ", failures)
	quit(1 if failures else 0)

func check(ok: bool, label: String) -> void:
	if not ok:
		failures += 1
		printerr("FAIL: ", label)

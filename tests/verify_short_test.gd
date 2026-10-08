extends SceneTree
var failures := 0
func _initialize() -> void:
	for layout in 8:
		var a := AttemptState.new()
		start(a)
		a.route_layout = layout
		a.observe_course(Transform3D(Basis.IDENTITY, Vector3(0, 0, -220)), 0.1)
		check(a.assessment().is_empty() and a.test_item == 0, "finish cannot skip the bridges")
		for index in 3:
			var side := SurvivalTrack.safe_side(layout, index)
			var z: float = SurvivalTrack.JUNCTIONS[index]
			a.observe_course(Transform3D(Basis.IDENTITY, Vector3(-side * 18, 0, z - 20)), 0.1)
			a.observe_course(Transform3D(Basis.IDENTITY, Vector3(-side * 18, 0, z - 53)), 0.1)
			check(a.test_item == index, "broken bridge cannot complete checkpoint")
			a.observe_course(Transform3D(Basis.IDENTITY, Vector3(side * 18, 0, z - 53)), 0.1)
			check(a.test_item == index, "exit alone cannot award bridge crossing")
			a.observe_course(Transform3D(Basis.IDENTITY, Vector3(side * 18, 0, z - 20)), 0.1)
			a.observe_course(Transform3D(Basis.IDENTITY, Vector3(side * 18, 0, z - 53)), 0.1)
			check(a.test_item == index + 1, "intact bridge completes in order")
			a.record_recovery()
			check(a.test_item == index + 1, "ordinary recovery retains completed crossings")
		var guest := AttemptState.new()
		guest.restore(a.snapshot())
		check(guest.route_layout == layout and guest.test_item == 3, "guest restores route geometry and progress")
		a.observe_course(Transform3D(Basis.IDENTITY, Vector3(0, 0, -220)), 0.1)
		check(a.assessment().get("outcome") == &"passed", "all bridges followed by finish passes despite faults")
		var result := a.assessment()
		a.observe_accident(1, a.id, &"ravine", Vector3(0, -20, 0))
		a.tick(1000)
		check(a.assessment() == result, "aftermath cannot revoke earned pass")
		for player in [1, 2, 3]:
			a.choose(player, a.id, 1, &"retry")
		check(a.test_item == 0 and a.assessment().is_empty() and a.minor_faults == 0, "retry clears attempt consequences")
	var a := AttemptState.new()
	start(a)
	a.test_item = 3
	a.observe_learner(1, AttemptState.CONTROLS.front)
	a.request_control(1, a.id, 1, &"front")
	check(a.observe_accident(1, a.id, &"ravine", Vector3(0, -15, -220)), "seated learner can suffer a lethal fall")
	a.observe_course(Transform3D(Basis.IDENTITY, Vector3(0, 0, -220)), 0.1)
	check(a.assessment().get("reason") == &"ravine", "death wins same-frame completion")
	start(a)
	a.test_item = 3
	a.remaining = 0
	a.observe_course(Transform3D(Basis.IDENTITY, Vector3(0, 0, -220)), 0.1)
	check(a.assessment().get("reason") == &"timeout", "zero timer wins same-frame completion")
	start(a)
	a.observe_course(Transform3D(Basis.IDENTITY, Vector3(0, -9, -30)), 0.1)
	check(a.assessment().get("reason") == &"ravine", "truck falling below course settles shared loss")
	print("Survival track failures: ", failures)
	quit(1 if failures else 0)
func start(a: AttemptState) -> void:
	a.begin(&"monster_truck", [1, 2, 3])
	for p in [1, 2, 3]:
		a.scene_ready(p, a.id)
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		printerr("FAIL: ", message)

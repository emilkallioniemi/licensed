extends SceneTree
var failures := 0
func _initialize() -> void:
	var a := AttemptState.new()
	start(a)
	var parked := Transform3D(Basis.IDENTITY, Vector3(17, 0, -10))
	for i in 180:
		a.observe_course(parked, 1.0 / 60.0)
	check(a.assessment().is_empty() and a.test_item == 0, "parking out of order cannot pass")
	a.observe_course(Transform3D(Basis(Vector3.UP, -PI / 2), Vector3(10, 0, -24)), 0.1)
	check(a.test_item == 1, "actual turn reaches first target")
	a.observe_course(Transform3D(Basis.IDENTITY, Vector3(21, 0, -24)), 0.1)
	check(a.test_item == 1, "cannot skip across bumps without entering")
	a.observe_course(Transform3D(Basis.IDENTITY, Vector3(12, 0, -24)), 0.1)
	a.observe_course(Transform3D(Basis.IDENTITY, Vector3(21, 0, -24)), 0.1)
	check(a.test_item == 2, "crossing bump section completes second item")
	a.record_recovery()
	check(a.test_item == 2 and a.minor_faults == 1, "recovery retains progress and records fault")
	a.observe_cone(0)
	a.observe_cone(0)
	check(a.minor_faults == 2, "one cone contact counts once and cannot prevent passing")
	a.speed = 1.0
	a.observe_course(parked, 3.0)
	check(a.assessment().is_empty(), "moving through parking does not pass")
	a.speed = 0.0
	a.observe_course(parked, 2.1)
	check(a.assessment().get("outcome") == &"passed", "recovered test can pass")
	var result := a.assessment()
	a.tick(1000.0)
	check(a.assessment() == result, "pass settles once and cannot become timeout")
	for p in [1, 2, 3]:
		a.choose(p, a.id, 1, &"retry")
	check(a.test_item == 0 and a.minor_faults == 0 and a.assessment().is_empty(), "retry clears progress faults and result")
	start(a)
	a.remaining = 0.0
	a.observe_course(parked, 3.0)
	a.tick(0.0)
	check(a.assessment().get("reason") == &"timeout", "zero timer wins over completion")
	print("Short test failures: ", failures)
	quit(1 if failures else 0)
func start(a: AttemptState) -> void:
	a.begin(&"monster_truck", [1, 2, 3])
	for p in [1, 2, 3]:
		a.scene_ready(p, a.id)
func check(ok: bool, label: String) -> void:
	if not ok:
		failures += 1
		printerr("FAIL: ", label)

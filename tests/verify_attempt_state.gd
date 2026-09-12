extends SceneTree
const Attempt := preload("res://scripts/attempt_state.gd")
var failures := 0

func _initialize() -> void:
	var attempt := Attempt.new()
	attempt.begin(&"monster_truck", [1001, 1002, 1003])
	var id: String = attempt.id
	check(not attempt.scene_ready(9999, id))
	check(not attempt.scene_ready(1001, "old"))
	check(attempt.scene_ready(1001, id))
	check(not attempt.scene_ready(1001, id))
	check(attempt.scene_ready(1002, id))
	attempt.tick(5.0)
	check(attempt.phase == &"loading" and attempt.remaining == 360.0)
	check(attempt.scene_ready(1003, id))
	check(attempt.phase == &"active" and attempt.remaining == 360.0)
	attempt.tick(1.5)
	check(attempt.remaining == 358.5)
	var guest := Attempt.new()
	guest.restore(attempt.snapshot())
	check(guest.id == id and guest.phase == &"active" and guest.remaining == 358.5)
	attempt.depart()
	check(not attempt.scene_ready(1003, id))
	attempt.tick(3.0)
	check(attempt.phase == &"departing" and attempt.remaining == 358.5)
	guest.restore(attempt.snapshot())
	check(guest.phase == &"departing")
	attempt.begin(&"monster_truck", [1001, 1002, 1003])
	check(attempt.id != id and not attempt.scene_ready(1001, id))
	attempt.tick(30.0)
	check(attempt.phase == &"departing" and attempt.remaining == 360.0)
	if failures == 0:
		print("PASS: scene readiness barrier, stale/duplicate rejection, arrival timer and load timeout")
	quit(1 if failures else 0)

func check(condition: bool) -> void:
	if not condition:
		failures += 1
		printerr("FAIL: ", get_stack())

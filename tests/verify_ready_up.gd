extends SceneTree
## Run: Godot --path . --script res://tests/verify_ready_up.gd --quit-after 600
## Use a Windows display: headless mode cannot catch native Windows TTS crashes.

var _failures := 0

func _initialize() -> void:
	call_deferred("_verify")


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures += 1
		printerr("FAIL: " + message)


func _verify() -> void:
	var waiting = load("res://scenes/waiting_room.tscn").instantiate()
	root.add_child(waiting)
	var room := RoomState.new()
	waiting._room = room
	waiting._bind_room(room)
	for id in [1001, 1002, 1003]:
		room.arrive(id, "Probe %d" % id)
		room.pick(id, &"monster_truck")
	for id in [1001, 1002, 1003]:
		room.take(id, &"random")
	print("READY_UP_PROBE: seating three players")
	for index in range(3):
		room.sit(1001 + index, index + 1)
	_check(room.is_counting_down(), "three ready players must start the countdown")
	_check(waiting._examiner.playing, "the examiner announcement must play")
	_check(waiting._examiner.stream.get_length() > 0.0, "the announcement must contain audio")
	room.stand(1003)
	_check(not waiting._examiner.playing, "standing must stop the announcement")
	room.sit(1003, 3)
	_check(waiting._examiner.playing, "readying again must restart the announcement")
	room.tick(10.0)
	await create_timer(1.2).timeout
	_check(waiting.is_in_test_area(), "countdown must launch the test")
	_check(waiting.test_area.visible, "the test area must appear after the fade")
	_check(not waiting.kit.visible, "the waiting room must disappear after the fade")
	waiting.queue_free()
	await process_frame
	if _failures == 0:
		print("PASS: three-player ready-up, announcement, cancellation, restart and test-area transition")
	quit(1 if _failures > 0 else 0)

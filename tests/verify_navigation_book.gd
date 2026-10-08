extends SceneTree
var failures := 0
func _initialize() -> void:
	call_deferred("verify")
func check(ok: bool, copy: String) -> void:
	if not ok:
		failures += 1
		printerr("FAIL: ", copy)
func press(key: Key) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = key
	event.pressed = true
	Input.parse_input_event(event)
func verify() -> void:
	var room = load("res://dev/solo_rehearsal.tscn").instantiate()
	root.add_child(room)
	await create_timer(0.3).timeout
	var book: NavigationBook = room.test_area.field_book
	check(not book.visible, "steering cannot see private book")
	room.select(&"rear")
	await process_frame
	await process_frame
	check(book.visible and book.spread == 0, "navigator opens contents rather than an automatic answer")
	room.test_area.boarding.set_process_unhandled_input(true)
	press(KEY_E)
	await create_timer(0.6).timeout
	check(book.spread == 1 and room.room_state().attempt.operators.rear == 1, "page key turns a page without leaving the seat")
	for layout in 8:
		book.reset_book(layout)
		for index in 3:
			book.turn(1)
			await create_timer(0.5).timeout
			var side := "LEFT" if SurvivalTrack.safe_side(layout, index) < 0 else "RIGHT"
			check(book.right.text.contains(side + " BRIDGE"), "page agrees with host bridge layout")
	book.turn(1)
	check(book.spread == 3 and not book.turning, "end of book has a firm bound")
	room.room_state().attempt.test_item = 2
	await process_frame
	check(book.spread == 3, "route progress cannot turn pages for the navigator")
	book.turn(-1)
	await create_timer(0.1).timeout
	book.reset_book(0)
	await create_timer(0.6).timeout
	check(book.spread == 0 and not book.turning, "retry cancels an in-flight page turn")
	room.select(&"pedals")
	await process_frame
	await process_frame
	check(not book.visible, "role change hides the entire private 3D viewport")
	room.free()
	print("Navigation book failures: ", failures)
	quit(1 if failures else 0)

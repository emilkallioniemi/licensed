extends SceneTree
## Exercises real reception controls and input forwarding without sending Steam invites.
## Run: godot --headless --path . --script res://tests/verify_reception_input.gd

func _initialize() -> void:
	call_deferred("_verify")


func _verify() -> void:
	var transport := root.get_node("Transport")
	transport.lobby_id = 123
	var desk = load("res://tests/reception_input_harness.gd").new()
	root.add_child(desk)
	desk._rebuild_rows(null, false)
	await process_frame
	await process_frame
	for label in ["Invite", "Join"]:
		var button: Button
		for candidate in desk._rows.find_children("*", "Button", true, false):
			if candidate.text == label:
				button = candidate
		var pos: Vector2 = button.get_global_rect().get_center()
		var motion := InputEventMouseMotion.new()
		motion.position = pos
		desk._input(motion)
		for down in [true, false]:
			var click := InputEventMouseButton.new()
			click.position = pos
			click.button_index = MOUSE_BUTTON_LEFT
			click.pressed = down
			desk._input(click)
			if down:
				desk._on_lobby_data_update(true, 789, 0)
				await process_frame
				await process_frame
		if not desk.actions.has(label):
			printerr("FAIL: clicking %s across a Steam lobby update did not reach its handler." % label)
			transport.lobby_id = 0
			quit(1)
			return
		await process_frame
		await process_frame
		if desk._list_queued or is_instance_valid(button):
			printerr("FAIL: the deferred refresh did not run after releasing %s." % label)
			transport.lobby_id = 0
			quit(1)
			return
	print("PASS: reception mouse clicks reach Invite and Join handlers.")
	transport.lobby_id = 0
	quit()

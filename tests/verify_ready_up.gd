extends SceneTree
## Run: Godot --path . --script res://tests/verify_ready_up.gd
## Use an external timeout; a frame cutoff can exit before awaited assertions.
## Use a Windows display: headless mode cannot catch native Windows TTS crashes.

var _failures := 0

func _initialize() -> void:
	call_deferred("_verify")


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures += 1
		printerr("FAIL: " + message)


func _verify() -> void:
	var room_scene := "res://scenes/waiting_room.tscn" if root.get_node("SteamClient").is_running() else "res://tests/network_room_harness.tscn"
	var waiting = load(room_scene).instantiate()
	root.add_child(waiting)
	current_scene = waiting
	if OS.get_cmdline_user_args().has("--capture-booking"):
		var camera := Camera3D.new()
		waiting.add_child(camera)
		camera.global_position = waiting.kit.get_node("AttachmentPoints/BookingBoardApproach").global_position + Vector3(0, 1.8, 0)
		var board = waiting.kit.find_child("BookingBoard", true, false)
		camera.look_at(board.global_position + Vector3(0, 1.9, 0))
		camera.current = true
		waiting.fade.to_clear(0.0)
		await create_timer(0.2).timeout
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://.scratch/monster-truck-build/booking.png")
		camera.queue_free()
	var room := RoomState.new()
	waiting._room = room
	waiting._bind_room(room)
	waiting._steam_id_of = {1: 1001, 2: 1002, 3: 1003}
	for id in [1001, 1002, 1003]:
		room.arrive(id, "Probe %d" % id)
		room.pick(id, &"monster_truck")
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
	_check(not waiting.test_area.visible, "arrival waits for the guests to load")
	_check(room.attempt.remaining == 360.0, "loading must not consume the test timer")
	var attempt_id: String = room.attempt.id
	waiting._accept_scene_ready(2, attempt_id, true)
	_check(not waiting.test_area.visible, "one unready guest still holds the arrival")
	waiting._accept_scene_ready(3, attempt_id, true)
	_check(waiting.test_area.visible, "the test area must appear after the fade")
	_check(not waiting.kit.visible, "the waiting room must disappear after the fade")
	_check(room.attempt.phase == &"active", "arrival commits the explicit active phase")
	await create_timer(0.2).timeout
	_check(room.attempt.remaining < 360.0, "the host timer runs without occupied controls")
	waiting.request_return_from_test_area()
	_check(room.attempt.phase == &"departing", "return is an explicit replicated transition")
	await create_timer(1.5).timeout
	_check(waiting.kit.visible and not waiting.test_area.visible, "return restores the waiting room")
	_check(not room.has_attempt() and not room.has_booking(), "return clears launch and picks")
	for occupant in room.players:
		_check(occupant.hold == &"" and occupant.chair == 0, "return clears roles and seats")
	# A guest disappears while the departure fade is pending. Its old continuation
	# must not reveal the car park after survivors have returned.
	for index in range(3):
		room.pick(1001 + index, &"monster_truck")
		room.sit(1001 + index, index + 1)
	room.tick(3.0)
	waiting._on_peer_disconnected(3)
	await create_timer(1.5).timeout
	_check(waiting.kit.visible and not waiting.test_area.visible, "loading loss cancels pending arrival")
	_check(room.player_count() == 2 and not room.has_attempt(), "survivors return without an attempt")
	# A load failure follows the same departure path, with all members retained.
	room.arrive(1003, "Probe 1003")
	waiting._steam_id_of[3] = 1003
	for index in range(3):
		room.pick(1001 + index, &"monster_truck")
		room.sit(1001 + index, index + 1)
	room.tick(3.0)
	waiting._accept_scene_ready(2, room.attempt.id, false)
	await create_timer(1.5).timeout
	_check(room.player_count() == 3 and not room.has_attempt(), "failed loading returns everyone")
	# Replay host snapshots through the guest presentation adapter, without roles.
	var host := RoomState.new()
	for index in range(3):
		host.arrive(1001 + index, "Probe")
		host.pick(1001 + index, &"monster_truck")
		host.sit(1001 + index, index + 1)
	host.tick(3.0)
	waiting.set_process(false)
	waiting._receive_state(host.snapshot())
	await create_timer(1.1).timeout
	_check(not waiting.test_area.visible, "replicated loading does not reveal the test area")
	for id in [1001, 1002, 1003]:
		host.attempt.scene_ready(id, host.attempt.id)
	waiting._receive_state(host.snapshot())
	_check(waiting.test_area.visible and not waiting.kit.visible, "replicated active reveals arrival without roles")
	host.attempt.depart()
	waiting._receive_state(host.snapshot())
	await create_timer(1.5).timeout
	_check(waiting.kit.visible and not waiting.test_area.visible, "replicated departure restores the room")
	# Host loss during loading uses the real fresh-room path on the development
	# transport. This does not stand in for three-human Steam acceptance.
	for index in range(3):
		room.pick(1001 + index, &"monster_truck")
		room.sit(1001 + index, index + 1)
	room.tick(3.0)
	root.get_node("Transport").kind = &"enet"
	waiting._on_host_vanished()
	await create_timer(0.7).timeout
	waiting = current_scene
	_check(waiting != null and waiting.room_state().player_count() == 1, "host loss creates the guest's own room")
	_check(not waiting.room_state().has_attempt(), "own room does not retain the abandoned attempt")
	waiting.queue_free()
	await process_frame
	if _failures == 0:
		print("PASS: three-player ready-up, announcement, cancellation, restart and test-area transition")
	quit(1 if _failures > 0 else 0)

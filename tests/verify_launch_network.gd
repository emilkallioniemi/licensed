extends SceneTree
## Three local development peers exercise the real launch RPCs and snapshots.
## This is protocol evidence, never three-human Steam play or feel evidence.
var failures := 0
var rooms: Array = []
var peers: Array[ENetMultiplayerPeer] = []

func _initialize() -> void:
	call_deferred("verify")

func verify() -> void:
	root.get_node("Transport").kind = &"enet"
	var port := 35000 + int(Time.get_ticks_usec() % 10000)
	for index in range(3):
		var branch := SubViewport.new()
		branch.own_world_3d = true
		branch.size = Vector2i(800, 600)
		branch.name = "Peer%d" % index
		root.add_child(branch)
		var api := SceneMultiplayer.new()
		set_multiplayer(api, branch.get_path())
		var peer := ENetMultiplayerPeer.new()
		var result := peer.create_server(port, 2) if index == 0 else peer.create_client("127.0.0.1", port)
		check(result == OK, "development peer opens")
		if result != OK:
			quit(1)
			return
		peers.append(peer)
		api.multiplayer_peer = peer
		var room = load("res://scenes/waiting_room.tscn").instantiate()
		room.name = "WaitingRoom"
		branch.add_child(room)
		rooms.append(room)
		if index != 0:
			await api.connected_to_server
		room._on_transport_ready()
	await create_timer(0.8).timeout
	var host = rooms[0].room_state()
	check(host.player_count() == 3, "three identities arrive through the network")
	for room in rooms:
		room.submit_command(&"pick", &"monster_truck")
	await create_timer(0.2).timeout
	for room in rooms:
		var occupant = room.room_state().player(room._steam_id_of.get(1, 0)) if room == rooms[0] else null
		var chair: int = occupant.palette if occupant != null else rooms.find(room) + 1
		room.submit_command(&"sit", chair)
	await create_timer(4.5).timeout
	for room in rooms:
		check(room.room_state().attempt.phase == &"active", "readiness RPC commits active on every peer")
		check(room.test_area.visible and not room.kit.visible, "every peer presents arrival")
		check(room.room_state().attempt.remaining < 360.0, "every peer receives the running timer")
		check(room.room_state().attempt.id == host.attempt.id, "every peer shares the same attempt identity")
	if OS.get_cmdline_user_args().has("--capture-truck"):
		await capture_truck()
	if OS.get_cmdline_user_args().has("--boarding"):
		await verify_boarding()
	# Lose one guest after arrival; survivors must observe departing, then reset.
	rooms[2].multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	peers[2].close()
	rooms[2].get_parent().queue_free()
	await process_frame
	await create_timer(0.5).timeout
	check(host.attempt.phase == &"departing", "guest loss starts authoritative departure")
	check(rooms[1].room_state().attempt.phase == &"departing", "guest receives departure phase")
	# Return theatre includes all surviving bodies walking through the entrance.
	await create_timer(7.5).timeout
	check(not host.has_attempt() and not host.has_booking(), "host completes return reset")
	check(not rooms[1].room_state().has_attempt(), "surviving guest receives reset")
	# Detach replication before freeing the independent fixture branches.
	for room in rooms:
		if is_instance_valid(room):
			room.multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
			room.get_parent().queue_free()
	for peer in peers:
		peer.close()
	await process_frame
	if failures == 0:
		print("PASS: three development peers launch by RPC, share arrival/timer and return on guest loss")
		if OS.get_cmdline_user_args().has("--boarding"):
			print("PASS: physical boarding, roof riding/detachment, guest look, moving release, contention and interruption recovery")
	quit(1 if failures else 0)

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		printerr("FAIL: ", message)

## Controlled moving truck fixture, development ENet only; no human feel claim.
func verify_boarding() -> void:
	var host_room = rooms[0]
	var boarding = host_room.test_area.boarding
	var truck = host_room.test_area.truck
	var learner = host_room._learner_of(1)
	# Fixture starts on the ground; all boarding thereafter uses walking/collisions.
	learner.global_position = truck.body.to_global(Vector3(1.1, 0.1, 7.0))
	boarding.test_intention = {"wish": Vector2(0, -1), "yaw": 0.0}
	await create_timer(2.0).timeout
	boarding.test_intention = {"wish": Vector2.ZERO, "yaw": 0.0}
	await create_timer(0.3).timeout
	print("BOARD deck: ", truck.body.to_local(learner.global_position), " ", learner.movement_mode)
	check(learner.support == &"truck" and truck.body.to_local(learner.global_position).y > 1.5, "walk from ground up boarding ramp onto truck")
	# Walk towards front control through roomy centre aisle.
	boarding.test_intention = {"wish": Vector2(-1, 0), "yaw": 0.0}
	await create_timer(0.36).timeout
	boarding.test_intention = {"wish": Vector2(0, -1), "yaw": 0.0}
	await create_timer(0.95).timeout
	boarding.test_intention = {"wish": Vector2(-1, 0), "yaw": 0.0}
	await create_timer(0.15).timeout
	boarding.test_intention = {"wish": Vector2.ZERO, "yaw": 0.0}
	await create_timer(0.2).timeout
	print("BOARD front: ", truck.body.to_local(learner.global_position))
	boarding.interact()
	await create_timer(0.2).timeout
	check(host_room.room_state().attempt.control_of(host_room._steam_id_of[1]) == &"front", "physical E takes front steering")
	boarding.controlled_motion(Vector3(0.6, 0, 0), 0.12)
	await create_timer(0.6).timeout
	boarding.interact()
	await create_timer(0.3).timeout
	check(not learner.is_seated() and learner.support == &"truck", "release while turning retains footing")
	for room in rooms:
		check(room.room_state().attempt.control_of(host_room._steam_id_of[1]) == &"", "release recovered on each peer")
	boarding.controlled_motion(Vector3.ZERO, 0.0)
	# Separate ground setup exercises the complete roof access and ordinary riding.
	truck.body.transform = Transform3D.IDENTITY
	learner.support = &""
	learner.global_position = truck.body.to_global(Vector3(-1.5, 0.1, 13.0))
	boarding.test_intention = {"wish": Vector2(0, -1), "yaw": 0.0}
	await create_timer(4.3).timeout
	boarding.test_intention = {"wish": Vector2.ZERO, "yaw": 0.0}
	await create_timer(0.2).timeout
	print("BOARD roof: ", truck.body.to_local(learner.global_position), " ", learner.movement_mode)
	check(learner.support == &"truck" and truck.body.to_local(learner.global_position).y > 4.1, "walk full roof access without placement or jump")
	boarding.controlled_motion(Vector3(1.0, 0, 0), 0.15)
	var start: Vector3 = truck.body.to_local(learner.global_position)
	await create_timer(1.0).timeout
	check(learner.support == &"truck" and truck.body.to_local(learner.global_position).distance_to(start) < 0.2, "ordinary turning roof riding holds relative footing")
	boarding.test_intention = {"wish": Vector2.ZERO, "yaw": 0.0, "jump": true}
	await create_timer(0.03).timeout
	boarding.test_intention = {"wish": Vector2.ZERO, "yaw": 0.0}
	var detached_at: Vector3 = learner.global_position
	await create_timer(0.2).timeout
	check(learner.support == &"" and learner.global_position.x > detached_at.x + 0.1, "jump detaches with inherited truck motion")
	boarding.controlled_motion(Vector3.ZERO, 0.0)
	await verify_guest_boarding()
	await verify_contention()
	print("BOARD correction counts: ", rooms[1].test_area.boarding.correction_count, ", ", rooms[2].test_area.boarding.correction_count)




func verify_guest_boarding() -> void:
	var room = rooms[1]
	var peer_id: int = room.multiplayer.get_unique_id()
	var player_id: int = room.player_id_for_peer(peer_id)
	var truck = rooms[0].test_area.truck
	var host_learner = rooms[0]._learner_of(peer_id)
	var local = room._learner_of(peer_id)
	var boarding = room.test_area.boarding
	var boarding_yaw: float = truck.body.global_rotation.y
	host_learner.global_position = truck.body.to_global(Vector3(1.1, 0.1, 7.0))
	host_learner.support = &""
	boarding.test_intention = {"wish": Vector2.ZERO, "yaw": boarding_yaw}
	await create_timer(0.2).timeout
	boarding.test_intention = {"wish": Vector2(0, -1), "yaw": boarding_yaw}
	await create_timer(2.0).timeout
	boarding.test_intention = {"wish": Vector2(-1, 0), "yaw": boarding_yaw}
	await create_timer(0.36).timeout
	boarding.test_intention = {"wish": Vector2(0, -1), "yaw": boarding_yaw}
	await create_timer(0.95).timeout
	boarding.test_intention = {"wish": Vector2(1, 0), "yaw": boarding_yaw}
	await create_timer(0.15).timeout
	boarding.test_intention = {"wish": Vector2.ZERO, "yaw": boarding_yaw}
	await create_timer(0.2).timeout
	print("BOARD guest pedals: ", truck.body.to_local(host_learner.global_position))
	check(host_learner.support == &"truck", "guest prediction boards authoritative truck")
	boarding.interact()
	await create_timer(0.3).timeout
	check(rooms[0].room_state().attempt.control_of(player_id) == &"pedals", "guest physical E is accepted at pedals")
	boarding.test_intention = {"wish": Vector2.ZERO, "yaw": 1.0}
	local.rotation.y = 1.0
	await create_timer(0.3).timeout
	check(absf(host_learner.rotation.y - 1.0) < 0.05 and absf(local.rotation.y - 1.0) < 0.05, "occupied guest free look survives snapshots")
	rooms[0].test_area.boarding.controlled_motion(Vector3(0.5, 0, 0), 0.1)
	boarding.interact()
	await create_timer(0.4).timeout
	var relative: Vector3 = truck.body.to_local(host_learner.global_position)
	check(not host_learner.is_seated() and relative.x < 0.8 and host_learner.support == &"truck", "moving pedals release stands in usable inward space")
	check(local.global_position.distance_to(host_learner.global_position) < 0.3, "guest and host agree after moving release")
	rooms[0].test_area.boarding.controlled_motion(Vector3.ZERO, 0.0)


func verify_contention() -> void:
	var guest = rooms[1]
	var other = rooms[2]
	var host = rooms[0]
	var truck = host.test_area.truck
	var other_peer: int = other.multiplayer.get_unique_id()
	var other_body = host._learner_of(other_peer)
	other_body.global_position = truck.body.to_global(Vector3(1.2, 1.65, -0.4))
	other_body.support = &"truck"
	other_body.support_pose = truck.body.global_transform
	other.test_area.boarding.test_intention = {"wish": Vector2.ZERO, "yaw": 0.0}
	await create_timer(0.25).timeout
	guest.test_area.boarding.interact()
	other.test_area.boarding.interact()
	await create_timer(0.25).timeout
	check(host.room_state().attempt.operators.size() == 1, "simultaneous peer E requests produce exactly one operator")
	var winner: int = host.room_state().attempt.operators.get(&"pedals", 0)
	check(winner != 0, "contention concerns physically reachable pedals")
	for room in rooms:
		check(room.room_state().attempt.operators.get(&"pedals", 0) == winner, "all peers recover same contention winner")
	var winning_room = guest if guest.player_id_for_peer(guest.multiplayer.get_unique_id()) == winner else other
	winning_room.test_area.boarding.interact()
	await create_timer(0.2).timeout
	check(host.room_state().attempt.operators.is_empty(), "winner releases before another occupancy generation")
	var boarding = guest.test_area.boarding
	boarding.test_intention = {"wish": Vector2(0, 1), "yaw": 0.0}
	await create_timer(0.1).timeout
	boarding.set_physics_process(false)
	await create_timer(0.5).timeout
	var body = host._learner_of(guest.multiplayer.get_unique_id())
	var stopped: Vector3 = body.global_position
	await create_timer(0.2).timeout
	check(stopped.distance_to(body.global_position) < 0.05, "interrupted held walking neutralizes after freshness window")
	boarding.test_intention = {"wish": Vector2.ZERO, "yaw": 0.0}
	boarding.set_physics_process(true)
	await create_timer(0.25).timeout
	var local = guest._learner_of(guest.multiplayer.get_unique_id())
	check(local.global_position.distance_to(body.global_position) < 0.25, "complete snapshot recovers after short interruption")

func capture_truck() -> void:
	var viewport = rooms[0].get_parent()
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	var camera := Camera3D.new()
	rooms[0].test_area.add_child(camera)
	var at: Vector3 = rooms[0].test_area.truck.global_position
	camera.global_position = at + Vector3(11, 10, 18)
	camera.look_at(at + Vector3(0, 2, 3))
	camera.current = true
	await RenderingServer.frame_post_draw
	viewport.get_texture().get_image().save_png("res://.scratch/monster-truck-build/02-rough-truck.png")
	camera.queue_free()

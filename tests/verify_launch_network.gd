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
		if not root.get_node("SteamClient").is_running():
			room.set_script(load("res://tests/network_room_harness.gd"))
			print("FIXTURE: native ENet room bootstrap; Steam login is not under test")
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
	for room in rooms:
		if room._learner_of(room.multiplayer.get_unique_id()) == null:
			check(false, "network fixture requires real spawned learners")
			quit(1)
			return
	if OS.get_cmdline_user_args().has("--capture-truck"):
		await capture_truck()
	if OS.get_cmdline_user_args().has("--boarding"):
		await verify_boarding()
	if OS.get_cmdline_user_args().has("--recovery"):
		await verify_recovery_network()
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

## Initial motion fixture isolates footing; no shipping controlled-motion API.
func seed_motion(linear: Vector3, angular: float) -> void:
	var state: AttemptState = rooms[0].room_state().attempt
	state.speed = linear.length()
	state.parking_brake = linear == Vector3.ZERO
	state.front_angle = -0.25 if angular != 0.0 else 0.0
	state.rear_angle = 0.0

func verify_shared_driving() -> void:
	var host = rooms[0]
	var state: AttemptState = host.room_state().attempt
	var controls := [&"front", &"pedals", &"rear"]
	# Ground boarding is covered above; set up only the driving comparison here.
	for room in rooms:
		var player_id: int = room.player_id_for_peer(room.multiplayer.get_unique_id())
		if state.control_of(player_id) != &"":
			room.test_area.boarding.interact()
	await create_timer(0.2).timeout
	for i in 3:
		var peer_id: int = rooms[i].multiplayer.get_unique_id()
		var body = host._learner_of(peer_id)
		body.global_position = host.test_area.truck.body.to_global(AttemptState.CONTROLS[controls[i]] + Vector3(0, 0.05, 0.5))
		body.support = &"truck"
		body.support_pose = host.test_area.truck.body.global_transform
		rooms[i].test_area.boarding.test_intention = {"wish": Vector2.ZERO, "yaw": 0.0}
	await create_timer(0.2).timeout
	for room in rooms:
		room.test_area.boarding.interact()
	await create_timer(0.3).timeout
	check(state.operators.size() == 3, "three physical controls occupied by different peers")
	state.front_angle = 0.0
	state.rear_angle = 0.0
	var origin: Vector3 = host.test_area.truck.body.global_position
	var yaw: float = host.test_area.truck.body.rotation.y
	var pedal = rooms[1].test_area.boarding
	var pedal_player: int = rooms[1].player_id_for_peer(rooms[1].multiplayer.get_unique_id())
	pedal._action.rpc_id(1, state.id, 1, state.generations[pedal_player], &"parking")
	rooms[0].test_area.boarding.test_intention["steer"] = 0.5
	rooms[2].test_area.boarding.test_intention["steer"] = -0.5
	pedal.test_intention["throttle"] = true
	await create_timer(1.0).timeout
	check(state.speed > 1.5 and host.test_area.truck.body.global_position.distance_to(origin) > 0.8, "guest throttle moves real truck")
	check(absf(host.test_area.truck.body.rotation.y - yaw) > 0.1 and state.front_angle > 0 and state.rear_angle < 0, "both axles produce moving turn")
	pedal._action.rpc_id(1, state.id, 2, state.generations[pedal_player], &"direction")
	await create_timer(0.1).timeout
	check(state.direction == 1, "network R rejected while moving")
	pedal.test_intention["throttle"] = false
	pedal.test_intention["brake"] = true
	await create_timer(0.6).timeout
	check(state.speed == 0.0, "network service brake stops truck")
	pedal._action.rpc_id(1, state.id, 3, state.generations[pedal_player], &"direction")
	await create_timer(0.15).timeout
	pedal.test_intention["brake"] = false
	pedal.test_intention["throttle"] = true
	await create_timer(0.6).timeout
	check(state.direction == -1 and state.speed < -0.5, "network reverse drives truck backward")
	pedal._action.rpc_id(1, state.id, 4, state.generations[pedal_player], &"parking")
	pedal._action.rpc_id(1, state.id, 4, state.generations[pedal_player], &"parking")
	await create_timer(0.5).timeout
	check(state.parking_brake and state.speed == 0.0, "duplicate parking event parks once")
	for room in rooms:
		check(room.room_state().attempt.parking_brake and room.room_state().attempt.direction == -1, "persistent instruments agree across peers")
	print("DRIVE: real three-peer turn, stopped reverse, and persistent parking verified")
	# Drive the real collision hull into a marked gate, then hear one impact.
	for room in rooms:
		room.test_area.boarding.test_intention = {"wish": Vector2.ZERO, "yaw": 0.0}
	await create_timer(0.1).timeout
	state.front_angle = 0.0
	state.rear_angle = 0.0
	state.speed = 6.0
	state.parking_brake = false
	host.test_area.truck.body.global_transform = Transform3D(Basis.IDENTITY, host.test_area.to_global(Vector3(4, 0, -17)))
	var heard := [false]
	host.test_area.truck.impact.finished.connect(func(): heard[0] = true)
	await create_timer(0.7).timeout
	check(state.speed == 0.0 and heard[0], "real gate collision stops truck and plays impact feedback")

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
	seed_motion(Vector3(0.6, 0, 0), 0.12)
	await create_timer(0.6).timeout
	boarding.interact()
	await create_timer(0.3).timeout
	check(not learner.is_seated() and learner.support == &"truck", "release while turning retains footing")
	for room in rooms:
		check(room.room_state().attempt.control_of(host_room._steam_id_of[1]) == &"", "release recovered on each peer")
	seed_motion(Vector3.ZERO, 0.0)
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
	seed_motion(Vector3(1.0, 0, 0), 0.15)
	var start: Vector3 = truck.body.to_local(learner.global_position)
	await create_timer(1.0).timeout
	check(learner.support == &"truck" and truck.body.to_local(learner.global_position).distance_to(start) < 0.2, "ordinary turning roof riding holds relative footing")
	boarding.test_intention = {"wish": Vector2.ZERO, "yaw": 0.0, "jump": true}
	await create_timer(0.03).timeout
	boarding.test_intention = {"wish": Vector2.ZERO, "yaw": 0.0}
	var detached_at: Vector3 = learner.global_position
	await create_timer(0.2).timeout
	check(learner.support == &"" and learner.global_position.distance_to(detached_at) > 0.1, "jump detaches with inherited truck motion")
	seed_motion(Vector3.ZERO, 0.0)
	await verify_guest_boarding()
	await verify_contention()
	await verify_shared_driving()
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
	seed_motion(Vector3(0.5, 0, 0), 0.1)
	boarding.interact()
	await create_timer(0.4).timeout
	var relative: Vector3 = truck.body.to_local(host_learner.global_position)
	check(not host_learner.is_seated() and relative.x < 0.8 and host_learner.support == &"truck", "moving pedals release stands in usable inward space")
	check(local.global_position.distance_to(host_learner.global_position) < 0.3, "guest and host agree after moving release")
	seed_motion(Vector3.ZERO, 0.0)


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
	viewport.get_texture().get_image().save_png("res://.scratch/monster-truck-build/03-rough-truck.png")
	for control in [&"front", &"pedals", &"rear"]:
		var seat: Vector3 = AttemptState.CONTROLS[control]
		camera.global_position = at + seat + Vector3(0, 1.3, 0)
		camera.rotation = Vector3(-0.25, PI if control == &"rear" else 0.0, 0)
		await RenderingServer.frame_post_draw
		viewport.get_texture().get_image().save_png("res://.scratch/monster-truck-build/03-%s-sight.png" % control)
	camera.queue_free()

## Delayed application of complete host snapshots models a brief delivery stall.
## Setup placement is a fixture; ejection and rescue use production collisions.
func verify_recovery_network() -> void:
	var host = rooms[0]
	var guest = rooms[1]
	var state: AttemptState = host.room_state().attempt
	var truck: MonsterTruck = host.test_area.truck
	for room in rooms:
		room.test_area.boarding.test_intention = {"wish": Vector2.ZERO, "yaw": 0.0}
		if state.control_of(room.player_id_for_peer(room.multiplayer.get_unique_id())) != &"":
			room.test_area.boarding.interact()
	await create_timer(0.2).timeout
	state.speed = 0.0
	state.parking_brake = true
	state.front_angle = 0.0
	state.rear_angle = 0.0
	truck.body.transform = Transform3D.IDENTITY
	truck.vertical_speed = 0.0
	var peer_id: int = guest.multiplayer.get_unique_id()
	var player_id: int = guest.player_id_for_peer(peer_id)
	var body: Learner = host._learner_of(peer_id)
	body.apply_recovery(&"independent")
	body.global_position = truck.body.to_global(Vector3(0, 4.3, 0))
	body.support = &"truck"
	body.support_pose = truck.body.global_transform
	await create_timer(0.25).timeout
	var local: Learner = guest._learner_of(peer_id)
	check(local.support == &"truck", "guest shares roof support before delivery stall")
	guest.test_area.boarding.set_physics_process(false)
	state.parking_brake = false
	state.speed = 8.0
	state.front_angle = 0.6
	state.rear_angle = -0.6
	await create_timer(0.25).timeout
	check(body.support == &"" and state.accident_states.get(player_id) == &"ejected", "host resolves ejection during delayed snapshots")
	state.speed = 0.0
	state.parking_brake = true
	guest.test_area.boarding.set_physics_process(true)
	await create_timer(0.3).timeout
	check(local.support == &"" and local.global_position.distance_to(body.global_position) < 0.6, "delayed correction preserves detached shared trajectory")
	for room in rooms:
		check(room.room_state().attempt.accident_states.get(player_id) == &"ejected", "all peers recover host accident observation")
	await create_timer(2.0).timeout
	check(state.accident_states.get(player_id) == &"landed", "shared harmless landing completes fall")
	# Pin the former operator under the deck, then collect them by actual driving.
	truck.body.transform = Transform3D.IDENTITY
	truck.vertical_speed = 0.0
	body.apply_recovery(&"independent")
	body.global_position = truck.body.to_global(Vector3(0, 0.02, 0))
	await create_timer(0.25).timeout
	check(body.movement_mode == &"trapped" and local.movement_mode == &"trapped", "host and guest agree on physical deck entrapment")
	check(local.global_position.distance_to(body.global_position) < 0.2, "trapped learner stays in shared world frame")
	var collector: Learner = host._learner_of(1)
	collector.apply_recovery(&"independent")
	collector.global_position = truck.body.to_global(AttemptState.CONTROLS.pedals + Vector3(0, 0.05, 0.5))
	collector.support = &"truck"
	collector.support_pose = truck.body.global_transform
	await create_timer(0.2).timeout
	host.test_area.boarding.interact()
	await create_timer(0.2).timeout
	var collector_id: int = host.player_id_for_peer(1)
	check(state.control_of(collector_id) == &"pedals", "friend physically takes pedals for rescue")
	state.driving_action(collector_id, state.id, 100, state.generations[collector_id], &"direction")
	state.driving_action(collector_id, state.id, 101, state.generations[collector_id], &"parking")
	state.front_angle = 0.0
	state.rear_angle = 0.0
	host.test_area.boarding.test_intention = {"wish": Vector2.ZERO, "yaw": 0.0, "throttle": true}
	await create_timer(2.1).timeout
	host.test_area.boarding.test_intention = {"wish": Vector2.ZERO, "yaw": 0.0, "brake": true}
	await create_timer(0.5).timeout
	for room in rooms:
		check(room.room_state().attempt.accident_states.get(player_id) == &"rescued", "all peers see physical truck rescue without teleport")
	check(local.global_position.distance_to(body.global_position) < 0.3, "rescued guest correction agrees with host")
	print("RECOVERY: delayed snapshots, shared ejection, landing, entrapment and collection verified")

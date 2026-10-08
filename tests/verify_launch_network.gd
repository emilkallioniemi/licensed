extends SceneTree

var capture_view_settings: Array[Dictionary] = []
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
	if OS.get_cmdline_user_args().has("--checkpoint-diagnostics"):
		await create_timer(2.0).timeout
		for room in rooms:
			check(room.test_area.boarding.has_node("CheckpointDiagnostics"), "opt-in capture is attached to each real peer")
	if OS.get_cmdline_user_args().has("--survival"):
		await verify_survival_network()

	if OS.get_cmdline_user_args().has("--failure"):
		await verify_failure_network()
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
			print("PASS: revised climbing, shared cameras, navigation, shared finish and lethal failure")
	quit(1 if failures else 0)

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		printerr("FAIL: ", message)

func verify_failure_network() -> void:
	var host: AttemptState = rooms[0].room_state().attempt
	var old_id := host.id
	# Real occupied guest pedal before concession: aftermath must release its
	# visible pad/load sound and keep remote tyre motion following the host.
	var guest = rooms[1]
	var guest_peer: int = guest.multiplayer.get_unique_id()
	var learner = rooms[0]._learner_of(guest_peer)
	learner.global_position = rooms[0].test_area.truck.body.to_global(AttemptState.CONTROLS.pedals + Vector3(0, 0.05, 0.5))
	learner.support = &"truck"
	learner.support_pose = rooms[0].test_area.truck.body.global_transform
	await create_timer(0.3).timeout
	guest.test_area.boarding._interaction.rpc_id(1, host.id, 10, &"pedals")
	await create_timer(0.3).timeout
	guest.test_area.boarding.test_intention = {"wish": Vector2.ZERO, "yaw": 0.0, "throttle": true}
	host.parking_brake = false
	await create_timer(0.5).timeout
	check(guest.test_area.truck.find_child("ThrottlePedal", true, false).rotation.x < -0.1, "guest throttle is visibly depressed before concession")
	for room in rooms:
		room.choose_attempt(&"concede")
	await create_timer(0.5).timeout
	for room in rooms:
		check(room.room_state().attempt.phase == &"aftermath", "unanimous RPC concession reaches every peer")
		check(room.test_area._guidance.text.begins_with("ATTEMPT LOST"), "shared failure is visible without examiner")
	var remote_roll: Node3D = guest.test_area.truck.find_child("FrontLRoll", true, false)
	var before_roll := remote_roll.rotation.x
	await create_timer(0.3).timeout
	check(not is_equal_approx(remote_roll.rotation.x, before_roll), "guest tyres keep rolling through host-owned physical aftermath")
	check(is_zero_approx(guest.test_area.truck.find_child("ThrottlePedal", true, false).rotation.x) and guest.test_area.truck.sound.load_layer.volume_db < -30.0, "guest aftermath releases visible throttle and load sound")
	guest.test_area.boarding.test_intention = {"wish": Vector2.ZERO, "yaw": 0.0}
	await create_timer(5.8).timeout
	for room in rooms:
		check(room.room_state().attempt.phase == &"settled", "every peer reaches results after aftermath")
	if OS.get_cmdline_user_args().has("--capture-results"):
		rooms[0].get_viewport().render_target_update_mode = SubViewport.UPDATE_ALWAYS
		await process_frame
		await RenderingServer.frame_post_draw
		rooms[0].get_viewport().get_texture().get_image().save_png("/private/tmp/licensed-05-results.png")
	rooms[0].choose_attempt(&"retry")
	rooms[1].choose_attempt(&"waiting_room")
	rooms[2].choose_attempt(&"retry")
	await create_timer(0.3).timeout
	check(host.id == old_id, "mixed shared choices keep aftermath")
	rooms[1].choose_attempt(&"retry")
	await create_timer(1.8).timeout
	for room in rooms:
		var state: AttemptState = room.room_state().attempt
		check(state.id != old_id and state.phase == &"active", "retry synchronizes new arrival without chairs")
		check(state.assessment().is_empty() and state.choices.is_empty() and state.parking_brake, "retry resets failure choices and secures truck")
		check(room.test_area.truck.body.position.length() < 0.2, "retry resets physical truck")
		for reset_learner in room._learners():
			check(not reset_learner.is_seated() and reset_learner.visual.scale.is_equal_approx(Vector3.ONE), "retry clears occupied and collapsed presentation for all three learners")
	print("FAILURE: shared concession, aftermath, changed choices and synchronized retry verified")

## Bounded real input path following; failure reports the physical stopped point.
func drive_track_to(target: Vector3, tolerance: float) -> void:
	var host = rooms[0]
	var state: AttemptState = host.room_state().attempt
	var truck: MonsterTruck = host.test_area.truck
	var blocked_steps := 0
	var reversing := 0
	for step in 450:
		if state.phase != &"active":
			if target.z < SurvivalTrack.FINISH_Z and state.assessment().get("outcome") == &"passed":
				return
			check(false, "route driving remains active at " + str(target))
			return
		var offset: Vector3 = host.test_area.to_global(target) - truck.body.global_position
		offset.y = 0.0
		if offset.length() < tolerance:
			return
		var desired := atan2(-offset.x, -offset.z)
		var error := wrapf(desired - truck.body.rotation.y, -PI, PI)
		var angle := clampf(-error * 1.0, -0.6, 0.6)
		blocked_steps = blocked_steps + 1 if state.speed < 0.1 and truck.impact_speed > 0 else 0
		if blocked_steps > 5:
			reversing = 25
			blocked_steps = 0
		if reversing > 0:
			reversing -= 1
			rooms[0].test_area.boarding.test_intention = {"wish": Vector2.ZERO, "steer": clampf((-angle - state.front_angle) * 8.0, -1.0, 1.0)}
			rooms[1].test_area.boarding.test_intention = {"wish": Vector2.ZERO, "brake": true}
			await create_timer(0.05).timeout
			continue
		rooms[0].test_area.boarding.test_intention = {"wish": Vector2.ZERO, "steer": clampf((angle - state.front_angle) * 8.0, -1.0, 1.0)}
		rooms[1].test_area.boarding.test_intention = {"wish": Vector2.ZERO, "throttle": state.speed < 2.0}
		await create_timer(0.05).timeout
	print("ROUTE missed ", target, " at ", host.test_area.to_local(truck.body.global_position), " heading ", truck.body.rotation.y)
	check(false, "route driver reaches " + str(target))

func verify_survival_network() -> void:
	var host = rooms[0]
	var state: AttemptState = host.room_state().attempt
	var truck: MonsterTruck = host.test_area.truck
	for index in 3:
		var peer_id: int = rooms[index].multiplayer.get_unique_id()
		var learner: Learner = host._learner_of(peer_id)
		var control: StringName = [&"front", &"pedals", &"rear"][index]
		learner.global_position = truck.body.to_global(AttemptState.CONTROLS[control] + Vector3(0, 0.05, 0.5))
		learner.support = &"truck"
		learner.support_pose = truck.body.global_transform
		rooms[index].test_area.boarding.test_intention = {"wish": Vector2.ZERO}
		if index == 0:
			host.test_area.boarding._accept_interaction(peer_id, state.id, 10, control)
		else:
			rooms[index].test_area.boarding._interaction.rpc_id(1, state.id, 10, control)
	await create_timer(0.4).timeout
	check(state.operators.size() == 3, "three peers occupy steering, speed and navigation")
	if state.operators.size() != 3:
		print("SEATING: ", state.operators, " accidents ", state.accident_states)
		return
	for index in 3:
		var room = rooms[index]
		var player: int = room.player_id_for_peer(room.multiplayer.get_unique_id())
		check(room.test_area.can_read_report(room.room_state().attempt, player) == (index == 2), "only navigator has private directions")
		check(room.test_area.track.layout == state.route_layout, "replicated report matches physical bridge layout")
	# Production peer input drives all crossings, without pose/progress injection.
	for index in 3:
		var side := SurvivalTrack.safe_side(state.route_layout, index)
		var junction: float = SurvivalTrack.JUNCTIONS[index]
		await drive_track_to(Vector3(side * 18, 0, junction + 3), 1.5)
		await drive_track_to(Vector3(side * 18, 0, junction - 7), 1.0)
		await drive_track_to(Vector3(side * 18, 0, junction - 22), 1.0)
		await drive_track_to(Vector3(side * 18, 0, junction - 54), 0.8)
		check(state.test_item == index + 1, "physical bridge crossing completes checkpoint " + str(index + 1))
		if state.phase != &"active":
			check(false, "route driver stays alive through correct bridges")
			return
	await drive_track_to(Vector3(0, 0, -210), 1.5)
	await drive_track_to(Vector3(0, 0, -221), 1.0)
	for room in rooms:
		room.test_area.boarding.test_intention = {"wish": Vector2.ZERO}
	await create_timer(6.5).timeout
	for room in rooms:
		check(room.room_state().attempt.assessment().get("outcome") == &"passed", "surviving track passes for every peer")
		room.choose_attempt(&"retry")
	await create_timer(3.5).timeout
	for room in rooms:
		check(room.room_state().attempt.phase == &"active" and room.room_state().attempt.test_item == 0, "retry resets all peers")
		check(room.test_area.track.layout == host.room_state().attempt.route_layout, "retry regenerates identical geometry on all peers")
	# Isolated fall setup; real gravity must kill even while recovery is held.
	# The former x=40 apron-side point is now a solid quarry ledge. Drop into
	# the actual first ravine, between the two bridges, for every route layout.
	truck.body.global_position = host.test_area.to_global(Vector3(0, 0, -60))
	truck.vertical_speed = 0
	rooms[2].test_area.boarding.test_intention = {"wish": Vector2.ZERO, "recover": true}
	await create_timer(3.5).timeout
	for room in rooms:
		check(room.room_state().attempt.assessment().get("reason") == &"ravine", "real fall causes shared failure and cannot be recovered")
	if failures == 0:
		print("PASS: navigation privacy, replicated bridges, actual three-peer driving, shared finish/retry and lethal fall")

func capture_revision(stage: String) -> void:
	if not OS.get_cmdline_user_args().has("--revision-capture"):
		return
	for i in 3:
		var viewport = rooms[i].get_parent()
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		await process_frame
		await RenderingServer.frame_post_draw
		viewport.get_texture().get_image().save_png("res://.scratch/monster-truck-build/revision-%s-%d.png" % [stage, i])

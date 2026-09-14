extends SceneTree

var capture_view_settings: Array[Dictionary] = []
var evidence_prefix := "08a" if OS.get_cmdline_user_args().has("--capture-scrapyard") else "08"
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
	if OS.get_cmdline_user_args().has("--capture-truck"):
		await capture_truck()
	if OS.get_cmdline_user_args().has("--capture-scrapyard"):
		await verify_scrapyard_exterior()
	if OS.get_cmdline_user_args().has("--revision") or OS.get_cmdline_user_args().has("--boarding") or OS.get_cmdline_user_args().has("--recovery"):
		await verify_revision()

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
			print("PASS: revised climbing, shared cameras, speed/balance, swaps, recovery and short-test completion")
	quit(1 if failures else 0)

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		printerr("FAIL: ", message)

func capture_truck() -> void:
	configure_scenery_capture(true)
	# Let the production arrival fade finish before assessing material brightness.
	await create_timer(1.1).timeout
	var viewport = rooms[0].get_parent()
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.audio_listener_enable_3d = true
	if OS.get_cmdline_user_args().has("--capture-scrapyard"):
		await RenderingServer.frame_post_draw
		viewport.get_texture().get_image().save_png("res://.scratch/monster-truck-build/08a-arrival.png")
	var camera := Camera3D.new()
	camera.fov = 88.0
	rooms[0].test_area.add_child(camera)
	var at: Vector3 = rooms[0].test_area.truck.global_position
	camera.global_position = at + Vector3(11, 10, 18)
	camera.look_at(at + Vector3(0, 2, 3))
	camera.current = true
	await RenderingServer.frame_post_draw
	viewport.get_texture().get_image().save_png("res://.scratch/monster-truck-build/" + evidence_prefix + "-game-truck.png")
	if OS.get_cmdline_user_args().has("--capture-scrapyard"):
		for view in [Vector3(-6, 1.75, 2), Vector3(0, 6.4, -9), Vector3(24, 19, 15)]:
			camera.global_position = rooms[0].test_area.to_global(view)
			camera.look_at(rooms[0].test_area.to_global(Vector3(0, 2, -12) if view.z > 0 else Vector3(0, 3, 20)))
			await RenderingServer.frame_post_draw
			var label := "ground" if view.y < 2 else ("roof" if view.y < 7 else "yard")
			viewport.get_texture().get_image().save_png("res://.scratch/monster-truck-build/08a-%s.png" % label)
		var frame_ms: Array[float] = []
		var previous := Time.get_ticks_usec()
		for sample in 120:
			await process_frame
			var now := Time.get_ticks_usec()
			frame_ms.append((now - previous) / 1000.0)
			previous = now
		frame_ms.sort()
		print("SCRAPYARD three-world 1280x720 MSAA4 frame intervals ms p50=", frame_ms[60], " p95=", frame_ms[114], " max=", frame_ms[119])
		print("SCRAPYARD RENDER draws=", viewport.get_render_info(Viewport.RENDER_INFO_TYPE_VISIBLE, Viewport.RENDER_INFO_DRAW_CALLS_IN_FRAME), " primitives=", viewport.get_render_info(Viewport.RENDER_INFO_TYPE_VISIBLE, Viewport.RENDER_INFO_PRIMITIVES_IN_FRAME))
	for control in [&"front", &"pedals", &"rear"]:
		var seat: Vector3 = AttemptState.CONTROLS[control]
		camera.global_position = at + seat + Vector3(0, Learner.SEATED_EYE_HEIGHT, 0)
		camera.rotation = Vector3(0, PI if control == &"rear" else 0.0, 0)
		await RenderingServer.frame_post_draw
		viewport.get_texture().get_image().save_png("res://.scratch/monster-truck-build/" + evidence_prefix + "-%s-forward.png" % control)
		camera.rotation.x = -0.25
		await RenderingServer.frame_post_draw
		viewport.get_texture().get_image().save_png("res://.scratch/monster-truck-build/" + evidence_prefix + "-%s-sight.png" % control)
	# Capture actual rendered engine audio with a listener inside the cab.
	var bus := AudioServer.bus_count
	AudioServer.add_bus()
	AudioServer.set_bus_name(bus, "TruckEvidence")
	var capture := AudioEffectCapture.new()
	capture.buffer_length = 1.0
	AudioServer.add_bus_effect(bus, capture)
	var sound = rooms[0].test_area.truck.sound
	for player in sound.get_children():
		if player is AudioStreamPlayer3D:
			player.bus = "TruckEvidence"
	await create_timer(0.5).timeout
	var frames := capture.get_buffer(capture.get_frames_available())
	var peak := 0.0
	for frame in frames:
		peak = maxf(peak, maxf(absf(frame.x), absf(frame.y)))
	check(peak > 0.00001 and peak < 0.95, "actual cab audio mixer emits non-silent unclipped vehicle sound")
	print("AUDIO captured frames=", frames.size(), " peak=", peak)
	for player in sound.get_children():
		if player is AudioStreamPlayer3D:
			player.bus = "Master"
	AudioServer.remove_bus(bus)
	camera.queue_free()
	configure_scenery_capture(false)

## Delayed application of complete host snapshots models a brief delivery stall.
## Setup placement is a fixture; ejection and rescue use production collisions.
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
		check(room.test_area.examiner_subtitle.text == "We will leave it there.", "shared offline examiner response")
		check(room.test_area.examiner_audio.stream.get_length() > 0.0 and room.test_area.examiner_audio.playing, "failure response plays offline audio")
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
	print("FAILURE: shared concession, examiner, aftermath, changed choices and synchronized retry verified")

## Bounded real input path following; failure reports the physical stopped point.
func verify_scrapyard_exterior() -> void:
	var failures_before := failures
	for room in rooms:
		var area: Node3D = room.test_area
		var space := area.get_world_3d().direct_space_state
		var ground := PhysicsRayQueryParameters3D.create(area.to_global(Vector3(46, 3, -9)), area.to_global(Vector3(46, -1, -9)), 1)
		check(not space.intersect_ray(ground).is_empty(), "each peer has exterior ground after a fence vault")
		var salvage := PhysicsRayQueryParameters3D.create(area.to_global(Vector3(46, 0.7, -9)), area.to_global(Vector3(39, 0.7, -9)), 4)
		check(not space.intersect_ray(salvage).is_empty(), "each peer has solid exterior salvage for truck contact")
	var area: Node3D = rooms[0].test_area
	var walker := CharacterBody3D.new()
	walker.collision_layer = 0
	walker.collision_mask = 1
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.3
	capsule.height = 1.7
	shape.shape = capsule
	shape.position.y = 0.85
	walker.add_child(shape)
	area.add_child(walker)
	walker.position = Vector3(46, 3, -9)
	for i in 90:
		await physics_frame
		walker.velocity.y -= 18.0 / 60.0
		walker.move_and_slide()
	check(walker.is_on_floor() and walker.position.y > -0.2, "fence-vault capsule lands on exterior ground")
	var start := walker.position
	var contacted := false
	for i in 120:
		await physics_frame
		walker.velocity = Vector3(-2, -0.3, 0)
		walker.move_and_slide()
		contacted = contacted or walker.is_on_wall()
	check(contacted and start.x - walker.position.x < 3.5, "walking capsule stops against exterior salvage instead of passing through")
	walker.queue_free()
	if failures == failures_before:
		print("SCRAPYARD exterior ground, truck contact and capsule landing/walking PASS")


func configure_scenery_capture(enabled: bool) -> void:
	if not OS.get_cmdline_user_args().has("--capture-scrapyard"):
		return
	if enabled:
		capture_view_settings.clear()
	for i in rooms.size():
		var viewport: SubViewport = rooms[i].get_parent()
		if enabled:
			capture_view_settings.append({"size": viewport.size, "msaa": viewport.msaa_3d, "update": viewport.render_target_update_mode})
			viewport.size = Vector2i(1280, 720)
			viewport.msaa_3d = Viewport.MSAA_4X
			viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		else:
			viewport.size = capture_view_settings[i].size
			viewport.msaa_3d = capture_view_settings[i].msaa
			viewport.render_target_update_mode = capture_view_settings[i].update

func verify_revision() -> void:
	var host = rooms[0]
	var state: AttemptState = host.room_state().attempt
	var truck: MonsterTruck = host.test_area.truck
	var ids: Array[int] = []
	var controls := [&"front", &"pedals", &"rear"]
	# Place by the vehicle; climbing uses ordinary held movement on all peers.
	for i in 3:
		var peer_id: int = rooms[i].multiplayer.get_unique_id()
		ids.append(host.player_id_for_peer(peer_id))
		var learner: Learner = host._learner_of(peer_id)
		learner.global_position = truck.body.to_global(Vector3(-3.9, 0.1, -1.1 + i * 1.1))
		rooms[i].test_area.boarding.test_intention = {"wish": Vector2(1, 0), "yaw": 0.0, "climb": true}
	await create_timer(1.7).timeout
	for i in 3:
		var learner: Learner = host._learner_of(rooms[i].multiplayer.get_unique_id())
		check(learner.global_position.y > 1.6, "held Space climbs truck for peer %d: %s" % [i, learner.global_position])
		rooms[i].test_area.boarding.test_intention = {"wish": Vector2.ZERO, "yaw": 0.0}
		# Isolate occupancy RPC from mouse aiming; physical reach still host-validated.
		learner.global_position = truck.body.to_global(AttemptState.CONTROLS[controls[i]] + Vector3(0, 0.05, 0.5))
		if i == 0:
			learner.camera.look_at(truck.body.to_global(AttemptState.CONTROLS[controls[i]]) + Vector3.UP * 0.5)
			check(host.test_area.boarding._nearest_control(learner.global_position) == controls[i], "aim selects highlighted seat")
			host.test_area.boarding.interaction_sequence = 9
			host.test_area.boarding.interact()
		else:
			rooms[i].test_area.boarding._interaction.rpc_id(1, state.id, 10, controls[i])
	await create_timer(0.3).timeout
	check(state.operators.size() == 3, "three peers occupy distinct controls")
	for room in rooms:
		var local: Learner = room._learner_of(room.multiplayer.get_unique_id())
		local._update_presentation(0.016, 1.0)
		check(local.camera.global_position.y > room.test_area.truck.body.global_position.y + 7.0, "every seated camera sees over cab")
	await capture_revision("seated")
	var pedal = rooms[1].test_area.boarding
	var balance = rooms[2].test_area.boarding
	pedal.test_intention["throttle"] = true
	balance.test_intention["steer"] = 1.0
	balance.test_intention["throttle"] = true
	await create_timer(1.0).timeout
	check(state.speed > 1.5 and absf(truck.body.rotation.z) > 0.1 and absf(truck.body.rotation.x) > 0.05, "guest speed and balance move actual truck")
	balance.test_intention = {"wish": Vector2.ZERO}
	pedal.test_intention = {"wish": Vector2.ZERO, "brake": true}
	await create_timer(2.0).timeout
	check(state.speed < -0.8, "guest S brakes then continues reverse")
	pedal.test_intention = {"wish": Vector2.ZERO}
	await create_timer(2.5).timeout
	host.test_area.boarding._accept_swap(1, state.id, 20, &"pedals", 0, false)
	await create_timer(0.15).timeout
	check(state.control_of(ids[0]) == &"front", "swap waits for consent")
	pedal._swap.rpc_id(1, state.id, 20, &"", ids[0], true, 20)
	await create_timer(0.3).timeout
	for room in rooms:
		check(room.room_state().attempt.control_of(ids[0]) == &"pedals", "accepted swap agrees on every peer")
	# Swap back so the route driver below keeps the original control mapping.
	host.test_area.boarding._accept_swap(1, state.id, 21, &"front", 0, false)
	pedal._swap.rpc_id(1, state.id, 21, &"", ids[0], true, 21)
	await create_timer(0.3).timeout
	# Recover an actual settled rollover through a guest's held command.
	truck.body.rotation.z = PI / 2.0
	truck.vertical_speed = 0.0
	await create_timer(0.4).timeout
	check(state.operators.size() == 3, "rollover keeps all occupants attached")
	balance.test_intention["recover"] = true
	await create_timer(3.0).timeout
	check(state.minor_faults == 1 and truck.body.global_basis.y.dot(Vector3.UP) > 0.9, "guest hold recovers upright once")
	await create_timer(0.5).timeout
	check(state.minor_faults == 1, "continued recovery hold does not duplicate fault")
	balance.test_intention = {"wish": Vector2.ZERO}
	# Deliberate guest exit releases exactly that seat, then permits reboarding.
	balance.interaction_sequence = 29
	balance.interact()
	await create_timer(0.3).timeout
	check(state.control_of(ids[2]) == &"", "guest E deliberately leaves the seat")
	balance._interaction.rpc_id(1, state.id, 31, &"rear")
	await create_timer(0.3).timeout
	check(state.control_of(ids[2]) == &"rear", "guest can reboard after deliberate exit")
	if OS.get_cmdline_user_args().has("--revision-controls"):
		truck.body.global_position = host.test_area.to_global(Vector3(28, 0, -10))
		balance.test_intention["recover"] = true
		await create_timer(2.6).timeout
		check(absf(host.test_area.to_local(truck.body.global_position).x) <= 25.0, "off-course recovery places truck back inside course")
		for room in rooms:
			check(room.room_state().attempt.minor_faults == 2 and room.room_state().attempt.test_item == 0, "off-course recovery agrees on one fault without skipping items")
		balance.test_intention = {"wish": Vector2.ZERO}
		return
	# Drive continuously through real course geometry. Steering helper uses the
	# same held controls a human has; no pose/progress injection along the route.
	await drive_revision_to(Vector3(4, 0, -22), 2.0)
	await drive_revision_to(Vector3(10, 0, -24), 1.8)
	check(state.test_item >= 1, "driving actual turn completes first item")
	await drive_revision_to(Vector3(12, 0, -24), 0.7)
	await drive_revision_to(Vector3(22, 0, -24), 1.0)
	check(state.test_item >= 2, "driving actual ridges completes bumps")
	await drive_revision_to(Vector3(23, 0, -17), 1.5)
	await drive_revision_to(Vector3(17, 0, -10), 1.0)
	# Parking corrections are intentional: aim towards the far end then stop.
	await drive_revision_to(Vector3(17, 0, -6), 3.5)
	for room in rooms:
		room.test_area.boarding.test_intention = {"wish": Vector2.ZERO}
	await create_timer(4.0).timeout
	for room in rooms:
		check(room.room_state().attempt.assessment().get("outcome") == &"passed", "course settles shared pass after recovery")
	print("REVISION final pose: ", host.test_area.to_local(truck.body.global_position), " item ", state.test_item, " angle ", truck.body.rotation.y)
	if state.assessment().get("outcome") == &"passed":
		await create_timer(6.0).timeout
		await capture_revision("result")
		for room in rooms:
			room.choose_attempt(&"retry")
		await create_timer(4.0).timeout
		for room in rooms:
			check(room.room_state().attempt.phase == &"active" and room.room_state().attempt.test_item == 0 and room.room_state().attempt.minor_faults == 0, "unanimous retry resets all peers")

func drive_revision_to(target: Vector3, tolerance: float) -> void:
	var host = rooms[0]
	var state: AttemptState = host.room_state().attempt
	var truck: MonsterTruck = host.test_area.truck
	for step in 450:
		var offset: Vector3 = host.test_area.to_global(target) - truck.body.global_position
		offset.y = 0.0
		if offset.length() < tolerance:
			return
		var desired := atan2(-offset.x, -offset.z)
		var error := wrapf(desired - truck.body.rotation.y, -PI, PI)
		var angle := clampf(-error * 1.0, -0.6, 0.6)
		rooms[0].test_area.boarding.test_intention = {"wish": Vector2.ZERO, "steer": clampf((angle - state.front_angle) * 8.0, -1.0, 1.0)}
		rooms[1].test_area.boarding.test_intention = {"wish": Vector2.ZERO, "throttle": state.speed < 2.0}
		await create_timer(0.05).timeout
	check(false, "route driver reaches " + str(target))

func capture_revision(stage: String) -> void:
	if not OS.get_cmdline_user_args().has("--revision-capture"):
		return
	for i in 3:
		var viewport = rooms[i].get_parent()
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		await process_frame
		await RenderingServer.frame_post_draw
		viewport.get_texture().get_image().save_png("res://.scratch/monster-truck-build/revision-%s-%d.png" % [stage, i])

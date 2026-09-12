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
		var branch := Node.new()
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
	quit(1 if failures else 0)

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		printerr("FAIL: ", message)

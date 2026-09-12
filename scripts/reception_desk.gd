class_name ReceptionDesk
extends Node3D
## The reception desk as a station: zone, prompt, E, then the station screen on the kit's
## friends terminal. Lists Steam friends, Invite, Join, and Leave. An invite rings here
## in-world; Accept is Join (ticket 10). Renders the header count from the host-owned
## room state and never writes it.

## Spec copy table: station prompts, two spaces, signage register.
const RECEPTION_PROMPT := "E  Reception"
const ZONE_SIZE := Vector3(1.9, 2.2, 1.5)
const PROMPT_HEIGHT := 2.05
## Physics layer the dock cursor ray tests against, same as the booking board.
const SCREEN_LAYER := 8
const SCREEN_PX := Vector2i(740, 460)
const SCREEN_M := Vector2(0.74, 0.46)
const AVATAR_PX := 64
## Signage on the kit Screen.
const SCREEN_BG := Color("1d343a")
const SCREEN_INK := Color("a8d9c4")
const INK_DIM := Color("7aa894")

const STATE_IN_ROOM := "In the waiting room"
const STATE_AT_CENTRE := "At the test centre"
const STATE_ONLINE := "Online. Not at the test centre."
const STATE_COMPANY := "You have company."
const STATE_FULL := "The waiting room is full."
const STATE_ASKING := "is asking for you"
const FAIL_FULL := "The waiting room is full."
const FAIL_GONE := "Nobody is at the test centre."
const FAIL_SILENCE := "The room did not answer."
const ASKING_PROMPT := "E  %s is asking for you"
const INVITED_FOR_MS := 30_000

const GROUP_IN_ROOM := 0
const GROUP_AT_CENTRE := 1
const GROUP_ONLINE := 2

var _waiting: WaitingRoom
var _station: Station
var _screen: StationScreen
var _marker: Marker3D
var _viewport: SubViewport
var _quad: MeshInstance3D
var _title: Label
var _count: Label
var _full_line: Label
var _rows: VBoxContainer
var _footer: VBoxContainer
var _leave_btn: Button
var _id_field: LineEdit
var _ring: AudioStreamPlayer3D
## steam_id → Array of TextureRect on the current list.
var _row_avatars: Dictionary = {}
## steam_id or "lobby:<id>" → failure line, kept across a live refresh.
var _errors: Dictionary = {}
## Newest invite first: {steam_id, lobby_id, name}. Never expire.
var _pending_invites: Array = []
## steam_id → msec until the row's verb returns from "Invited." to Invite.
var _invited_until: Dictionary = {}
var _list_queued := false
var _lobby_refresh_queued := false


func _ready() -> void:
	_waiting = get_parent() as WaitingRoom
	_waiting.room_changed.connect(_on_room_changed)
	_build(_waiting.get_node("Kit") as Node3D)
	_take_join_error()
	if SteamClient.is_running():
		Steam.persona_state_change.connect(_on_persona_state_change)
		Steam.friend_rich_presence_update.connect(_on_friend_rich_presence_update)
		Steam.lobby_data_update.connect(_on_lobby_data_update)
		Steam.lobby_invite.connect(_on_lobby_invite)
		Steam.join_requested.connect(_on_join_requested)
		SteamClient.avatar_ready.connect(_on_avatar_ready)
		_queue_lobby_refresh()
	Transport.join_recovered.connect(_on_join_recovered)
	_queue_list()


func _exit_tree() -> void:
	if Transport.join_recovered.is_connected(_on_join_recovered):
		Transport.join_recovered.disconnect(_on_join_recovered)
	if not SteamClient.is_running():
		return
	if Steam.persona_state_change.is_connected(_on_persona_state_change):
		Steam.persona_state_change.disconnect(_on_persona_state_change)
	if Steam.friend_rich_presence_update.is_connected(_on_friend_rich_presence_update):
		Steam.friend_rich_presence_update.disconnect(_on_friend_rich_presence_update)
	if Steam.lobby_data_update.is_connected(_on_lobby_data_update):
		Steam.lobby_data_update.disconnect(_on_lobby_data_update)
	if Steam.lobby_invite.is_connected(_on_lobby_invite):
		Steam.lobby_invite.disconnect(_on_lobby_invite)
	if Steam.join_requested.is_connected(_on_join_requested):
		Steam.join_requested.disconnect(_on_join_requested)
	if SteamClient.avatar_ready.is_connected(_on_avatar_ready):
		SteamClient.avatar_ready.disconnect(_on_avatar_ready)


func _build(kit: Node3D) -> void:
	var approach := kit.get_node_or_null("AttachmentPoints/ReceptionApproach") as Marker3D
	_marker = kit.get_node_or_null("AttachmentPoints/FriendsScreen") as Marker3D
	if approach == null or _marker == null:
		push_error("Waiting room kit has no reception approach or FriendsScreen marker")
		return

	var placeholder := kit.find_child("FriendsScreenPlaceholder", true, false) as Node3D
	if placeholder != null:
		placeholder.visible = false

	_station = Station.new()
	_station.name = "Reception"
	add_child(_station)
	_station.global_position = approach.global_position
	_station.setup(
		RECEPTION_PROMPT,
		approach.global_position + Vector3(0.0, PROMPT_HEIGHT, 0.0),
		ZONE_SIZE,
	)
	_station.used.connect(_on_used)

	_screen = StationScreen.new()
	_screen.name = "Screen"
	add_child(_screen)
	_screen.closed.connect(_on_screen_closed)

	_viewport = SubViewport.new()
	_viewport.name = "DeskScreen"
	_viewport.size = SCREEN_PX
	_viewport.transparent_bg = false
	_viewport.disable_3d = true
	_viewport.handle_input_locally = true
	_viewport.gui_disable_input = false
	_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(_viewport)
	_build_screen()

	_quad = MeshInstance3D.new()
	_quad.name = "DeskQuad"
	var mesh := QuadMesh.new()
	mesh.size = SCREEN_M
	_quad.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
	mat.albedo_texture = _viewport.get_texture()
	_quad.set_surface_override_material(0, mat)
	add_child(_quad)
	_quad.global_transform = _marker.global_transform

	var area := Area3D.new()
	area.name = "DeskSurface"
	area.collision_layer = SCREEN_LAYER
	area.collision_mask = 0
	area.monitoring = false
	area.monitorable = true
	area.input_ray_pickable = true
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(SCREEN_M.x, SCREEN_M.y, 0.04)
	shape.shape = box
	area.add_child(shape)
	add_child(area)
	area.global_transform = _marker.global_transform

	_ring = AudioStreamPlayer3D.new()
	_ring.name = "Ring"
	_ring.stream = _placeholder_ring()
	_ring.unit_size = 20.0
	_ring.max_distance = 0.0
	_ring.volume_db = 6.0
	add_child(_ring)
	_ring.global_position = _marker.global_position


func _build_screen() -> void:
	var root := Control.new()
	root.name = "Root"
	root.size = Vector2(SCREEN_PX)
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	_viewport.add_child(root)

	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = SCREEN_BG
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(bg)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	root.add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	margin.add_child(column)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	column.add_child(header)

	_title = Label.new()
	_title.text = "Reception"
	_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_ink(_title, 22)
	header.add_child(_title)

	_count = Label.new()
	_count.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_ink(_count, 22)
	header.add_child(_count)

	_full_line = Label.new()
	_full_line.text = STATE_FULL
	_full_line.visible = false
	_ink(_full_line, 16)
	column.add_child(_full_line)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scroll)

	_rows = VBoxContainer.new()
	_rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_rows.add_theme_constant_override("separation", 6)
	scroll.add_child(_rows)

	_footer = VBoxContainer.new()
	_footer.add_theme_constant_override("separation", 6)
	column.add_child(_footer)


func _ink(label: Label, size: int, dim: bool = false) -> void:
	label.add_theme_color_override("font_color", INK_DIM if dim else SCREEN_INK)
	label.add_theme_font_size_override("font_size", size)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _on_used() -> void:
	if _screen.is_open():
		return
	var learner := _local_learner()
	if learner == null:
		return
	_station.set_listening(false)
	set_process_input(true)
	_waiting.close_escape_overlay()
	_screen.open(learner, _dock_pose(), SCREEN_LAYER)


func _on_screen_closed() -> void:
	set_process_input(false)
	_station.set_listening(true)


func _on_room_changed() -> void:
	_queue_list()


func _on_persona_state_change(_steam_id: int, _flags: int) -> void:
	_queue_lobby_refresh()


func _on_friend_rich_presence_update(_steam_id: int, _app_id: int) -> void:
	_queue_lobby_refresh()


func _on_lobby_data_update(_success: bool, _lobby: int, _member: int) -> void:
	_queue_list()


func _on_avatar_ready(steam_id: int) -> void:
	var rects: Array = _row_avatars.get(steam_id, [])
	var texture := SteamClient.avatar_of(steam_id)
	for rect in rects:
		if rect is TextureRect:
			(rect as TextureRect).texture = texture


func _on_join_recovered() -> void:
	_take_join_error()
	if _screen == null or not _screen.is_open():
		return
	var learner := _local_learner()
	if learner != null:
		_screen.rebind_learner(learner)
		_station.set_listening(false)


func _take_join_error() -> void:
	var err := Transport.take_join_error()
	if err.is_empty():
		return
	var steam_id := int(err.get("steam_id", 0))
	var lobby := int(err.get("lobby_id", 0))
	var line := _failure_line(int(err.get("response", 0)), steam_id)
	if steam_id != 0:
		_errors[steam_id] = line
	if lobby != 0:
		_errors["lobby:%d" % lobby] = line
	_queue_list()


func _failure_line(response: int, friend_id: int = 0) -> String:
	if response == Steam.CHAT_ROOM_ENTER_RESPONSE_FULL:
		return FAIL_FULL
	if response == Steam.CHAT_ROOM_ENTER_RESPONSE_DOESNT_EXIST:
		return FAIL_GONE
	if friend_id != 0 and not _at_the_test_centre(friend_id):
		return FAIL_GONE
	return FAIL_SILENCE


func _queue_list() -> void:
	if _list_queued:
		return
	_list_queued = true
	_flush_list.call_deferred()


func _flush_list() -> void:
	_list_queued = false
	if not is_inside_tree():
		return
	_redraw()


func _queue_lobby_refresh() -> void:
	if _lobby_refresh_queued:
		return
	_lobby_refresh_queued = true
	_flush_lobby_refresh.call_deferred()


func _flush_lobby_refresh() -> void:
	_lobby_refresh_queued = false
	if not is_inside_tree():
		return
	_refresh_lobby_data()
	_queue_list()


func _refresh_lobby_data() -> void:
	if not SteamClient.is_running():
		return
	var count := Steam.getFriendCount(Steam.FRIEND_FLAG_IMMEDIATE)
	for i in count:
		var id: int = Steam.getFriendByIndex(i, Steam.FRIEND_FLAG_IMMEDIATE)
		if id == 0:
			continue
		var game: Dictionary = Steam.getFriendGamePlayed(id)
		var lobby := int(game.get("lobby", 0))
		if lobby != 0:
			Steam.requestLobbyData(lobby)


func _redraw() -> void:
	if _count == null or _rows == null or _footer == null:
		return
	var room := _waiting.room_state()
	var n := 1 if room == null else room.player_count()
	_count.text = "%d of %d" % [n, RoomState.CAPACITY]
	var full := n >= RoomState.CAPACITY
	_full_line.visible = full
	_refresh_desk_prompt()
	_rebuild_rows(room, full)
	_rebuild_footer(room)


func _rebuild_rows(room: RoomState, room_full: bool) -> void:
	_clear_container(_rows)
	_row_avatars.clear()
	var has_company := room != null and room.player_count() > 1
	var verbs_live := Transport.kind == Transport.STEAM
	for invite in _pending_invites:
		_rows.add_child(_make_invite_row(invite, room_full, has_company, verbs_live))
	if not SteamClient.is_running():
		return
	var friends := _collect_friends(room)
	for friend in friends:
		_rows.add_child(_make_row(friend, room_full, has_company, verbs_live))


func _collect_friends(room: RoomState) -> Array:
	var in_room: Dictionary = {}
	if room != null:
		for occupant in room.players:
			in_room[occupant.steam_id] = true
	var grouped: Array = [[], [], []]
	var count := Steam.getFriendCount(Steam.FRIEND_FLAG_IMMEDIATE)
	for i in count:
		var id: int = Steam.getFriendByIndex(i, Steam.FRIEND_FLAG_IMMEDIATE)
		if id == 0 or id == SteamClient.steam_id:
			continue
		var state: int = Steam.getFriendPersonaState(id)
		if state == Steam.PERSONA_STATE_OFFLINE:
			continue
		Steam.requestFriendRichPresence(id)
		var name := Steam.getFriendPersonaName(id)
		var licensed := _at_the_test_centre(id)
		var game: Dictionary = Steam.getFriendGamePlayed(id)
		var lobby := int(game.get("lobby", 0))
		var group := GROUP_ONLINE
		var line := STATE_ONLINE
		if in_room.has(id):
			group = GROUP_IN_ROOM
			line = STATE_IN_ROOM
		elif licensed:
			group = GROUP_AT_CENTRE
			line = STATE_AT_CENTRE
		var occupancy := 0
		if lobby != 0:
			var raw := Steam.getLobbyData(lobby, Transport.OCCUPANCY_KEY)
			if raw.is_valid_int():
				occupancy = raw.to_int()
		var error := _error_for(id, lobby)
		if error != "":
			line = error
		elif group == GROUP_AT_CENTRE and room != null and room.player_count() > 1:
			line = STATE_COMPANY
		grouped[group].append({
			"steam_id": id,
			"name": name,
			"group": group,
			"state": line,
			"lobby_id": lobby,
			"friend_full": occupancy >= RoomState.CAPACITY,
		})
	var ordered: Array = []
	for group_rows in grouped:
		group_rows.sort_custom(func(a, b) -> bool:
			return String(a["name"]).nocasecmp_to(String(b["name"])) < 0
		)
		for friend in group_rows:
			ordered.append(friend)
	return ordered


func _error_for(steam_id: int, lobby_id: int) -> String:
	if _errors.has(steam_id):
		return String(_errors[steam_id])
	if lobby_id != 0 and _errors.has("lobby:%d" % lobby_id):
		return String(_errors["lobby:%d" % lobby_id])
	return ""


func _make_row(friend: Dictionary, room_full: bool, has_company: bool, verbs_live: bool) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var avatar := TextureRect.new()
	avatar.custom_minimum_size = Vector2(AVATAR_PX, AVATAR_PX)
	avatar.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	avatar.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	avatar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	avatar.texture = SteamClient.avatar_of(int(friend["steam_id"]))
	_register_avatar(int(friend["steam_id"]), avatar)
	row.add_child(avatar)

	var text := VBoxContainer.new()
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text.add_theme_constant_override("separation", 2)
	row.add_child(text)

	var name_label := Label.new()
	name_label.text = String(friend["name"])
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_ink(name_label, 16)
	text.add_child(name_label)

	var state := Label.new()
	state.text = String(friend["state"])
	state.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_ink(state, 14, true)
	text.add_child(state)

	if room_full or int(friend["group"]) != GROUP_AT_CENTRE:
		return row
	if bool(friend["friend_full"]):
		return row

	var verbs := HBoxContainer.new()
	verbs.add_theme_constant_override("separation", 6)
	row.add_child(verbs)

	var invited := _invite_is_pending(int(friend["steam_id"]))
	var invite := _make_verb("Invited." if invited else "Invite")
	invite.disabled = not verbs_live or invited or Transport.lobby_id == 0
	if verbs_live and not invited:
		invite.pressed.connect(_on_invite_pressed.bind(int(friend["steam_id"])))
	verbs.add_child(invite)

	if not has_company:
		var join := _make_verb("Join")
		join.disabled = not verbs_live
		join.pressed.connect(_on_join_pressed.bind(int(friend["lobby_id"]), int(friend["steam_id"])))
		verbs.add_child(join)

	return row


func _make_invite_row(invite: Dictionary, room_full: bool, has_company: bool, verbs_live: bool) -> Control:
	var steam_id := int(invite["steam_id"])
	var lobby_id := int(invite["lobby_id"])
	var name := _invite_name(invite)
	invite["name"] = name
	var line := _error_for(steam_id, lobby_id)
	if line.is_empty():
		line = STATE_COMPANY if has_company else STATE_ASKING

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var avatar := TextureRect.new()
	avatar.custom_minimum_size = Vector2(AVATAR_PX, AVATAR_PX)
	avatar.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	avatar.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	avatar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	avatar.texture = SteamClient.avatar_of(steam_id)
	_register_avatar(steam_id, avatar)
	row.add_child(avatar)

	var text := VBoxContainer.new()
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text.add_theme_constant_override("separation", 2)
	row.add_child(text)

	var name_label := Label.new()
	name_label.text = name
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_ink(name_label, 16)
	text.add_child(name_label)

	var state := Label.new()
	state.text = line
	state.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_ink(state, 14, true)
	text.add_child(state)

	if room_full:
		return row

	var verbs := HBoxContainer.new()
	verbs.add_theme_constant_override("separation", 6)
	row.add_child(verbs)

	if not has_company:
		var accept := _make_verb("Accept")
		accept.disabled = not verbs_live
		if verbs_live:
			accept.pressed.connect(_on_accept_pressed.bind(lobby_id, steam_id))
		verbs.add_child(accept)

	var ignore := _make_verb("Ignore")
	ignore.disabled = not verbs_live
	if verbs_live:
		ignore.pressed.connect(_on_ignore_pressed.bind(lobby_id))
	verbs.add_child(ignore)
	return row


func _make_verb(line: String) -> Button:
	var button := Button.new()
	button.text = line
	button.custom_minimum_size = Vector2(0, 28)
	button.add_theme_font_size_override("font_size", 14)
	return button


func _clear_container(box: Container) -> void:
	while box.get_child_count() > 0:
		var child := box.get_child(0)
		box.remove_child(child)
		child.queue_free()


func _rebuild_footer(room: RoomState) -> void:
	var typed := ""
	if _id_field != null:
		typed = _id_field.text
	_clear_container(_footer)
	_leave_btn = null
	_id_field = null
	if Transport.kind == Transport.ENET:
		var seam := Label.new()
		seam.text = "Dev transport."
		_ink(seam, 14)
		_footer.add_child(seam)
		return
	var guest := room != null and not Transport.hosting and not multiplayer.is_server()
	if guest:
		_leave_btn = _make_verb("Leave")
		_leave_btn.pressed.connect(_on_leave_pressed)
		_footer.add_child(_leave_btn)
	if not OS.is_debug_build():
		return
	var strip := HBoxContainer.new()
	strip.add_theme_constant_override("separation", 8)
	_footer.add_child(strip)
	var copy := _make_verb("Copy room ID")
	copy.pressed.connect(_on_copy_id)
	strip.add_child(copy)
	var join_label := Label.new()
	join_label.text = "Join by ID"
	_ink(join_label, 14)
	strip.add_child(join_label)
	_id_field = LineEdit.new()
	_id_field.custom_minimum_size = Vector2(180, 28)
	_id_field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_id_field.text = typed
	_id_field.text_submitted.connect(_on_join_by_id)
	strip.add_child(_id_field)


func _on_invite_pressed(friend_id: int) -> void:
	if Transport.kind != Transport.STEAM or Transport.lobby_id == 0 or friend_id == 0:
		return
	Steam.inviteUserToLobby(Transport.lobby_id, friend_id)
	_invited_until[friend_id] = Time.get_ticks_msec() + INVITED_FOR_MS
	_queue_list()
	get_tree().create_timer(INVITED_FOR_MS / 1000.0).timeout.connect(
		_on_invited_elapsed.bind(friend_id),
		CONNECT_ONE_SHOT,
	)


func _on_invited_elapsed(friend_id: int) -> void:
	if not is_inside_tree():
		return
	if Time.get_ticks_msec() < int(_invited_until.get(friend_id, 0)):
		return
	_invited_until.erase(friend_id)
	_queue_list()


func _invite_is_pending(friend_id: int) -> bool:
	return Time.get_ticks_msec() < int(_invited_until.get(friend_id, 0))


func _on_lobby_invite(inviter: int, lobby: int, _game: int) -> void:
	if inviter == 0 or lobby == 0 or lobby == Transport.lobby_id:
		return
	_push_invite(inviter, lobby, true)


func _on_join_requested(lobby_id: int, friend_id: int) -> void:
	if Transport.kind != Transport.STEAM:
		return
	_accept_invite(lobby_id, friend_id)


func _on_accept_pressed(lobby_id: int, friend_id: int) -> void:
	_accept_invite(lobby_id, friend_id)


func _on_ignore_pressed(lobby_id: int) -> void:
	_drop_invite(lobby_id)
	_refresh_desk_prompt()
	_queue_list()


func _accept_invite(lobby_id: int, friend_id: int) -> void:
	if Transport.kind != Transport.STEAM:
		return
	var room := _waiting.room_state()
	if room != null and room.player_count() > 1:
		if friend_id != 0:
			_push_invite(friend_id, lobby_id, false)
		_queue_list()
		return
	_keep_only_invite(lobby_id, friend_id)
	_refresh_desk_prompt()
	_on_join_pressed(lobby_id, friend_id)


func _push_invite(inviter: int, lobby: int, ring: bool) -> void:
	_drop_invite(lobby)
	if SteamClient.is_running():
		Steam.requestUserInformation(inviter, true)
	_pending_invites.insert(0, {
		"steam_id": inviter,
		"lobby_id": lobby,
		"name": _persona_name(inviter),
	})
	if ring:
		_play_ring()
	_refresh_desk_prompt()
	_queue_list()


func _keep_only_invite(lobby_id: int, friend_id: int) -> void:
	var kept: Array = []
	for invite in _pending_invites:
		if int(invite["lobby_id"]) == lobby_id:
			kept.append(invite)
	if kept.is_empty() and (friend_id != 0 or lobby_id != 0):
		kept.append({
			"steam_id": friend_id,
			"lobby_id": lobby_id,
			"name": _persona_name(friend_id),
		})
	_pending_invites = kept


func _drop_invite(lobby_id: int) -> void:
	var kept: Array = []
	for invite in _pending_invites:
		if int(invite["lobby_id"]) != lobby_id:
			kept.append(invite)
	_pending_invites = kept


func _invite_name(invite: Dictionary) -> String:
	var name := _persona_name(int(invite["steam_id"]))
	if name.is_empty():
		return String(invite.get("name", ""))
	return name


func _persona_name(steam_id: int) -> String:
	if steam_id == 0 or not SteamClient.is_running():
		return ""
	return Steam.getFriendPersonaName(steam_id)


func _refresh_desk_prompt() -> void:
	if _station == null:
		return
	if _pending_invites.is_empty():
		_station.set_prompt(RECEPTION_PROMPT)
		return
	var name := _invite_name(_pending_invites[0])
	_station.set_prompt(ASKING_PROMPT % name)


func _register_avatar(steam_id: int, avatar: TextureRect) -> void:
	if not _row_avatars.has(steam_id):
		_row_avatars[steam_id] = []
	(_row_avatars[steam_id] as Array).append(avatar)


func _play_ring() -> void:
	if _ring == null or _ring.stream == null:
		return
	if _ring.playing:
		_ring.stop()
	_ring.play()


func _placeholder_ring() -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = 44100
	stream.stereo = false
	var n := int(44100 * 2.0)
	var data := PackedByteArray()
	data.resize(n * 2)
	for i in n:
		var t := float(i) / 44100.0
		var env := _ring_envelope(t)
		var sample := int(clampf(0.45 * env * sin(TAU * 880.0 * t), -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, sample)
	stream.data = data
	return stream


func _ring_envelope(t: float) -> float:
	var starts: Array[float] = [0.0, 0.4, 1.1, 1.5]
	for start in starts:
		var u := t - start
		if u >= 0.0 and u < 0.25:
			if u < 0.02:
				return u / 0.02
			if u > 0.20:
				return (0.25 - u) / 0.05
			return 1.0
	return 0.0


func _on_join_pressed(lobby_id: int, friend_id: int) -> void:
	if Transport.kind != Transport.STEAM:
		return
	_errors.erase(friend_id)
	if friend_id != 0 and not _at_the_test_centre(friend_id):
		_errors[friend_id] = FAIL_GONE
		_queue_list()
		return
	if lobby_id == 0:
		_errors[friend_id] = FAIL_SILENCE
		_queue_list()
		return
	_waiting.begin_join()
	Transport.join_lobby(lobby_id, friend_id)


func _on_join_by_id(text: String) -> void:
	if Transport.kind != Transport.STEAM:
		return
	var room := _waiting.room_state()
	if room != null and room.player_count() > 1:
		return
	var raw := text.strip_edges()
	if not raw.is_valid_int():
		return
	var lobby_id := raw.to_int()
	_waiting.begin_join()
	Transport.join_lobby(lobby_id, 0)


func _at_the_test_centre(friend_id: int) -> bool:
	return Steam.getFriendRichPresence(friend_id, SteamClient.RICH_PRESENCE_KEY) == SteamClient.RICH_PRESENCE_VALUE


func _on_leave_pressed() -> void:
	_waiting.leave_to_own_room()


func _on_copy_id() -> void:
	DisplayServer.clipboard_set(str(Transport.lobby_id))


func _dock_pose() -> Transform3D:
	var screen := _marker.global_position
	var out := _marker.global_transform.basis.z
	var origin := screen + out * 0.9 + Vector3(0.0, 0.04, 0.0)
	return Transform3D(Basis.looking_at(screen - origin, Vector3.UP), origin)


func _input(event: InputEvent) -> void:
	if _screen == null or not _screen.is_open() or _viewport == null:
		return
	if event.is_action("ui_cancel"):
		return
	if event is InputEventMouse:
		var mapped := _map_mouse((event as InputEventMouse).position)
		if mapped.x < 0.0:
			return
		var forwarded := _viewport_mouse(event as InputEventMouse, mapped)
		if forwarded != null:
			_viewport.push_input(forwarded, true)
			get_viewport().set_input_as_handled()
		return
	if event is InputEventKey:
		_viewport.push_input(event, true)
		get_viewport().set_input_as_handled()


func _map_mouse(mouse: Vector2) -> Vector2:
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return Vector2(-1.0, -1.0)
	var from := camera.project_ray_origin(mouse)
	var dir := camera.project_ray_normal(mouse)
	var query := PhysicsRayQueryParameters3D.create(from, from + dir * 8.0)
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.collision_mask = SCREEN_LAYER
	var hit := camera.get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return Vector2(-1.0, -1.0)
	var local: Vector3 = _quad.to_local(hit["position"])
	var x := (local.x / SCREEN_M.x + 0.5) * float(SCREEN_PX.x)
	var y := (0.5 - local.y / SCREEN_M.y) * float(SCREEN_PX.y)
	if x < 0.0 or y < 0.0 or x > float(SCREEN_PX.x) or y > float(SCREEN_PX.y):
		return Vector2(-1.0, -1.0)
	return Vector2(x, y)


func _viewport_mouse(event: InputEventMouse, pos: Vector2) -> InputEvent:
	if event is InputEventMouseButton:
		var click := event as InputEventMouseButton
		var forwarded := InputEventMouseButton.new()
		forwarded.button_index = click.button_index
		forwarded.pressed = click.pressed
		forwarded.double_click = click.double_click
		forwarded.position = pos
		forwarded.global_position = pos
		return forwarded
	if event is InputEventMouseMotion:
		var motion := event as InputEventMouseMotion
		var forwarded := InputEventMouseMotion.new()
		forwarded.position = pos
		forwarded.global_position = pos
		forwarded.relative = motion.relative
		forwarded.button_mask = motion.button_mask
		return forwarded
	return null


func _local_learner() -> Learner:
	var spawner := _waiting.get_node("LearnerSpawner")
	for child in spawner.get_children():
		if child is Learner and (child as Learner).is_local():
			return child
	return null

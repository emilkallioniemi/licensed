class_name BookingBoard
extends Node3D
## The booking board as a station: zone, prompt, E, then the station screen on the
## board's own surfaces. Renders picks, BOOKED, and the role pickup from the host-owned
## room state and never writes it. Clicks go through `WaitingRoom.submit_command`.

## Spec copy table: station prompts, two spaces, signage register.
const BOOKING_PROMPT := "E  Booking"
## Volume around the board's approach marker, metres. Wide enough for the 3.5 m board.
const ZONE_SIZE := Vector3(3.6, 2.4, 2.2)
## World height of the prompt above the board origin.
const PROMPT_HEIGHT := 3.25
## Physics layer the dock cursor ray tests against. Learners mask 1+2, so this is not walkable.
const ROW_LAYER := 8
## Drawn row resolution, matching the spec's ~560 × 100 px at the dock.
const ROW_PX := Vector2i(560, 100)
## Occupant strip: 0.65 × 0.105 m, about 180 × 30 px at the dock.
const STRIP_PX := Vector2i(196, 40)
const INK := Color("293a3d")
## Signage on the kit Screen, as the friends-terminal placeholder uses.
const SCREEN_INK := Color("a8d9c4")
## Own held button moves this far into the board (world −Z); everyone else's stays flat.
const BUTTON_INSET := Vector3(0.0, 0.0, -0.022)

const ROWS: Array[Dictionary] = [
	{
		"slot": "MonsterTruckSlot",
		"surface": "MonsterTruckDisplaySurface",
		"label": "MonsterTruckLabel",
		"marker": "Available marker",
		"vehicle": RoomState.MONSTER_TRUCK,
		"title": "MONSTER TRUCK",
		"locked": "",
	},
	{
		"slot": "CarSlot",
		"surface": "CarDisplaySurface",
		"label": "CarLabel",
		"marker": "",
		"vehicle": &"car",
		"title": "CAR",
		"locked": "Manual. Indicators on the passenger side.",
	},
	{
		"slot": "MopedSlot",
		"surface": "MopedDisplaySurface",
		"label": "MopedLabel",
		"marker": "",
		"vehicle": &"moped",
		"title": "MOPED",
		"locked": "Seats one. Party of three.",
	},
	{
		"slot": "TruckTrailerSlot",
		"surface": "TruckTrailerDisplaySurface",
		"label": "TruckTrailerLabel",
		"marker": "",
		"vehicle": &"truck_trailer",
		"title": "TRUCK + TRAILER",
		"locked": "One of you rides on the trailer.",
	},
	{
		"slot": "HelicopterSlot",
		"surface": "HelicopterDisplaySurface",
		"label": "HelicopterLabel",
		"marker": "",
		"vehicle": &"helicopter",
		"title": "HELICOPTER",
		"locked": "Three controls. No manual.",
	},
]

const ROLES: Array[Dictionary] = [
	{
		"button": "DriverButton",
		"label": "DriverButtonLabel",
		"surface": "DriverOccupantSurface",
		"lamp": "DriverStatusLamp",
		"role": RoomState.DRIVER,
	},
	{
		"button": "SpotterButton",
		"label": "SpotterButtonLabel",
		"surface": "SpotterOccupantSurface",
		"lamp": "SpotterStatusLamp",
		"role": RoomState.SPOTTER,
	},
	{
		"button": "NavigatorButton",
		"label": "NavigatorButtonLabel",
		"surface": "NavigatorOccupantSurface",
		"lamp": "NavigatorStatusLamp",
		"role": RoomState.NAVIGATOR,
	},
	{
		"button": "RandomButton",
		"label": "RandomButtonLabel",
		"surface": "",
		"lamp": "",
		"role": RoomState.RANDOM,
	},
]

var _waiting: WaitingRoom
var _station: Station
var _screen: StationScreen
var _board: Node3D
var _sound: AudioStreamPlayer3D
var _rows: Array[Dictionary] = []
var _roles: Array[Dictionary] = []
var _signals_connected := false


func _ready() -> void:
	_waiting = get_parent() as WaitingRoom
	_waiting.room_changed.connect(_on_room_changed)
	_build(_waiting.get_node("Kit") as Node3D)


func _build(kit: Node3D) -> void:
	var approach := kit.get_node_or_null("AttachmentPoints/BookingBoardApproach") as Marker3D
	_board = kit.find_child("BookingBoard", true, false) as Node3D
	if approach == null or _board == null:
		push_error("Waiting room kit has no booking board or approach marker")
		return

	_station = Station.new()
	_station.name = "Booking"
	add_child(_station)
	_station.global_position = approach.global_position
	_station.setup(
		BOOKING_PROMPT,
		_board.global_position + Vector3(0.0, PROMPT_HEIGHT, 0.35),
		ZONE_SIZE,
	)
	_station.used.connect(_on_used)

	_screen = StationScreen.new()
	_screen.name = "Screen"
	add_child(_screen)
	_screen.cursor_hit.connect(_on_cursor_hit)
	_screen.closed.connect(_on_screen_closed)

	_sound = AudioStreamPlayer3D.new()
	_sound.name = "Sound"
	_sound.stream = _placeholder_beep()
	_sound.unit_size = 20.0
	_sound.max_distance = 0.0
	_sound.volume_db = 4.0
	add_child(_sound)
	_sound.global_position = _board.global_position + Vector3(0.0, 1.91, 0.2)

	for spec in ROWS:
		_rows.append(_build_row(spec))
	for spec in ROLES:
		_roles.append(_build_role(spec))


func _build_row(spec: Dictionary) -> Dictionary:
	var slot := _board.find_child(String(spec["slot"]), true, false) as Node3D
	var surface := _board.find_child(String(spec["surface"]), true, false) as MeshInstance3D
	var label := _board.find_child(String(spec["label"]), true, false) as MeshInstance3D
	if slot == null or surface == null:
		push_error("Waiting room kit has no booking row '%s'" % spec["slot"])
		return {}
	if label != null:
		label.visible = false
	var marker_name := String(spec["marker"])
	if marker_name != "":
		var marker := slot.find_child(marker_name, true, false) as MeshInstance3D
		if marker != null:
			marker.visible = false

	var locked_copy := String(spec["locked"])
	var padlock_margin := 80 if locked_copy != "" else 12
	var viewport := SubViewport.new()
	viewport.name = "%sScreen" % spec["slot"]
	viewport.size = ROW_PX
	viewport.transparent_bg = true
	viewport.disable_3d = true
	viewport.handle_input_locally = false
	viewport.gui_disable_input = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(viewport)

	var root := Control.new()
	root.size = Vector2(ROW_PX)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	viewport.add_child(root)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_right", padlock_margin)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(margin)

	var lines := VBoxContainer.new()
	lines.add_theme_constant_override("separation", 4)
	lines.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(lines)

	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 8)
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lines.add_child(top)

	var title := Label.new()
	title.text = String(spec["title"])
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", INK)
	title.add_theme_font_size_override("font_size", 26)
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.add_child(title)

	var booked := Label.new()
	booked.text = "BOOKED"
	booked.visible = false
	booked.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	booked.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	booked.add_theme_color_override("font_color", INK)
	booked.add_theme_font_size_override("font_size", 26)
	booked.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.add_child(booked)

	var chips: Array[Panel] = []
	var chip_names: Array[Label] = []
	if locked_copy == "":
		var chip_line := HBoxContainer.new()
		chip_line.add_theme_constant_override("separation", 8)
		chip_line.mouse_filter = Control.MOUSE_FILTER_IGNORE
		chip_line.size_flags_vertical = Control.SIZE_EXPAND_FILL
		lines.add_child(chip_line)
		for _i in 3:
			var chip := _make_chip()
			chip_line.add_child(chip)
			chips.append(chip)
			chip_names.append(chip.get_node("Name") as Label)
	else:
		var copy := Label.new()
		copy.text = locked_copy
		copy.size_flags_vertical = Control.SIZE_EXPAND_FILL
		copy.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		copy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		copy.add_theme_color_override("font_color", INK)
		copy.add_theme_font_size_override("font_size", 16)
		copy.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lines.add_child(copy)

	var quad := MeshInstance3D.new()
	quad.name = "%sQuad" % spec["slot"]
	var mesh := QuadMesh.new()
	mesh.size = Vector2(1.93, 0.34)
	quad.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
	mat.albedo_texture = viewport.get_texture()
	quad.set_surface_override_material(0, mat)
	add_child(quad)
	quad.global_transform = surface.global_transform
	quad.global_position = surface.global_position + surface.global_transform.basis.z * 0.022

	var area := Area3D.new()
	area.name = String(spec["vehicle"])
	area.collision_layer = ROW_LAYER
	area.collision_mask = 0
	area.monitoring = false
	area.monitorable = true
	area.input_ray_pickable = true
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(1.93, 0.34, 0.08)
	shape.shape = box
	area.add_child(shape)
	add_child(area)
	area.global_transform = surface.global_transform
	area.global_position = surface.global_position + surface.global_transform.basis.z * 0.022

	return {
		"vehicle": spec["vehicle"],
		"booked": booked,
		"chips": chips,
		"chip_names": chip_names,
		"area": area,
	}


func _build_role(spec: Dictionary) -> Dictionary:
	var role: StringName = spec["role"]
	var button := _board.find_child(String(spec["button"]), true, false) as MeshInstance3D
	var label := _board.find_child(String(spec["label"]), true, false) as MeshInstance3D
	if button == null:
		push_error("Waiting room kit has no role button '%s'" % spec["button"])
		return {}

	var flood: Panel = null
	var name_label: Label = null
	var lamp: MeshInstance3D = null
	var surface_name := String(spec["surface"])
	if surface_name != "":
		var surface := _board.find_child(surface_name, true, false) as MeshInstance3D
		if surface == null:
			push_error("Waiting room kit has no occupant surface '%s'" % surface_name)
			return {}
		var strip := _build_strip(surface, String(role))
		flood = strip["flood"]
		name_label = strip["name"]
		name_label.text = "No booking."
	var lamp_name := String(spec["lamp"])
	if lamp_name != "":
		lamp = _board.find_child(lamp_name, true, false) as MeshInstance3D

	var aabb := button.mesh.get_aabb() if button.mesh != null else AABB(Vector3.ZERO, Vector3(0.87, 0.21, 0.055))
	var area := Area3D.new()
	area.name = String(role)
	area.collision_layer = ROW_LAYER
	area.collision_mask = 0
	area.monitoring = false
	area.monitorable = true
	area.input_ray_pickable = true
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(aabb.size.x, aabb.size.y, 0.08)
	shape.shape = box
	area.add_child(shape)
	add_child(area)
	area.global_transform = button.global_transform
	area.global_position = button.global_position + button.global_transform.basis.z * 0.02

	var pips: Array[MeshInstance3D] = []
	if role == RoomState.RANDOM:
		pips = _build_pips(button)

	return {
		"role": role,
		"button": button,
		"label": label,
		"button_rest": button.global_position,
		"label_rest": label.global_position if label != null else Vector3.ZERO,
		"flood": flood,
		"name": name_label,
		"lamp": lamp,
		"pips": pips,
	}


func _build_strip(surface: MeshInstance3D, slot: String) -> Dictionary:
	var viewport := SubViewport.new()
	viewport.name = "%sStrip" % slot
	viewport.size = STRIP_PX
	viewport.transparent_bg = true
	viewport.disable_3d = true
	viewport.handle_input_locally = false
	viewport.gui_disable_input = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(viewport)

	var root := Control.new()
	root.size = Vector2(STRIP_PX)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	viewport.add_child(root)

	var flood := Panel.new()
	flood.name = "Flood"
	flood.visible = false
	flood.set_anchors_preset(Control.PRESET_FULL_RECT)
	flood.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(flood)

	var name_label := Label.new()
	name_label.name = "Name"
	name_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	name_label.offset_left = 6
	name_label.offset_right = -6
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	name_label.add_theme_color_override("font_color", SCREEN_INK)
	name_label.add_theme_font_size_override("font_size", 15)
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(name_label)

	var quad := MeshInstance3D.new()
	quad.name = "%sStripQuad" % slot
	var mesh := QuadMesh.new()
	mesh.size = Vector2(0.65, 0.105)
	quad.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
	mat.albedo_texture = viewport.get_texture()
	quad.set_surface_override_material(0, mat)
	add_child(quad)
	quad.global_transform = surface.global_transform
	quad.global_position = surface.global_position + surface.global_transform.basis.z * 0.008

	return {"flood": flood, "name": name_label}


func _build_pips(button: MeshInstance3D) -> Array[MeshInstance3D]:
	var pips: Array[MeshInstance3D] = []
	# Right edge of the Random button, top to bottom, in front of the cream face.
	var ys := [0.07, 0.0, -0.07]
	for i in ys.size():
		var pip := MeshInstance3D.new()
		pip.name = "RandomPip%d" % (i + 1)
		pip.visible = false
		var mesh := BoxMesh.new()
		mesh.size = Vector3(0.038, 0.038, 0.016)
		pip.mesh = mesh
		var mat := StandardMaterial3D.new()
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		pip.set_surface_override_material(0, mat)
		button.add_child(pip)
		pip.position = Vector3(0.44, float(ys[i]), 0.032)
		pips.append(pip)
	return pips


func _make_chip() -> Panel:
	var chip := Panel.new()
	chip.visible = false
	chip.custom_minimum_size = Vector2(150, 32)
	chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var name_label := Label.new()
	name_label.name = "Name"
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	name_label.add_theme_color_override("font_color", INK)
	name_label.add_theme_font_size_override("font_size", 15)
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	name_label.offset_left = 6
	name_label.offset_right = -6
	chip.add_child(name_label)
	return chip


func _on_used() -> void:
	if _screen.is_open():
		return
	var learner := _local_learner()
	if learner == null:
		return
	_station.set_listening(false)
	_waiting.close_escape_overlay()
	_screen.open(learner, _dock_pose(), ROW_LAYER)


func _on_screen_closed() -> void:
	_station.set_listening(true)


func _on_cursor_hit(collider: Node3D) -> void:
	var id := StringName(collider.name)
	var room := _waiting.room_state()
	if room == null:
		return
	if _is_role(id):
		_on_role_clicked(room, id)
		return
	if not room.bookable_vehicles.has(id):
		return
	var occupant := _local_occupant(room)
	if occupant == null:
		return
	if occupant.pick == id:
		_waiting.submit_command(&"drop_pick")
	else:
		_waiting.submit_command(&"pick", id)


func _on_role_clicked(room: RoomState, role: StringName) -> void:
	if not room.has_booking():
		return
	var occupant := _local_occupant(room)
	if occupant == null:
		return
	if occupant.hold == role:
		_waiting.submit_command(&"drop_hold")
		return
	if role != RoomState.RANDOM and room.holder_of(role) != null:
		return
	_waiting.submit_command(&"take", role)


func _is_role(id: StringName) -> bool:
	for spec in ROLES:
		if spec["role"] == id:
			return true
	return false


func _on_room_changed() -> void:
	var room := _waiting.room_state()
	if room == null:
		return
	_ensure_booking_signals(room)
	_redraw(room)


func _ensure_booking_signals(room: RoomState) -> void:
	if _signals_connected:
		return
	room.booking_formed.connect(_on_booking_formed)
	_signals_connected = true


func _on_booking_formed(_vehicle: StringName) -> void:
	if _sound != null and _sound.stream != null:
		_sound.play()


func _redraw(room: RoomState) -> void:
	# The deal is revealed in the test area; strips and chips stay as held (spec section 7).
	if not room.launched_roles().is_empty():
		return
	var booked_vehicle := room.booking()
	for row in _rows:
		if row.is_empty():
			continue
		var vehicle: StringName = row["vehicle"]
		(row["booked"] as Label).visible = booked_vehicle == vehicle
		var chips: Array = row["chips"]
		var chip_names: Array = row["chip_names"]
		if chips.is_empty():
			continue
		var pickers: Array[RoomState.Player] = []
		for occupant in room.players:
			if occupant.pick == vehicle:
				pickers.append(occupant)
		for i in chips.size():
			if i < pickers.size():
				(chips[i] as Panel).visible = true
				_flood_chip(chips[i] as Panel, pickers[i].palette)
				(chip_names[i] as Label).text = pickers[i].display_name
			else:
				(chips[i] as Panel).visible = false
				(chip_names[i] as Label).text = ""
	_redraw_roles(room)
	_redraw_name_tags(room)


func _redraw_roles(room: RoomState) -> void:
	var booked := room.has_booking()
	var local := _local_occupant(room)
	var local_hold: StringName = &"" if local == null else local.hold
	for choice in _roles:
		if choice.is_empty():
			continue
		var role: StringName = choice["role"]
		_set_pressed(choice, local_hold == role)
		if role == RoomState.RANDOM:
			var holders: Array[RoomState.Player] = []
			if booked:
				holders = room.random_holders()
			_redraw_pips(choice["pips"], holders)
			continue
		var holder := room.holder_of(role) if booked else null
		var flood := choice["flood"] as Panel
		var name_label := choice["name"] as Label
		if not booked:
			flood.visible = false
			name_label.text = "No booking."
			name_label.add_theme_color_override("font_color", SCREEN_INK)
			_set_lamp(choice["lamp"] as MeshInstance3D, 0)
		elif holder == null:
			flood.visible = false
			name_label.text = ""
			_set_lamp(choice["lamp"] as MeshInstance3D, 0)
		else:
			flood.visible = true
			_flood_chip(flood, holder.palette)
			name_label.text = holder.display_name
			name_label.add_theme_color_override("font_color", INK)
			_set_lamp(choice["lamp"] as MeshInstance3D, holder.palette)


func _redraw_pips(pips: Array, holders: Array[RoomState.Player]) -> void:
	for i in pips.size():
		var pip := pips[i] as MeshInstance3D
		if i < holders.size():
			pip.visible = true
			var mat := pip.get_surface_override_material(0) as StandardMaterial3D
			if mat != null:
				mat.albedo_color = Palettes.flood_color(holders[i].palette)
		else:
			pip.visible = false


func _redraw_name_tags(room: RoomState) -> void:
	for learner in _learners():
		var occupant := _occupant_of(room, learner)
		learner.set_held_role(&"" if occupant == null else occupant.hold)


func _set_pressed(choice: Dictionary, pressed: bool) -> void:
	var button := choice["button"] as MeshInstance3D
	var label := choice["label"] as MeshInstance3D
	var inset := BUTTON_INSET if pressed else Vector3.ZERO
	button.global_position = (choice["button_rest"] as Vector3) + inset
	if label != null:
		label.global_position = (choice["label_rest"] as Vector3) + inset


func _set_lamp(lamp: MeshInstance3D, palette: int) -> void:
	if lamp == null:
		return
	if palette < 1:
		lamp.material_override = null
		return
	var mat := StandardMaterial3D.new()
	var flood := Palettes.flood_color(palette)
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = flood
	mat.emission_enabled = true
	mat.emission = flood
	mat.emission_energy_multiplier = 1.6
	lamp.material_override = mat


func _occupant_of(room: RoomState, learner: Learner) -> RoomState.Player:
	for occupant in room.players:
		if occupant.palette == learner.palette():
			return occupant
	return null


func _flood_chip(chip: Panel, palette: int) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Palettes.flood_color(palette)
	style.border_color = INK
	style.set_border_width_all(2)
	style.content_margin_left = 6
	style.content_margin_right = 6
	style.content_margin_top = 2
	style.content_margin_bottom = 2
	chip.add_theme_stylebox_override("panel", style)


func _dock_pose() -> Transform3D:
	# Kit preview_booking.png: about 3 m back, framing the whole 3.5 m board.
	var look_at := _board.global_position + Vector3(0.0, 1.91, 0.0)
	var origin := look_at + Vector3(0.0, 0.09, 3.15)
	return Transform3D(Basis.looking_at(look_at - origin, Vector3.UP), origin)


func _local_learner() -> Learner:
	for learner in _learners():
		if learner.is_local():
			return learner
	return null


func _local_occupant(room: RoomState) -> RoomState.Player:
	var learner := _local_learner()
	if learner == null:
		return null
	return _occupant_of(room, learner)


func _learners() -> Array[Learner]:
	var found: Array[Learner] = []
	var spawner := _waiting.get_node("LearnerSpawner")
	for child in spawner.get_children():
		if child is Learner:
			found.append(child)
	return found


## Short placeholder from the board, heard by everyone. Same job as the door beep.
func _placeholder_beep() -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = 44100
	stream.stereo = false
	var n := int(44100 * 0.16)
	var data := PackedByteArray()
	data.resize(n * 2)
	for i in n:
		var t := float(i) / 44100.0
		var env := exp(-t * 16.0)
		var sample := int(clampf(0.5 * env * sin(TAU * 784.0 * t), -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, sample)
	stream.data = data
	return stream

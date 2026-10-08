class_name TestArea
extends Node3D
## Shared track geometry and results; only the navigator sees the route report.
var daylight: Environment
var truck: MonsterTruck
var boarding: TruckBoarding
var track: SurvivalTrack
var _bays: Array[Marker3D] = []
var _own_role: Label
var _results: PanelContainer
var _assessment: Label
var _retry: Button
var _return: Button
var _reticle: Label
var _guidance: Label
var report_open := true
var field_book: NavigationBook

func _ready() -> void:
	visible = false
	truck = MonsterTruck.new()
	truck.name = "MonsterTruck"
	add_child(truck)
	truck.position = Vector3(0, 0, -9)
	boarding = TruckBoarding.new()
	boarding.name = "Boarding"
	add_child(boarding)
	track = SurvivalTrack.new()
	track.name = "SurvivalTrack"
	add_child(track)
	track.build(0)
	daylight = Environment.new()
	daylight.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var atmosphere := ProceduralSkyMaterial.new()
	atmosphere.sky_top_color = Color("172b51")
	atmosphere.sky_horizon_color = Color("a294ac")
	atmosphere.ground_horizon_color = Color("8b7c8c")
	sky.sky_material = atmosphere
	daylight.sky = sky
	daylight.fog_enabled = true
	daylight.fog_light_color = Color("69768d")
	daylight.fog_density = 0.0005
	daylight.glow_enabled = true
	daylight.glow_intensity = 0.55
	daylight.ssao_enabled = true
	daylight.ssao_radius = 2.0
	daylight.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	daylight.ambient_light_color = Color("c3d2d0")
	daylight.ambient_light_energy = 0.45
	daylight.tonemap_mode = Environment.TONE_MAPPER_ACES
	var sun := DirectionalLight3D.new()
	sun.light_color = Color("fff0d5")
	sun.light_energy = 0.85
	sun.shadow_enabled = true
	sun.rotation_degrees = Vector3(-48, 35, 0)
	add_child(sun)
	for index in 3:
		var bay := Marker3D.new()
		add_child(bay)
		bay.position = Vector3((index - 1) * 1.5, 0, 0)
		bay.rotation.y = PI
		_bays.append(bay)
	var layer := CanvasLayer.new()
	layer.layer = 20
	add_child(layer)
	_own_role = label(layer, Vector2(20, 20), 18)
	_guidance = label(layer, Vector2(20, 120), 20)
	_reticle = label(layer, Vector2.ZERO, 20)
	_reticle.text = "+"
	field_book = NavigationBook.new()
	layer.add_child(field_book)
	_results = PanelContainer.new()
	_results.position = Vector2(24, 210)
	_results.custom_minimum_size = Vector2(340, 180)
	layer.add_child(_results)
	var column := VBoxContainer.new()
	_results.add_child(column)
	_assessment = Label.new()
	_assessment.add_theme_font_size_override("font_size", 24)
	column.add_child(_assessment)
	_retry = Button.new()
	_retry.pressed.connect(func(): (get_parent() as WaitingRoom).choose_attempt(&"retry"))
	column.add_child(_retry)
	_return = Button.new()
	_return.pressed.connect(func(): (get_parent() as WaitingRoom).choose_attempt(&"waiting_room"))
	column.add_child(_return)
	_results.hide()

func label(parent: Node, at: Vector2, font: int) -> Label:
	var text := Label.new()
	text.position = at
	text.size.x = 950
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.add_theme_font_size_override("font_size", font)
	text.add_theme_color_override("font_outline_color", Color.BLACK)
	text.add_theme_constant_override("outline_size", 4)
	parent.add_child(text)
	return text

func announce_arrival() -> void:
	var waiting := get_parent() as WaitingRoom
	track.build(waiting.room_state().attempt.route_layout)
	report_open = true
	field_book.reset_book(waiting.room_state().attempt.route_layout)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if visible and event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_TAB:
		report_open = not report_open

func _input(event: InputEvent) -> void:
	# Consume page keys before E reaches the boarding interaction handler.
	var waiting := get_parent() as WaitingRoom
	if waiting == null or waiting.room_state() == null:
		return
	var player_id := waiting.player_id_for_peer(multiplayer.get_unique_id())
	if report_open and can_read_report(waiting.room_state().attempt, player_id) and event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode in [KEY_E, KEY_RIGHT, KEY_PAGEDOWN]:
			field_book.turn(1)
			get_viewport().set_input_as_handled()
		elif event.physical_keycode in [KEY_Q, KEY_LEFT, KEY_PAGEUP]:
			field_book.turn(-1)
			get_viewport().set_input_as_handled()

func can_read_report(state: AttemptState, player_id: int) -> bool:
	return visible and state.phase == &"active" and state.control_of(player_id) == &"rear"

func _process(_delta: float) -> void:
	var waiting := get_parent() as WaitingRoom
	if waiting == null or waiting.room_state() == null:
		return
	var state: AttemptState = waiting.room_state().attempt
	if visible:
		track.sync_obstacles(state, to_local(truck.body.global_position), multiplayer.is_server())
	var local := waiting._local_learner()
	var player_id := waiting.player_id_for_peer(multiplayer.get_unique_id())
	_reticle.visible = visible and state.phase == &"active" and local != null and not local.is_seated()
	_reticle.position = get_viewport().get_visible_rect().size * 0.5 - Vector2(6, 12)
	_guidance.visible = visible and state.phase in [&"active", &"aftermath"]
	_guidance.text = "MONSTER ARENA · Stunts cleared %d / 3\nTime %d:%02d" % [mini(state.test_item, 3), int(state.remaining) / 60, int(state.remaining) % 60]
	if state.phase == &"active":
		if state.control_of(player_id) == &"":
			_guidance.text += "\nBoard together: steering, speed, navigation. Navigator has the stunt book."
		elif state.control_of(player_id) != &"rear":
			_guidance.text += "\nAsk your navigator which stunt lane is live."
		if state.recovery_available:
			_guidance.text += "\nHold R to right the settled truck. %d%%" % int(state.recovery_elapsed * 50)
	elif not state.assessment().is_empty():
		_guidance.text = "EVERYONE MADE IT." if state.assessment().outcome == &"passed" else "ATTEMPT LOST · " + failure_reason(state.assessment().reason)
	field_book.visible = report_open and can_read_report(state, player_id)
	_results.visible = visible and state.phase == &"settled"
	if _results.visible:
		var result := state.assessment()
		_assessment.text = "EVERYONE MADE IT" if result.outcome == &"passed" else "ATTEMPT LOST\n" + failure_reason(result.reason)
		_retry.text = "Retry (%d/3)" % state.choices.values().count(&"retry")
		_return.text = "Waiting room (%d/3)" % state.choices.values().count(&"waiting_room")
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func failure_reason(reason: StringName) -> String:
	match reason:
		&"ravine": return "Lethal fall"
		&"crushed": return "A learner was crushed"
		&"timeout": return "Time ran out"
		_: return "Attempt conceded"

func bay_transform(index: int) -> Transform3D:
	return _bays[clampi(index, 0, 2)].global_transform

func is_prepared() -> bool:
	return _bays.size() == 3 and track != null and track.get_child_count() > 0

func show_own_role(copy: String) -> void:
	_own_role.text = copy
	_own_role.visible = visible and copy != ""

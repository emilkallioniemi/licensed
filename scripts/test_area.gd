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
var _report: PanelContainer
var _report_text: Label
var report_open := true

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
	daylight.background_mode = Environment.BG_COLOR
	daylight.background_color = Color("9caeac")
	daylight.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	daylight.ambient_light_color = Color("c3d2d0")
	daylight.ambient_light_energy = 0.65
	daylight.tonemap_mode = Environment.TONE_MAPPER_ACES
	var sun := DirectionalLight3D.new()
	sun.light_color = Color("fff0d5")
	sun.light_energy = 1.3
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
	_report = PanelContainer.new()
	_report.position = Vector2(20, 210)
	_report.custom_minimum_size = Vector2(470, 310)
	var paper := StyleBoxFlat.new()
	paper.bg_color = Color("eee3c8")
	paper.content_margin_left = 22
	paper.content_margin_right = 22
	paper.content_margin_top = 18
	paper.content_margin_bottom = 18
	_report.add_theme_stylebox_override("panel", paper)
	layer.add_child(_report)
	_report_text = Label.new()
	_report_text.custom_minimum_size.x = 440
	_report_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_report_text.add_theme_font_size_override("font_size", 18)
	_report_text.add_theme_color_override("font_color", Color("293a3d"))
	_report.add_child(_report_text)
	_report.hide()
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
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if visible and event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_TAB:
		report_open = not report_open

func can_read_report(state: AttemptState, player_id: int) -> bool:
	return visible and state.phase == &"active" and state.control_of(player_id) == &"rear"

func _process(_delta: float) -> void:
	var waiting := get_parent() as WaitingRoom
	if waiting == null or waiting.room_state() == null:
		return
	var state: AttemptState = waiting.room_state().attempt
	var local := waiting._local_learner()
	var player_id := waiting.player_id_for_peer(multiplayer.get_unique_id())
	_reticle.visible = visible and state.phase == &"active" and local != null and not local.is_seated()
	_reticle.position = get_viewport().get_visible_rect().size * 0.5 - Vector2(6, 12)
	_guidance.visible = visible and state.phase in [&"active", &"aftermath"]
	_guidance.text = "GET THROUGH ALIVE · Bridges crossed %d / 3\nTime %d:%02d" % [mini(state.test_item, 3), int(state.remaining) / 60, int(state.remaining) % 60]
	if state.phase == &"active":
		if state.control_of(player_id) == &"":
			_guidance.text += "\nBoard together: steering, speed, navigation. Navigator has the bridge report."
		elif state.control_of(player_id) != &"rear":
			_guidance.text += "\nAsk your navigator which bridge to take."
		if state.recovery_available:
			_guidance.text += "\nHold R to right the settled truck. %d%%" % int(state.recovery_elapsed * 50)
	elif not state.assessment().is_empty():
		_guidance.text = "EVERYONE MADE IT." if state.assessment().outcome == &"passed" else "ATTEMPT LOST · " + failure_reason(state.assessment().reason)
	_report.visible = report_open and can_read_report(state, player_id)
	if _report.visible:
		_report_text.text = SurvivalTrack.report(state.route_layout, state.test_item) + "\n\nTAB · Close / open report"
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

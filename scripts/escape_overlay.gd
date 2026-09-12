class_name EscapeOverlay
extends CanvasLayer
## A small panel over the world: quit, and Back for the host in the test area.
## Not a menu, not a pause; the room runs on behind it (spec section 9). Mic mode
## and mute are ticket 13 and land in `Voice`.

const QUIT_COPY := "Quit to desktop"
const BACK_COPY := "Back to the waiting room"

var _waiting: WaitingRoom
var _panel: PanelContainer
var _back: Button
var _open := false


func _ready() -> void:
	_waiting = get_parent() as WaitingRoom
	layer = 50
	_build()
	_show(false)
	set_process_unhandled_input(true)


func is_open() -> bool:
	return _open


func open() -> void:
	if _open or _waiting == null or _waiting.station_screen_is_open() or _waiting.is_returning():
		return
	_open = true
	_refresh_actions()
	_show(true)
	_waiting.set_escape_overlay_open(true)


func close() -> void:
	if not _open:
		return
	_open = false
	_show(false)
	if _waiting != null:
		_waiting.set_escape_overlay_open(false)


func _build() -> void:
	var root := Control.new()
	root.name = "Root"
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	var center := CenterContainer.new()
	center.name = "Center"
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(center)

	_panel = PanelContainer.new()
	_panel.name = "Panel"
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_panel.custom_minimum_size = Vector2(280, 0)
	center.add_child(_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 16)
	_panel.add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	margin.add_child(column)

	var top := HBoxContainer.new()
	column.add_child(top)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.add_child(spacer)
	var dismiss := Button.new()
	dismiss.name = "Close"
	dismiss.text = "×"
	dismiss.focus_mode = Control.FOCUS_NONE
	dismiss.pressed.connect(close)
	top.add_child(dismiss)

	# Ticket 13 adds mic mode and mute here. Leave the slot; do not build them.
	var voice := VBoxContainer.new()
	voice.name = "Voice"
	voice.add_theme_constant_override("separation", 8)
	column.add_child(voice)

	var quit := Button.new()
	quit.name = "Quit"
	quit.text = QUIT_COPY
	quit.focus_mode = Control.FOCUS_NONE
	quit.pressed.connect(_on_quit)
	column.add_child(quit)

	_back = Button.new()
	_back.name = "Back"
	_back.text = BACK_COPY
	_back.focus_mode = Control.FOCUS_NONE
	_back.pressed.connect(_on_back)
	column.add_child(_back)


func _show(shown: bool) -> void:
	if _panel != null:
		_panel.visible = shown


func _refresh_actions() -> void:
	if _back == null or _waiting == null:
		return
	_back.visible = _waiting.is_in_test_area() and multiplayer.is_server()


func _on_quit() -> void:
	if _waiting == null:
		return
	_waiting.quit_to_desktop()


func _on_back() -> void:
	if _waiting == null:
		return
	close()
	_waiting.request_return_from_test_area()


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	if _waiting != null and _waiting.station_screen_is_open():
		return
	if _open:
		close()
		get_viewport().set_input_as_handled()
		return
	if _waiting != null and _waiting.is_returning():
		return
	open()
	get_viewport().set_input_as_handled()

class_name EscapeOverlay
extends CanvasLayer
## A small panel over the world: mic mode, mute, quit, and Back for the host in
## the test area. Not a menu, not a pause; the room and voice run on behind it
## (spec section 9).

const QUIT_COPY := "Quit to desktop"
const BACK_COPY := "Back to the waiting room"
const OPEN_MIC_COPY := "Open mic"
const PUSH_TO_TALK_COPY := "Push to talk"
const MUTE_COPY := "Mute microphone"
const VoiceScript := preload("res://scripts/voice.gd")

var _waiting: WaitingRoom
var _voice: VoiceScript
var _panel: PanelContainer
var _open_mic: Button
var _push_to_talk: Button
var _mute: Button
var _back: Button
var _open := false


func _ready() -> void:
	_waiting = get_parent() as WaitingRoom
	_voice = get_parent().get_node_or_null("Voice") as VoiceScript
	layer = 50
	_build()
	_refresh_voice()
	_show(false)
	set_process_unhandled_input(true)


func is_open() -> bool:
	return _open


func open() -> void:
	if _open or _waiting == null or _waiting.station_screen_is_open() or _waiting.is_returning():
		return
	_open = true
	_refresh_actions()
	_refresh_voice()
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

	var voice := VBoxContainer.new()
	voice.name = "Voice"
	voice.add_theme_constant_override("separation", 8)
	column.add_child(voice)

	var modes := ButtonGroup.new()
	modes.allow_unpress = false
	_open_mic = Button.new()
	_open_mic.name = "OpenMic"
	_open_mic.text = OPEN_MIC_COPY
	_open_mic.toggle_mode = true
	_open_mic.button_group = modes
	_open_mic.focus_mode = Control.FOCUS_NONE
	_open_mic.pressed.connect(_on_open_mic)
	voice.add_child(_open_mic)
	_push_to_talk = Button.new()
	_push_to_talk.name = "PushToTalk"
	_push_to_talk.text = PUSH_TO_TALK_COPY
	_push_to_talk.toggle_mode = true
	_push_to_talk.button_group = modes
	_push_to_talk.focus_mode = Control.FOCUS_NONE
	_push_to_talk.pressed.connect(_on_push_to_talk)
	voice.add_child(_push_to_talk)
	_mute = Button.new()
	_mute.name = "Mute"
	_mute.text = MUTE_COPY
	_mute.toggle_mode = true
	_mute.focus_mode = Control.FOCUS_NONE
	_mute.toggled.connect(_on_mute)
	voice.add_child(_mute)

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


func _refresh_voice() -> void:
	if _voice == null:
		return
	if _open_mic != null:
		_open_mic.set_pressed_no_signal(_voice.is_open_mic())
	if _push_to_talk != null:
		_push_to_talk.set_pressed_no_signal(not _voice.is_open_mic())
	if _mute != null:
		_mute.set_pressed_no_signal(_voice.is_muted())


func _on_open_mic() -> void:
	if _voice != null:
		_voice.set_open_mic(true)


func _on_push_to_talk() -> void:
	if _voice != null:
		_voice.set_open_mic(false)


func _on_mute(pressed: bool) -> void:
	if _voice != null:
		_voice.set_muted(pressed)


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

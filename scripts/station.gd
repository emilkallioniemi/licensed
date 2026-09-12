class_name Station
extends Node3D
## The half of the station grammar every station shares: a zone around the approach
## marker, a world-space prompt in the signage register, and E. A screened station
## (the desk, the board) adds a station screen on top; a chair does not.

signal used

var _prompt: Label3D
var _zone: Area3D
var _local_in_zone := false
var _listening := true


## Place this node on the approach marker first, then call `setup`. `prompt_at` is
## the world position above the station; `zone_size` is the volume around the marker.
func setup(prompt_line: String, prompt_at: Vector3, zone_size: Vector3) -> void:
	_prompt = Label3D.new()
	_prompt.text = prompt_line
	_prompt.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_prompt.font_size = 42
	_prompt.outline_size = 10
	_prompt.pixel_size = 0.0014
	_prompt.fixed_size = true
	_prompt.modulate = Color("f4ecd7")
	_prompt.outline_modulate = Color(0.08, 0.08, 0.1, 1)
	_prompt.visible = false
	add_child(_prompt)
	_prompt.global_position = prompt_at

	_zone = Area3D.new()
	_zone.name = "Zone"
	_zone.collision_layer = 0
	_zone.collision_mask = 2
	_zone.monitoring = true
	_zone.monitorable = false
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = zone_size
	shape.shape = box
	shape.position.y = zone_size.y * 0.5 - global_position.y
	_zone.add_child(shape)
	add_child(_zone)
	_zone.body_entered.connect(_on_body_entered)
	_zone.body_exited.connect(_on_body_exited)

	set_process_unhandled_input(true)


## Signage on the world prompt; the desk swaps this when an invite is waiting.
func set_prompt(prompt_line: String) -> void:
	if _prompt != null:
		_prompt.text = prompt_line


## While false, the prompt stays hidden and E does nothing. Chairs turn this off
## while the local learner is seated, so E can stand instead of sitting again.
func set_listening(listening: bool) -> void:
	_listening = listening
	if listening:
		_rescan_zone.call_deferred()
	_refresh_prompt()


func _rescan_zone() -> void:
	_local_in_zone = false
	if _zone == null:
		return
	for body in _zone.get_overlapping_bodies():
		if body is Learner and (body as Learner).is_local():
			_local_in_zone = true
			break
	_refresh_prompt()


func _on_body_entered(body: Node3D) -> void:
	if body is Learner and (body as Learner).is_local():
		_local_in_zone = true
		_refresh_prompt()


func _on_body_exited(body: Node3D) -> void:
	if body is Learner and (body as Learner).is_local():
		_local_in_zone = false
		_refresh_prompt()


func _refresh_prompt() -> void:
	if _prompt != null:
		_prompt.visible = _listening and _local_in_zone


func _unhandled_input(event: InputEvent) -> void:
	if not _listening or not _local_in_zone:
		return
	if event is InputEventKey:
		var key := event as InputEventKey
		if key.pressed and not key.echo and key.physical_keycode == KEY_E:
			used.emit()
			get_viewport().set_input_as_handled()

class_name NoticeBoard
extends Node3D
## The kit's spare display: one line of signage, always on, not a station. Renders
## `RoomState.notice_board_line()` and never recomputes it.

## Drawn resolution on the cream backing (about 2.2 × 1.1 m).
const BOARD_PX := Vector2i(640, 320)
const BOARD_M := Vector2(2.2, 1.1)
## Signage ink, same as the booking board.
const INK := Color("293a3d")

var _waiting: WaitingRoom
var _line: Label


func _ready() -> void:
	_waiting = get_parent() as WaitingRoom
	_waiting.room_changed.connect(_on_room_changed)
	_build(_waiting.get_node("Kit") as Node3D)


func _build(kit: Node3D) -> void:
	var marker := kit.get_node_or_null("AttachmentPoints/FutureDisplay") as Marker3D
	if marker == null:
		push_error("Waiting room kit has no FutureDisplay marker")
		return
	_hide_placeholder_papers(kit)

	var viewport := SubViewport.new()
	viewport.name = "Line"
	viewport.size = BOARD_PX
	viewport.transparent_bg = true
	viewport.disable_3d = true
	viewport.handle_input_locally = false
	viewport.gui_disable_input = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(viewport)

	var root := Control.new()
	root.size = Vector2(BOARD_PX)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	viewport.add_child(root)

	_line = Label.new()
	_line.name = "Copy"
	_line.set_anchors_preset(Control.PRESET_FULL_RECT)
	_line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_line.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_line.add_theme_color_override("font_color", INK)
	_line.add_theme_font_size_override("font_size", 64)
	_line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_line)

	var quad := MeshInstance3D.new()
	quad.name = "Quad"
	var mesh := QuadMesh.new()
	mesh.size = BOARD_M
	quad.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
	mat.albedo_texture = viewport.get_texture()
	quad.set_surface_override_material(0, mat)
	add_child(quad)
	quad.global_transform = marker.global_transform
	quad.global_position = marker.global_position + marker.global_transform.basis.z * 0.04


func _hide_placeholder_papers(kit: Node3D) -> void:
	var display := kit.find_child("FutureDisplay", true, false)
	if display == null:
		return
	for node in display.find_children("*", "MeshInstance3D", true, false):
		var mesh := node as MeshInstance3D
		if (
			mesh.name.begins_with("Blank notice")
			or mesh.name.begins_with("Notice pin")
			or mesh.name.begins_with("Notice title")
		):
			mesh.visible = false


func _on_room_changed() -> void:
	var room := _waiting.room_state()
	if room == null or _line == null:
		return
	_line.text = room.notice_board_line()

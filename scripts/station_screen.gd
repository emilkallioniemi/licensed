class_name StationScreen
extends Node3D
## The other half of the station grammar: the camera glides to a dock pose framing the
## station, the mouse is released as a cursor, the learner stands still facing the
## station, and Escape returns the camera to the head. A screened station (the board,
## the desk) adds this on top of `Station`; a chair does not.

signal closed
## `collider` is the Area3D the cursor ray hit on the station's surfaces.
signal cursor_hit(collider: Node3D)

const GLIDE := 0.45
## Vertical FOV at the dock so the 3.5 m board (or a later desk) fills the view.
const DOCK_FOV := 55.0

var _camera: Camera3D
var _open := false
var _closing := false
var _learner: Learner
var _cursor_layer := 0
var _tween: Tween


func _ready() -> void:
	_camera = Camera3D.new()
	_camera.name = "DockCamera"
	_camera.current = false
	_camera.fov = DOCK_FOV
	add_child(_camera)
	set_process_unhandled_input(true)


func is_open() -> bool:
	return _open or _closing


## `cursor_layer` is the physics layer the cursor ray tests against (row surfaces, later
## desk controls). Hits on that layer are mapped by the station that owns this screen.
func open(learner: Learner, dock: Transform3D, cursor_layer: int) -> void:
	if _open or _closing or learner == null or learner.camera == null:
		return
	_learner = learner
	_cursor_layer = cursor_layer
	_open = true
	_closing = false
	_face_station(learner, dock)
	_camera.global_transform = learner.camera.global_transform
	_camera.fov = learner.camera.fov
	_camera.current = true
	learner.set_using_station(true)
	_glide(dock, DOCK_FOV)


func close() -> void:
	if not _open or _closing:
		return
	_open = false
	_closing = true
	if _learner != null and is_instance_valid(_learner) and _learner.camera != null:
		await _glide(_learner.camera.global_transform, _learner.camera.fov)
	_camera.current = false
	if _learner != null and is_instance_valid(_learner):
		_learner.set_using_station(false)
	_learner = null
	_closing = false
	closed.emit()


## Keep the dock after a failed Join rehosts this room. The old learner is gone; the
## new one must stand still at the desk so the row can show the failure line.
func rebind_learner(learner: Learner) -> void:
	if not _open or _closing or learner == null:
		return
	_learner = learner
	_face_station(learner, _camera.global_transform)
	learner.set_using_station(true)
	_camera.current = true


func _face_station(learner: Learner, dock: Transform3D) -> void:
	var toward := -dock.basis.z
	toward.y = 0.0
	if toward.length_squared() > 0.0001:
		learner.basis = Basis.looking_at(toward.normalized(), Vector3.UP)
	learner.velocity = Vector3.ZERO


func _glide(to: Transform3D, fov: float) -> void:
	if _tween != null and _tween.is_running():
		_tween.kill()
	_tween = create_tween()
	_tween.set_parallel(true)
	_tween.tween_property(_camera, "global_transform", to, GLIDE).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_property(_camera, "fov", fov, GLIDE)
	await _tween.finished


func _unhandled_input(event: InputEvent) -> void:
	if not _open:
		return
	if event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()
		return
	if event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if mouse.pressed and mouse.button_index == MOUSE_BUTTON_LEFT:
			var collider := _raycast(mouse.position)
			if collider != null:
				cursor_hit.emit(collider)
			get_viewport().set_input_as_handled()


func _raycast(mouse: Vector2) -> Node3D:
	if _camera == null:
		return null
	var from := _camera.project_ray_origin(mouse)
	var dir := _camera.project_ray_normal(mouse)
	var query := PhysicsRayQueryParameters3D.create(from, from + dir * 16.0)
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.collision_mask = _cursor_layer
	var hit := _camera.get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return null
	return hit.get("collider") as Node3D

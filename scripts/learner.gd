class_name Learner
extends CharacterBody3D
## A player's body in the waiting room: first-person walk, look, and collide. Ticket 04 wraps
## this in a replicated peer; `set_local` is the seam that turns input, the camera, and hiding
## your own head on or off without a rewrite.

## Walk speed. No sprint, no jump (spec section 2).
const WALK_SPEED := 3.0
## First-person camera height, metres above the feet.
const EYE_HEIGHT := 1.75
## Radians per mouse-pixel. Not a setting; ticket 12's overlay does not expose it.
const MOUSE_SENSITIVITY := 0.0022
## Pitch stops just short of straight up/down so the camera cannot flip.
const PITCH_LIMIT := deg_to_rad(89.0)

## True for the learner this machine walks. Ticket 04 sets it from multiplayer authority.
## Defaults off so a remote spawn cannot steal the camera before `set_local` runs.
var _local := false
var _palette := 0
var _display_name := ""

@onready var camera: Camera3D = $Camera3D
@onready var visual: Node3D = $Visual
@onready var name_tag: Label3D = $NameTag


func _ready() -> void:
	camera.position.y = EYE_HEIGHT
	_apply_local()
	_apply_palette()
	_apply_display_name()


## Turns this learner into the one this machine walks (`true`) or a body someone else walks
## (`false`). Safe before or after the node enters the tree.
func set_local(local: bool) -> void:
	_local = local
	if is_node_ready():
		_apply_local()


func is_local() -> bool:
	return _local


## Arrival-slot palette 1/2/3. Safe before or after the node enters the tree.
func apply_palette(slot: int) -> void:
	_palette = slot
	if is_node_ready():
		_apply_palette()


func palette() -> int:
	return _palette


## The name tag's line. Drawn for the other two, never for the local learner.
func set_display_name(text: String) -> void:
	_display_name = text
	if is_node_ready():
		_apply_display_name()


func _apply_local() -> void:
	camera.current = _local
	var head := visual.find_child("HeadPivot", true, false)
	if head != null:
		head.visible = not _local
	name_tag.visible = not _local
	set_physics_process(_local)
	set_process_unhandled_input(_local)
	if _local:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _apply_palette() -> void:
	if _palette < 1:
		return
	Palettes.apply(visual, _palette)


func _apply_display_name() -> void:
	name_tag.text = _display_name


func _unhandled_input(event: InputEvent) -> void:
	if not _local:
		return
	if event.is_action_pressed("ui_cancel") and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		get_viewport().set_input_as_handled()
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var motion := event as InputEventMouseMotion
		rotate_y(-motion.relative.x * MOUSE_SENSITIVITY)
		camera.rotate_x(-motion.relative.y * MOUSE_SENSITIVITY)
		camera.rotation.x = clampf(camera.rotation.x, -PITCH_LIMIT, PITCH_LIMIT)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= float(ProjectSettings.get_setting("physics/3d/default_gravity")) * delta
	var wish := Vector2(
		float(Input.is_physical_key_pressed(KEY_D)) - float(Input.is_physical_key_pressed(KEY_A)),
		float(Input.is_physical_key_pressed(KEY_S)) - float(Input.is_physical_key_pressed(KEY_W)),
	)
	if wish != Vector2.ZERO:
		var direction := (transform.basis * Vector3(wish.x, 0.0, wish.y)).normalized()
		velocity.x = direction.x * WALK_SPEED
		velocity.z = direction.z * WALK_SPEED
	else:
		velocity.x = 0.0
		velocity.z = 0.0
	move_and_slide()

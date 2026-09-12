class_name Learner
extends CharacterBody3D
## A player's body in the waiting room: first-person walk, look, and collide. Ticket 04 wraps
## this in a replicated peer; `set_local` is the seam that turns input, the camera, and hiding
## your own body on or off without a rewrite.

## Waiting-room movement speeds in metres per second.
const WALK_SPEED := 3.0
const SPRINT_SPEED := 6.0
const JUMP_VELOCITY := 5.0
## First-person camera height, metres above the feet.
const EYE_HEIGHT := 1.75
## Seated camera height, metres above the feet. Mouse look stays live (spec section 7).
const SEATED_EYE_HEIGHT := 1.2
## Radians per mouse-pixel. Not a setting; ticket 12's overlay does not expose it.
const MOUSE_SENSITIVITY := 0.0022
## Pitch stops just short of straight up/down so the camera cannot flip.
const PITCH_LIMIT := deg_to_rad(89.0)

## True for the learner this machine walks. Ticket 04 sets it from multiplayer authority.
## Defaults off so a remote spawn cannot steal the camera before `set_local` runs.
var _local := false
var _palette := 0
var _display_name := ""
var _held_role: StringName = &""
## False while the arrival theatre has this body hidden in the doorway.
var _body_visible := true
## False for a joiner until the door has opened, so they fade up standing still on Entrance.
var _can_walk := true
## True while this learner occupies a chair. Walk is off; look stays on.
var _seated := false
## True while this machine's station screen is open. Walk and look are off; the
## station's dock camera is current and the mouse is a cursor.
var _using_station := false
## True while the Escape overlay is open. Look is off and the mouse is a cursor;
## walk stays on because the overlay pauses nothing.
var _escape_overlay_open := false
## True while this machine is receiving this learner's voice.
var _speaking := false

# Presentation runs at render frequency; collision and walking stay at 60 Hz.
var _previous_position := Vector3.ZERO
var _current_position := Vector3.ZERO
var _pitch := 0.0
var _remote_pose := Transform3D.IDENTITY
var _visual_offset := Transform3D.IDENTITY
var _tag_offset := Transform3D.IDENTITY
const REMOTE_RESPONSE := 20.0
const TELEPORT_DISTANCE := 1.5

@onready var camera: Camera3D = $Camera3D
@onready var visual: Node3D = $Visual
@onready var name_tag: Label3D = $NameTag
@onready var role_line: Label3D = $NameTag/RoleLine
@onready var speaking_mark: Label3D = $NameTag/Speaking


func _ready() -> void:
	_previous_position = global_position
	_current_position = global_position
	_remote_pose = global_transform
	_visual_offset = visual.transform
	_tag_offset = name_tag.transform
	camera.top_level = true
	_apply_local()
	_apply_palette()
	_apply_display_name()
	_apply_held_role()
	_apply_speaking()
	_update_presentation(0.0, 1.0)


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


## The name tag's second line: the held role, seen by the other two, never by yourself.
func set_held_role(role: StringName) -> void:
	_held_role = role
	if is_node_ready():
		_apply_held_role()


## Shown in the room (true) or hidden in the doorway until the door opens (false).
## Safe before or after the node enters the tree. Does not hide the local camera.
func set_body_visible(shown: bool) -> void:
	_body_visible = shown
	if is_node_ready():
		_apply_body_visible()


## Walk and look. Off for a joiner until they have appeared in the doorway.
func set_can_walk(enabled: bool) -> void:
	_can_walk = enabled
	if is_node_ready():
		_apply_local()


## Sit on a chair's footprint. Camera drops to seated height; mouse look stays live.
func set_seated(seated: bool) -> void:
	_seated = seated
	if is_node_ready():
		_apply_local()


func is_seated() -> bool:
	return _seated


## Stand still at a screened station. The dock camera takes over; the other two
## still see this body facing the station. Safe before or after the node enters the tree.
func set_using_station(using: bool) -> void:
	_using_station = using
	if is_node_ready():
		_apply_local()


func is_using_station() -> bool:
	return _using_station


## Release the mouse as a cursor while the Escape overlay is open; recapture on close.
func set_escape_overlay_open(open: bool) -> void:
	_escape_overlay_open = open
	if is_node_ready():
		_apply_local()


## The name-tag mark while this player's voice is being received here.
func set_speaking(speaking: bool) -> void:
	_speaking = speaking
	if is_node_ready():
		_apply_speaking()


func _apply_local() -> void:
	camera.current = _local and not _using_station
	var walk := _local and _can_walk and not _seated and not _using_station
	if not walk:
		velocity = Vector3.ZERO
		_previous_position = global_position
		_current_position = global_position
	var look := _local and not _using_station and not _escape_overlay_open and (_can_walk or _seated)
	set_physics_process(walk)
	set_process_unhandled_input(look)
	if _local:
		if _using_station or _escape_overlay_open:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_apply_body_visible()


func _apply_body_visible() -> void:
	if visual == null or name_tag == null:
		return
	# Each player sees only the other learners, including while using a station.
	visual.visible = _body_visible and not _local
	name_tag.visible = _body_visible and not _local


func _apply_palette() -> void:
	if _palette < 1:
		return
	Palettes.apply(visual, _palette)


func _apply_display_name() -> void:
	name_tag.text = _display_name


## Signage for a held or dealt role: "Driver" / "Spotter" / "Navigator" / "Random".
static func role_label(role: StringName) -> String:
	match role:
		RoomState.DRIVER:
			return "Driver"
		RoomState.SPOTTER:
			return "Spotter"
		RoomState.NAVIGATOR:
			return "Navigator"
		RoomState.RANDOM:
			return "Random"
		_:
			return ""


func _apply_held_role() -> void:
	if role_line == null:
		return
	role_line.text = role_label(_held_role)


func _apply_speaking() -> void:
	if speaking_mark == null:
		return
	speaking_mark.visible = _speaking


func _unhandled_input(event: InputEvent) -> void:
	if not _local:
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var motion := event as InputEventMouseMotion
		rotate_y(-motion.relative.x * MOUSE_SENSITIVITY)
		_pitch = clampf(_pitch - motion.relative.y * MOUSE_SENSITIVITY, -PITCH_LIMIT, PITCH_LIMIT)


func _process(delta: float) -> void:
	_update_presentation(delta, Engine.get_physics_interpolation_fraction())


func _update_presentation(delta: float, fraction: float) -> void:
	if _local:
		# Chair, doorway and test-area placement writes the body outside physics.
		# Discard old samples so those moves never sweep the camera through walls.
		if not global_position.is_equal_approx(_current_position):
			_previous_position = global_position
			_current_position = global_position
		var eye_height := SEATED_EYE_HEIGHT if _seated else EYE_HEIGHT
		camera.global_transform = Transform3D(
			global_basis * Basis(Vector3.RIGHT, _pitch),
			_previous_position.lerp(_current_position, clampf(fraction, 0.0, 1.0)) + Vector3.UP * eye_height
		)
	else:
		# Keep collision at the received position, smoothing only visible geometry.
		# A large discontinuity is a teleport, not a walk to interpolate.
		if _remote_pose.origin.distance_to(global_position) > TELEPORT_DISTANCE or not _body_visible:
			_remote_pose = global_transform
		else:
			_remote_pose = _remote_pose.interpolate_with(global_transform, 1.0 - exp(-REMOTE_RESPONSE * delta))
		visual.global_transform = _remote_pose * _visual_offset
		name_tag.global_transform = _remote_pose * _tag_offset


func _physics_process(delta: float) -> void:
	_previous_position = global_position
	if not is_on_floor():
		velocity.y -= float(ProjectSettings.get_setting("physics/3d/default_gravity")) * delta
	elif Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
	var wish := Vector2(
		float(Input.is_physical_key_pressed(KEY_D)) - float(Input.is_physical_key_pressed(KEY_A)),
		float(Input.is_physical_key_pressed(KEY_S)) - float(Input.is_physical_key_pressed(KEY_W)),
	)
	if wish != Vector2.ZERO:
		var direction := (transform.basis * Vector3(wish.x, 0.0, wish.y)).normalized()
		var speed := SPRINT_SPEED if Input.is_action_pressed("sprint") else WALK_SPEED
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = 0.0
		velocity.z = 0.0
	move_and_slide()
	_current_position = global_position

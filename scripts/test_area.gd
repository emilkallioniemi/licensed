class_name TestArea
extends Node3D
## The car park beyond the Test Area door: asphalt, painted bays as boxes, daylight,
## one MONSTER TRUCK sign. TEMPORARY ARRIVAL GEOMETRY: ticket 02 replaces the
## car park with the secured truck, seated examiner and boarding space.

## Centre-to-centre spacing of the three bays, metres (spec section 8).
const BAY_SPACING := 1.5

## Daylight the waiting room swaps in for its WorldEnvironment.
var daylight: Environment

var truck: MonsterTruck
var boarding: TruckBoarding
var _bays: Array[Marker3D] = []
var _own_role: Label
var examiner_audio: AudioStreamPlayer
var examiner_subtitle: Label
var subtitle_time := 0.0
var _announced_result := ""
var _results: PanelContainer
var _assessment: Label
var _retry: Button
var _return: Button


func _ready() -> void:
	visible = false
	_build()


func _build() -> void:
	truck = MonsterTruck.new()
	truck.name = "MonsterTruck"
	add_child(truck)
	truck.position = Vector3(0, 0, -9)
	examiner_audio = AudioStreamPlayer.new()
	examiner_audio.stream = load("res://assets/monster_truck/temporary_request.wav")
	add_child(examiner_audio)
	boarding = TruckBoarding.new()
	boarding.name = "Boarding"
	add_child(boarding)
	daylight = Environment.new()
	daylight.background_mode = Environment.BG_COLOR
	daylight.background_color = Color(0.62, 0.78, 0.92)
	daylight.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	daylight.ambient_light_color = Color(0.92, 0.93, 0.88)
	daylight.ambient_light_energy = 0.9
	daylight.tonemap_mode = Environment.TONE_MAPPER_ACES

	var sun := DirectionalLight3D.new()
	sun.name = "Sun"
	sun.light_color = Color(1.0, 0.96, 0.88)
	sun.light_energy = 1.35
	sun.shadow_enabled = true
	sun.rotation_degrees = Vector3(-48.0, 35.0, 0.0)
	add_child(sun)

	_add_box("Asphalt", Vector3(80.0, 0.08, 80.0), Vector3(0.0, -0.04, 0.0), Color("3a3a38"), true)
	var xs := [-BAY_SPACING, 0.0, BAY_SPACING]
	for i in xs.size():
		_add_box(
			"Bay%d" % (i + 1),
			Vector3(1.15, 0.06, 2.4),
			Vector3(xs[i], 0.03, 0.2),
			Color("c9b56a"),
			false,
		)
		var bay := Marker3D.new()
		bay.name = "BayMarker%d" % (i + 1)
		add_child(bay)
		bay.position = Vector3(xs[i], 0.0, 0.0)
		_bays.append(bay)

	_add_box("SignPost", Vector3(0.12, 2.2, 0.12), Vector3(0.0, 1.1, 6.0), Color("4a4034"), false)
	_add_box("SignBoard", Vector3(2.6, 0.7, 0.08), Vector3(0.0, 2.35, 6.0), Color("e8e0cc"), false)
	var sign := Label3D.new()
	sign.name = "Vehicle"
	sign.text = "MONSTER TRUCK"
	sign.font_size = 72
	sign.outline_size = 8
	sign.pixel_size = 0.004
	sign.modulate = Color("293a3d")
	sign.outline_modulate = Color("e8e0cc")
	add_child(sign)
	sign.position = Vector3(0.0, 2.35, 5.94)
	sign.rotation.y = PI

	var own_role_layer := CanvasLayer.new()
	own_role_layer.name = "OwnRole"
	own_role_layer.layer = 20
	add_child(own_role_layer)
	_own_role = Label.new()
	_own_role.name = "Line"
	_own_role.visible = false
	_own_role.position = Vector2(16, 16)
	_own_role.add_theme_font_size_override("font_size", 16)
	_own_role.add_theme_color_override("font_color", Color("f4ecd7"))
	_own_role.add_theme_color_override("font_outline_color", Color(0.08, 0.08, 0.1, 1))
	_own_role.add_theme_constant_override("outline_size", 4)
	own_role_layer.add_child(_own_role)
	examiner_subtitle = Label.new()
	examiner_subtitle.position = Vector2(16, 550)
	examiner_subtitle.add_theme_font_size_override("font_size", 22)
	own_role_layer.add_child(examiner_subtitle)
	_results = PanelContainer.new()
	_results.position = Vector2(24, 170)
	_results.custom_minimum_size = Vector2(320, 200)
	own_role_layer.add_child(_results)
	var column := VBoxContainer.new()
	_results.add_child(column)
	_assessment = Label.new()
	column.add_child(_assessment)
	_retry = Button.new()
	_retry.text = "Retry"
	_retry.pressed.connect(func(): (get_parent() as WaitingRoom).choose_attempt(&"retry"))
	column.add_child(_retry)
	_return = Button.new()
	_return.text = "Waiting room"
	_return.pressed.connect(func(): (get_parent() as WaitingRoom).choose_attempt(&"waiting_room"))
	column.add_child(_return)
	_results.hide()
	# Temporary side-bank overturn sample; route tickets replace this geometry.
	_add_box("ApronBump", Vector3(3, 1.4, 10), Vector3(-25, 0.7, -12), Color("777d7b"), true)
	# Temporary uneven-ground checkpoint sample; route ticket 12 owns replacement.
	_add_box("ApronBump", Vector3(7, 0.9, 1.5), Vector3(-14, 0.45, -8), Color("777d7b"), true)
	# Cooperation course only. Tickets 09–12 replace this apron with the fixed route.
	for at in [Vector3(-4, 0.6, -21), Vector3(4, 0.6, -21), Vector3(4, 0.6, -30), Vector3(12, 0.6, -30)]:
		_add_box("Gate", Vector3(0.5, 1.2, 0.5), at, Color("e4b752"), true)
	for at in [Vector3(16, 0.7, -18), Vector3(16, 0.7, -7)]:
		_add_box("ParkingWreck", Vector3(3, 1.4, 3), at, Color("705f56"), true)
	for x in [12.0, 20.0]:
		_add_box("ParkingLine", Vector3(0.12, 0.02, 8), Vector3(x, 0.02, -12.5), Color("e4b752"), false)
	for z in [-16.5, -8.5]:
		_add_box("ParkingLine", Vector3(8, 0.02, 0.12), Vector3(16, 0.02, z), Color("e4b752"), false)

func announce_arrival() -> void:
	_announced_result = ""
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	examiner_audio.stream = load("res://assets/monster_truck/temporary_request.wav")
	examiner_audio.play()
	examiner_subtitle.text = "I would like to see a turn, a reverse, and a parked vehicle."
	subtitle_time = 7.0

func _process(delta: float) -> void:
	subtitle_time = maxf(0.0, subtitle_time - delta)
	examiner_subtitle.visible = visible and subtitle_time > 0.0
	var waiting := get_parent() as WaitingRoom
	if waiting == null or waiting.room_state() == null:
		return
	var state: AttemptState = waiting.room_state().attempt
	var result := state.assessment()
	_results.visible = visible and state.phase == &"settled"
	if not result.is_empty() and visible and _announced_result != state.id:
		_announced_result = state.id
		examiner_audio.stream = load("res://assets/monster_truck/temporary_failure.wav")
		examiner_audio.play()
		examiner_subtitle.text = "We will leave it there."
		subtitle_time = 5.0
	if _results.visible:
		_assessment.text = "DRIVING TEST — FAILED\n%s\nMinor faults: %d" % [str(result.reason).capitalize(), result.minor_faults]
		_retry.text = "Retry (%d/3)" % state.choices.values().count(&"retry")
		_return.text = "Waiting room (%d/3)" % state.choices.values().count(&"waiting_room")
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _add_box(box_name: String, size: Vector3, at: Vector3, color: Color, collide: bool) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = box_name
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = color
	mesh_instance.set_surface_override_material(0, mat)
	add_child(mesh_instance)
	mesh_instance.position = at
	if not collide:
		return
	var body := StaticBody3D.new()
	if box_name in ["Asphalt", "ApronBump"]:
		body.collision_layer = 9
	if box_name in ["Gate", "ParkingWreck"]:
		body.collision_layer = 5
	body.name = "%sCollision" % box_name
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	body.add_child(shape)
	add_child(body)
	body.position = at


## Pose of bay `index` (0, 1, 2) in world space, facing the sign.
func bay_transform(index: int) -> Transform3D:
	var bay := _bays[clampi(index, 0, _bays.size() - 1)]
	# Learners look down local −Z; +Z of the bay is toward the sign.
	var facing := bay.global_transform.basis.z
	facing.y = 0.0
	if facing.length_squared() <= 0.0001:
		facing = Vector3.FORWARD
	return Transform3D(Basis.looking_at(facing.normalized(), Vector3.UP), bay.global_position)


func is_prepared() -> bool:
	return _bays.size() == 3 and get_node_or_null("AsphaltCollision") != null


func show_own_role(copy: String) -> void:
	if _own_role == null:
		return
	_own_role.text = copy
	_own_role.visible = copy != ""

class_name TestArea
extends Node3D
## The car park beyond the Test Area door: asphalt, painted bays as boxes, daylight,
## one MONSTER TRUCK sign. Nothing to do. Slice 1 starts here.

## Centre-to-centre spacing of the three bays, metres (spec section 8).
const BAY_SPACING := 1.5

## Daylight the waiting room swaps in for its WorldEnvironment.
var daylight: Environment

var _bays: Array[Marker3D] = []
var _own_role: Label


func _ready() -> void:
	visible = false
	_build()


func _build() -> void:
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


func show_own_role(copy: String) -> void:
	if _own_role == null:
		return
	_own_role.text = copy
	_own_role.visible = copy != ""

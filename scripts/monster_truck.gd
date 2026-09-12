class_name MonsterTruck
extends Node3D
## Retained rough cab; ticket 03 supplies driving.
var body: AnimatableBody3D
var motion := Vector3.ZERO
var angular_motion := 0.0

func _ready() -> void:
	body = AnimatableBody3D.new()
	body.name = "Body"
	body.sync_to_physics = false
	add_child(body)
	box("Deck", Vector3(4.8, 0.3, 5.0), Vector3(0, 1.45, 0), Color("ba713d"))
	box("Roof", Vector3(4.8, 0.2, 5.0), Vector3(0, 4.15, 0), Color("ba713d"))
	for x in [-2.25, 2.25]:
		box("FrontPillar", Vector3(0.3, 2.6, 0.3), Vector3(x, 2.8, -2.3), Color("a95232"))
		box("RearPillar", Vector3(0.3, 2.6, 0.3), Vector3(x, 2.8, 2.3), Color("a95232"))
		box("Sill", Vector3(0.2, 0.65, 2.7), Vector3(x, 1.9, -0.95), Color("a95232"))
		for z in [-1.8, 1.8]:
			box("Tyre", Vector3(1.0, 2.2, 1.7), Vector3(x * 1.22, 1.1, z), Color("27282b"))
	# Walkable ramps are rough access, no teleport ladder.
	ramp("BoardingRamp", Vector3(1.4, 0.16, 4.1), Vector3(1.1, 0.8, 4.4), deg_to_rad(23))
	ramp("RoofRamp", Vector3(1.4, 0.16, 11.0), Vector3(-1.5, 2.1, 7.5), deg_to_rad(23))
	for control in AttemptState.CONTROLS:
		var at: Vector3 = AttemptState.CONTROLS[control]
		var back := 1.0 if control != &"rear" else -1.0
		box("Seat", Vector3(0.65, 0.35, 0.65), at + Vector3(0, 0.175, 0), Color("334b55"))
		box("Control", Vector3(0.6, 0.16, 0.2), at + Vector3(0, 0.9, -back * 0.5), Color("e6ce72"))
		label(str(control).to_upper(), at + Vector3(0, 1.1, -back * 0.6), PI if back < 0 else 0.0)
	box("ExaminerSeat", Vector3(0.7, 0.4, 0.7), Vector3(1.2, 1.8, 1.4), Color("394049"))
	box("Examiner", Vector3(0.55, 0.85, 0.45), Vector3(1.2, 2.35, 1.4), Color("655951"))
	box("ExaminerHead", Vector3(0.4, 0.4, 0.4), Vector3(1.2, 2.98, 1.4), Color("c59a79"))
	box("Clipboard", Vector3(0.45, 0.06, 0.5), Vector3(1.2, 2.2, 0.95), Color("d0c5a0"))
	label("EXAMINER", Vector3(1.2, 3.4, 1.4), 0.0)

func box(title: String, size: Vector3, at: Vector3, colour: Color) -> Node3D:
	var part := CollisionShape3D.new()
	part.name = title
	var shape := BoxShape3D.new()
	shape.size = size
	part.shape = shape
	body.add_child(part)
	part.position = at
	var mesh := MeshInstance3D.new()
	var cube := BoxMesh.new()
	cube.size = size
	mesh.mesh = cube
	var material := StandardMaterial3D.new()
	material.albedo_color = colour
	mesh.material_override = material
	part.add_child(mesh)
	return part

func ramp(title: String, size: Vector3, at: Vector3, angle: float) -> void:
	box(title, size, at, Color("777d7b")).rotation.x = angle

func label(copy: String, at: Vector3, yaw: float) -> void:
	var sign := Label3D.new()
	sign.text = copy
	sign.font_size = 36
	sign.pixel_size = 0.004
	body.add_child(sign)
	sign.position = at
	sign.rotation.y = yaw

func advance(delta: float) -> void:
	body.position += motion * delta
	body.rotate_y(angular_motion * delta)

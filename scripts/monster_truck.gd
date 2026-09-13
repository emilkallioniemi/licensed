class_name MonsterTruck
extends Node3D
## Retained rough cab and arcade two-axle driving. Production bodywork: ticket 07.
var body: AnimatableBody3D
var motion := Vector3.ZERO
var angular_motion := 0.0
var instruments: Label3D
var pointers: Dictionary = {}
var needles: Dictionary = {}
var tyres: Array[Node3D] = []
var engine: AudioStreamPlayer3D
var impact: AudioStreamPlayer3D
var impact_cooldown := 0.0
var visuals: Node3D
var control_meshes: Dictionary = {}

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
			tyres.append(box("Tyre", Vector3(1.0, 2.2, 1.7), Vector3(x * 1.22, 1.1, z), Color("27282b")))
	# Walkable ramps are rough access, no teleport ladder.
	ramp("BoardingRamp", Vector3(1.4, 0.16, 4.1), Vector3(1.1, 0.8, 4.4), deg_to_rad(23))
	ramp("RoofRamp", Vector3(1.4, 0.16, 11.0), Vector3(-1.5, 2.1, 7.5), deg_to_rad(23))
	for control in AttemptState.CONTROLS:
		var at: Vector3 = AttemptState.CONTROLS[control]
		var back := 1.0 if control != &"rear" else -1.0
		box("Seat", Vector3(0.65, 0.35, 0.65), at + Vector3(0, 0.175, 0), Color("334b55"))
		control_meshes[control] = box("Control", Vector3(0.6, 0.16, 0.2), at + Vector3(0, 0.9, -back * 0.5), Color("e6ce72")).get_child(0)
		var name_sign := label(str(control).to_upper(), at + Vector3(0.32, 1.25, -back * 0.65), PI if back < 0 else 0.0)
		name_sign.pixel_size = 0.0015
	box("ExaminerSeat", Vector3(0.7, 0.4, 0.7), Vector3(1.2, 1.8, 1.4), Color("394049"))
	box("Examiner", Vector3(0.55, 0.85, 0.45), Vector3(1.2, 2.35, 1.4), Color("655951"))
	box("ExaminerHead", Vector3(0.4, 0.4, 0.4), Vector3(1.2, 2.98, 1.4), Color("c59a79"))
	box("Clipboard", Vector3(0.45, 0.06, 0.5), Vector3(1.2, 2.2, 0.95), Color("d0c5a0"))
	label("EXAMINER", Vector3(1.2, 3.4, 1.4), 0.0)
	# Opaque waist-height bodywork hides nearby tyre contact points; instruments
	# are ordinary depth-tested surfaces, readable only with physical sight.
	box("Bonnet", Vector3(4.1, 1.0, 0.9), Vector3(0, 2.1, -2.6), Color("a95232"))
	box("RearPanel", Vector3(2.0, 0.8, 0.2), Vector3(-0.9, 2.05, 2.35), Color("a95232"))
	instruments = label("", Vector3(1.2, 2.95, -2.03), 0.0)
	instruments.font_size = 28
	instruments.pixel_size = 0.0018
	for control in [&"front", &"rear"]:
		var at: Vector3 = AttemptState.CONTROLS[control]
		var back := -1.0 if control == &"rear" else 1.0
		pointers[control] = label("", at + Vector3(-0.38, 1.1, -back * 0.65), PI if back < 0 else 0.0)
		pointers[control].pixel_size = 0.0015
		var pivot := Node3D.new()
		body.add_child(pivot)
		pivot.position = at + Vector3(-0.38, 1.2, -back * 0.65)
		pivot.rotation.y = PI if back < 0 else 0.0
		var needle := MeshInstance3D.new()
		var needle_mesh := BoxMesh.new()
		needle_mesh.size = Vector3(0.018, 0.16, 0.018)
		needle.mesh = needle_mesh
		needle.position.y = 0.08
		pivot.add_child(needle)
		needles[control] = pivot
	engine = AudioStreamPlayer3D.new()
	engine.stream = tone(true)
	engine.volume_db = -19.0
	body.add_child(engine)
	impact = AudioStreamPlayer3D.new()
	impact.stream = tone(false)
	impact.volume_db = -8.0
	body.add_child(impact)
	visuals = Node3D.new()
	body.add_child(visuals)
	var visible_tyres: Array[Node3D] = []
	for part in body.get_children():
		if part is CollisionShape3D:
			for mesh in part.get_children():
				mesh.reparent(visuals, true)
				if part in tyres:
					visible_tyres.append(mesh)
		elif part is Label3D or part in needles.values():
			part.reparent(visuals, true)
	tyres = visible_tyres

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

func label(copy: String, at: Vector3, yaw: float) -> Label3D:
	var sign := Label3D.new()
	sign.text = copy
	sign.font_size = 36
	sign.pixel_size = 0.004
	body.add_child(sign)
	sign.position = at
	sign.rotation.y = yaw
	return sign

func drive(state: AttemptState, delta: float, present := true) -> void:
	var front := tan(state.front_angle)
	var rear := tan(state.rear_angle)
	angular_motion = -state.speed * (front - rear) / 3.6
	var sideways := (front + rear) * 0.5
	motion = body.global_basis * Vector3(sideways, 0, -1).normalized() * state.speed
	var from := body.global_transform
	# Only environment structures use layer 4. Learners and deck contact must
	# not stop the truck. Sweep a whole-cab hull, including rotation corners.
	var query := PhysicsShapeQueryParameters3D.new()
	var hull := BoxShape3D.new()
	hull.size = Vector3(5.8, 3.8, 5.8)
	query.shape = hull
	query.transform = from.translated_local(Vector3(0, 2.0, -0.2))
	query.motion = motion * delta
	query.collision_mask = 4
	var fractions := get_world_3d().direct_space_state.cast_motion(query)
	var fraction := fractions[0]
	body.global_position += motion * delta * fraction
	body.rotate_y(angular_motion * delta * fraction)
	query.transform = body.global_transform.translated_local(Vector3(0, 2.0, -0.2))
	if not get_world_3d().direct_space_state.intersect_shape(query, 1).is_empty():
		body.global_transform = from
		fraction = 0.0
	if present:
		impact_cooldown = maxf(0.0, impact_cooldown - delta)
	if fraction < 1.0:
		if present and absf(state.speed) > 0.5 and impact_cooldown == 0.0:
			impact.play()
			impact_cooldown = 0.5
		state.speed = 0.0
		motion = Vector3.ZERO
		angular_motion = 0.0
	if not present:
		return
	visuals.position = visuals.position.move_toward(Vector3.ZERO, delta * 8.0)
	visuals.rotation.y = move_toward(visuals.rotation.y, 0.0, delta * 2.0)
	for tyre in tyres:
		tyre.rotation.y = -state.front_angle if tyre.position.z < 0 else -state.rear_angle
	pointers.front.text = "AXLE  %+.0f°" % rad_to_deg(state.front_angle)
	pointers.rear.text = "AXLE  %+.0f°" % rad_to_deg(state.rear_angle)
	needles.front.rotation.z = -state.front_angle
	needles.rear.rotation.z = -state.rear_angle
	instruments.text = "%d:%02d\n%s   PARK %s" % [int(state.remaining) / 60, int(state.remaining) % 60, "FORWARD" if state.direction == 1 else "REVERSE", "ON" if state.parking_brake else "OFF"]
	if not engine.playing:
		engine.play()
	engine.pitch_scale = 0.8 + absf(state.speed) * 0.16
	engine.volume_db = -24.0 + absf(state.speed)

func smooth_correction(previous_visual: Transform3D) -> void:
	if previous_visual.origin.distance_to(body.global_position) < 1.5:
		visuals.global_transform = previous_visual
	else:
		visuals.transform = Transform3D.IDENTITY

func highlight(control: StringName, enabled: bool) -> void:
	for key in control_meshes:
		var material: StandardMaterial3D = control_meshes[key].material_override
		material.emission_enabled = enabled and key == control
		material.emission = Color("8c7945")

## Basic procedural feedback, generated at scene construction, no TTS.
func tone(loop: bool) -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = 22050
	var count := 22050 if loop else 6615
	var bytes := PackedByteArray()
	bytes.resize(count * 2)
	for i in count:
		var t := float(i) / 22050.0
		var sample := (sin(TAU * 55 * t) * 0.5 + sin(TAU * 110 * t) * 0.25) if loop else sin(TAU * (110 * t + 70 * t * t)) * exp(-t * 18) * 0.8
		bytes.encode_s16(i * 2, int(sample * 32767))
	stream.data = bytes
	if loop:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_end = count
	return stream

func advance(delta: float) -> void:
	body.position += motion * delta
	body.rotate_y(angular_motion * delta)

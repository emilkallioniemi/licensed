class_name MonsterTruck
extends Node3D
## Retained arcade mechanics with modeled, state-driven mechanical presentation.
var body: AnimatableBody3D
var motion := Vector3.ZERO
var angular_motion := 0.0
var tyres: Array[Node3D] = []
var engine: AudioStreamPlayer3D
var impact: AudioStreamPlayer3D
var impact_cooldown := 0.0
var visuals: TruckPresentation
var sound: TruckSound
var vertical_speed := 0.0
var jolt := Vector3.ZERO
var impact_speed := 0.0

func _ready() -> void:
	body = AnimatableBody3D.new()
	body.name = "Body"
	body.sync_to_physics = false
	add_child(body)
	shell_box("Deck", Vector3(4.8, 0.3, 5.0), Vector3(0, 1.45, 0))
	for x in [-2.25, 2.25]:
		for z in [-2.3, 0.1]:
			shell_rail(Vector3(x, 1.6, z), Vector3(x, 3.55, z), 0.075)
		shell_rail(Vector3(x, 3.55, -2.3), Vector3(x, 3.55, 0.1), 0.075)
		shell_rail(Vector3(x, 3.55, 0.1), Vector3(x, 1.7, 2.3), 0.06)
		shell_box("Sill", Vector3(0.2, 0.65, 2.7), Vector3(x, 1.9, -0.95))
		for z in [-1.8, 1.8]:
			# Direct-body shapes participate in AnimatableBody collision. Steering
			# cylinders are symmetric about the rolling axle, with tread envelope.
			var tyre := CollisionShape3D.new()
			var shape := CylinderShape3D.new()
			shape.radius = 1.6
			shape.height = 1.9
			tyre.shape = shape
			body.add_child(tyre)
			tyre.position = Vector3(x / 2.25 * 2.4, 1.6, signf(z) * 2.1)
			tyre.rotation.z = PI / 2.0
			tyres.append(tyre)
	for z in [-2.3, 0.1]:
		shell_rail(Vector3(-2.25, 3.55, z), Vector3(2.25, 3.55, z), 0.075)
	for control in AttemptState.CONTROLS:
		var at: Vector3 = AttemptState.CONTROLS[control]
		var back := -1.0 if control == &"rear" else 1.0
		box("Seat", Vector3(0.68, 0.44, 0.68), at + Vector3(0, 0.22, 0))
		box("SeatBack", Vector3(0.66, 0.7, 0.17), at + Vector3(0, 0.76, back * 0.28))
		if control != &"rear":
			box("Console", Vector3(1.02, 0.44, 0.16), at + Vector3(0, 0.78, -back * 0.72))
	box("ExaminerSeat", Vector3(0.7, 0.44, 0.7), Vector3(0.864, 2.92, 1.12))
	shell_box("Bonnet", Vector3(4.1, 1.0, 0.9), Vector3(0, 2.1, -2.6))
	shell_box("RearPanel", Vector3(2.0, 0.8, 0.2), Vector3(-0.9, 2.05, 2.35))
	visuals = TruckPresentation.new()
	visuals.name = "Presentation"
	body.add_child(visuals)
	# Existing learner is temporary examiner body; full distinct rig belongs to 23.
	var examiner: Node3D = preload("res://assets/slice_0/player/learner.glb").instantiate()
	visuals.add_child(examiner)
	examiner.position = Vector3(0.864, 2.7, 1.12)
	examiner.find_child("BodyPivot", true, false).position.y = 0.59
	examiner.rotation.y = PI
	for side in ["Left", "Right"]:
		examiner.find_child(side + "Hip", true, false).rotation.x = -PI / 2.0
		examiner.find_child(side + "Knee", true, false).rotation.x = PI / 2.0
	sound = TruckSound.new()
	body.add_child(sound)
	engine = sound.engine
	impact = sound.impact

func box(title: String, size: Vector3, at: Vector3) -> CollisionShape3D:
	var part := CollisionShape3D.new()
	part.name = title
	var shape := BoxShape3D.new()
	shape.size = size
	part.shape = shape
	body.add_child(part)
	part.position = at
	return part

func stair(title: String, x: float, z0: float, z1: float, y0: float, y1: float, width: float) -> void:
	var length := Vector2(z1 - z0, y1 - y0).length()
	var shape := box(title, Vector3(width, 0.10, length), Vector3(x, (y0 + y1) / 2.0, (z0 + z1) / 2.0))
	shape.rotation.x = -atan2(y1 - y0, z1 - z0)
	shape.position.y -= 0.05 / absf(cos(shape.rotation.x))
	for side in [-1.0, 1.0]:
		var edge: float = x + side * (width / 2.0 - 0.02)
		rail(Vector3(edge, y0 + 0.85, z0), Vector3(edge, y1 + 0.85, z1), 0.035)
		for fraction in [0.0, 0.5, 1.0]:
			var foot := Vector3(edge, lerpf(y0, y1, fraction), lerpf(z0, z1, fraction))
			rail(foot, foot + Vector3.UP * 0.85, 0.025)

func rail(from: Vector3, to: Vector3, radius: float) -> void:
	var part := CollisionShape3D.new()
	part.name = "AccessRail"
	var shape := CapsuleShape3D.new()
	shape.radius = radius
	shape.height = from.distance_to(to) + radius * 2.0
	part.shape = shape
	body.add_child(part)
	part.position = (from + to) / 2.0
	part.quaternion = Quaternion(Vector3.UP, (to - from).normalized())

func drive(state: AttemptState, delta: float, present := true) -> void:
	jolt = Vector3.ZERO
	impact_speed = 0.0
	var front := tan(state.front_angle)
	var rear := tan(state.rear_angle)
	angular_motion = -state.speed * (front - rear) / 3.6
	var sideways := (front + rear) * 0.5
	motion = Basis(Vector3.UP, body.global_rotation.y) * Vector3(sideways, 0, -1).normalized() * state.speed
	# Forgiving ordinary turns; a fast tight turn throws an unsecured rider
	# outward. These arcade thresholds remain candidates for checkpoint 06.
	if absf(state.speed * angular_motion) > 8.0:
		jolt = body.global_basis.x * signf(angular_motion * state.speed) * 5.0 + Vector3.UP * 3.5
	var from := body.global_transform
	# Only environment structures use layer 4. Learners and deck contact must
	# not stop the truck. Sweep a whole-cab hull, including rotation corners.
	var query := PhysicsShapeQueryParameters3D.new()
	var hull := BoxShape3D.new()
	hull.size = Vector3(6.8, 4.8, 7.4)
	query.shape = hull
	query.transform = from.translated_local(Vector3(0, 2.4, 0))
	query.motion = motion * delta
	query.collision_mask = 4
	var fractions := get_world_3d().direct_space_state.cast_motion(query)
	var fraction := fractions[0]
	body.global_position += motion * delta * fraction
	body.rotation.y += angular_motion * delta * fraction
	query.transform = body.global_transform.translated_local(Vector3(0, 2.4, 0))
	if not get_world_3d().direct_space_state.intersect_shape(query, 1).is_empty():
		body.global_transform = from
		fraction = 0.0
	if present:
		impact_cooldown = maxf(0.0, impact_cooldown - delta)
	if fraction < 1.0:
		impact_speed = absf(state.speed)
		if impact_speed > 4.0:
			jolt = motion + Vector3.UP * 4.0
		if present and absf(state.speed) > 0.5 and impact_cooldown == 0.0:
			impact.play()
			impact_cooldown = 0.5
		state.speed = 0.0
		motion = Vector3.ZERO
		angular_motion = 0.0
	for tyre in tyres:
		tyre.rotation.y = -state.front_angle if tyre.position.z < 0 else -state.rear_angle
	_advance_suspension(delta, state)
	if not present:
		return
	visuals.position = visuals.position.move_toward(Vector3.ZERO, delta * 8.0)
	visuals.rotation.y = move_toward(visuals.rotation.y, 0.0, delta * 2.0)
	present_state(state, delta)

## Guests present the confirmed aftermath without authoring its physics.
func present_state(state: AttemptState, delta: float) -> void:
	visuals.update(state, vertical_speed, delta)
	sound.update(state, vertical_speed, delta)

func smooth_correction(previous_visual: Transform3D) -> void:
	if previous_visual.origin.distance_to(body.global_position) < 1.5:
		visuals.global_transform = previous_visual
	else:
		visuals.transform = Transform3D.IDENTITY

func _advance_suspension(delta: float, state: AttemptState) -> void:
	# Terrain is layer 8, separate from hull-blocking structures (4). Four tyre
	# probes preserve real vertical support while the arcade cab stays upright.
	var heights: Array[float] = []
	var side_heights: Dictionary = {}
	for x in [-2.4, 2.4]:
		for z in [-2.1, 2.1]:
			var at := body.to_global(Vector3(x, 0, z))
			var ray := PhysicsRayQueryParameters3D.create(at + Vector3.UP * 1.5, at - Vector3.UP * 3.0, 8)
			var hit := get_world_3d().direct_space_state.intersect_ray(ray)
			if not hit.is_empty():
				heights.append(hit.position.y)
				side_heights[x] = hit.position.y
	# Balance moves the centre of weight. Ordinary cornering stays forgiving.
	if absf(body.rotation.z) > 0.9:
		body.rotation.z = move_toward(body.rotation.z, signf(body.rotation.z) * PI / 2.0, delta)
	else:
		var bank := 0.0
		if side_heights.size() == 2:
			bank = atan2(side_heights[2.4] - side_heights[-2.4], 4.8)
		var roll_target := clampf(bank - state.speed * angular_motion * 0.06 - state.balance.x * 0.30, -1.2, 1.2)
		body.rotation.z = move_toward(body.rotation.z, roll_target, delta * 1.2)
		body.rotation.x = move_toward(body.rotation.x, clampf(vertical_speed * 0.04 + state.balance.y * 0.16, -0.28, 0.28), delta)
	var before := vertical_speed
	if heights.is_empty():
		vertical_speed -= 9.8 * delta
	else:
		var height: float = heights.max()
		vertical_speed += ((height - body.global_position.y) * 65.0 - vertical_speed * 8.0) * delta
		if before > 3.0 and vertical_speed < before:
			jolt = motion * 0.3 + Vector3.UP * 5.5
	body.global_position.y += vertical_speed * delta
	motion.y = vertical_speed

func highlight(control: StringName, enabled: bool) -> void:
	visuals.highlight(control, enabled)

func reset_presentation() -> void:
	visuals.reset()
	sound.reset()
	impact_cooldown = 0.0

func advance(delta: float) -> void:
	body.position += motion * delta
	body.rotate_y(angular_motion * delta)

func shell_point(at: Vector3) -> Vector3:
	return Vector3(at.x * 0.72, at.y + 1.1, at.z * 0.8)

func shell_box(title: String, size: Vector3, at: Vector3) -> void:
	box(title, size * Vector3(0.72, 1.0, 0.8), shell_point(at))

func shell_rail(from: Vector3, to: Vector3, radius: float) -> void:
	rail(shell_point(from), shell_point(to), radius)

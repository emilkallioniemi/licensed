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
var suspension_rotation_velocity := Vector2.ZERO
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
	shell_box("Bonnet", Vector3(4.1, 1.0, 0.9), Vector3(0, 2.1, -2.6))
	shell_box("RearPanel", Vector3(2.0, 0.8, 0.2), Vector3(-0.9, 2.05, 2.35))
	box("CompetitionRoof", Vector3(3.28, 0.24, 3.9), Vector3(0, 4.78, 0.35))
	box("CompetitionRearBody", Vector3(3.15, 1.95, 0.18), Vector3(0, 3.64, 2.22))
	for side in [-1, 1]:
		box("CompetitionQuarter", Vector3(0.18, 1.9, 1.35), Vector3(side * 1.56, 3.64, 1.58))
	visuals = TruckPresentation.new()
	visuals.name = "Presentation"
	body.add_child(visuals)
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
	var sideways := (front + rear) * 0.5
	var has_traction := _has_tyre_contact()
	if has_traction:
		var heading := Basis(Vector3.UP, body.global_rotation.y)
		var desired := heading * Vector3(sideways, 0, -1).normalized() * state.speed
		# Tyre forces change velocity over time; touching dirt cannot replace
		# takeoff momentum with the chassis's new facing after a spin.
		var horizontal := Vector3(motion.x, 0, motion.z)
		horizontal = horizontal.move_toward(desired, AttemptState.BRAKE_SPEED * delta)
		motion.x = horizontal.x
		motion.z = horizontal.z
		var rolling_speed := horizontal.dot(-heading.z)
		angular_motion = -rolling_speed * (front - rear) / 3.6
	# Forgiving ordinary turns; a fast tight turn throws an unsecured rider
	# outward. These arcade thresholds remain candidates for checkpoint 06.
	if has_traction and absf(state.speed * angular_motion) > 8.0:
		jolt = body.global_basis.x * signf(angular_motion * state.speed) * 5.0 + Vector3.UP * 3.5
	var from := body.global_transform
	# Only environment structures use layer 4. Learners and deck contact must
	# not stop the truck. Sweep a whole-cab hull, including rotation corners.
	var query := PhysicsShapeQueryParameters3D.new()
	var hull := BoxShape3D.new()
	hull.size = Vector3(6.8, 4.8, 7.4)
	query.shape = hull
	query.transform = from.translated_local(Vector3(0, 2.4, 0))
	# Suspension integrates gravity once, below; this sweep moves horizontally.
	var horizontal_motion := Vector3(motion.x, 0, motion.z)
	query.motion = horizontal_motion * delta
	query.collision_mask = 4
	var previous_overlap := _hull_overlap_depth(query)
	var fractions := get_world_3d().direct_space_state.cast_motion(query)
	var fraction := fractions[0]
	body.global_position += horizontal_motion * delta * fraction
	body.rotation.y += angular_motion * delta * fraction
	query.transform = body.global_transform.translated_local(Vector3(0, 2.4, 0))
	var overlap := _hull_overlap_depth(query)
	# Suspension or turning can put a corner slightly inside a wall. Let a
	# step reduce that penetration instead of requiring instant full clearance.
	if overlap > 0.0 and not (previous_overlap > 0.0 and overlap < previous_overlap - 0.000001):
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
	visuals.follow_ground(body)
	sound.update(state, vertical_speed, delta)

func smooth_correction(previous_visual: Transform3D) -> void:
	if previous_visual.origin.distance_to(body.global_position) < 1.5:
		visuals.global_transform = previous_visual
	else:
		visuals.transform = Transform3D.IDENTITY

func _hull_overlap_depth(query: PhysicsShapeQueryParameters3D) -> float:
	var contacts := get_world_3d().direct_space_state.collide_shape(query, 32)
	var depth := 0.0
	for index in range(0, contacts.size(), 2):
		depth = maxf(depth, contacts[index].distance_to(contacts[index + 1]))
	return depth

func _has_tyre_contact() -> bool:
	if body.global_basis.y.dot(Vector3.UP) < 0.3:
		return false
	for x in [-2.4, 2.4]:
		for z in [-2.1, 2.1]:
			var at := body.to_global(Vector3(x, 0, z))
			var ray := PhysicsRayQueryParameters3D.create(at + Vector3.UP * 1.8, at - Vector3.UP * 0.18, 8)
			var hit := get_world_3d().direct_space_state.intersect_ray(ray)
			if not hit.is_empty() and hit.position.y + 0.18 > at.y:
				return true
	return false

func _advance_suspension(delta: float, state: AttemptState) -> void:
	# Each tyre applies a push at its contact point, producing lift and torque.
	# No steering-induced lean or airborne terrain attraction.
	var supported := false
	var support_force := 0.0
	var torque := Vector2.ZERO # pitch, roll in the truck's heading frame
	var heading := Basis(Vector3.UP, body.rotation.y)
	for x in [-2.4, 2.4]:
		for z in [-2.1, 2.1]:
			if body.global_basis.y.dot(Vector3.UP) < 0.3:
				continue
			var at := body.to_global(Vector3(x, 0, z))
			var ray := PhysicsRayQueryParameters3D.create(at + Vector3.UP * 1.8, at - Vector3.UP * 3.0, 8)
			var hit := get_world_3d().direct_space_state.intersect_ray(ray)
			if hit.is_empty():
				continue
			var compression: float = hit.position.y + 0.18 - at.y
			if compression <= 0.0:
				continue
			supported = true
			var lever := heading.inverse() * (at - body.global_position)
			var wheel_speed := vertical_speed + 2.0 * suspension_rotation_velocity.y * lever.x - 8.0 * suspension_rotation_velocity.x * lever.z
			var force := maxf(0.0, compression * 110.0 - wheel_speed * 5.0) / 4.0
			support_force += force
			torque += Vector2(-lever.z, lever.x) * force
	# Wheel damping settles landing rotation; unloaded wheels keep their momentum.
	suspension_rotation_velocity += Vector2(torque.x / 30.0, torque.y / 10.0) * delta
	body.global_basis = (Basis(heading.x, suspension_rotation_velocity.x * delta) * Basis(heading.z, suspension_rotation_velocity.y * delta) * body.global_basis).orthonormalized()
	var before := vertical_speed
	if supported:
		if before < -3.0 and support_force > 9.8:
			jolt = motion * 0.3 + Vector3.UP * 5.5
	vertical_speed += (support_force - 9.8) * delta
	body.global_position.y += vertical_speed * delta
	_support_chassis(delta)
	motion.y = vertical_speed

func _support_chassis(delta: float) -> void:
	if body.global_basis.y.dot(Vector3.UP) > 0.5:
		return
	# Tyres cannot support a roof landing. Sample the modeled cab and tyre
	# envelope against terrain, resolving the lowest actual chassis contact.
	var penetration := 0.0
	for y in [1.6, 4.9]:
		var width := 3.3 if y < 2 else 1.65
		for x in [-width, width]:
			for z in [-2.1, 2.1]:
				var at := body.to_global(Vector3(x, y, z))
				var ray := PhysicsRayQueryParameters3D.create(at + Vector3.UP * 6, at - Vector3.UP * 0.1, 8)
				var hit := get_world_3d().direct_space_state.intersect_ray(ray)
				if not hit.is_empty():
					penetration = maxf(penetration, hit.position.y + 0.03 - at.y)
	if penetration > 0:
		body.global_position.y += penetration
		vertical_speed = maxf(0.0, -vertical_speed * 0.12) if vertical_speed < -1.0 else maxf(0.0, vertical_speed)
		suspension_rotation_velocity *= exp(-5.0 * delta)
		motion.x = move_toward(motion.x, 0, 6 * delta)
		motion.z = move_toward(motion.z, 0, 6 * delta)
		angular_motion *= exp(-5.0 * delta)

func highlight(control: StringName, enabled: bool) -> void:
	visuals.highlight(control, enabled)

func reset_presentation() -> void:
	motion = Vector3.ZERO
	angular_motion = 0.0
	suspension_rotation_velocity = Vector2.ZERO
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

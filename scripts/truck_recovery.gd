class_name TruckRecovery
extends RefCounted
## Integrated host accident resolution. Guests only replay ordinary locomotion;
## shared snapshots carry the host's conditions, impulses and support frames.

func simulate(learner: Learner, command: Dictionary, truck: MonsterTruck, previous: Transform3D, state: AttemptState, player_id: int, delta: float, authoritative: bool) -> void:
	if authoritative:
		_resolve(learner, truck, previous, state, player_id, delta)
	var supported := learner.support == &"truck"
	learner.simulate_truck_walk(command, truck.body, previous, state.control_of(player_id), delta)
	if not authoritative:
		return
	if supported and learner.support == &"" and learner.movement_mode == &"independent":
		state.observe_accident(player_id, state.id, &"ejected", learner.global_position, learner.velocity)
	if learner.is_on_floor() and learner.ejection_time == 0.0 and state.accident_states.get(player_id, &"") == &"ejected":
		state.observe_accident(player_id, state.id, &"landed", learner.global_position)

func _resolve(learner: Learner, truck: MonsterTruck, previous: Transform3D, state: AttemptState, player_id: int, delta: float) -> void:
	if absf(truck.body.global_basis.y.dot(Vector3.UP)) < 0.35:
		state.observe_accident(player_id, state.id, &"overturn", truck.body.global_position)
	if learner.movement_mode in [&"crushed", &"ravine"]:
		return
	if learner.global_position.y < -12.0:
		_record(learner, state, player_id, &"ravine")
		return
	if learner.support == &"truck" and truck.jolt != Vector3.ZERO:
		# Seats secure ordinary turning; a collision or large vertical jolt can
		# still remove an operator and leave rescue to the other two learners.
		if state.control_of(player_id) == &"" or truck.impact_speed > 4.0 or truck.jolt.y > 5.0:
			var carried := truck.body.global_transform * (previous.affine_inverse() * learner.global_position)
			var impulse := (carried - learner.global_position) / delta + truck.jolt
			state.observe_accident(player_id, state.id, &"ejected", learner.global_position, impulse)
			learner.apply_recovery(&"independent", impulse)
			return
	if learner.support == &"truck" or learner.ejection_time > 0.0:
		return
	# A standing capsule may be enveloped when the truck rolls over somebody.
	# Low deck clearance pins them; tyre/chassis compression is catastrophic.
	# Raycasts test actual collision geometry, not an invisible rescue volume.
	var feet := learner.global_position + Vector3.UP * 0.08
	var ray := PhysicsRayQueryParameters3D.create(feet, feet + Vector3.UP * 1.85, 1, [learner.get_rid()])
	ray.hit_from_inside = true
	var hit := learner.get_world_3d().direct_space_state.intersect_ray(ray)
	if not hit.is_empty() and hit.collider == truck.body:
		var clearance: float = hit.position.y - learner.global_position.y
		if clearance < 0.72:
			_record(learner, state, player_id, &"crushed")
		elif learner.movement_mode != &"trapped":
			_record(learner, state, player_id, &"trapped")
	elif learner.movement_mode == &"trapped":
		var query := PhysicsShapeQueryParameters3D.new()
		var capsule := CapsuleShape3D.new()
		capsule.height = 2.0
		capsule.radius = 0.3
		query.shape = capsule
		query.transform = Transform3D(Basis.IDENTITY, learner.global_position + Vector3.UP * 1.02)
		query.collision_mask = 1
		query.exclude = [learner.get_rid()]
		if learner.get_world_3d().direct_space_state.intersect_shape(query, 1).is_empty():
			state.observe_accident(player_id, state.id, &"rescued", learner.global_position)
			learner.apply_recovery(&"independent")

func _record(learner: Learner, state: AttemptState, player_id: int, kind: StringName) -> void:
	state.observe_accident(player_id, state.id, kind, learner.global_position)
	learner.apply_recovery(kind)

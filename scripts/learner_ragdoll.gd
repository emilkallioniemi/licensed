class_name LearnerRagdoll
extends Node3D
## Physical presentation attached to the confirmed learner trajectory. Limbs
## collide with scenery; they never author occupancy, death or network movement.
var bodies: Dictionary = {}
var offsets: Dictionary = {}
var bindings: Dictionary = {}
var anchor := Vector3.ZERO
var travel := Vector3.ZERO
var landed_time := 0.0
var grounded := false

func build(rig: Node3D, joints: Dictionary, velocity: Vector3) -> void:
	rig.add_child(self)
	top_level = true
	global_transform = Transform3D.IDENTITY
	bindings = joints
	var pelvis: Node3D = joints.BodyPivot
	_part("BodyPivot", pelvis.global_position + Vector3.UP * 0.25,
		pelvis.global_basis, Vector3(0.44, 0.55, 0.30), 5.0)
	var head: Node3D = joints.HeadPivot
	_part("HeadPivot", head.to_global(Vector3(0, 0.20, 0)), head.global_basis, Vector3(0.32, 0.40, 0.32), 1.0)
	_link("BodyPivot", "HeadPivot", head.global_position)
	for side in ["Left", "Right"]:
		for chain in [["Shoulder", "Elbow", "Wrist"], ["Hip", "Knee", "Ankle"]]:
			var parent := "BodyPivot"
			for segment in 2:
				var title: String = side + chain[segment]
				var from: Node3D = joints[title]
				var to: Node3D = joints[side + chain[segment + 1]]
				var along := to.global_position - from.global_position
				var basis := Basis(Quaternion(Vector3.UP, along.normalized()))
				var width := 0.27 if chain[0] == "Hip" else 0.23
				_part(title, (from.global_position + to.global_position) * 0.5, basis,
					Vector3(width, along.length(), width), 1.0)
				_link(parent, title, from.global_position)
				parent = title
			var end_title: String = side + chain[2]
			var end: Node3D = joints[end_title]
			var foot: bool = chain[0] == "Hip"
			_part(end_title, end.to_global(Vector3(0, -0.06, 0.075) if foot else Vector3(0, -0.12, 0)),
				end.global_basis, Vector3(0.28, 0.18, 0.40) if foot else Vector3(0.18, 0.24, 0.12), 0.4)
			_link(parent, end_title, end.global_position)
	for title in bodies:
		var body: RigidBody3D = bodies[title]
		var spin := Vector3(3.2, 1.1, -2.1)
		body.linear_velocity = velocity + spin.cross(body.global_position - bodies.BodyPivot.global_position)
		body.angular_velocity = spin
		for other in bodies.values():
			if other != body:
				body.add_collision_exception_with(other)
	anchor = bodies.BodyPivot.global_position
	travel = velocity

func _part(title: String, at: Vector3, basis: Basis, size: Vector3, mass: float) -> void:
	var body := RigidBody3D.new()
	body.name = title + "Physics"
	body.mass = mass
	body.collision_layer = 0
	body.collision_mask = 1
	body.angular_damp = 0.6
	body.linear_damp = 0.1
	body.continuous_cd = true
	add_child(body)
	body.global_transform = Transform3D(basis, at)
	var collision := CollisionShape3D.new()
	if title.ends_with("Wrist") or title.ends_with("Ankle"):
		var box := BoxShape3D.new()
		box.size = size
		collision.shape = box
	else:
		var capsule := CapsuleShape3D.new()
		capsule.radius = size.x * 0.5
		capsule.height = maxf(size.y, size.x)
		collision.shape = capsule
	body.add_child(collision)
	bodies[title] = body
	offsets[title] = body.global_transform.affine_inverse() * bindings[title].global_transform

func _link(parent: String, child: String, at: Vector3) -> void:
	var joint := PinJoint3D.new()
	add_child(joint)
	joint.global_position = at
	joint.node_a = joint.get_path_to(bodies[parent])
	joint.node_b = joint.get_path_to(bodies[child])

func _physics_process(delta: float) -> void:
	if bodies.is_empty():
		return
	var pelvis: RigidBody3D = bodies.BodyPivot
	# Follow host-owned flight without forcing a rotation or rigid limb pose.
	# On landing lower the torso and let its contacts tumble against the floor.
	var error := anchor - pelvis.global_position
	var desired := travel + (error * 9.0).limit_length(18.0)
	pelvis.linear_velocity = pelvis.linear_velocity.lerp(desired, 1.0 - exp(-12.0 * delta))
	if grounded:
		landed_time += delta

func present(rig: Node3D, data: Dictionary) -> void:
	grounded = data.get("grounded", false)
	travel = data.get("velocity", Vector3.ZERO)
	anchor = rig.global_position + Vector3.UP * (0.48 if grounded else 1.33)
	# Parents first: applying the child global pose then preserves joint contact.
	for title in bodies:
		bindings[title].global_transform = bodies[title].global_transform * offsets[title]

func local_pose() -> Dictionary:
	var result := {}
	for title in bodies:
		result[title] = bindings[title].transform
	return result

class_name LearnerPose
extends RefCounted
## Articulated presentation only. The CharacterBody and host recovery state own
## contact/occupancy. Ragdolls are authored loose-limb poses, never a second solver
## that can move the learner or decide whether the player is trapped.
const DIGITS := ["Index", "Middle", "Ring", "Little", "Thumb"]
var rig: Node3D
var joints: Dictionary = {}
var rest: Dictionary = {}
var angles: Dictionary = {}
var body_height := 1.08
var state: StringName = &"idle"
var previous_grounded := true
var previous_support: StringName = &""
var tumble := false
var landing := 0.0
var recovery := 0.0
var boarding := 0.0
var seat_blend := 0.0
var time := 0.0

func _init(visual: Node3D) -> void:
	rig = visual
	for title in ["BodyPivot", "Spine", "HeadPivot", "LeftBrow", "RightBrow", "LeftEye", "RightEye"]:
		_register(title)
	for side in ["Left", "Right"]:
		for title in ["Shoulder", "Elbow", "Wrist", "Hip", "Knee", "Ankle"]:
			_register(side + title)
		for digit in DIGITS:
			_register(side + digit)
			_register(side + digit + "Tip")

func _register(title: String) -> void:
	var joint := rig.find_child(title, true, false) as Node3D
	if joint != null:
		joints[title] = joint
		rest[title] = joint.transform
		angles[title] = Vector3.ZERO

func reset() -> void:
	state = &"idle"
	landing = 0.0
	recovery = 0.0
	boarding = 0.0
	seat_blend = 0.0
	body_height = 1.08
	tumble = false
	previous_grounded = true
	previous_support = &""
	for title in joints:
		joints[title].transform = rest[title]
		angles[title] = Vector3.ZERO

func update(data: Dictionary, delta: float) -> void:
	if joints.is_empty():
		return
	time += delta
	var mode: StringName = data.get("mode", &"independent")
	var grounded: bool = data.get("grounded", true)
	var seated: bool = data.get("seated", false)
	var support: StringName = data.get("support", &"")
	var speed: float = data.get("speed", 0.0)
	var phase: float = data.get("phase", time * 7.0)
	var vertical: float = data.get("vertical", 0.0)
	var pinned := mode in [&"trapped", &"crushed"]
	if data.get("ejected", false) or mode == &"ravine":
		tumble = true
	if not previous_grounded and grounded:
		landing = 0.28
		if tumble:
			recovery = 0.85
			tumble = false
	if state == &"ragdoll" and not pinned and not tumble and not seated:
		recovery = maxf(recovery, 0.85)
	if seated:
		# Confirmed control retake can end a fall before physical ground contact.
		tumble = false
		recovery = 0.0
		landing = 0.0
	if support == &"truck" and previous_support != &"truck" and not seated:
		boarding = 0.45
	landing = maxf(0.0, landing - delta)
	recovery = maxf(0.0, recovery - delta)
	boarding = maxf(0.0, boarding - delta)
	var next: StringName = &"idle"
	if pinned or tumble:
		next = &"ragdoll"
	elif recovery > 0.0:
		next = &"recover"
	elif seated:
		next = &"take" if seat_blend < 0.98 else &"seated"
	elif seat_blend > 0.02:
		next = &"leave"
	elif not grounded:
		next = &"jump" if vertical > 0.0 else &"fall"
	elif landing > 0.0:
		next = &"land"
	elif mode == &"climbing" and speed > 0.1:
		next = &"climb"
	elif boarding > 0.0:
		next = &"board"
	elif speed > 0.12:
		next = &"walk"
	state = next
	previous_grounded = grounded
	previous_support = support
	seat_blend = move_toward(seat_blend, 1.0 if seated else 0.0, delta * 3.6)
	var target := {}
	for title in joints:
		target[title] = Vector3.ZERO
	var height := lerpf(1.08, 0.59, seat_blend)
	var stride := sin(phase) * clampf(speed / 3.0, 0.0, 1.3)
	var stride_other := sin(phase + PI) * clampf(speed / 3.0, 0.0, 1.3)
	if next in [&"walk", &"climb", &"board"]:
		var climbing := next in [&"climb", &"board"]
		height += absf(cos(phase)) * 0.025
		target.Spine = Vector3(-0.12 if climbing else -0.035, 0, stride * 0.04)
		for side in ["Left", "Right"]:
			var swing := stride if side == "Left" else stride_other
			target[side + "Hip"] = Vector3(swing * (0.8 if climbing else 0.48), 0, 0)
			target[side + "Knee"] = Vector3(maxf(0, -swing) * 0.9, 0, 0)
			target[side + "Shoulder"] = Vector3(-0.8 + swing * 0.32 if climbing else -swing * 0.42, 0, 0)
			target[side + "Elbow"] = Vector3(-0.65 if climbing else -0.18, 0, 0)
	elif next in [&"jump", &"fall", &"land"]:
		var crouch := landing / 0.28 if next == &"land" else 0.0
		height -= crouch * 0.18
		for side in ["Left", "Right"]:
			target[side + "Hip"] = Vector3(-0.35 - crouch * 0.4, 0, 0)
			target[side + "Knee"] = Vector3(0.55 + crouch * 0.65, 0, 0)
			target[side + "Shoulder"] = Vector3(-0.8 if next == &"jump" else -0.3, 0, -0.45 if side == "Left" else 0.45)
			target[side + "Elbow"] = Vector3(-0.45, 0, 0)
	elif next in [&"ragdoll", &"recover"]:
		var folded := 1.0 if next == &"ragdoll" else recovery / 0.85
		height = lerpf(1.08, 0.34, folded)
		target.BodyPivot = Vector3(1.35 * folded, 0.13 * folded, 0.20 * folded)
		target.Spine = Vector3(0, 0, 0.04) * folded
		target.HeadPivot = Vector3(0.15, 0.10, 0.08) * folded
		for side in ["Left", "Right"]:
			var sign_side := -1.0 if side == "Left" else 1.0
			var loose := sin(time * 6.0 + sign_side) * 0.18 if tumble and not grounded else 0.0
			target[side + "Shoulder"] = Vector3(-2.8 + loose, 0.15 * sign_side, 0.35 * sign_side) * folded
			target[side + "Elbow"] = Vector3(-0.2 - loose, 0, 0) * folded
			target[side + "Hip"] = Vector3(0.05 + sign_side * 0.1, 0, sign_side * 0.12) * folded
			target[side + "Knee"] = Vector3(0.35 + loose, 0, 0) * folded
	# Seated legs bend at both joints, with soles on deck and pelvis on cushion.
	if seat_blend > 0.0:
		for side in ["Left", "Right"]:
			target[side + "Hip"] = target[side + "Hip"].lerp(Vector3(-PI / 2, -1.0 if side == "Left" else 1.0, 0), seat_blend)
			target[side + "Knee"] = target[side + "Knee"].lerp(Vector3(PI / 2, 0, 0), seat_blend)
			target[side + "Shoulder"] = target[side + "Shoulder"].lerp(Vector3(-0.2, 0, 0), seat_blend)
			target[side + "Elbow"] = target[side + "Elbow"].lerp(Vector3(-0.75, 0, 0), seat_blend)
	if next not in [&"ragdoll", &"recover"]:
		target.HeadPivot = Vector3(-data.get("pitch", 0.0) * 0.6, clampf(data.get("look_yaw", 0.0), -1.0, 1.0), 0)
		target.Spine += Vector3(sin(time * 2.1) * 0.012, 0, 0)
	var blend := 1.0 - exp(-18.0 * delta)
	body_height = lerpf(body_height, height, blend)
	for title in joints:
		angles[title] = angles[title].lerp(target[title], blend)
		joints[title].transform = rest[title]
		joints[title].basis = Basis.from_euler(angles[title]) * rest[title].basis
	joints.BodyPivot.position.y = body_height
	# Blinks and eyebrows retain an expressive face in close views and portraits.
	var blink := 0.15 if fmod(time + 0.3, 4.7) < 0.12 else 1.0
	joints.LeftEye.scale.y = blink
	joints.RightEye.scale.y = blink
	joints.LeftBrow.rotation.z += 0.12 if next in [&"fall", &"ragdoll"] else 0.0
	joints.RightBrow.rotation.z -= 0.12 if next in [&"fall", &"ragdoll"] else 0.0
	var contacts: Dictionary = data.get("contacts", {})
	if seated and seat_blend > 0.0:
		for side in ["Left", "Right"]:
			if contacts.has(side + "Hand"):
				var wrist: Node3D = joints[side + "Wrist"]
				var target_wrist: Vector3 = contacts[side + "Hand"] + rig.global_basis * Vector3(0, 0.065, -0.045)
				_two_bone(side + "Shoulder", side + "Elbow", side + "Wrist", wrist.global_position.lerp(target_wrist, seat_blend), rig.global_basis * Vector3(-1 if side == "Left" else 1, -0.25, -0.25))
				wrist.global_basis = rig.global_basis
				for digit in DIGITS:
					joints[side + digit].rotation.x = -1.1 * seat_blend
					joints[side + digit + "Tip"].rotation.x = -0.95 * seat_blend
			if contacts.has(side + "Foot"):
				var ankle: Node3D = joints[side + "Ankle"]
				var foot_basis := rig.global_basis * Basis(Vector3.RIGHT, -0.65)
				var target_ankle: Vector3 = contacts[side + "Foot"] - foot_basis * Vector3(0, -0.06, 0.27)
				_two_bone(side + "Hip", side + "Knee", side + "Ankle", ankle.global_position.lerp(target_ankle, seat_blend), rig.global_basis * Vector3(-1 if side == "Left" else 1, 0, 0.1))
				ankle.global_basis = foot_basis

func _two_bone(upper_name: String, lower_name: String, end_name: String, goal: Vector3, pole: Vector3) -> void:
	var upper: Node3D = joints[upper_name]
	var lower: Node3D = joints[lower_name]
	var end: Node3D = joints[end_name]
	var origin := upper.global_position
	var a: float = rest[lower_name].origin.length()
	var b: float = rest[end_name].origin.length()
	var distance := clampf(origin.distance_to(goal), 0.01, a + b - 0.001)
	var direction := (goal - origin).normalized()
	var bend := (pole - direction * pole.dot(direction)).normalized()
	var along := (a * a + distance * distance - b * b) / (2 * distance)
	var elbow := origin + direction * along + bend * sqrt(maxf(0, a * a - along * along))
	_aim(upper, elbow)
	_aim(lower, goal)

func _aim(joint: Node3D, target: Vector3) -> void:
	var local_direction := rig.global_basis.inverse() * (target - joint.global_position).normalized()
	joint.global_basis = rig.global_basis * Basis(Quaternion(Vector3.DOWN, local_direction))

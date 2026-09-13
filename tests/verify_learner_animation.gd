extends SceneTree
## Presentation scene regression: host-confirmed recovery must remain inside the
## body's physical ground/clearance, then restore a full upright learner.
var failures := 0
func _initialize() -> void:
	_run.call_deferred()
func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)
func bounds(node: Node3D) -> AABB:
	var result := AABB()
	var first := true
	for child in node.find_children("*", "MeshInstance3D", true, false):
		if not child.is_visible_in_tree():
			continue
		var box: AABB = child.global_transform * child.get_aabb()
		result = box if first else result.merge(box)
		first = false
	return result
func _run() -> void:
	var scene := load("res://scenes/learner.tscn") as PackedScene
	var learners: Array[Learner] = []
	for slot in range(1, 4):
		var learner := scene.instantiate() as Learner
		root.add_child(learner)
		learner.position.x = (slot - 2) * 3.0
		learner.apply_palette(slot)
		learner.set_truck_movement(true)
		learners.append(learner)
		learner.apply_recovery(&"trapped")
	await create_timer(0.7).timeout
	for learner in learners:
		var occupied := bounds(learner.visual)
		print("Prone rendered bounds: ", occupied)
		check(occupied.position.y > -0.08, "articulated prone limbs must not sink through the physical ground")
		check(occupied.end.y < 0.8, "collapsed learner fits recoverable under-deck clearance")
		check(learner.visual.scale.is_equal_approx(Vector3.ONE), "collapse never compresses body scale")
		learner.apply_recovery(&"independent")
	await create_timer(1.3).timeout
	for learner in learners:
		var recovered := bounds(learner.visual)
		check(recovered.end.y > 1.8 and recovered.position.y > -0.08, "physical rescue restores complete upright anatomy")
		# A complete late snapshot can arrive after the short detachment impulse
		# timer expired. The visible tumble still belongs to that airborne body.
		var late := learner.truck_snapshot()
		late.pose.origin.y = 4.0
		late.velocity = Vector3(0, -3, 0)
		late.grounded = false
		late.pose_ejected = true
		late.ejection_time = 0.0
		learner.restore_truck_snapshot(late, Transform3D.IDENTITY)
	await create_timer(0.4).timeout
	for learner in learners:
		var pelvis: Node3D = learner.visual.find_child("BodyPivot", true, false)
		check(absf(pelvis.rotation.x) > 1.0, "late complete snapshot retains articulated airborne tumble after impulse timer")
		learner.set_truck_movement(false)
		learner.position.y = 0.0
		learner.set_seated(true)
	await create_timer(0.7).timeout
	for learner in learners:
		var pelvis: Node3D = learner.visual.find_child("BodyPivot", true, false)
		var head: Node3D = learner.visual.find_child("HeadPivot", true, false)
		check(absf(pelvis.position.y - 0.59) < 0.02, "pelvis meets the retained cushion without standing compression")
		check(absf(head.to_global(Vector3(0, 0.215, 0)).y - Learner.SEATED_EYE_HEIGHT) < 0.07, "modeled seated eyes agree with the retained first-person eye")
		learner.set_local(true)
		check(learner.visual.find_child("LeftWrist", true, false).is_visible_in_tree(), "same articulated hands remain visible in first person")
		check(not learner.visual.find_child("HeadPivot", true, false).is_visible_in_tree(), "own face is excluded from first-person clipping")
		learner.free()
	print("Learner animation: %s" % ("PASS" if failures == 0 else "FAIL"))
	quit(1 if failures else 0)

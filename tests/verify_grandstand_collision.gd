extends SceneTree
var failures := 0
func _initialize() -> void:
	call_deferred("verify")
func verify() -> void:
	var track := SurvivalTrack.new()
	root.add_child(track)
	track.build(7)
	await physics_frame
	await physics_frame
	var stands := track.find_children("Grandstands*", "MeshInstance3D", true, false)
	check(not stands.is_empty(), "authored grandstands exist")
	for stand in stands:
		var arrays: Array = stand.mesh.surface_get_arrays(0)
		var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
		var tested := 0
		for triangle in range(0, indices.size(), maxi(3, (indices.size() / 24 / 3) * 3)):
			if triangle + 2 >= indices.size(): break
			var a: Vector3 = stand.to_global(vertices[indices[triangle]])
			var b: Vector3 = stand.to_global(vertices[indices[triangle + 1]])
			var c: Vector3 = stand.to_global(vertices[indices[triangle + 2]])
			var normal := (b - a).cross(c - a).normalized()
			var centre := (a + b + c) / 3
			var ray := PhysicsRayQueryParameters3D.create(centre + normal * 0.1, centre - normal * 0.1, 4)
			ray.hit_back_faces = true
			var hit := track.get_world_3d().direct_space_state.intersect_ray(ray)
			if hit.is_empty():
				ray.from = centre - normal * 0.1
				ray.to = centre + normal * 0.1
				hit = track.get_world_3d().direct_space_state.intersect_ray(ray)
			check(not hit.is_empty(), "spectator tier surface blocks the truck collision layer")
			tested += 1
		check(tested > 10, "collision covers tiers around the stadium")
	track.free()
	print("Grandstand collision failures: ", failures)
	quit(1 if failures else 0)
func check(ok: bool, label: String) -> void:
	if not ok:
		failures += 1
		printerr("FAIL: ", label)

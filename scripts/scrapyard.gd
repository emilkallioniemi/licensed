class_name Scrapyard
extends Node3D
## Static reusable art around the retained cooperation apron. No attempt state.

const KIT := "res://assets/scrapyard/"

func _ready() -> void:
	name = "Scrapyard"
	# Backdrop ground and a lower collision skirt preserve the original apron.
	var horizon := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(240, 240)
	horizon.mesh = plane
	horizon.position.y = -0.09
	var surface := ShaderMaterial.new()
	surface.shader = load(KIT + "ground.gdshader")
	horizon.material_override = surface
	add_child(horizon)
	# Roof riders can climb the fence. Exterior ground and salvage stay solid.
	for strip in [Vector3(-80, -0.14, 0), Vector3(80, -0.14, 0), Vector3(0, -0.14, -80), Vector3(0, -0.14, 80)]:
		var body := StaticBody3D.new()
		body.collision_layer = 9
		body.collision_mask = 0
		var shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = Vector3(80, 0.1, 240) if strip.x != 0 else Vector3(80, 0.1, 80)
		shape.shape = box
		body.add_child(shape)
		body.position = strip
		add_child(body)
	# Wide margins around arrival, stairs, the two gates, parking and rescue samples.
	for x in [-36.0, 36.0]:
		for z in range(-35, 18, 6):
			_prop("fence", Vector3(x, 0, z), PI / 2.0, true)
	for x in range(-33, 34, 6):
		_prop("fence", Vector3(x, 0, 18), 0, true)
		_prop("fence", Vector3(x, 0, -38), 0, true)
	for placement in [Vector3(29, 0, -29), Vector3(30, 0, -2), Vector3(-31, 0, 3), Vector3(-29, 0, -29)]:
		_prop("wreck_stack", placement, 0.12 if placement.x > 0 else -0.18, true)
	for placement in [Vector3(23, 0, 11), Vector3(-22, 0, 11), Vector3(-11, 0, -35)]:
		_prop("container", placement, 0, true)
	_prop("container", Vector3(23, 3.08, 11), 0.04, true)
	for placement in [Vector3(30, 0, -12), Vector3(-31, 0, -18), Vector3(10, 0, 12)]:
		_prop("scrap_pile", placement, 0.2, true)
	_prop("wreck", Vector3(-12, 0, 11), -0.24, true)
	# Industrial context remains solid even when players climb over the fence.
	_prop("workshop", Vector3(-17, 0, 26), PI, true)
	_prop("industrial_skyline", Vector3(17, 0, 53), 0.08, true)
	_prop("industrial_skyline", Vector3(-37, 0, -56), 0.5, true)
	# Dense salvage stock behind the perimeter gives the depot depth without
	# consuming the retained apron.
	for x in range(-31, 34, 7):
		_prop("wreck_stack", Vector3(x, 0, -43), 0.10 * (x % 3), true)
		if x > 1:
			_prop("wreck_stack", Vector3(x, 0, 24), -0.12, true)
	for z in range(-30, 19, 7):
		_prop("wreck_stack", Vector3(-41, 0, z), PI / 2.0 + 0.1, true)
		_prop("wreck_stack", Vector3(41, 0, z), PI / 2.0 - 0.1, true)
	for x in [-24.0, -9.0, 8.0, 24.0]:
		_prop("container", Vector3(x, 0, -49), 0.07, true)
	_ground_detail()

func _prop(asset: String, at: Vector3, angle: float, solid: bool) -> Node3D:
	var instance := (load(KIT + asset + ".glb") as PackedScene).instantiate() as Node3D
	add_child(instance)
	instance.position = at
	instance.rotation.y = angle
	if solid:
		for node in instance.find_children("*", "MeshInstance3D", true, false):
			var mesh_instance := node as MeshInstance3D
			mesh_instance.create_trimesh_collision()
			for body in mesh_instance.get_children():
				if body is StaticBody3D:
					body.collision_layer = 5 # World + truck contact; never tyre ground.
					body.collision_mask = 0
	return instance

func dress_exercise(area: Node3D) -> void:
	# The original box shapes remain the authoritative collision footprints.
	for node in area.get_children():
		if not node is MeshInstance3D:
			continue
		var mesh := node as MeshInstance3D
		var kind: String = mesh.get_meta("scenery_kind", "")
		if kind.begins_with("Gate") or kind.begins_with("ParkingWreck"):
			var asset := "gate_post" if kind.begins_with("Gate") else "parking_wreck"
			_prop(asset, mesh.position - Vector3(0, (mesh.mesh as BoxMesh).size.y / 2, 0), 0, false)
			mesh.hide()
		elif kind.begins_with("ApronBump"):
			var material := StandardMaterial3D.new()
			material.albedo_color = Color("777c6b")
			material.roughness = 0.94
			mesh.material_override = material
			var size := (mesh.mesh as BoxMesh).size
			for i in range(1, int(size.z / 0.5)):
				_flat_box(mesh.position + Vector3(0, size.y / 2 + 0.006, -size.z / 2 + i * 0.5), Vector3(size.x - 0.06, 0.009, 0.025), Color("4d554c"))
		elif kind == "Asphalt":
			var material := ShaderMaterial.new()
			material.shader = load(KIT + "ground.gdshader")
			mesh.material_override = material

func _ground_detail() -> void:
	# Flush surface repairs and drains cannot snag feet or change vehicle handling.
	for patch in [Vector3(-8, 0.006, 3), Vector3(8, 0.007, -6), Vector3(-19, 0.008, -24), Vector3(21, 0.009, -25)]:
		_flat_box(patch, Vector3(5.2, 0.004, 3.4), Color("373c36"))
	for x in [-27.0, 26.0]:
		_flat_box(Vector3(x, 0.012, 5), Vector3(0.65, 0.008, 5), Color("262e2c"))
		for z in range(20):
			_flat_box(Vector3(x, 0.02, 2.6 + z * 0.25), Vector3(0.6, 0.012, 0.035), Color("798074"))
	# Sparse surface aggregate, concentrated along the perimeter, batched in one draw.
	var gravel := MultiMeshInstance3D.new()
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = true
	var stone := BoxMesh.new()
	stone.size = Vector3(0.09, 0.025, 0.13)
	var material := StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	material.roughness = 1.0
	stone.material = material
	mm.mesh = stone
	mm.instance_count = 1600
	var rng := RandomNumberGenerator.new()
	rng.seed = 804
	for i in mm.instance_count:
		var x := rng.randf_range(-35, 35)
		var z := rng.randf_range(-37, 17)
		if absf(x) < 25 and z < 8 and z > -32:
			x = signf(x) * rng.randf_range(26, 35)
		mm.set_instance_transform(i, Transform3D(Basis(Vector3.UP, rng.randf() * TAU), Vector3(x, 0.013, z)))
		mm.set_instance_color(i, Color("575d51") * rng.randf_range(0.65, 1.0))
	gravel.multimesh = mm
	add_child(gravel)

func _flat_box(at: Vector3, size: Vector3, color: Color) -> void:
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 1.0
	mesh.material_override = mat
	mesh.position = at
	add_child(mesh)

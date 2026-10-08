class_name SurvivalTrack
extends Node3D
## Host-selected live stunt lanes, authored dirt collision and replicated wrecks.
const JUNCTIONS := [-30.0, -90.0, -150.0]
const BRIDGE_X := 18.0 # Retained course-coordinate contract; now stunt lanes.
const FINISH_Z := -218.0
const ART := "res://assets/stadium/"
var layout := -1
var cars: Array[Node3D] = []
var car_colliders: Array[CollisionShape3D] = []
var car_positions: Array[Vector3] = []
var _crush_mask := -1

func build(route: int) -> void:
	if layout == route:
		return
	layout = route
	for child in get_children():
		remove_child(child)
		child.queue_free()
	cars.clear()
	car_colliders.clear()
	car_positions.clear()
	_crush_mask = -1
	var environment := asset("stadium")
	decorate(environment)
	for index in 3:
		for side in [-1, 1]:
			var live_asset := "lane_jump" if index == 2 else "lane_live"
			var lane := asset(live_asset if side == safe_side(route, index) else "lane_missing")
			lane.position = Vector3(side * BRIDGE_X, 0, JUNCTIONS[index] - 30)
			decorate(lane)
			if index == 1:
				var ring := asset("ring")
				ring.position = Vector3(side * BRIDGE_X, 1.8, -120)
				decorate(ring)
				for angle in range(0, 360, 30):
					var a := deg_to_rad(angle)
					var point := Vector3(side * BRIDGE_X + cos(a) * 7.5, 8.3 + sin(a) * 7.5, -120)
					if point.y > 4.1:
						flame(point, 0.7)
		for side in [-1, 1]:
			flame(Vector3(side * 32, 0.5, JUNCTIONS[index] - 7), 3.2)
	for offset in [-1.5, 1.5]:
		for z in [-52.0, -60.0, -68.0]:
			var at := Vector3(safe_side(route, 0) * BRIDGE_X + offset, ramp_height(z + 60), z)
			var car := asset("crush_car")
			car.position = at
			cars.append(car)
			car_positions.append(at)
			var body := StaticBody3D.new()
			body.collision_layer = 9
			add_child(body)
			body.position = at
			var collision := CollisionShape3D.new()
			var shape := BoxShape3D.new()
			shape.size = Vector3(2.7, 0.9, 4.8)
			collision.shape = shape
			collision.position.y = 0.45
			body.add_child(collision)
			car_colliders.append(collision)
	for side in [-1, 1]:
		for z in [-35.0, -110.0, -190.0]:
			var light := SpotLight3D.new()
			add_child(light)
			light.position = Vector3(side * 44, 24, z)
			light.look_at(to_global(Vector3(0, 0, z - 15)))
			light.light_color = Color("c4dcff") if side < 0 else Color("ffd2a0")
			light.light_energy = 8
			light.spot_range = 110
			light.spot_angle = 57
			light.spot_attenuation = 0.6

func asset(title: String) -> Node3D:
	var model := (load(ART + title + ".glb") as PackedScene).instantiate() as Node3D
	add_child(model)
	return model

static func safe_side(route: int, index: int) -> int:
	return 1 if route & (1 << index) else -1

static func ramp_height(z: float) -> float:
	var t := clampf((z + 18) / 36, 0, 1)
	return 3.8 * pow(sin(PI * t), 2) + 0.28 * pow(sin(t * PI * 12), 2)

func decorate(node: Node) -> void:
	for child in node.get_children():
		decorate(child)
	if node is MeshInstance3D:
		var title := str(node.name)
		if title.begins_with("Crowd_"):
			var material := ShaderMaterial.new()
			material.shader = load(ART + "crowd.gdshader")
			var original := node.mesh.surface_get_material(0) as StandardMaterial3D
			if original != null:
				material.set_shader_parameter("clothing", original.albedo_color)
			node.material_override = material
		if title.begins_with("Ride_"):
			if not title.contains("PitFloor"):
				var dirt := ShaderMaterial.new()
				dirt.shader = load(ART + "dirt.gdshader")
				node.material_override = dirt
			node.create_trimesh_collision()
			set_layers(node, 9)
		elif title.begins_with("Solid_") or title.begins_with("Ring steel"):
			node.create_trimesh_collision()
			set_layers(node, 5)

func set_layers(node: Node, mask: int) -> void:
	for child in node.get_children():
		if child is StaticBody3D:
			child.collision_layer = mask

func flame(at: Vector3, height: float) -> void:
	var fire := MeshInstance3D.new()
	var cone := CylinderMesh.new()
	cone.top_radius = 0.02
	cone.bottom_radius = height * 0.2
	cone.height = height
	cone.radial_segments = 12
	fire.mesh = cone
	var material := ShaderMaterial.new()
	material.shader = load(ART + "fire.gdshader")
	fire.material_override = material
	fire.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(fire)
	fire.position = at + Vector3.UP * height / 2
	if height > 2:
		var sparks := GPUParticles3D.new()
		sparks.amount = 28
		sparks.lifetime = 0.8
		sparks.visibility_aabb = AABB(Vector3(-3, -1, -3), Vector3(6, 10, 6))
		var process := ParticleProcessMaterial.new()
		process.direction = Vector3.UP
		process.spread = 20
		process.initial_velocity_min = 5
		process.initial_velocity_max = 9
		process.gravity = Vector3(0, -3, 0)
		sparks.process_material = process
		var fleck := QuadMesh.new()
		fleck.size = Vector2(0.1, 0.18)
		var glow := StandardMaterial3D.new()
		glow.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		glow.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
		glow.albedo_color = Color("ffd480")
		glow.emission_enabled = true
		glow.emission = Color("ffb534")
		glow.emission_energy_multiplier = 4
		fleck.material = glow
		sparks.draw_pass_1 = fleck
		add_child(sparks)
		sparks.position = at

func sync_obstacles(state: AttemptState, truck_at: Vector3, authoritative: bool) -> void:
	if authoritative and state.phase == &"active":
		for index in cars.size():
			var offset := truck_at - car_positions[index]
			if absf(offset.x) < 3.5 and absf(offset.z) < 3.6 and offset.y > -0.3 and offset.y < 2.3:
				state.crushed_cars |= 1 << index
	if _crush_mask == state.crushed_cars:
		return
	_crush_mask = state.crushed_cars
	for index in cars.size():
		var crushed := (state.crushed_cars & (1 << index)) != 0
		cars[index].scale.y = 0.24 if crushed else 1.0
		car_colliders[index].scale.y = 0.24 if crushed else 1.0
		car_colliders[index].position.y = 0.108 if crushed else 0.45

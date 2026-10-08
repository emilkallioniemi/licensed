class_name SurvivalTrack
extends Node3D
## One authored course, with a host-selected intact bridge at each junction.
## Geometry is shared; the inspection report belongs to the navigator.
const JUNCTIONS := [-30.0, -90.0, -150.0]
const BRIDGE_X := 18.0
const FINISH_Z := -218.0
var layout := -1
const ART := "res://assets/survival_map/"

func build(route: int) -> void:
	if layout == route:
		return
	layout = route
	for child in get_children():
		remove_child(child)
		child.queue_free()
	var environment := (load(ART + "environment.glb") as PackedScene).instantiate()
	add_child(environment)
	add_scenery_collision(environment)
	road(Vector3(52, 0.6, 50), Vector3(0, -0.3, -17))
	for index in 3:
		var junction: float = JUNCTIONS[index]
		for side in [-1, 1]:
			var x: float = side * BRIDGE_X
			var intact: bool = side == safe_side(route, index)
			var bridge := (load(ART + ("bridge_intact.glb" if intact else "bridge_broken.glb")) as PackedScene).instantiate() as Node3D
			add_child(bridge)
			bridge.position = Vector3(x, 0, junction - 30)
			if intact:
				road(Vector3(14, 0.6, 36), Vector3(x, -0.3, junction - 30))
			else:
				road(Vector3(14, 0.6, 10), Vector3(x, -0.3, junction - 17))
				road(Vector3(14, 0.6, 10), Vector3(x, -0.3, junction - 43))
		var end := junction - 60
		road(Vector3(52, 0.6, 24 if index < 2 else 40), Vector3(0, -0.3, end if index < 2 else end - 8))
		# Side barriers make a bad turn recoverable before the next exposed span.
		for side in [-1, 1]:
			block(Vector3(0.8, 1.5, 18), Vector3(side * 25.5, 0.75, end), Color("736f64"), 5)
	for side in [-1, 1]:
		block(Vector3(0.8, 1.5, 18), Vector3(side * 25.5, 0.75, -17), Color.WHITE, 5)
	# Distant floor gives falling a visible scale, below the lethal drop threshold.
	block(Vector3(200, 1, 320), Vector3(0, -24, -100), Color("6a6357"), 9)

static func safe_side(route: int, index: int) -> int:
	return 1 if route & (1 << index) else -1

func add_scenery_collision(node: Node) -> void:
	# The accessible rock ledges and buildings are solid too. Road and bridge
	# tyre support retains simple primitives; scenery uses its authored surface.
	for child in node.get_children():
		add_scenery_collision(child)
	if node is MeshInstance3D:
		var title := str(node.name).replace("_", " ").to_lower()
		for prefix in ["road", "lane", "asphalt", "concrete road barrier", "barrier warning", "scrub", "finish chequer"]:
			if title.begins_with(prefix):
				return
		node.create_trimesh_collision()
		for child in node.get_children():
			if child is StaticBody3D:
				child.collision_layer = 13

func road(size: Vector3, at: Vector3) -> void:
	if size.x < 50:
		block(size, at, Color.WHITE, 9)
		return
	var points := PackedVector3Array()
	for y in [-size.y / 2, size.y / 2]:
		for corner in 4:
			var centre := Vector2((size.x / 2 - 4) * (1 if corner in [0, 3] else -1), (size.z / 2 - 4) * (1 if corner < 2 else -1))
			for step in 7:
				var angle := deg_to_rad(corner * 90 + step * 15)
				points.append(Vector3(centre.x + cos(angle) * 4, y, centre.y + sin(angle) * 4))
	var shape := ConvexPolygonShape3D.new()
	shape.points = points
	var body := StaticBody3D.new()
	body.collision_layer = 9
	var collision := CollisionShape3D.new()
	collision.shape = shape
	body.add_child(collision)
	add_child(body)
	body.position = at

func block(size: Vector3, at: Vector3, _color: Color, layer: int) -> void:
	# Collision primitives match the authored road deck; visible geometry is Blender art.
	if layer != 0:
		var body := StaticBody3D.new()
		body.collision_layer = layer
		var collision := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = size
		collision.shape = shape
		body.add_child(collision)
		add_child(body)
		body.position = at

class_name SurvivalTrack
extends Node3D
## One authored course, with a host-selected intact bridge at each junction.
## Geometry is shared; the inspection report belongs to the navigator.
const JUNCTIONS := [-30.0, -90.0, -150.0]
const BRIDGE_X := 18.0
const FINISH_Z := -218.0
var layout := -1

func build(route: int) -> void:
	if layout == route:
		return
	layout = route
	for child in get_children():
		remove_child(child)
		child.queue_free()
	road(Vector3(52, 0.6, 50), Vector3(0, -0.3, -17))
	for index in 3:
		var junction: float = JUNCTIONS[index]
		for side in [-1, 1]:
			var x: float = side * BRIDGE_X
			var intact: bool = side == safe_side(route, index)
			if intact:
				road(Vector3(14, 0.6, 36), Vector3(x, -0.3, junction - 30))
			else:
				road(Vector3(14, 0.6, 10), Vector3(x, -0.3, junction - 17))
				road(Vector3(14, 0.6, 10), Vector3(x, -0.3, junction - 43))
				# The broken span is a real visible gap, never a kill trigger.
				letter("MISSING SPAN", Vector3(x, -2, junction - 30), Color("e99667"))
			letter("%d · %s" % [index + 1, "LEFT" if side < 0 else "RIGHT"], Vector3(x, 2, junction - 10))
			for edge in [-7.0, 7.0]:
				var length := 36.0 if intact else 10.0
				mark(Vector3(0.18, 0.04, length), Vector3(x + edge, 0.025, junction - (30 if intact else 17)))
		var end := junction - 60
		road(Vector3(52, 0.6, 24 if index < 2 else 40), Vector3(0, -0.3, end if index < 2 else end - 8))
		# Side barriers make a bad turn recoverable before the next exposed span.
		for side in [-1, 1]:
			block(Vector3(0.8, 1.5, 18), Vector3(side * 25.5, 0.75, end), Color("736f64"), 5)
		letter("JUNCTION %d" % (index + 1), Vector3(0, 3, junction + 5))
	mark(Vector3(24, 0.04, 0.5), Vector3(0, 0.025, FINISH_Z + 4))
	letter("FINISH", Vector3(0, 3, FINISH_Z + 4), Color("a5e3ab"))
	# Distant floor gives falling a visible scale, below the lethal drop threshold.
	block(Vector3(200, 1, 320), Vector3(0, -24, -100), Color("6a6357"), 9)

static func safe_side(route: int, index: int) -> int:
	return 1 if route & (1 << index) else -1

static func report(route: int, progress: int) -> String:
	var text := "BRIDGE INSPECTION REPORT\nRead directions aloud before each junction.\n\n"
	for index in 3:
		var side := "LEFT" if safe_side(route, index) < 0 else "RIGHT"
		text += "%s %d. Take %s. Other bridge has a missing span.\n" % ["✓" if index < progress else "→", index + 1, side]
	text += "\nSlow before turning. Straighten on each bridge.\nAfter bridge 3, merge to the centre and cross FINISH.\nWalls: reverse and try again. A lethal fall loses the attempt."
	return text

func road(size: Vector3, at: Vector3) -> void:
	block(size, at, Color("454a48"), 9)

func mark(size: Vector3, at: Vector3) -> void:
	block(size, at, Color("e4bc58"), 0)

func block(size: Vector3, at: Vector3, color: Color, layer: int) -> void:
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh.mesh = box
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.9
	mesh.material_override = material
	add_child(mesh)
	mesh.position = at
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

func letter(text: String, at: Vector3, color := Color("f7e6b2")) -> void:
	var label := Label3D.new()
	label.text = text
	label.font_size = 64
	label.pixel_size = 0.012
	label.modulate = color
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(label)
	label.position = at

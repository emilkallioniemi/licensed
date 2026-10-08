class_name NavigationBook
extends Control
## A local-only 3D field manual. Page selection never follows course progress.
const TITLES := ["CAR CRUNCH", "RING RUN", "BIG AIR"]
var spread := 0
var route := 0
var turning := false
var left: Label3D
var right: Label3D
var leaf: Node3D
var leaf_ink: Label3D
var view: SubViewport
var page_tween: Tween

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var frame := SubViewportContainer.new()
	frame.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	frame.offset_left = -520
	frame.offset_right = 520
	frame.offset_top = -625
	frame.offset_bottom = -5
	frame.stretch = true
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(frame)
	view = SubViewport.new()
	view.size = Vector2i(1040, 620)
	view.transparent_bg = true
	view.own_world_3d = true
	view.render_target_update_mode = SubViewport.UPDATE_WHEN_PARENT_VISIBLE
	frame.add_child(view)
	var world := Node3D.new()
	view.add_child(world)
	world.add_child((load("res://assets/survival_map/field_book.glb") as PackedScene).instantiate())
	var camera := Camera3D.new()
	world.add_child(camera)
	camera.position = Vector3(0, 6.5, 3.5)
	camera.look_at(Vector3.ZERO)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.keep_aspect = Camera3D.KEEP_WIDTH
	camera.size = 6.7
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-65, -20, 0)
	light.light_energy = 0.85
	world.add_child(light)
	var environment := WorldEnvironment.new()
	environment.environment = Environment.new()
	environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.environment.ambient_light_color = Color.WHITE
	environment.environment.ambient_light_energy = 0.45
	environment.environment.tonemap_mode = Environment.TONE_MAPPER_ACES
	world.add_child(environment)
	left = ink(world, Vector3(-1.46, 0.075, 0))
	right = ink(world, Vector3(1.46, 0.075, 0))
	leaf = Node3D.new()
	world.add_child(leaf)
	var page := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(2.78, 0.015, 3.87)
	page.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = Color("eee1bf")
	material.roughness = 1
	page.material_override = material
	page.position = Vector3(1.43, 0, 0)
	leaf.add_child(page)
	leaf.position.y = 0.1
	leaf_ink = ink(leaf, Vector3(1.43, 0.015, 0))
	leaf.hide()
	var hint := Label.new()
	hint.text = "Q / E   TURN PAGES       TAB   LOWER BOOK"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	hint.offset_left = -300
	hint.offset_right = 300
	hint.offset_top = -37
	hint.add_theme_font_size_override("font_size", 17)
	hint.add_theme_constant_override("outline_size", 4)
	add_child(hint)
	refresh()
	hide()

func ink(parent: Node3D, at: Vector3) -> Label3D:
	var label := Label3D.new()
	label.font_size = 42
	label.pixel_size = 0.0053
	label.modulate = Color("253e40")
	label.outline_size = 0
	label.no_depth_test = false
	label.shaded = false
	label.rotation_degrees.x = -90
	label.position = at
	parent.add_child(label)
	return label

func reset_book(layout: int) -> void:
	if page_tween != null:
		page_tween.kill()
	turning = false
	if leaf != null:
		leaf.hide()
	route = layout
	spread = 0
	if is_node_ready():
		refresh()

func turn(direction: int) -> void:
	if turning or not visible:
		return
	var next := clampi(spread + direction, 0, 3)
	if next == spread:
		return
	turning = true
	leaf.show()
	leaf_ink.text = right.text if direction > 0 else left.text
	leaf.rotation.z = 0 if direction > 0 else PI
	page_tween = create_tween()
	page_tween.tween_property(leaf, "rotation:z", PI if direction > 0 else 0.0, 0.45).set_trans(Tween.TRANS_SINE)
	page_tween.tween_callback(func():
		spread = next
		leaf.hide()
		turning = false
		refresh())

func refresh() -> void:
	if left == null:
		return
	if spread == 0:
		left.text = "MONSTER ARENA\n________________\n\nCREW\nSTUNT BOOK\n\nTonight's setup\n\nCall the live lane.\nAgree your speed.\nCommit together.\n\nPIT CREW COPY"
		right.text = "RUNNING ORDER\n________________\n\n01   CAR CRUNCH .. 2\n\n02   RING RUN ...... 4\n\n03   BIG AIR ........ 6\n\n\nCrashes: reverse.\nPit falls: all lose.\n\n1"
	else:
		var index := spread - 1
		var side := "LEFT" if SurvivalTrack.safe_side(route, index) < 0 else "RIGHT"
		var landmark: String = ["The wreck stacks.\nRoll over the roofs.", "The flaming hoops.\nCentre the truck.", "The final dirt jump.\nStraighten on entry."][index]
		var advice: String = ["Use steady throttle.\nLet the tires climb.\nSteer before the cars.", "Ease off to line up.\nHold a straight line.\nPyro is show fire.", "Build speed straight.\nEase off on landing.\nThen aim for FINISH."][index]
		left.text = "%02d / %s\n________________\n\n%s\n\nCREW CALL\n\n%s\n\n%d" % [spread, TITLES[index], landmark, advice, spread * 2]
		right.text = "LIVE LANE\n________________\n\nTAKE THE\n\n%s LANE\n\nOther deck is out.\nA pit fall ends\neveryone's run.\n\n%s\n\n%d" % [side, "Regroup on the dirt.\nFind the next tower." if index < 2 else "Merge to the centre.\nCross the red banner.", spread * 2 + 1]

@tool
extends Node3D
## Standalone visual. Colors belong to each instance; no gameplay or networking.

@export var shirt_color: Color = Color("648db1"):
	set(value):
		shirt_color = value
		_refresh_colors()
@export var trousers_color: Color = Color("555f73"):
	set(value):
		trousers_color = value
		_refresh_colors()
@export var skin_color: Color = Color("d3a78c"):
	set(value):
		skin_color = value
		_refresh_colors()
@export var hair_color: Color = Color("493429"):
	set(value):
		hair_color = value
		_refresh_colors()
@export var shoes_color: Color = Color("3c4248"):
	set(value):
		shoes_color = value
		_refresh_colors()
@export var accent_color: Color = Color("facf76"):
	set(value):
		accent_color = value
		_refresh_colors()


var pose: LearnerPose

func _ready() -> void:
	_refresh_colors()
	if not Engine.is_editor_hint():
		pose = LearnerPose.new(self)


## Same world-space rig in both views. Hide only the own head/neck which contain
## the eye; arms, articulated fingers and legs retain ordinary world depth.
func set_first_person(enabled: bool) -> void:
	var head := find_child("HeadPivot", true, false) as Node3D
	if head != null:
		head.visible = not enabled
	var neck := find_child("Neck", true, false) as Node3D
	if neck != null:
		neck.visible = not enabled
	# A world-space collar surrounds the neck/eye. Suppress only own torso
	# surfaces; children at shoulder joints (the actual shared arms) stay drawn.
	var spine := find_child("Spine", true, false) as Node3D
	if spine != null:
		for child in spine.get_children():
			if child is MeshInstance3D:
				child.visible = not enabled


func animate(data: Dictionary, delta: float) -> void:
	if pose != null:
		pose.update(data, delta)


func reset_pose() -> void:
	if pose != null:
		pose.reset()


## Matching art is ready for the physical license (ticket 19); no card gameplay.
static func portrait(slot: int) -> Texture2D:
	return load("res://assets/slice_0/player/portrait_%d.png" % clampi(slot, 1, 3))



func _refresh_colors() -> void:
	if not is_node_ready():
		return
	var palette := {
		"Shirt": shirt_color, "Trousers": trousers_color, "Skin": skin_color,
		"Hair": hair_color, "Shoes": shoes_color, "Accent": accent_color,
	}
	for node in find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := node as MeshInstance3D
		for surface in range(mesh_instance.mesh.get_surface_count()):
			var source := mesh_instance.mesh.surface_get_material(surface) as StandardMaterial3D
			if source == null or not palette.has(source.resource_name):
				continue
			var material := mesh_instance.get_surface_override_material(surface) as StandardMaterial3D
			if material == null:
				material = source.duplicate() as StandardMaterial3D
				mesh_instance.set_surface_override_material(surface, material)
			material.albedo_color = palette[source.resource_name]

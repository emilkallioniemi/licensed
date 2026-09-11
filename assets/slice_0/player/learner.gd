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


func _ready() -> void:
	_refresh_colors()


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

extends Node3D


func _ready() -> void:
	var physics_engine: String = ProjectSettings.get_setting("physics/3d/physics_engine")
	print("licensed: main scene ready (Godot %s, physics: %s)" % [Engine.get_version_info()["string"], physics_engine])

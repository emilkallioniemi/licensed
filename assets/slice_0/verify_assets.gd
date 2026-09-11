extends SceneTree
## Run headless with --path <project> --script res://assets/slice_0/verify_assets.gd


func _initialize() -> void:
	call_deferred("_verify")


func _verify() -> void:
	var packed := load("res://assets/slice_0/player/learner.tscn") as PackedScene
	assert(packed != null)
	var first = packed.instantiate()
	var second = packed.instantiate()
	root.add_child(first)
	root.add_child(second)
	first.shirt_color = Color.RED
	second.shirt_color = Color.GREEN
	var count := 0
	for node in first.find_children("*", "MeshInstance3D", true, false):
		var mesh := node as MeshInstance3D
		for surface in range(mesh.mesh.get_surface_count()):
			if mesh.mesh.surface_get_material(surface).resource_name == "Shirt":
				assert(mesh.get_surface_override_material(surface).albedo_color == Color.RED)
				var other = second.get_node(first.get_path_to(mesh))
				assert(other.get_surface_override_material(surface).albedo_color == Color.GREEN)
				assert(mesh.get_surface_override_material(surface) != other.get_surface_override_material(surface))
				count += 1
	assert(count > 0, "No shirt materials were found")
	var music := load("res://assets/slice_0/music/please_take_a_number.wav") as AudioStreamWAV
	assert(music != null and music.stereo and music.mix_rate == 44100)
	assert(music.loop_mode == AudioStreamWAV.LOOP_FORWARD)
	assert(music.loop_begin == 0 and music.loop_end == 3256615)
	assert(absf(music.get_length() - 73.846145) < 0.01)
	print("PASS: scene imports, %d shirt surfaces recolor independently, stereo music loads." % count)
	quit()

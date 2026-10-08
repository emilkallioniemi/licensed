extends SceneTree
func _initialize() -> void:
	call_deferred("capture")
func capture() -> void:
	var room = load("res://dev/solo_rehearsal.tscn").instantiate()
	root.add_child(room)
	await create_timer(0.5).timeout
	room.select(&"rear")
	await create_timer(0.2).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.scratch/monster-truck-build/navigation-evidence/navigation-navigator.png")
	room.select(&"front")
	await create_timer(0.2).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.scratch/monster-truck-build/navigation-evidence/navigation-steering.png")
	var camera := Camera3D.new()
	room.test_area.add_child(camera)
	camera.global_position = room.test_area.to_global(Vector3(100, 135, -70))
	camera.look_at(room.test_area.to_global(Vector3(0, 0, -115)))
	camera.current = true
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.scratch/monster-truck-build/navigation-evidence/navigation-overview.png")
	room.free()
	quit()

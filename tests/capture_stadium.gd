extends SceneTree
func _initialize() -> void:
	call_deferred("capture")
func shot(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.scratch/monster-truck-build/stadium-evidence/" + name + ".png")
func capture() -> void:
	var room = load("res://dev/solo_rehearsal.tscn").instantiate()
	root.add_child(room)
	await create_timer(1.0).timeout
	room.dev_status.hide()
	await shot("driving")
	room.select(&"rear")
	await create_timer(0.2).timeout
	await shot("book-contents")
	room.test_area.field_book.turn(1)
	await create_timer(0.2).timeout
	await shot("book-turn")
	await create_timer(0.45).timeout
	await shot("book-entry")
	room.select(&"front")
	var camera := Camera3D.new()
	room.test_area.add_child(camera)
	camera.position = Vector3(105, 108, 14)
	camera.look_at(room.test_area.to_global(Vector3(0, 0, -105)))
	camera.current = true
	await shot("overview")
	camera.position = Vector3(-5, 12, -79)
	camera.look_at(room.test_area.to_global(Vector3(15, 3, -123)))
	await shot("ring-run")
	camera.position = Vector3(9, 6, -18)
	camera.look_at(room.test_area.to_global(Vector3(0, 2.5, -9)))
	await shot("truck-front")
	room.free()
	quit()

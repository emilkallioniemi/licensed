extends SceneTree
## Supporting-art inspection under the production stadium environment.
func _initialize() -> void:
	call_deferred("capture")

func shot(title: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.scratch/monster-truck-build/stadium-evidence/" + title + ".png")
	print(title, " draw calls: ", RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME))

func capture() -> void:
	var room = load("res://dev/solo_rehearsal.tscn").instantiate()
	root.add_child(room)
	await create_timer(1.0).timeout
	room.dev_status.hide()
	var camera := Camera3D.new()
	room.test_area.add_child(camera)
	camera.current = true
	camera.fov = 55
	camera.position = Vector3(-49, 6.4, -95)
	camera.look_at(room.test_area.to_global(Vector3(-56, 6.0, -91.3)))
	await shot("spectator-detail")
	var track := room.test_area.get_node("SurvivalTrack") as SurvivalTrack
	if track == null:
		printerr("Missing production track")
		quit(1)
		return
	var at := track.car_positions[0]
	camera.position = at + Vector3(5, 3.0, -5)
	camera.look_at(track.to_global(at + Vector3(0, 0.7, 0)))
	await shot("wreck-detail")
	room.room_state().attempt.crushed_cars = 63
	track.sync_obstacles(room.room_state().attempt, Vector3.ZERO, false)
	await shot("wreck-folded-detail")
	# The other production salvage silhouettes, at their actual course placements.
	room.room_state().attempt.crushed_cars = 0
	track.sync_obstacles(room.room_state().attempt, Vector3.ZERO, false)
	for index in [1, 2]:
		at = track.car_positions[index]
		camera.position = at + Vector3(5, 3, -5)
		camera.look_at(track.to_global(at + Vector3(0, 0.7, 0)))
		await shot("wreck-variant-" + str(index))
	room.free()
	quit()

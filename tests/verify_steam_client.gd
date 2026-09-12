extends SceneTree
## Run headless with --path <project> --script res://tests/verify_steam_client.gd
## Checks the one part of SteamClient that needs no Steam: turning the RGBA buffer that
## `avatar_loaded` delivers into a texture the reception desk can draw.

const SteamClientScript := preload("res://scripts/steam_client.gd")


func _initialize() -> void:
	call_deferred("_verify")


func _verify() -> void:
	# A 2 x 2 avatar, row by row: red, green / blue, white.
	var rgba := PackedByteArray([
		255, 0, 0, 255,   0, 255, 0, 255,
		0, 0, 255, 255,   255, 255, 255, 255,
	])
	var texture: ImageTexture = SteamClientScript.avatar_texture_from(2, rgba)
	assert(texture != null)
	assert(texture.get_size() == Vector2(2, 2))
	var image := texture.get_image()
	assert(image.get_pixel(0, 0) == Color(1, 0, 0, 1))
	assert(image.get_pixel(1, 0) == Color(0, 1, 0, 1))
	assert(image.get_pixel(0, 1) == Color(0, 0, 1, 1))
	assert(image.get_pixel(1, 1) == Color(1, 1, 1, 1))
	print("PASS: a %d x %d RGBA avatar buffer becomes a texture with its pixels in place." % [image.get_width(), image.get_height()])
	quit()

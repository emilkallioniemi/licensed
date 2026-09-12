extends Node3D
## The game's main scene. There is no menu in front of it: Steam running puts the player
## straight in the room; Steam not running shows the one-line state instead and opens no room.

const STEAM_NOT_RUNNING_SCENE := preload("res://scenes/steam_not_running.tscn")

@onready var music: AudioStreamPlayer = $Music


func _ready() -> void:
	if not SteamClient.is_running():
		# Deferred: at boot the root is still adding this scene, so a direct change_scene fails
		# to remove it and prints an error. The swap still lands before the first frame draws.
		get_tree().change_scene_to_packed.call_deferred(STEAM_NOT_RUNNING_SCENE)
		return
	music.play()

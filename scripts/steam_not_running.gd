extends Control
## The Steam-not-running state: a black window, one line of signage, Valve's message beneath
## it, and a way out. Escape quits here; the window close quits through the tree's default.

@onready var message: Label = %Message


func _ready() -> void:
	message.text = SteamClient.init_message


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

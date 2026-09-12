class_name FadeOverlay
extends CanvasLayer
## Full-screen black fade. A joining instance stays black until it is standing in the
## host's doorway; ticket 09 Join/Leave and ticket 11's launch reuse the same overlay.
## Fades happen here, never in the music asset (spec section 1).

const DURATION := 0.8

@onready var black: ColorRect = $Black


func _ready() -> void:
	black.mouse_filter = Control.MOUSE_FILTER_IGNORE
	black.color = Color(0.0, 0.0, 0.0, 1.0)


## Cover the room. Ticket 09 calls this when Join or Accept is pressed.
func to_black(duration: float = DURATION) -> void:
	_tween_alpha(1.0, duration)


## Reveal the room. The joiner's first visible frame is standing on the Entrance marker.
func to_clear(duration: float = DURATION) -> void:
	_tween_alpha(0.0, duration)


func _tween_alpha(target: float, duration: float) -> void:
	if black == null:
		return
	var tween := create_tween()
	tween.tween_property(black, "color:a", target, duration)

class_name ArrivalTheatre
extends Node3D
## The entrance door's arrival and departure: one positional placeholder sound, a leaf
## pivot Astra can drop a mesh onto, and the open-appear-close timing. Until the leaf
## lands, the sound alone carries it (spec Further Notes, kit request 1).
##
## Parent a closed door leaf to `Leaf` (hinge at the −X jamb, mesh extending +X). The
## swing is already here; the sound carries the beat until that mesh exists.

signal finished

## Seconds to swing the leaf from shut to open (and back).
const SWING := 0.4
## Seconds the leaf stays open after the learner appears or vanishes.
const OPEN_FOR := 2.0
## Inward swing, hinge on the −X jamb. A mesh parented to `Leaf` inherits it.
const OPEN_ANGLE := deg_to_rad(90.0)

@onready var leaf: Node3D = $Leaf
@onready var sound: AudioStreamPlayer3D = $Sound

var _busy := false


## Sound plus swing open. Caller shows or hides the learner, then `close_door`.
func open_door() -> void:
	await _gate()
	_busy = true
	_play_sound()
	await _swing(OPEN_ANGLE)


## Hold a couple of seconds, swing shut. Pairs with `open_door`.
func close_door() -> void:
	await get_tree().create_timer(OPEN_FOR).timeout
	await _swing(0.0)
	_busy = false
	finished.emit()


## A mid-room drop is not a walk out: no leaf, the body has already vanished. The sound
## is how the room tells everyone they lost someone, without a toast or an examiner.
func play_drop() -> void:
	_play_sound()


func _gate() -> void:
	while _busy:
		await finished


func _play_sound() -> void:
	if sound.stream == null:
		return
	if sound.playing:
		sound.stop()
	sound.play()


func _swing(angle: float) -> void:
	var tween := create_tween()
	tween.tween_property(leaf, "rotation:y", angle, SWING).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished

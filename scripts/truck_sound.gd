class_name TruckSound
extends Node3D
## State-driven original vehicle layers. Voice stays on its existing voice bus;
## conservative layer gains and distance attenuation leave room for speech.
var engine: AudioStreamPlayer3D
var impact: AudioStreamPlayer3D
var load_layer: AudioStreamPlayer3D
var scrub: AudioStreamPlayer3D
var cabin: AudioStreamPlayer3D
var suspension: AudioStreamPlayer3D
var suspension_cooldown := 0.0
var previous_vertical := 0.0

func _ready() -> void:
	engine = layer("engine_idle", true, Vector3(0, 1.4, -2))
	load_layer = layer("engine_load", true, Vector3(0, 1.4, -2))
	scrub = layer("tyre_scrub", true, Vector3(0, 0.8, 0))
	cabin = layer("cabin_rattle", true, Vector3(0, 2.4, 0))
	suspension = layer("suspension", false, Vector3(0, 1.1, 0))
	impact = layer("impact", false, Vector3(0, 1.5, -2.5))
	impact.volume_db = -15.0
	suspension.volume_db = -24.0

func layer(title: String, loop: bool, at: Vector3) -> AudioStreamPlayer3D:
	var player := AudioStreamPlayer3D.new()
	player.name = title
	var stream: AudioStreamWAV = load("res://assets/monster_truck/audio/" + title + ".wav").duplicate()
	if loop:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_end = stream.data.size() / 2
	player.stream = stream
	player.volume_db = -40.0
	player.unit_size = 5.0
	player.max_distance = 35.0
	add_child(player)
	player.position = at
	return player

func update(state: AttemptState, vertical: float, delta: float) -> void:
	var speed := absf(state.speed)
	var pedal_input: Dictionary = state.effective_driving_input(&"pedals")
	var loaded: bool = pedal_input.get("throttle", false)
	for player in [engine, load_layer, scrub, cabin]:
		if not player.playing:
			player.play()
	engine.pitch_scale = 0.85 + minf(speed, 9.0) * 0.035
	engine.volume_db = -24.0
	load_layer.pitch_scale = 0.9 + minf(speed, 9.0) * 0.075
	load_layer.volume_db = -25.0 if loaded else -38.0
	var scrub_amount := clampf(speed * absf(state.front_angle - state.rear_angle) / 6.0, 0.0, 1.0)
	scrub.volume_db = lerpf(-60.0, -26.0, scrub_amount)
	cabin.volume_db = lerpf(-60.0, -29.0, clampf(speed / 7.0 + absf(vertical) * 0.15, 0.0, 1.0))
	suspension_cooldown = maxf(0.0, suspension_cooldown - delta)
	if absf(vertical - previous_vertical) > 0.35 and suspension_cooldown == 0.0:
		suspension.play()
		suspension_cooldown = 0.35
	previous_vertical = vertical

func reset() -> void:
	for player in [engine, load_layer, scrub, cabin, suspension, impact]:
		player.stop()
	previous_vertical = 0.0
	suspension_cooldown = 0.0

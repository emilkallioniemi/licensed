class_name Voice
extends Node
## In-game voice: Steam capture, an unreliable RPC, and one positional player on each
## remote learner (spec section 10). Ring-fenced; RoomState does not know about it.
## Mic mode and mute live in `user://voice.cfg` and on the Escape overlay.

## Compressed capture buffer. Valve recommends 8 KiB; GodotSteam defaults to 1 KiB.
const VOICE_BUFFER := 8192
## Playback and decompress rate. The generator does not resample.
const SAMPLE_RATE := 48000
## `AudioStreamGenerator.buffer_length`. The engine default of 0.5 s is half a second late.
const BUFFER_LENGTH := 0.1
## Hold V to talk when the overlay is on push-to-talk.
const TALK_KEY := KEY_V
## Seconds after the last received packet before the name-tag mark goes out.
const SPEAKING_HOLD := 0.35
## Give up waiting for `VOICE_RESULT_NOT_RECORDING` after stop, so Steam's speaking bit cannot stick.
const DRAIN_LIMIT := 1.0
## Inverse-distance unit: beside someone is full, the far corner of the 12 × 10 m room
## is about 10 dB down, and `max_distance` stays 0 so nobody is gated out.
const UNIT_SIZE := 5.0
const SETTINGS_PATH := "user://voice.cfg"
const SETTINGS_SECTION := "voice"

var _open_mic := true
var _mute := false
var _recording := false
var _draining := false
var _drain_left := 0.0
## peer_id → `AudioStreamGeneratorPlayback` on that remote learner.
var _playback_of: Dictionary = {}
## peer_id → seconds since a voice packet arrived.
var _heard_for: Dictionary = {}


func _ready() -> void:
	_load_settings()
	set_process(true)


func is_open_mic() -> bool:
	return _open_mic


func is_muted() -> bool:
	return _mute


func set_open_mic(enabled: bool) -> void:
	if _open_mic == enabled:
		return
	_open_mic = enabled
	_save_settings()


func set_muted(muted: bool) -> void:
	if _mute == muted:
		return
	_mute = muted
	_save_settings()


func _process(delta: float) -> void:
	if not SteamClient.is_running():
		return
	_ensure_players()
	_age_speaking(delta)
	_capture(delta)


func _capture(delta: float) -> void:
	var want := _wants_to_record()
	if want:
		if not _recording:
			_start_recording()
		_draining = false
	elif _recording:
		_stop_recording()
	if not (_recording or _draining):
		return
	var result := _poll_voice()
	if _draining:
		_drain_left -= delta
		if result == Steam.VOICE_RESULT_NOT_RECORDING or _drain_left <= 0.0:
			_finish_drain()


func _wants_to_record() -> bool:
	if _mute:
		return false
	if _open_mic:
		return true
	return Input.is_physical_key_pressed(TALK_KEY)


func _start_recording() -> void:
	_recording = true
	_draining = false
	Steam.setInGameVoiceSpeaking(SteamClient.steam_id, true)
	Steam.startVoiceRecording()
	print("Voice: recording")


func _stop_recording() -> void:
	_recording = false
	_draining = true
	_drain_left = DRAIN_LIMIT
	Steam.stopVoiceRecording()
	print("Voice: stopped recording")


func _finish_drain() -> void:
	_draining = false
	_drain_left = 0.0
	if not _recording:
		Steam.setInGameVoiceSpeaking(SteamClient.steam_id, false)


func _poll_voice() -> int:
	var available: Dictionary = Steam.getAvailableVoice()
	var result: int = int(available.get("result", Steam.VOICE_RESULT_NOT_RECORDING))
	if result == Steam.VOICE_RESULT_NOT_RECORDING:
		return result
	if result != Steam.VOICE_RESULT_OK or int(available.get("size", 0)) <= 0:
		return result
	var voice: Dictionary = Steam.getVoice(VOICE_BUFFER)
	result = int(voice.get("result", result))
	if result == Steam.VOICE_RESULT_OK and int(voice.get("size", 0)) > 0:
		_send(voice["buffer"])
	return result


func _send(buffer: PackedByteArray) -> void:
	var peer := multiplayer.multiplayer_peer
	if peer == null or peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		return
	_receive_voice.rpc(buffer)


@rpc("any_peer", "call_remote", "unreliable", 1)
func _receive_voice(bytes: PackedByteArray) -> void:
	var from := multiplayer.get_remote_sender_id()
	var playback := _playback_of.get(from) as AudioStreamGeneratorPlayback
	if playback == null:
		_ensure_players()
		playback = _playback_of.get(from) as AudioStreamGeneratorPlayback
	if playback == null:
		return
	var decoded: Dictionary = Steam.decompressVoice(bytes, SAMPLE_RATE)
	if int(decoded.get("result", Steam.VOICE_RESULT_NO_DATA)) != Steam.VOICE_RESULT_OK:
		return
	var byte_count := int(decoded.get("size", 0))
	if byte_count <= 0:
		return
	var raw: PackedByteArray = decoded["uncompressed"]
	var frames := PackedVector2Array()
	frames.resize(byte_count / 2)
	for i in range(0, byte_count, 2):
		var sample := float(raw.decode_s16(i)) / 32768.0
		frames[i / 2] = Vector2(sample, sample)
	var room := playback.get_frames_available()
	if room <= 0:
		return
	if frames.size() > room:
		playback.push_buffer(frames.slice(0, room))
	else:
		playback.push_buffer(frames)
	if not _heard_for.has(from):
		print("Voice: hearing peer %d" % from)
	_heard_for[from] = SPEAKING_HOLD
	_set_speaking(from, true)


func _ensure_players() -> void:
	var seen: Dictionary = {}
	for learner in _learners():
		var peer_id := learner.get_multiplayer_authority()
		seen[peer_id] = true
		if learner.is_local():
			_drop_player(learner, peer_id)
			continue
		_attach_player(learner, peer_id)
	var stale: Array = []
	for peer_id in _playback_of.keys():
		if not seen.has(peer_id):
			stale.append(peer_id)
	for peer_id in stale:
		_playback_of.erase(peer_id)
		_heard_for.erase(peer_id)


func _attach_player(learner: Learner, peer_id: int) -> void:
	var player := learner.get_node_or_null("VoicePlayer") as AudioStreamPlayer3D
	if player == null:
		player = AudioStreamPlayer3D.new()
		player.name = "VoicePlayer"
		player.position = Vector3(0.0, 1.6, 0.0)
		player.unit_size = UNIT_SIZE
		player.max_distance = 0.0
		player.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE
		player.attenuation_filter_cutoff_hz = 20500.0
		var generator := AudioStreamGenerator.new()
		generator.mix_rate_mode = AudioStreamGenerator.MIX_RATE_CUSTOM
		generator.mix_rate = float(SAMPLE_RATE)
		generator.buffer_length = BUFFER_LENGTH
		player.stream = generator
		learner.add_child(player)
		player.play()
	if not player.playing:
		player.play()
	var playback := player.get_stream_playback() as AudioStreamGeneratorPlayback
	if playback != null:
		_playback_of[peer_id] = playback


func _drop_player(learner: Learner, peer_id: int) -> void:
	var player := learner.get_node_or_null("VoicePlayer")
	if player != null:
		player.queue_free()
	_playback_of.erase(peer_id)
	_heard_for.erase(peer_id)


func _age_speaking(delta: float) -> void:
	var expired: Array[int] = []
	for peer_id in _heard_for.keys():
		var left: float = float(_heard_for[peer_id]) - delta
		if left <= 0.0:
			expired.append(int(peer_id))
		else:
			_heard_for[peer_id] = left
	for peer_id in expired:
		_heard_for.erase(peer_id)
		_set_speaking(peer_id, false)


func _set_speaking(peer_id: int, speaking: bool) -> void:
	for learner in _learners():
		if learner.get_multiplayer_authority() == peer_id:
			learner.set_speaking(speaking)
			return


func _learners() -> Array[Learner]:
	var found: Array[Learner] = []
	var spawner := get_parent().get_node_or_null("LearnerSpawner") as MultiplayerSpawner
	if spawner == null:
		return found
	for child in spawner.get_children():
		if child is Learner:
			found.append(child)
	return found


func _load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		return
	_open_mic = bool(config.get_value(SETTINGS_SECTION, "open_mic", true))
	_mute = bool(config.get_value(SETTINGS_SECTION, "mute", false))


func _save_settings() -> void:
	var config := ConfigFile.new()
	config.load(SETTINGS_PATH)
	config.set_value(SETTINGS_SECTION, "open_mic", _open_mic)
	config.set_value(SETTINGS_SECTION, "mute", _mute)
	config.save(SETTINGS_PATH)

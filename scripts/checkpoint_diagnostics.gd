extends Node
## Opt-in checkpoint recorder. No gameplay authority, HUD, or transport substitution.
## Probe timeouts are round-trip application loss, never Steam packet-loss statistics.
var capture: FileAccess
var boarding: TruckBoarding
var frames: Array[float] = []
var elapsed := 0.0
var probes: Dictionary = {}
var sent_commands: Dictionary = {}
var probe_sequence := 0
var last_rtt := -1.0
var attempt := ""
var previous_frame_us := 0

func _ready() -> void:
	boarding = get_parent()
	var path := "user://checkpoint-%s-%s-%s.jsonl" % [Time.get_unix_time_from_system(), OS.get_process_id(), multiplayer.get_unique_id()]
	capture = FileAccess.open(path, FileAccess.WRITE)
	if capture == null:
		push_error("Checkpoint capture unavailable: %s" % FileAccess.get_open_error())
		set_process(false)
		return
	print("CHECKPOINT_CAPTURE: ", ProjectSettings.globalize_path(path))
	record("metadata", {"engine": Engine.get_version_info().string, "transport": str(get_node("/root/Transport").kind), "probe_timeout_ms": 3000, "probe_interval_ms": 500, "frame_cap": Engine.max_fps})

func record(kind: String, values: Dictionary) -> void:
	if capture == null:
		return
	var row := values.duplicate()
	row["event"] = kind
	row["time_us"] = Time.get_ticks_usec()
	row["peer"] = multiplayer.get_unique_id()
	row["attempt"] = attempt
	capture.store_line(JSON.stringify(row))

func command_sent(seq: int) -> void:
	sent_commands[seq] = Time.get_ticks_usec()
	if sent_commands.size() > 240:
		sent_commands.erase(sent_commands.keys()[0])

func reconciled(ack: int, distance: float) -> void:
	var age: Variant = null
	if sent_commands.has(ack):
		age = (Time.get_ticks_usec() - sent_commands[ack]) / 1000.0
	for seq in sent_commands.keys():
		if seq <= ack:
			sent_commands.erase(seq)
	record("reconciliation", {"ack_age_ms": age, "learner_distance_m": distance, "large_correction": distance > 1.5})

func _process(delta: float) -> void:
	var frame_us := Time.get_ticks_usec()
	if previous_frame_us > 0:
		frames.append((frame_us - previous_frame_us) / 1000.0)
	previous_frame_us = frame_us
	elapsed += delta
	if elapsed < 0.5:
		return
	elapsed = 0.0
	if boarding.room != null:
		var current: String = boarding.room.room_state().attempt.id
		if current != attempt:
			attempt = current
			sent_commands.clear()
		record("frames", {"intervals_ms": frames, "phase": str(boarding.room.room_state().attempt.phase), "active": boarding.active})
	frames.clear()
	var now := Time.get_ticks_usec()
	for seq in probes.keys():
		if now - probes[seq] >= 3000000:
			record("probe_timeout", {"sequence": seq})
			probes.erase(seq)
	if multiplayer.has_multiplayer_peer() and not multiplayer.is_server() and multiplayer.get_peers().has(1):
		probe_sequence += 1
		probes[probe_sequence] = now
		record("probe_sent", {"sequence": probe_sequence})
		_probe.rpc_id(1, probe_sequence)
	capture.flush()

@rpc("any_peer", "call_remote", "unreliable", 2)
func _probe(seq: int) -> void:
	if multiplayer.is_server():
		_reply.rpc_id(multiplayer.get_remote_sender_id(), seq)

@rpc("authority", "call_remote", "unreliable", 2)
func _reply(seq: int) -> void:
	if not probes.has(seq):
		return
	var rtt: float = (Time.get_ticks_usec() - probes[seq]) / 1000.0
	probes.erase(seq)
	var jitter: Variant = absf(rtt - last_rtt) if last_rtt >= 0.0 else null
	last_rtt = rtt
	record("probe_reply", {"sequence": seq, "rtt_ms": rtt, "successive_rtt_delta_ms": jitter})

func _exit_tree() -> void:
	if capture != null:
		record("end", {"unresolved_probes": probes.size()})
		capture.close()

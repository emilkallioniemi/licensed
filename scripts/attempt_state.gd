class_name AttemptState
extends RefCounted
## Host-owned attempt boundary. Booking remains in RoomState; this record survives
## changes to presentation and will own controls, scoring and choices in later tickets.

const DURATION := 360.0
const LOAD_TIMEOUT := 30.0

var id := ""
var phase: StringName = &"waiting"
var vehicle: StringName = &""
var remaining := DURATION
var _participants: Array[int] = []
var _ready: Array[int] = []
var _loading_elapsed := 0.0


func begin(booked_vehicle: StringName, participants: Array[int]) -> void:
	id = Crypto.new().generate_random_bytes(16).hex_encode()
	vehicle = booked_vehicle
	_participants = participants.duplicate()
	_ready.clear()
	remaining = DURATION
	_loading_elapsed = 0.0
	phase = &"loading"


func scene_ready(player_id: int, attempt_id: String) -> bool:
	if phase != &"loading" or id != attempt_id or not _participants.has(player_id) or _ready.has(player_id):
		return false
	_ready.append(player_id)
	if _ready.size() == _participants.size():
		phase = &"active"
	return true


func tick(delta: float) -> void:
	if phase == &"loading":
		_loading_elapsed += maxf(0.0, delta)
		if _loading_elapsed >= LOAD_TIMEOUT:
			depart()
	elif phase == &"active":
		remaining = maxf(0.0, remaining - maxf(0.0, delta))
		# Ticket 05 adds immutable scoring and the timeout assessment.
		if remaining == 0.0:
			phase = &"settled"


func depart() -> void:
	if phase != &"waiting":
		phase = &"departing"


func snapshot() -> Dictionary:
	return {"id": id, "phase": phase, "vehicle": vehicle, "remaining": remaining,
		"participants": _participants.duplicate(), "ready": _ready.duplicate(),
		"loading_elapsed": _loading_elapsed}


func restore(data: Dictionary) -> void:
	id = data["id"]
	phase = data["phase"]
	vehicle = data["vehicle"]
	remaining = data["remaining"]
	_participants.assign(data["participants"])
	_ready.assign(data["ready"])
	_loading_elapsed = data["loading_elapsed"]

class_name AttemptState
extends RefCounted
## Host-owned attempt boundary. Booking remains in RoomState; this record survives
## changes to presentation and will own controls, scoring and choices in later tickets.

const DURATION := 360.0
const LOAD_TIMEOUT := 30.0
const CONTROLS := {&"front": Vector3(-1.2, 1.6, -1.3), &"pedals": Vector3(1.2, 1.6, -1.3), &"rear": Vector3(-1.2, 1.6, 1.3)}
const CONTROL_REACH := 1.15
var operators: Dictionary = {}
var generations: Dictionary = {}
var _learner_positions: Dictionary = {}
var _interaction_sequences: Dictionary = {}

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
	operators.clear()
	generations.clear()
	_learner_positions.clear()
	_interaction_sequences.clear()
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
		"loading_elapsed": _loading_elapsed, "operators": operators.duplicate(), "generations": generations.duplicate()}


func restore(data: Dictionary) -> void:
	id = data["id"]
	phase = data["phase"]
	vehicle = data["vehicle"]
	remaining = data["remaining"]
	_participants.assign(data["participants"])
	_ready.assign(data["ready"])
	_loading_elapsed = data["loading_elapsed"]
	operators = data.get("operators", {}).duplicate()
	generations = data.get("generations", {}).duplicate()


## Only the authoritative physical world supplies positions, in truck space.
func observe_learner(player_id: int, truck_position: Vector3) -> void:
	if _participants.has(player_id):
		_learner_positions[player_id] = truck_position


func control_of(player_id: int) -> StringName:
	for control in operators:
		if operators[control] == player_id:
			return control
	return &""


func request_control(player_id: int, attempt_id: String, sequence: int, control: StringName) -> bool:
	if not _accept_interaction(player_id, attempt_id, sequence):
		return false
	if not CONTROLS.has(control) or operators.has(control) or control_of(player_id) != &"":
		return false
	if not _learner_positions.has(player_id) or _learner_positions[player_id].distance_to(CONTROLS[control]) > CONTROL_REACH:
		return false
	operators[control] = player_id
	generations[player_id] = generations.get(player_id, 0) + 1
	return true


func release_control(player_id: int, attempt_id: String, sequence: int) -> bool:
	if not _accept_interaction(player_id, attempt_id, sequence):
		return false
	var control := control_of(player_id)
	if control == &"":
		return false
	operators.erase(control)
	generations[player_id] = generations.get(player_id, 0) + 1
	return true


func _accept_interaction(player_id: int, attempt_id: String, sequence: int) -> bool:
	if id != attempt_id or phase != &"active" or not _participants.has(player_id):
		return false
	if sequence <= _interaction_sequences.get(player_id, 0):
		return false
	_interaction_sequences[player_id] = sequence
	return true

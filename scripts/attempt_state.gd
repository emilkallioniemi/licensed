class_name AttemptState
extends RefCounted
## Host-owned attempt boundary. Booking remains in RoomState; this record survives
## changes to presentation and will own controls, scoring and choices in later tickets.

const DURATION := 360.0
const LOAD_TIMEOUT := 30.0
const AFTERMATH_DURATION := 6.0
const SERIOUS_ACCIDENTS := [&"crushed", &"ravine", &"overturn"]
var _result: Dictionary = {}
var _aftermath_elapsed := 0.0
var _serious_reason: StringName = &""
var choices: Dictionary = {}
var _choice_sequences: Dictionary = {}
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
const INPUT_FRESHNESS := 0.35
const AXLE_LIMIT := 0.6
var front_angle := 0.0
var rear_angle := 0.0
var speed := 0.0
var direction := 1
var parking_brake := true
var driving_inputs: Dictionary = {}
var driving_sequences: Dictionary = {}
var driving_ages: Dictionary = {}
var toggle_sequences: Dictionary = {}
## Physical observations only; ticket 05 consumes these at its scoring boundary.
## Stable event numbers plus current conditions survive missed snapshots.
var accidents: Array = []
var accident_states: Dictionary = {}
var accident_sequence := 0


func begin(booked_vehicle: StringName, participants: Array[int]) -> void:
	id = Crypto.new().generate_random_bytes(16).hex_encode()
	vehicle = booked_vehicle
	_participants = participants.duplicate()
	_ready.clear()
	operators.clear()
	generations.clear()
	_learner_positions.clear()
	_interaction_sequences.clear()
	front_angle = 0.0
	rear_angle = 0.0
	speed = 0.0
	direction = 1
	parking_brake = true
	driving_inputs.clear()
	driving_sequences.clear()
	driving_ages.clear()
	toggle_sequences.clear()
	accidents.clear()
	accident_states.clear()
	accident_sequence = 0
	_serious_reason = &""
	choices.clear()
	_choice_sequences.clear()
	_result.clear()
	_aftermath_elapsed = 0.0
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
	elif phase == &"aftermath":
		_aftermath_elapsed += maxf(0.0, delta)
		if _aftermath_elapsed >= AFTERMATH_DURATION:
			phase = &"settled"
	elif phase == &"active":
		remaining = maxf(0.0, remaining - maxf(0.0, delta))
		if _serious_reason != &"":
			_settle_failure(_serious_reason)
			return
		if remaining == 0.0:
			_settle_failure(&"timeout")


func depart() -> void:
	if phase != &"waiting":
		choices.clear()
		phase = &"departing"


func snapshot() -> Dictionary:
	return {"id": id, "phase": phase, "vehicle": vehicle, "remaining": remaining,
		"participants": _participants.duplicate(), "ready": _ready.duplicate(),
		"serious_reason": _serious_reason, "result": assessment(), "aftermath_elapsed": _aftermath_elapsed, "choices": choices.duplicate(), "choice_sequences": _choice_sequences.duplicate(),
		"loading_elapsed": _loading_elapsed, "operators": operators.duplicate(), "generations": generations.duplicate(), "driving": driving_snapshot(), "recovery": recovery_snapshot()}


func restore(data: Dictionary) -> void:
	_serious_reason = data.get("serious_reason", &"")
	_result = data.get("result", {}).duplicate(true)
	_aftermath_elapsed = data.get("aftermath_elapsed", 0.0)
	choices = data.get("choices", {}).duplicate()
	_choice_sequences = data.get("choice_sequences", {}).duplicate()
	id = data["id"]
	phase = data["phase"]
	vehicle = data["vehicle"]
	remaining = data["remaining"]
	_participants.assign(data["participants"])
	_ready.assign(data["ready"])
	_loading_elapsed = data["loading_elapsed"]
	operators = data.get("operators", {}).duplicate()
	generations = data.get("generations", {}).duplicate()
	if data.has("driving"):
		restore_driving(data.driving)
	restore_recovery(data.get("recovery", {}))


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
	if accident_states.get(player_id, &"") in [&"trapped", &"crushed", &"ravine"]:
		return false
	if not CONTROLS.has(control) or operators.has(control) or control_of(player_id) != &"":
		return false
	if not _learner_positions.has(player_id) or _learner_positions[player_id].distance_to(CONTROLS[control]) > CONTROL_REACH:
		return false
	# Confirmed seating ends an airborne condition; another jolt is a new fall.
	if accident_states.get(player_id, &"") == &"ejected":
		accident_states.erase(player_id)
	operators[control] = player_id
	generations[player_id] = generations.get(player_id, 0) + 1
	return true


func release_control(player_id: int, attempt_id: String, sequence: int) -> bool:
	if not _accept_interaction(player_id, attempt_id, sequence):
		return false
	var control := control_of(player_id)
	if control == &"":
		return false
	_drop_operator(player_id)
	return true


func _accept_interaction(player_id: int, attempt_id: String, sequence: int) -> bool:
	if id != attempt_id or phase != &"active" or not _participants.has(player_id):
		return false
	if sequence <= _interaction_sequences.get(player_id, 0):
		return false
	_interaction_sequences[player_id] = sequence
	return true

## Held commands are resubmitted, while reliable discrete actions have their own
## sequence: a newer held packet must not discard a delayed parking-brake press.
func drive(player_id: int, attempt_id: String, sequence: int, generation: int, command: Dictionary) -> bool:
	if not _valid_operator(player_id, attempt_id, generation) or sequence <= driving_sequences.get(player_id, 0):
		return false
	var steer: float = command.get("steer", 0.0)
	if not is_finite(steer):
		return false
	driving_sequences[player_id] = sequence
	driving_inputs[player_id] = {"steer": clampf(steer, -1.0, 1.0), "throttle": command.get("throttle", false) == true, "brake": command.get("brake", false) == true}
	driving_ages[player_id] = 0.0
	return true

func driving_action(player_id: int, attempt_id: String, sequence: int, generation: int, action: StringName) -> bool:
	if not _valid_operator(player_id, attempt_id, generation) or control_of(player_id) != &"pedals" or sequence <= toggle_sequences.get(player_id, 0):
		return false
	toggle_sequences[player_id] = sequence
	if action == &"parking":
		parking_brake = not parking_brake
		return true
	if action == &"direction" and absf(speed) < 0.05:
		direction *= -1
		return true
	return false

func neutralize_driving(player_id: int) -> void:
	driving_inputs.erase(player_id)

func _valid_operator(player_id: int, attempt_id: String, generation: int) -> bool:
	return phase == &"active" and attempt_id == id and control_of(player_id) != &"" and generations.get(player_id, 0) == generation

func advance_driving(delta: float) -> void:
	if phase != &"active":
		driving_inputs.clear()
	var throttle := false
	var brake := false
	for player_id in driving_inputs:
		driving_ages[player_id] = driving_ages.get(player_id, 0.0) + delta
	for control in CONTROLS:
		var command := effective_driving_input(control)
		if command.is_empty():
			continue
		match control:
			&"front": front_angle = clampf(front_angle + command.steer * 1.8 * delta, -AXLE_LIMIT, AXLE_LIMIT)
			&"rear": rear_angle = clampf(rear_angle + command.steer * 1.8 * delta, -AXLE_LIMIT, AXLE_LIMIT)
			&"pedals":
				throttle = command.throttle
				brake = command.brake
	if parking_brake or brake:
		speed = move_toward(speed, 0.0, (12.0 if parking_brake else 8.0) * delta)
	elif throttle:
		speed = move_toward(speed, direction * 8.0, 3.0 * delta)
	else:
		speed = move_toward(speed, 0.0, 0.45 * delta)


## The currently effective held input, shared by mechanics and presentation.
## Stale or unoccupied controls are neutral even while their last packet is kept.
func effective_driving_input(control: StringName) -> Dictionary:
	var player_id: int = operators.get(control, 0)
	if phase != &"active" or player_id == 0 or driving_ages.get(player_id, INF) > INPUT_FRESHNESS:
		return {}
	return driving_inputs.get(player_id, {}).duplicate()

func driving_snapshot() -> Dictionary:
	return {"front": front_angle, "rear": rear_angle, "speed": speed, "direction": direction, "parking": parking_brake, "inputs": driving_inputs.duplicate(true), "ages": driving_ages.duplicate(), "sequences": driving_sequences.duplicate(), "toggles": toggle_sequences.duplicate()}

func restore_driving(data: Dictionary) -> void:
	front_angle = data.front
	rear_angle = data.rear
	speed = data.speed
	direction = data.direction
	parking_brake = data.parking
	driving_inputs = data.inputs.duplicate(true)
	driving_ages = data.ages.duplicate()
	driving_sequences = data.sequences.duplicate()
	toggle_sequences = data.toggles.duplicate()

## Called only by host world simulation, never by an accident RPC from a guest.
func observe_accident(player_id: int, attempt_id: String, kind: StringName, at: Vector3, impulse := Vector3.ZERO) -> bool:
	if attempt_id != id or phase not in [&"active", &"aftermath", &"settled"] or not _participants.has(player_id):
		return false
	if kind not in [&"ejected", &"landed", &"trapped", &"rescued", &"crushed", &"ravine", &"overturn"] or not at.is_finite() or not impulse.is_finite():
		return false
	var prior: StringName = accident_states.get(player_id, &"")
	if prior == kind or prior in SERIOUS_ACCIDENTS:
		return false
	accident_states[player_id] = kind
	if kind in [&"ejected", &"trapped", &"crushed", &"ravine"]:
		_drop_operator(player_id)
	if kind in SERIOUS_ACCIDENTS and _serious_reason == &"":
		_serious_reason = kind
	accident_sequence += 1
	accidents.append({"sequence": accident_sequence, "player": player_id, "kind": kind, "position": at, "impulse": impulse, "severity": &"serious" if kind in SERIOUS_ACCIDENTS else &"none"})
	# Current conditions retain catastrophes even after the recent event window.
	if accidents.size() > 32:
		accidents.pop_front()
	return true

func recovery_snapshot() -> Dictionary:
	return {"sequence": accident_sequence, "states": accident_states.duplicate(), "events": accidents.duplicate(true)}

func restore_recovery(data: Dictionary) -> void:
	accident_sequence = data.get("sequence", 0)
	accident_states = data.get("states", {}).duplicate()
	accidents = data.get("events", []).duplicate(true)

func _drop_operator(player_id: int) -> void:
	var control := control_of(player_id)
	if control != &"":
		operators.erase(control)
		neutralize_driving(player_id)
		generations[player_id] = generations.get(player_id, 0) + 1

func assessment() -> Dictionary:
	return _result.duplicate(true)

func _settle_failure(reason: StringName) -> void:
	if phase != &"active" or not _result.is_empty():
		return
	_result = {"attempt": id, "outcome": &"failed", "reason": reason, "participants": _participants.duplicate(), "minor_faults": 0}
	choices.clear()
	phase = &"aftermath"
	driving_inputs.clear()

## Reliable intentions are scoped to the current trio and unique attempt.
func choose(player_id: int, attempt_id: String, sequence: int, choice: StringName) -> bool:
	if attempt_id != id or not _participants.has(player_id) or _participants.size() != 3:
		return false
	if phase == &"active":
		if choice not in [&"concede", &"continue"]:
			return false
	elif phase == &"settled":
		if choice not in [&"retry", &"waiting_room"]:
			return false
	else:
		return false
	if sequence <= _choice_sequences.get(player_id, 0):
		return false
	_choice_sequences[player_id] = sequence
	choices[player_id] = choice
	for participant in _participants:
		if choices.get(participant, &"") != choice:
			return true
	match choice:
		&"concede":
			# Observed catastrophe wins a concession arriving in this step.
			tick(0.0)
			_settle_failure(&"concession")
		&"retry": begin(vehicle, _participants.duplicate())
		&"waiting_room": depart()
	return true

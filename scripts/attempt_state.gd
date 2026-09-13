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
		"loading_elapsed": _loading_elapsed, "operators": operators.duplicate(), "generations": generations.duplicate(), "driving": driving_snapshot()}


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
	if data.has("driving"):
		restore_driving(data.driving)


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
	driving_inputs.erase(player_id)
	generations[player_id] = generations.get(player_id, 0) + 1
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
	var throttle := false
	var brake := false
	for player_id in driving_inputs:
		driving_ages[player_id] = driving_ages.get(player_id, 0.0) + delta
		if driving_ages[player_id] > INPUT_FRESHNESS:
			continue
		var command: Dictionary = driving_inputs[player_id]
		match control_of(player_id):
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

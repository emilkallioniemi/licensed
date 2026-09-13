class_name TruckPresentation
extends Node3D
## Imported mechanical pivots and physical instrument lettering. No screen HUD.
var model: Node3D
var timer: Label3D
var direction: Label3D
var parking: Label3D
var wheels: Dictionary = {}
var pivots: Dictionary = {}
var highlighted: Dictionary = {}
var roll := 0.0

func _ready() -> void:
	model = preload("res://assets/monster_truck/truck.glb").instantiate()
	add_child(model)
	for title in ["FrontNeedle", "RearNeedle", "ThrottlePedal", "BrakePedal", "ParkingLever", "DirectionLever", "FrontAxle", "RearAxle"]:
		pivots[title] = model.find_child(title, true, false)
	for axle in ["Front", "Rear"]:
		for side in ["L", "R"]:
			for part in ["Steer", "Roll", "Suspension"]:
				var title: String = axle + side + part
				pivots[title] = model.find_child(title, true, false)
	for axle in ["Front", "Rear"]:
		wheels[axle] = model.find_child(axle + "Wheel", true, false)
		var control: Node3D = wheels[axle]
		highlighted[axle.to_lower()] = meshes(control)
	var pedals := model.find_child("PedalsConsole", true, false)
	highlighted["pedals"] = meshes(pedals.find_child("ThrottlePedal", true, false)) + meshes(pedals.find_child("BrakePedal", true, false))
	timer = lettering("Timer", Vector3(1.2, 2.38, -1.875), 0.0016, 36)
	direction = lettering("Direction", Vector3(1.0, 2.28, -1.905), 0.0012, 30)
	parking = lettering("Parking", Vector3(1.42, 2.28, -1.905), 0.0012, 30)
	var examiner_seat := lettering("ExaminerSeatPrint", Vector3(1.2, 2.36, 1.775), 0.0012, 24)
	examiner_seat.text = "EXAMINER"
	examiner_seat.modulate = Color("eadcb9")

func lettering(title: String, at: Vector3, pixel: float, font: int) -> Label3D:
	var label := Label3D.new()
	label.name = title
	label.position = at
	label.pixel_size = pixel
	label.font_size = font
	label.outline_size = 0
	label.modulate = Color("cce2b2") if title == "Timer" else Color("263537")
	label.no_depth_test = false
	add_child(label)
	return label

func meshes(node: Node3D) -> Array[MeshInstance3D]:
	var result: Array[MeshInstance3D] = []
	for child in node.get_children():
		if child is MeshInstance3D:
			child.material_override = child.mesh.surface_get_material(0).duplicate()
			result.append(child)
		if child is Node3D:
			result.append_array(meshes(child))
	return result

func update(state: AttemptState, vertical: float, delta: float) -> void:
	roll = fmod(roll - state.speed * delta / 1.1, TAU)
	for axle in ["Front", "Rear"]:
		var angle: float = state.front_angle if axle == "Front" else state.rear_angle
		wheels[axle].rotation.z = -angle * 2.4 * (-1.0 if axle == "Rear" else 1.0)
		pivots[axle + "Needle"].rotation.z = -angle * (-1.0 if axle == "Rear" else 1.0)
		for side in ["L", "R"]:
			pivots[axle + side + "Steer"].rotation.y = -angle
			pivots[axle + side + "Roll"].rotation.x = roll
			pivots[axle + side + "Suspension"].position.y = 1.1 - clampf(vertical * 0.035, -0.12, 0.12)
		pivots[axle + "Axle"].position.y = 1.1 - clampf(vertical * 0.035, -0.12, 0.12)
	var command: Dictionary = state.effective_driving_input(&"pedals")
	pivots["ThrottlePedal"].rotation.x = -0.3 if command.get("throttle", false) else 0.0
	pivots["BrakePedal"].rotation.x = -0.3 if command.get("brake", false) else 0.0
	pivots["ParkingLever"].rotation.x = -0.6 if state.parking_brake else 0.0
	pivots["DirectionLever"].rotation.x = -0.3 * state.direction
	timer.text = "%d:%02d" % [int(state.remaining) / 60, int(state.remaining) % 60]
	direction.text = "FWD" if state.direction == 1 else "REV"
	parking.text = "PARK ON" if state.parking_brake else "PARK OFF"

func highlight(control: StringName, enabled: bool) -> void:
	for key in highlighted:
		for mesh in highlighted[key]:
			var material: StandardMaterial3D = mesh.material_override
			material.emission_enabled = enabled and key == control
			material.emission = Color("8c7945")
			material.emission_energy_multiplier = 0.3

func reset() -> void:
	roll = 0.0
	transform = Transform3D.IDENTITY

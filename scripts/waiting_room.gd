extends Node3D
## The game's main scene. There is no menu in front of it: Steam running puts the player
## straight in the room; Steam not running shows the one-line state instead and opens no room.

const STEAM_NOT_RUNNING_SCENE := preload("res://scenes/steam_not_running.tscn")
const LEARNER_SCENE := preload("res://scenes/learner.tscn")

## Furniture the spec names for box colliders, looked up on the kit by node name.
const FURNITURE_GROUPS: PackedStringArray = [
	"Reception",
	"Chair01",
	"Chair02",
	"Chair03",
	"Plant",
	"WasteBin",
]

@onready var kit: Node3D = $Kit
@onready var music: AudioStreamPlayer = $Music


func _ready() -> void:
	if not SteamClient.is_running():
		# Deferred: at boot the root is still adding this scene, so a direct change_scene fails
		# to remove it and prints an error. The swap still lands before the first frame draws.
		get_tree().change_scene_to_packed.call_deferred(STEAM_NOT_RUNNING_SCENE)
		return
	music.play()
	_add_room_collision()
	_place_local_learner()


## Trimesh the kit's Architecture group (walls and floor); box colliders on the named
## furniture; a plug in the entrance opening so the room is closed. The kit scene itself
## is not edited.
func _add_room_collision() -> void:
	var architecture := kit.find_child("Architecture", true, false)
	if architecture == null:
		push_error("Waiting room kit has no Architecture group")
	else:
		for node in architecture.find_children("*", "MeshInstance3D", true, false):
			var mesh_instance := node as MeshInstance3D
			if mesh_instance.name.begins_with("Floor tile"):
				continue
			mesh_instance.create_trimesh_collision()
	for group_name in FURNITURE_GROUPS:
		var group := kit.find_child(group_name, true, false)
		if group == null:
			push_error("Waiting room kit has no furniture group '%s'" % group_name)
			continue
		_add_box_collision(group)
	for cupboard in kit.find_children("Back storage cupboard*", "", true, false):
		_add_box_collision(cupboard)
	_plug_entrance()


func _place_local_learner() -> void:
	# AttachmentPoints/Entrance, not the GLB's Entrance frame group of the same name.
	var entrance := kit.get_node_or_null("AttachmentPoints/Entrance") as Marker3D
	if entrance == null:
		push_error("Waiting room kit has no Entrance marker")
		return
	var learner: Learner = LEARNER_SCENE.instantiate()
	add_child(learner)
	learner.global_position = entrance.global_position
	var into_room := -entrance.global_transform.basis.z
	into_room.y = 0.0
	if into_room.length_squared() > 0.0001:
		learner.look_at(learner.global_position + into_room.normalized(), Vector3.UP)
	learner.set_local(true)


func _add_box_collision(from: Node) -> void:
	var bounds := _visual_aabb(from)
	if bounds.size == Vector3.ZERO:
		push_error("No mesh to box-collide for '%s'" % from.name)
		return
	var body := StaticBody3D.new()
	body.name = "%sCollision" % from.name
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = bounds.size
	shape.shape = box
	body.add_child(shape)
	add_child(body)
	body.global_position = bounds.get_center()


func _plug_entrance() -> void:
	# The opening is 2.2 m wide at Z = +5. A thin wall fills it so the entrance is a way in
	# only; the kit's door leaf is still a request to Astra.
	var body := StaticBody3D.new()
	body.name = "EntrancePlug"
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(2.24, 2.8, 0.3)
	shape.shape = box
	body.add_child(shape)
	add_child(body)
	body.global_position = Vector3(0.0, 1.4, 5.15)


func _visual_aabb(root: Node) -> AABB:
	var meshes: Array[Node] = root.find_children("*", "MeshInstance3D", true, false)
	if root is MeshInstance3D:
		meshes.insert(0, root)
	var bounds := AABB()
	var started := false
	for node in meshes:
		var mesh_instance := node as MeshInstance3D
		if mesh_instance.mesh == null:
			continue
		var local := mesh_instance.mesh.get_aabb()
		for i in 8:
			var corner := mesh_instance.global_transform * local.get_endpoint(i)
			if not started:
				bounds = AABB(corner, Vector3.ZERO)
				started = true
			else:
				bounds = bounds.expand(corner)
	return bounds

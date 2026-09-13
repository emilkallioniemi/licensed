extends WaitingRoom
## Test-only bootstrap for native ENet scene fixtures without a logged-in Steam
## client. No shipping code uses this script; Steam bootstrap remains unverified.
## Reuse production geometry/spawner and all room, arrival and movement code.
func _ready() -> void:
	_waiting_environment = world_environment.environment
	_add_room_collision()
	_add_test_area_door()
	learner_spawner.spawn_function = _spawn_learner
	Transport.room_switched.connect(_on_room_switched)
	if Transport.is_ready():
		_on_transport_ready()

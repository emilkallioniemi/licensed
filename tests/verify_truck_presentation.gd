extends SceneTree
## Production scene observations, not human sight/feel acceptance.
var failures := 0
var truck: MonsterTruck
var state: AttemptState

func _initialize() -> void:
	call_deferred("verify")

func verify() -> void:
	var world := Node3D.new()
	root.add_child(world)
	truck = MonsterTruck.new()
	world.add_child(truck)
	state = AttemptState.new()
	state.begin(&"monster_truck", [1, 2, 3])
	for player in [1, 2, 3]:
		state.scene_ready(player, state.id)
	await physics_frame
	var wheel := truck.find_child("FrontWheel", true, false)
	check(wheel != null, "integrated modeled steering wheel exists at physical control")
	if wheel == null:
		world.free()
		quit(1)
		return
	state.observe_learner(1, AttemptState.CONTROLS.front)
	state.request_control(1, state.id, 1, &"front")
	state.drive(1, state.id, 1, 1, {"steer": 1.0})
	state.advance_driving(0.2)
	truck.drive(state, 0.02)
	check(absf(wheel.rotation.z) > 0.1, "accepted front input visibly turns physical wheel")
	var held: float = wheel.rotation.z
	state.release_control(1, state.id, 2)
	state.advance_driving(0.1)
	truck.drive(state, 0.02)
	check(is_equal_approx(wheel.rotation.z, held), "released wheel visibly retains held axle angle")
	state.observe_learner(2, AttemptState.CONTROLS.rear)
	state.request_control(2, state.id, 1, &"rear")
	state.drive(2, state.id, 1, 1, {"steer": -1.0})
	state.advance_driving(0.2)
	truck.drive(state, 0.02)
	var rear_wheel: Node3D = truck.find_child("RearWheel", true, false)
	check(not rear_wheel.is_visible_in_tree() and state.balance.x < 0.0 and is_equal_approx(wheel.rotation.z, held), "balance replaces rear wheel without changing front steering")
	var front_tyre: Node3D = truck.find_child("FrontLSteer", true, false)
	var rear_tyre: Node3D = truck.find_child("RearLSteer", true, false)
	check(front_tyre.rotation.y < 0.0 and is_zero_approx(rear_tyre.rotation.y), "only front tyres steer")
	state.observe_learner(3, AttemptState.CONTROLS.pedals)
	state.request_control(3, state.id, 1, &"pedals")
	state.driving_action(3, state.id, 1, 1, &"parking")
	state.drive(3, state.id, 1, 1, {"throttle": true})
	state.advance_driving(0.2)
	truck.drive(state, 0.02)
	var pedal: Node3D = truck.find_child("ThrottlePedal", true, false)
	var rolling_tyre: Node3D = truck.find_child("FrontLRoll", true, false)
	check(pedal.rotation.x < -0.1 and absf(rolling_tyre.rotation.x) > 0.0, "throttle pad depresses and tyre tread rolls during actual movement")
	state.advance_driving(0.4)
	truck.drive(state, 0.02)
	check(is_zero_approx(pedal.rotation.x) and truck.sound.load_layer.volume_db < -30.0, "expired throttle visibly releases and engine load quiets while occupancy remains")
	state.release_control(3, state.id, 2)
	truck.drive(state, 0.02)
	check(is_zero_approx(pedal.rotation.x), "physical pedal returns when operator releases control")
	state.observe_learner(3, AttemptState.CONTROLS.pedals)
	state.request_control(3, state.id, 3, &"pedals")
	state.driving_action(3, state.id, 2, 3, &"parking")
	state.advance_driving(0.2)
	truck.drive(state, 0.02)
	check(not truck.find_child("ParkingLever", true, false).visible, "manual parking lever is removed from the controls")
	check(truck.visuals.parking.text == "PARK ON" and truck.visuals.timer.text == "6:00", "physical pedals instruments print actual timer and parking state")
	for player in truck.sound.get_children():
		if player is AudioStreamPlayer3D:
			check(player.stream is AudioStreamWAV and player.stream.data.size() > 1000, "generated sound contains real PCM frames")
	truck.reset_presentation()
	check(not truck.engine.playing and not truck.sound.load_layer.playing and not truck.sound.cabin.playing, "attempt reset silences every looping vehicle layer")
	world.free()
	if failures == 0:
		print("PASS: modeled truck controls follow public attempt commands")
	quit(1 if failures else 0)

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error("FAIL: " + message)

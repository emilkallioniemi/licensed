extends SceneTree
## Run headless with --path <project> --script res://tests/verify_room_state.gd
## Drives the host-owned room state through the commands a player's click would send and
## asserts what the room would show, as literals (spec, Testing Decisions). Never touches a
## node, the MultiplayerAPI, or Steam.

const RoomStateScript := preload("res://scripts/room_state.gd")

const EMIL := 1001
const ASTRA := 1002
const BROTHER := 1003
const FOURTH := 1004


func _initialize() -> void:
	call_deferred("_verify")


func _verify() -> void:
	_arrival_deals_palettes_in_order()
	_booking_forms_on_the_third_matching_pick()
	_switch_dissolves_the_booking()
	_booking_forms_at_n_under_min_players()
	_holds_follow_the_booking()
	_notice_board_states_what_the_room_waits_for()
	_notice_board_counts_out_of_n()
	print("PASS: the room state enforces every rule of the waiting room.")
	quit()


## A room with Emil, Astra, and Brother arrived in that order.
func _room_of_three(min_players: int = 3) -> RoomStateScript:
	var room := RoomStateScript.new(min_players)
	room.arrive(EMIL, "Emil")
	room.arrive(ASTRA, "Astra")
	room.arrive(BROTHER, "Brother")
	return room


## A room of three with the monster truck booked.
func _booked_room() -> RoomStateScript:
	var room := _room_of_three()
	for id in [EMIL, ASTRA, BROTHER]:
		room.pick(id, RoomStateScript.MONSTER_TRUCK)
	assert(room.has_booking())
	return room


func _arrival_deals_palettes_in_order() -> void:
	var room := RoomStateScript.new()
	assert(room.player_count() == 0)
	assert(room.arrive(EMIL, "Emil"))
	assert(room.arrive(ASTRA, "Astra"))
	assert(room.arrive(BROTHER, "Brother"))
	assert(room.player_count() == 3)
	assert(room.player(EMIL).palette == 1)
	assert(room.player(ASTRA).palette == 2)
	assert(room.player(BROTHER).palette == 3)
	assert(room.player(ASTRA).display_name == "Astra")
	# A room holds exactly three; a fourth is impossible (ADR-0001).
	assert(not room.arrive(FOURTH, "Fourth"))
	assert(room.player_count() == 3)
	# Arriving twice is one arrival.
	assert(not room.arrive(EMIL, "Emil"))
	# The middle player leaves: the survivors keep their palettes.
	assert(room.leave(ASTRA))
	assert(room.player(ASTRA) == null)
	assert(room.player(EMIL).palette == 1)
	assert(room.player(BROTHER).palette == 3)
	# The next arrival takes the freed palette, not a fourth one.
	assert(room.arrive(FOURTH, "Fourth"))
	assert(room.player(FOURTH).palette == 2)
	assert(room.players[2].steam_id == FOURTH)
	assert(not room.leave(ASTRA))


## Counts each event as it fires so a test can assert what the views would have reacted to.
class Events extends RefCounted:
	var formed := 0
	var dissolved := 0

	func _init(room: RoomStateScript) -> void:
		room.booking_formed.connect(func(_vehicle: StringName) -> void: formed += 1)
		room.booking_dissolved.connect(func() -> void: dissolved += 1)


func _booking_forms_on_the_third_matching_pick() -> void:
	var room := _room_of_three()
	var events := Events.new(room)
	var truck: StringName = RoomStateScript.MONSTER_TRUCK
	assert(not room.has_booking())
	# Nobody arrives with a pick.
	assert(room.player(EMIL).pick == &"")
	assert(room.pick(EMIL, truck))
	assert(room.pick(ASTRA, truck))
	assert(not room.has_booking(), "two matching picks are not a booking")
	assert(events.formed == 0)
	assert(room.pick(BROTHER, truck))
	assert(room.has_booking())
	assert(room.booking() == truck)
	assert(events.formed == 1)
	# Picking what you already picked changes nothing.
	assert(not room.pick(BROTHER, truck))
	assert(events.formed == 1)
	# A drop dissolves it, silently to the record but as an event to the views.
	assert(room.drop_pick(ASTRA))
	assert(not room.has_booking())
	assert(room.player(ASTRA).pick == &"")
	assert(events.dissolved == 1)
	assert(not room.drop_pick(ASTRA), "nothing to drop")
	# Re-form, then a departure dissolves it.
	assert(room.pick(ASTRA, truck))
	assert(room.has_booking() and events.formed == 2)
	assert(room.leave(BROTHER))
	assert(not room.has_booking() and events.dissolved == 2)
	# An arrival never dissolves a booking (here: never forms one either).
	assert(room.arrive(BROTHER, "Brother"))
	assert(not room.has_booking() and events.dissolved == 2 and events.formed == 2)
	# Only a bookable vehicle can be picked; a locked row does nothing.
	assert(not room.pick(BROTHER, &"helicopter"))
	assert(room.player(BROTHER).pick == &"")
	assert(room.pick(BROTHER, truck) and room.has_booking() and events.formed == 3)


## Only the monster truck is bookable this slice, so a switch needs a room whose board offers
## two rows; the record takes the bookable list as configuration for the day a second unlocks.
func _switch_dissolves_the_booking() -> void:
	var truck: StringName = RoomStateScript.MONSTER_TRUCK
	var room := RoomStateScript.new(3, [truck, &"car"])
	var events := Events.new(room)
	room.arrive(EMIL, "Emil")
	room.arrive(ASTRA, "Astra")
	room.arrive(BROTHER, "Brother")
	room.pick(EMIL, truck)
	room.pick(ASTRA, truck)
	room.pick(BROTHER, truck)
	assert(room.has_booking())
	assert(room.pick(EMIL, &"car"), "a switch is one move")
	assert(room.player(EMIL).pick == &"car")
	assert(not room.has_booking() and events.dissolved == 1)
	assert(room.pick(EMIL, truck) and room.has_booking() and events.formed == 2)


func _booking_forms_at_n_under_min_players() -> void:
	var room := RoomStateScript.new(2)
	var events := Events.new(room)
	var truck: StringName = RoomStateScript.MONSTER_TRUCK
	room.arrive(EMIL, "Emil")
	room.arrive(ASTRA, "Astra")
	room.pick(EMIL, truck)
	assert(not room.has_booking())
	room.pick(ASTRA, truck)
	assert(room.has_booking() and events.formed == 1)
	# A third arrival does not dissolve the booking of two.
	room.arrive(BROTHER, "Brother")
	assert(room.has_booking() and events.dissolved == 0)
	# A third matching pick keeps the one booking; it does not form again.
	room.pick(BROTHER, truck)
	assert(room.has_booking() and events.formed == 1)
	room.drop_pick(EMIL)
	assert(room.has_booking(), "two still match")
	room.drop_pick(ASTRA)
	assert(not room.has_booking() and events.dissolved == 1)


func _holds_follow_the_booking() -> void:
	var driver: StringName = RoomStateScript.DRIVER
	var spotter: StringName = RoomStateScript.SPOTTER
	var navigator: StringName = RoomStateScript.NAVIGATOR
	var random: StringName = RoomStateScript.RANDOM
	# The role column is dead without a booking.
	var room := _room_of_three()
	assert(not room.take(EMIL, driver))
	assert(not room.take(EMIL, random))
	assert(room.player(EMIL).hold == &"")
	assert(room.holder_of(driver) == null)
	# With a booking, take, drop, swap.
	room = _booked_room()
	assert(room.take(EMIL, driver))
	assert(room.holder_of(driver).display_name == "Emil")
	assert(room.player(EMIL).hold == driver)
	# A taken role rejects a second taker; a same-frame tie is two commands, receive order wins.
	assert(not room.take(ASTRA, driver))
	assert(room.holder_of(driver).display_name == "Emil")
	assert(room.player(ASTRA).hold == &"")
	# Swap in one move; the old role is free again.
	assert(room.take(EMIL, spotter))
	assert(room.holder_of(driver) == null)
	assert(room.holder_of(spotter).display_name == "Emil")
	assert(not room.take(EMIL, spotter), "taking what you hold changes nothing")
	# Drop.
	assert(room.drop_hold(EMIL))
	assert(room.holder_of(spotter) == null and room.player(EMIL).hold == &"")
	assert(not room.drop_hold(EMIL), "nothing to drop")
	# Random accepts any number of holders, in arrival order.
	assert(room.take(BROTHER, random))
	assert(room.take(ASTRA, random))
	assert(room.take(EMIL, random))
	var random_names: Array[String] = []
	for holder in room.random_holders():
		random_names.append(holder.display_name)
	assert(random_names == ["Emil", "Astra", "Brother"])
	assert(room.holder_of(random) == null, "Random has no single holder")
	# Only the booked vehicle's roles exist.
	assert(not room.take(EMIL, &"pilot"))
	assert(room.player(EMIL).hold == random)
	# The booking dissolves: every hold is released.
	room.take(EMIL, navigator)
	room.drop_pick(BROTHER)
	assert(not room.has_booking())
	for id in [EMIL, ASTRA, BROTHER]:
		assert(room.player(id).hold == &"")
	assert(room.holder_of(navigator) == null and room.random_holders().is_empty())
	# Dead again until it re-forms.
	assert(not room.take(EMIL, navigator))
	room.pick(BROTHER, RoomStateScript.MONSTER_TRUCK)
	assert(room.take(EMIL, navigator))


func _notice_board_states_what_the_room_waits_for() -> void:
	var room := RoomStateScript.new()
	assert(room.notice_board_line() == "Waiting for 3.")
	room.arrive(EMIL, "Emil")
	assert(room.notice_board_line() == "Waiting for 2.")
	room.arrive(ASTRA, "Astra")
	assert(room.notice_board_line() == "Waiting for 1.")
	room.arrive(BROTHER, "Brother")
	assert(room.notice_board_line() == "No booking.")
	# Two matching picks are still no booking; disagreement is quiet.
	room.pick(EMIL, RoomStateScript.MONSTER_TRUCK)
	room.pick(ASTRA, RoomStateScript.MONSTER_TRUCK)
	assert(room.notice_board_line() == "No booking.")
	room.pick(BROTHER, RoomStateScript.MONSTER_TRUCK)
	assert(room.notice_board_line() == "Roles: 0 of 3.")
	room.take(EMIL, RoomStateScript.DRIVER)
	room.take(ASTRA, RoomStateScript.RANDOM)
	assert(room.notice_board_line() == "Roles: 2 of 3.", "Random counts as a role held")
	# Sitting early is allowed and changes nothing on the board until roles are held.
	assert(room.sit(BROTHER, 2))
	assert(room.player(BROTHER).chair == 2)
	assert(room.notice_board_line() == "Roles: 2 of 3.")
	room.take(BROTHER, RoomStateScript.RANDOM)
	assert(room.notice_board_line() == "Seated: 1 of 3.")
	assert(room.sit(EMIL, 1))
	assert(not room.sit(ASTRA, 1), "a chair seats one; any chair, first come")
	assert(room.player(ASTRA).chair == 0)
	assert(room.notice_board_line() == "Seated: 2 of 3.")
	# Standing takes the ready-up back.
	assert(room.stand(EMIL))
	assert(room.player(EMIL).chair == 0)
	assert(not room.stand(EMIL), "already standing")
	assert(room.notice_board_line() == "Seated: 1 of 3.")
	# Moving chairs while seated is one command.
	assert(room.sit(BROTHER, 3))
	assert(room.player(BROTHER).chair == 3)
	assert(room.sit(EMIL, 2))
	assert(room.notice_board_line() == "Seated: 2 of 3.")
	# A dropped hold outranks the seated count.
	room.drop_hold(ASTRA)
	assert(room.notice_board_line() == "Roles: 2 of 3.")
	# A departure outranks everything.
	room.leave(ASTRA)
	assert(room.notice_board_line() == "Waiting for 1.")


func _notice_board_counts_out_of_n() -> void:
	var room := RoomStateScript.new(2)
	assert(room.notice_board_line() == "Waiting for 2.")
	room.arrive(EMIL, "Emil")
	assert(room.notice_board_line() == "Waiting for 1.")
	room.arrive(ASTRA, "Astra")
	assert(room.notice_board_line() == "No booking.")
	room.pick(EMIL, RoomStateScript.MONSTER_TRUCK)
	room.pick(ASTRA, RoomStateScript.MONSTER_TRUCK)
	assert(room.notice_board_line() == "Roles: 0 of 2.")
	room.take(EMIL, RoomStateScript.NAVIGATOR)
	assert(room.notice_board_line() == "Roles: 1 of 2.")
	room.take(ASTRA, RoomStateScript.RANDOM)
	assert(room.notice_board_line() == "Seated: 0 of 2.")
	room.sit(EMIL, 3)
	assert(room.notice_board_line() == "Seated: 1 of 2.")

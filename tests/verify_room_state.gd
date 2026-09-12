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
	print("PASS: the room state enforces every rule of the waiting room.")
	quit()


## A room with Emil, Astra, and Brother arrived in that order.
func _room_of_three(min_players: int = 3) -> RoomStateScript:
	var room := RoomStateScript.new(min_players)
	room.arrive(EMIL, "Emil")
	room.arrive(ASTRA, "Astra")
	room.arrive(BROTHER, "Brother")
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

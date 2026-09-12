extends SceneTree
## Run with `godot --headless --path <project> --script res://tests/verify_room_state.gd`; it
## prints PASS and exits 0, or FAIL and exits 1.
## Drives the host-owned room state through the commands a player's click would send and
## asserts what the room would show, as literals (spec, Testing Decisions). Never touches a
## node, the MultiplayerAPI, or Steam.

const RoomStateScript := preload("res://scripts/room_state.gd")

const EMIL := 1001
const ASTRA := 1002
const BROTHER := 1003
const FOURTH := 1004

var _failures := 0


func _initialize() -> void:
	call_deferred("_verify")


## A failed `assert` in a headless script reports its line, aborts only the function it is in,
## and the run would still end in PASS. Every check goes through here so it ends in FAIL.
func _check(condition: bool, message: String = "") -> void:
	if condition:
		return
	_failures += 1
	assert(condition, message)


func _verify() -> void:
	_arrival_deals_palettes_in_order()
	_booking_forms_on_the_third_matching_pick()
	_switch_dissolves_the_booking()
	_booking_forms_at_n_under_min_players()
	_holds_follow_the_booking()
	_notice_board_states_what_the_room_waits_for()
	_notice_board_counts_out_of_n()
	_countdown_starts_only_when_everything_holds()
	_countdown_is_cancelled_by_any_change()
	_deal_gives_random_holders_the_remaining_roles()
	_return_from_the_test_area_clears_everything()
	_departure_frees_the_leavers_pick_and_hold()
	_min_players_comes_from_the_command_line()
	_replicated_state_round_trips()
	if _failures > 0:
		printerr("FAIL: %d checks failed; see the assertion reports above." % _failures)
		quit(1)
		return
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
	_check(room.has_booking())
	return room


func _arrival_deals_palettes_in_order() -> void:
	var room := RoomStateScript.new()
	_check(room.player_count() == 0)
	_check(room.arrive(EMIL, "Emil"))
	_check(room.arrive(ASTRA, "Astra"))
	_check(room.arrive(BROTHER, "Brother"))
	_check(room.player_count() == 3)
	_check(room.player(EMIL).palette == 1)
	_check(room.player(ASTRA).palette == 2)
	_check(room.player(BROTHER).palette == 3)
	_check(room.player(ASTRA).display_name == "Astra")
	# A room holds exactly three; a fourth is impossible (ADR-0001).
	_check(not room.arrive(FOURTH, "Fourth"))
	_check(room.player_count() == 3)
	# Arriving twice is one arrival.
	_check(not room.arrive(EMIL, "Emil"))
	# The middle player leaves: the survivors keep their palettes.
	_check(room.leave(ASTRA))
	_check(room.player(ASTRA) == null)
	_check(room.player(EMIL).palette == 1)
	_check(room.player(BROTHER).palette == 3)
	# The next arrival takes the freed palette, not a fourth one.
	_check(room.arrive(FOURTH, "Fourth"))
	_check(room.player(FOURTH).palette == 2)
	_check(room.players[2].steam_id == FOURTH)
	_check(not room.leave(ASTRA))


## Counts each event as it fires so a test can assert what the views would have reacted to.
class Events extends RefCounted:
	var formed := 0
	var dissolved := 0
	var countdown_started := 0
	var countdown_cancelled := 0
	var launches: Array[Dictionary] = []

	func _init(room: RoomStateScript) -> void:
		room.booking_formed.connect(func(_vehicle: StringName) -> void: formed += 1)
		room.booking_dissolved.connect(func() -> void: dissolved += 1)
		room.countdown_started.connect(func() -> void: countdown_started += 1)
		room.countdown_cancelled.connect(func() -> void: countdown_cancelled += 1)
		room.launched.connect(func(_vehicle: StringName, roles: Dictionary) -> void: launches.append(roles))


func _booking_forms_on_the_third_matching_pick() -> void:
	var room := _room_of_three()
	var events := Events.new(room)
	var truck: StringName = RoomStateScript.MONSTER_TRUCK
	_check(not room.has_booking())
	# Nobody arrives with a pick.
	_check(room.player(EMIL).pick == &"")
	_check(room.pick(EMIL, truck))
	_check(room.pick(ASTRA, truck))
	_check(not room.has_booking(), "two matching picks are not a booking")
	_check(events.formed == 0)
	_check(room.pick(BROTHER, truck))
	_check(room.has_booking())
	_check(room.booking() == truck)
	_check(events.formed == 1)
	# Picking what you already picked changes nothing.
	_check(not room.pick(BROTHER, truck))
	_check(events.formed == 1)
	# A drop dissolves it, silently to the record but as an event to the views.
	_check(room.drop_pick(ASTRA))
	_check(not room.has_booking())
	_check(room.player(ASTRA).pick == &"")
	_check(events.dissolved == 1)
	_check(not room.drop_pick(ASTRA), "nothing to drop")
	# Re-form, then a departure dissolves it.
	_check(room.pick(ASTRA, truck))
	_check(room.has_booking() and events.formed == 2)
	_check(room.leave(BROTHER))
	_check(not room.has_booking() and events.dissolved == 2)
	# An arrival never dissolves a booking (here: never forms one either).
	_check(room.arrive(BROTHER, "Brother"))
	_check(not room.has_booking() and events.dissolved == 2 and events.formed == 2)
	# Only a bookable vehicle can be picked; a locked row does nothing.
	_check(not room.pick(BROTHER, &"helicopter"))
	_check(room.player(BROTHER).pick == &"")
	_check(room.pick(BROTHER, truck) and room.has_booking() and events.formed == 3)


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
	_check(room.has_booking())
	_check(room.pick(EMIL, &"car"), "a switch is one move")
	_check(room.player(EMIL).pick == &"car")
	_check(not room.has_booking() and events.dissolved == 1)
	_check(room.pick(EMIL, truck) and room.has_booking() and events.formed == 2)


func _booking_forms_at_n_under_min_players() -> void:
	var room := RoomStateScript.new(2)
	var events := Events.new(room)
	var truck: StringName = RoomStateScript.MONSTER_TRUCK
	room.arrive(EMIL, "Emil")
	room.arrive(ASTRA, "Astra")
	room.pick(EMIL, truck)
	_check(not room.has_booking())
	room.pick(ASTRA, truck)
	_check(room.has_booking() and events.formed == 1)
	# A third arrival does not dissolve the booking of two.
	room.arrive(BROTHER, "Brother")
	_check(room.has_booking() and events.dissolved == 0)
	# A third matching pick keeps the one booking; it does not form again.
	room.pick(BROTHER, truck)
	_check(room.has_booking() and events.formed == 1)
	room.drop_pick(EMIL)
	_check(room.has_booking(), "two still match")
	room.drop_pick(ASTRA)
	_check(not room.has_booking() and events.dissolved == 1)


func _holds_follow_the_booking() -> void:
	var driver: StringName = RoomStateScript.DRIVER
	var spotter: StringName = RoomStateScript.SPOTTER
	var navigator: StringName = RoomStateScript.NAVIGATOR
	var random: StringName = RoomStateScript.RANDOM
	# The role column is dead without a booking.
	var room := _room_of_three()
	_check(not room.take(EMIL, driver))
	_check(not room.take(EMIL, random))
	_check(room.player(EMIL).hold == &"")
	_check(room.holder_of(driver) == null)
	# With a booking, take, drop, swap.
	room = _booked_room()
	_check(room.take(EMIL, driver))
	_check(room.holder_of(driver).display_name == "Emil")
	_check(room.player(EMIL).hold == driver)
	# A taken role rejects a second taker; a same-frame tie is two commands, receive order wins.
	_check(not room.take(ASTRA, driver))
	_check(room.holder_of(driver).display_name == "Emil")
	_check(room.player(ASTRA).hold == &"")
	# Swap in one move; the old role is free again.
	_check(room.take(EMIL, spotter))
	_check(room.holder_of(driver) == null)
	_check(room.holder_of(spotter).display_name == "Emil")
	_check(not room.take(EMIL, spotter), "taking what you hold changes nothing")
	# Drop.
	_check(room.drop_hold(EMIL))
	_check(room.holder_of(spotter) == null and room.player(EMIL).hold == &"")
	_check(not room.drop_hold(EMIL), "nothing to drop")
	# Random accepts any number of holders, in arrival order.
	_check(room.take(BROTHER, random))
	_check(room.take(ASTRA, random))
	_check(room.take(EMIL, random))
	var random_names: Array[String] = []
	for holder in room.random_holders():
		random_names.append(holder.display_name)
	_check(random_names == ["Emil", "Astra", "Brother"])
	_check(room.holder_of(random) == null, "Random has no single holder")
	# Only the booked vehicle's roles exist.
	_check(not room.take(EMIL, &"pilot"))
	_check(room.player(EMIL).hold == random)
	# The booking dissolves: every hold is released.
	room.take(EMIL, navigator)
	room.drop_pick(BROTHER)
	_check(not room.has_booking())
	for id in [EMIL, ASTRA, BROTHER]:
		_check(room.player(id).hold == &"")
	_check(room.holder_of(navigator) == null and room.random_holders().is_empty())
	# Dead again until it re-forms.
	_check(not room.take(EMIL, navigator))
	room.pick(BROTHER, RoomStateScript.MONSTER_TRUCK)
	_check(room.take(EMIL, navigator))


func _notice_board_states_what_the_room_waits_for() -> void:
	var room := RoomStateScript.new()
	_check(room.notice_board_line() == "Waiting for 3.")
	room.arrive(EMIL, "Emil")
	_check(room.notice_board_line() == "Waiting for 2.")
	room.arrive(ASTRA, "Astra")
	_check(room.notice_board_line() == "Waiting for 1.")
	room.arrive(BROTHER, "Brother")
	_check(room.notice_board_line() == "No booking.")
	# Two matching picks are still no booking; disagreement is quiet.
	room.pick(EMIL, RoomStateScript.MONSTER_TRUCK)
	room.pick(ASTRA, RoomStateScript.MONSTER_TRUCK)
	_check(room.notice_board_line() == "No booking.")
	room.pick(BROTHER, RoomStateScript.MONSTER_TRUCK)
	_check(room.notice_board_line() == "Roles: 0 of 3.")
	room.take(EMIL, RoomStateScript.DRIVER)
	room.take(ASTRA, RoomStateScript.RANDOM)
	_check(room.notice_board_line() == "Roles: 2 of 3.", "Random counts as a role held")
	# Sitting early is allowed and changes nothing on the board until roles are held.
	_check(room.sit(BROTHER, 2))
	_check(room.player(BROTHER).chair == 2)
	_check(room.notice_board_line() == "Roles: 2 of 3.")
	room.take(BROTHER, RoomStateScript.RANDOM)
	_check(room.notice_board_line() == "Seated: 1 of 3.")
	_check(room.sit(EMIL, 1))
	_check(not room.sit(ASTRA, 1), "a chair seats one; any chair, first come")
	_check(room.player(ASTRA).chair == 0)
	_check(room.notice_board_line() == "Seated: 2 of 3.")
	# Standing takes the ready-up back.
	_check(room.stand(EMIL))
	_check(room.player(EMIL).chair == 0)
	_check(not room.stand(EMIL), "already standing")
	_check(room.notice_board_line() == "Seated: 1 of 3.")
	# Moving chairs while seated is one command.
	_check(room.sit(BROTHER, 3))
	_check(room.player(BROTHER).chair == 3)
	_check(room.sit(EMIL, 2))
	_check(room.notice_board_line() == "Seated: 2 of 3.")
	# A dropped hold outranks the seated count.
	room.drop_hold(ASTRA)
	_check(room.notice_board_line() == "Roles: 2 of 3.")
	# A departure outranks everything.
	room.leave(ASTRA)
	_check(room.notice_board_line() == "Waiting for 1.")


func _notice_board_counts_out_of_n() -> void:
	var room := RoomStateScript.new(2)
	_check(room.notice_board_line() == "Waiting for 2.")
	room.arrive(EMIL, "Emil")
	_check(room.notice_board_line() == "Waiting for 1.")
	room.arrive(ASTRA, "Astra")
	_check(room.notice_board_line() == "No booking.")
	room.pick(EMIL, RoomStateScript.MONSTER_TRUCK)
	room.pick(ASTRA, RoomStateScript.MONSTER_TRUCK)
	_check(room.notice_board_line() == "Roles: 0 of 2.")
	room.take(EMIL, RoomStateScript.NAVIGATOR)
	_check(room.notice_board_line() == "Roles: 1 of 2.")
	room.take(ASTRA, RoomStateScript.RANDOM)
	_check(room.notice_board_line() == "Seated: 0 of 2.")
	room.sit(EMIL, 3)
	_check(room.notice_board_line() == "Seated: 1 of 2.")


## A booked room of three with Emil holding Driver and the other two holding Random, all seated
## but Brother, so one command away from the countdown.
func _room_one_seat_short() -> RoomStateScript:
	var room := _booked_room()
	room.take(EMIL, RoomStateScript.DRIVER)
	room.take(ASTRA, RoomStateScript.RANDOM)
	room.take(BROTHER, RoomStateScript.RANDOM)
	room.sit(EMIL, 1)
	room.sit(ASTRA, 2)
	return room


func _countdown_starts_only_when_everything_holds() -> void:
	var room := _room_one_seat_short()
	var events := Events.new(room)
	_check(not room.is_counting_down())
	_check(room.notice_board_line() == "Seated: 2 of 3.")
	room.sit(BROTHER, 3)
	_check(room.is_counting_down() and events.countdown_started == 1)
	_check(room.notice_board_line() == "Monster truck. 3.")
	room.tick(1.0)
	_check(room.notice_board_line() == "Monster truck. 2.")
	room.tick(1.0)
	_check(room.notice_board_line() == "Monster truck. 1.")
	room.tick(0.5)
	_check(room.notice_board_line() == "Monster truck. 1.")
	_check(events.launches.is_empty(), "nothing is dealt during the count")
	_check(room.launched_roles().is_empty())
	room.tick(0.6)
	_check(not room.is_counting_down())
	_check(events.launches.size() == 1)
	_check(room.launched_roles() == events.launches[0])
	# Ticking after launch does nothing more.
	room.tick(5.0)
	_check(events.launches.size() == 1 and events.countdown_started == 1)
	# Under --min-players=2 the count fires at two.
	var short_room := RoomStateScript.new(2)
	var short_events := Events.new(short_room)
	short_room.arrive(EMIL, "Emil")
	short_room.arrive(ASTRA, "Astra")
	short_room.pick(EMIL, RoomStateScript.MONSTER_TRUCK)
	short_room.pick(ASTRA, RoomStateScript.MONSTER_TRUCK)
	short_room.take(EMIL, RoomStateScript.SPOTTER)
	short_room.take(ASTRA, RoomStateScript.RANDOM)
	short_room.sit(EMIL, 1)
	short_room.sit(ASTRA, 2)
	_check(short_room.is_counting_down() and short_events.countdown_started == 1)
	_check(short_room.notice_board_line() == "Monster truck. 3.")


func _countdown_is_cancelled_by_any_change() -> void:
	# A stand.
	var room := _room_one_seat_short()
	var events := Events.new(room)
	room.sit(BROTHER, 3)
	room.tick(1.5)
	_check(room.notice_board_line() == "Monster truck. 2.")
	room.stand(ASTRA)
	_check(not room.is_counting_down() and events.countdown_cancelled == 1)
	_check(room.notice_board_line() == "Seated: 2 of 3.")
	room.tick(5.0)
	_check(events.launches.is_empty(), "a cancelled count never launches")
	# Re-arming starts a fresh count of three.
	room.sit(ASTRA, 2)
	_check(events.countdown_started == 2)
	_check(room.notice_board_line() == "Monster truck. 3.")
	# A pick change.
	room.drop_pick(EMIL)
	_check(not room.is_counting_down() and events.countdown_cancelled == 2)
	_check(room.notice_board_line() == "No booking.")
	# A hold drop.
	room = _room_one_seat_short()
	events = Events.new(room)
	room.sit(BROTHER, 3)
	room.drop_hold(BROTHER)
	_check(not room.is_counting_down() and events.countdown_cancelled == 1)
	_check(room.notice_board_line() == "Roles: 2 of 3.")
	# A swap of holds keeps every condition true and is not a cancel.
	room.take(BROTHER, RoomStateScript.RANDOM)
	_check(events.countdown_started == 2)
	room.take(BROTHER, RoomStateScript.NAVIGATOR)
	_check(room.is_counting_down() and events.countdown_cancelled == 1)
	# A departure.
	room.leave(ASTRA)
	_check(not room.is_counting_down() and events.countdown_cancelled == 2)
	_check(room.notice_board_line() == "Waiting for 1.")
	_check(events.launches.is_empty() and room.launched_roles().is_empty())


func _deal_gives_random_holders_the_remaining_roles() -> void:
	# One named holder, two Random: the two remaining roles, one each, distinct.
	for _attempt in range(20):
		var room := _room_one_seat_short()
		var events := Events.new(room)
		room.sit(BROTHER, 3)
		room.tick(3.0)
		_check(events.launches.size() == 1)
		var roles: Dictionary = events.launches[0]
		_check(roles.size() == 3)
		_check(roles[EMIL] == RoomStateScript.DRIVER, "a named holder is untouched")
		_check(roles[ASTRA] != roles[BROTHER])
		_check(roles[ASTRA] in [RoomStateScript.SPOTTER, RoomStateScript.NAVIGATOR])
		_check(roles[BROTHER] in [RoomStateScript.SPOTTER, RoomStateScript.NAVIGATOR])
		# The board's strips do not update: the holds still read as held before launch.
		_check(room.player(ASTRA).hold == RoomStateScript.RANDOM)
	# Three Random holders get all three, distinct.
	var room := _booked_room()
	var events := Events.new(room)
	for id in [EMIL, ASTRA, BROTHER]:
		room.take(id, RoomStateScript.RANDOM)
	room.sit(EMIL, 1)
	room.sit(ASTRA, 2)
	room.sit(BROTHER, 3)
	room.tick(3.0)
	var dealt: Array[String] = []
	for role in events.launches[0].values():
		dealt.append(String(role))
	dealt.sort()
	_check(dealt == ["driver", "navigator", "spotter"])
	# No Random holders: the deal is the holds as they stand.
	room = _booked_room()
	events = Events.new(room)
	room.take(EMIL, RoomStateScript.NAVIGATOR)
	room.take(ASTRA, RoomStateScript.DRIVER)
	room.take(BROTHER, RoomStateScript.SPOTTER)
	room.sit(EMIL, 1)
	room.sit(ASTRA, 2)
	room.sit(BROTHER, 3)
	room.tick(3.0)
	_check(events.launches[0] == {
		EMIL: RoomStateScript.NAVIGATOR, ASTRA: RoomStateScript.DRIVER, BROTHER: RoomStateScript.SPOTTER,
	})
	# Under --min-players=2, named plus dealt sums to two and the dealt role is one nobody holds.
	var short_room := RoomStateScript.new(2)
	var short_events := Events.new(short_room)
	short_room.arrive(EMIL, "Emil")
	short_room.arrive(ASTRA, "Astra")
	short_room.pick(EMIL, RoomStateScript.MONSTER_TRUCK)
	short_room.pick(ASTRA, RoomStateScript.MONSTER_TRUCK)
	short_room.take(EMIL, RoomStateScript.SPOTTER)
	short_room.take(ASTRA, RoomStateScript.RANDOM)
	short_room.sit(EMIL, 1)
	short_room.sit(ASTRA, 2)
	short_room.tick(3.0)
	var short_roles: Dictionary = short_events.launches[0]
	_check(short_roles.size() == 2)
	_check(short_roles[EMIL] == RoomStateScript.SPOTTER)
	_check(short_roles[ASTRA] in [RoomStateScript.DRIVER, RoomStateScript.NAVIGATOR])


func _return_from_the_test_area_clears_everything() -> void:
	var room := _room_one_seat_short()
	var events := Events.new(room)
	room.sit(BROTHER, 3)
	room.tick(3.0)
	_check(events.launches.size() == 1)
	room.return_from_test_area()
	_check(not room.has_booking())
	_check(room.launched_roles().is_empty())
	_check(not room.is_counting_down())
	for id in [EMIL, ASTRA, BROTHER]:
		_check(room.player(id).pick == &"")
		_check(room.player(id).hold == &"")
		_check(room.player(id).chair == 0)
	_check(room.player_count() == 3, "everyone is still in the room")
	_check(room.player(BROTHER).palette == 3, "palettes survive the return")
	_check(room.notice_board_line() == "No booking.")
	_check(events.dissolved == 1, "the booking dissolved with the return")
	_check(events.countdown_cancelled == 0, "nothing was counting")
	# The ritual runs again from the start, and the count arms again.
	for id in [EMIL, ASTRA, BROTHER]:
		room.pick(id, RoomStateScript.MONSTER_TRUCK)
	for id in [EMIL, ASTRA, BROTHER]:
		room.take(id, RoomStateScript.RANDOM)
	room.sit(EMIL, 1)
	room.sit(ASTRA, 2)
	room.sit(BROTHER, 3)
	_check(room.is_counting_down() and events.countdown_started == 2)
	room.tick(3.0)
	_check(events.launches.size() == 2)
	# Someone dropped in the test area: the survivors come back to a room of two.
	room.leave(ASTRA)
	room.return_from_test_area()
	_check(room.notice_board_line() == "Waiting for 1.")
	_check(room.player(EMIL).hold == &"" and room.player(BROTHER).hold == &"")
	# Returning when nothing was launched is harmless.
	var fresh := _room_of_three()
	var fresh_events := Events.new(fresh)
	fresh.return_from_test_area()
	_check(fresh.notice_board_line() == "No booking." and fresh_events.dissolved == 0)


func _departure_frees_the_leavers_pick_and_hold() -> void:
	# Under --min-players=2 a booking of three survives one departure, so the leaver's role
	# can be seen to come free while the column is still awake.
	var room := RoomStateScript.new(2)
	room.arrive(EMIL, "Emil")
	room.arrive(ASTRA, "Astra")
	room.arrive(BROTHER, "Brother")
	for id in [EMIL, ASTRA, BROTHER]:
		room.pick(id, RoomStateScript.MONSTER_TRUCK)
	room.take(BROTHER, RoomStateScript.DRIVER)
	_check(not room.take(EMIL, RoomStateScript.DRIVER))
	room.leave(BROTHER)
	_check(room.has_booking())
	_check(room.holder_of(RoomStateScript.DRIVER) == null, "the leaver's hold is free")
	_check(room.take(EMIL, RoomStateScript.DRIVER))
	# Coming back is a fresh arrival: no pick, no hold, the palette that is free.
	room.arrive(BROTHER, "Brother")
	_check(room.player(BROTHER).pick == &"")
	_check(room.player(BROTHER).hold == &"")
	_check(room.player(BROTHER).palette == 3)
	# Under the default N the leaver's pick going with them is what dissolves the booking.
	room = _booked_room()
	room.leave(EMIL)
	_check(not room.has_booking())
	room.arrive(EMIL, "Emil")
	_check(room.player(EMIL).pick == &"" and not room.has_booking())


func _min_players_comes_from_the_command_line() -> void:
	_check(RoomStateScript.min_players_from_args(PackedStringArray()) == 3)
	_check(RoomStateScript.min_players_from_args(PackedStringArray(["--transport=enet"])) == 3)
	_check(RoomStateScript.min_players_from_args(PackedStringArray(["--min-players=2"])) == 2)
	_check(RoomStateScript.min_players_from_args(PackedStringArray(["--transport=enet", "--min-players=1"])) == 1)
	# Never fewer than one, never more than the room holds, never garbage.
	_check(RoomStateScript.min_players_from_args(PackedStringArray(["--min-players=0"])) == 1)
	_check(RoomStateScript.min_players_from_args(PackedStringArray(["--min-players=7"])) == 3)
	_check(RoomStateScript.min_players_from_args(PackedStringArray(["--min-players=two"])) == 3)
	_check(RoomStateScript.min_players_from_args(PackedStringArray(["--min-players"])) == 3)


## The host replicates the whole record; a guest's copy renders the same facts from it.
func _replicated_state_round_trips() -> void:
	var host := _room_one_seat_short()
	host.sit(BROTHER, 3)
	host.tick(1.2)
	_check(host.notice_board_line() == "Monster truck. 2.")
	var guest := RoomStateScript.new()
	guest.restore(host.snapshot())
	_check(guest.player_count() == 3)
	_check(guest.min_players == 3)
	_check(guest.player(ASTRA).display_name == "Astra" and guest.player(ASTRA).palette == 2)
	_check(guest.players[2].steam_id == BROTHER, "arrival order is kept")
	_check(guest.booking() == RoomStateScript.MONSTER_TRUCK)
	_check(guest.holder_of(RoomStateScript.DRIVER).display_name == "Emil")
	_check(guest.random_holders().size() == 2)
	_check(guest.player(BROTHER).chair == 3)
	_check(guest.is_counting_down())
	_check(guest.notice_board_line() == "Monster truck. 2.")
	_check(guest.launched_roles().is_empty())
	# The snapshot is plain data a reliable RPC can carry.
	var data: Dictionary = host.snapshot()
	_check(data == host.snapshot(), "snapshots of the same record are equal")
	_check(str_to_var(var_to_str(data)) == data, "plain data survives serialisation")
	# After launch the deal travels too.
	host.tick(2.0)
	guest.restore(host.snapshot())
	_check(guest.launched_roles() == host.launched_roles() and not guest.launched_roles().is_empty())
	# Restoring over an older copy replaces it entirely.
	host.return_from_test_area()
	host.leave(ASTRA)
	guest.restore(host.snapshot())
	_check(guest.player_count() == 2 and guest.player(ASTRA) == null)
	_check(guest.notice_board_line() == "Waiting for 1.")
	_check(not guest.is_counting_down() and guest.launched_roles().is_empty())

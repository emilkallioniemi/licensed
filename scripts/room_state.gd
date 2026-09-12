class_name RoomState
extends RefCounted
## The host-owned record of the waiting room and every rule of it (spec section 0). The host
## is the only writer: it applies commands in receive order and replicates the whole record;
## every view renders from it and never mutates it. No scene, node, Steam, or transport here;
## this is the slice's one testing seam (`tests/verify_room_state.gd`).

## A booking formed: `vehicle` is now booked and the role column wakes.
signal booking_formed(vehicle: StringName)
## The booking dissolved (a drop, a switch, or a departure); every hold was released.
signal booking_dissolved
## The ready-up fired: the examiner calls the booking and the notice board starts counting.
signal countdown_started
## Something the ready-up needs stopped holding mid-count; the notice board goes back to
## its state line and nothing is announced.
signal countdown_cancelled
## The count reached its end: `roles` maps every Steam id to the named role they leave with,
## the deal for Random holders included. The room fades and the test area loads.
signal launched(vehicle: StringName, roles: Dictionary)

## A room holds exactly three players, whatever the room waits for (ADR-0001).
const CAPACITY := 3
## The count the room waits for by default; `--min-players=N` lowers it (spec section 11).
const DEFAULT_MIN_PLAYERS := 3
## Seconds from the ready-up firing to the launch, counted on the notice board.
const COUNTDOWN_SECONDS := 3.0

const MONSTER_TRUCK := &"monster_truck"
## The vehicles the booking board offers this slice; the other rows are locked and a pick of
## them is refused, so a click on a locked row does nothing wherever it is sent from.
const BOOKABLE_VEHICLES: Array[StringName] = [MONSTER_TRUCK]
## How the notice board names a vehicle: "Monster truck. 3."
const VEHICLE_NAMES := {MONSTER_TRUCK: "Monster truck"}

const DRIVER := &"driver"
const SPOTTER := &"spotter"
const NAVIGATOR := &"navigator"
## Not a fourth role: holding Random means being dealt whichever named role is left at launch.
const RANDOM := &"random"
## The monster truck's three roles; the role column shows the booked vehicle's roles, and only
## the monster truck can be booked this slice.
const NAMED_ROLES: Array[StringName] = [DRIVER, SPOTTER, NAVIGATOR]

## The count the room waits for: booking, roles, seated, and the notice board's "of N".
var min_players: int
## The rows a pick may land on.
var bookable_vehicles: Array[StringName]
## Every player in the room, in arrival order.
var players: Array[Player] = []

## Seconds left on the count while it runs; negative when it is not running.
var _countdown_remaining := -1.0
## Steam id to named role, set by the deal at launch; empty until then and after a return.
var _launched_roles: Dictionary = {}


func _init(waits_for: int = DEFAULT_MIN_PLAYERS, bookable: Array[StringName] = BOOKABLE_VEHICLES) -> void:
	min_players = waits_for
	bookable_vehicles = bookable


## The count the room waits for, read from the user args after `--`: `--min-players=N`, with
## N kept between one and the room's capacity. Anything else means three (spec section 11).
static func min_players_from_args(args: PackedStringArray) -> int:
	const FLAG := "--min-players="
	for arg in args:
		if arg.begins_with(FLAG):
			var value := arg.substr(FLAG.length())
			if value.is_valid_int():
				return clampi(value.to_int(), 1, CAPACITY)
	return DEFAULT_MIN_PLAYERS


func player_count() -> int:
	return players.size()


## The player with this Steam id, or null when nobody in the room has it.
func player(steam_id: int) -> Player:
	for occupant in players:
		if occupant.steam_id == steam_id:
			return occupant
	return null


## A player walks in. Takes the lowest free palette, so survivors of a departure keep theirs.
func arrive(steam_id: int, display_name: String) -> bool:
	if players.size() >= CAPACITY or player(steam_id) != null:
		return false
	var before := booking()
	players.append(Player.new(steam_id, display_name, _free_palette()))
	_after_command(before, false)
	return true


## A player walks out. Their pick and hold go with them.
func leave(steam_id: int) -> bool:
	var leaver := player(steam_id)
	if leaver == null:
		return false
	var before := booking()
	players.erase(leaver)
	_after_command(before, true)
	return true


## Pick a vehicle, or switch to it from the current pick. Same pick again changes nothing.
func pick(steam_id: int, vehicle: StringName) -> bool:
	var picker := player(steam_id)
	if picker == null or not bookable_vehicles.has(vehicle) or picker.pick == vehicle:
		return false
	var before := booking()
	picker.pick = vehicle
	_after_command(before, true)
	return true


## Drop the current pick.
func drop_pick(steam_id: int) -> bool:
	var picker := player(steam_id)
	if picker == null or not picker.has_a_pick():
		return false
	var before := booking()
	picker.pick = &""
	_after_command(before, true)
	return true


## Take a role, or swap to it from the one held. Dead without a booking; a taken named role
## refuses a second taker, which is how a same-frame tie resolves in receive order. A swap
## leaves every player holding a role, so it is not one of the count's cancels.
func take(steam_id: int, role: StringName) -> bool:
	var taker := player(steam_id)
	if taker == null or not has_booking() or taker.hold == role:
		return false
	if role != RANDOM and (not NAMED_ROLES.has(role) or holder_of(role) != null):
		return false
	taker.hold = role
	_after_command(booking(), false)
	return true


## Drop the held role.
func drop_hold(steam_id: int) -> bool:
	var holder := player(steam_id)
	if holder == null or not holder.holds_a_role():
		return false
	holder.hold = &""
	_after_command(booking(), true)
	return true


## Sit in a chair: the ready-up. Any chair, first come; the chair never refuses for any other
## reason, in any room state. Changing chairs means standing first.
func sit(steam_id: int, chair: int) -> bool:
	var sitter := player(steam_id)
	if sitter == null or sitter.is_seated() or chair < 1 or chair > CAPACITY:
		return false
	for occupant in players:
		if occupant.chair == chair:
			return false
	sitter.chair = chair
	_after_command(booking(), false)
	return true


## Stand up, taking the ready-up back.
func stand(steam_id: int) -> bool:
	var sitter := player(steam_id)
	if sitter == null or not sitter.is_seated():
		return false
	sitter.chair = 0
	_after_command(booking(), true)
	return true


## Everyone is back from the test area: no picks, no holds, nobody seated, nothing dealt, so
## the ritual runs again from the start. Whoever is still in the room keeps their palette.
func return_from_test_area() -> void:
	var before := booking()
	for occupant in players:
		occupant.pick = &""
		occupant.hold = &""
		occupant.chair = 0
	_countdown_remaining = -1.0
	_launched_roles = {}
	_after_command(before, false)


## Advance the countdown by `delta` seconds. At the end of the count the Random holders are
## dealt the remaining named roles and `launched` fires; nothing is dealt before that.
func tick(delta: float) -> void:
	if not is_counting_down():
		return
	_countdown_remaining -= delta
	if _countdown_remaining > 0.0:
		return
	_countdown_remaining = -1.0
	_launched_roles = _deal()
	launched.emit(booking(), _launched_roles)


func has_booking() -> bool:
	return booking() != &""


## The vehicle at least N players have picked, or empty. Nobody can arrive at a room of
## three, so under the default N an arrival cannot touch it; under a lower N it must not.
func booking() -> StringName:
	var picks := {}
	for occupant in players:
		if not occupant.has_a_pick():
			continue
		picks[occupant.pick] = picks.get(occupant.pick, 0) + 1
		if picks[occupant.pick] >= min_players:
			return occupant.pick
	return &""


## The one player holding this named role, or null when it is free (or for RANDOM).
func holder_of(role: StringName) -> Player:
	if role == RANDOM:
		return null
	for occupant in players:
		if occupant.hold == role:
			return occupant
	return null


## Every player holding Random, in arrival order.
func random_holders() -> Array[Player]:
	var holders: Array[Player] = []
	for occupant in players:
		if occupant.hold == RANDOM:
			holders.append(occupant)
	return holders


func is_counting_down() -> bool:
	return _countdown_remaining > 0.0


## The number the notice board shows while counting: 3, 2, 1.
func countdown_count() -> int:
	return maxi(1, ceili(_countdown_remaining))


## Every player's named role once the count has ended, the deal included; empty before
## launch and again after the return from the test area.
func launched_roles() -> Dictionary:
	return _launched_roles


## The one line of signage on the notice board: the first thing the room is still waiting
## for, counting out of N (spec section 7). Signage register: short, full stop, nobody addressed.
## Under a lowered N a room can hold more players than N; every one of them must be ready, so
## the count is then out of those present.
func notice_board_line() -> String:
	if players.size() < min_players:
		return "Waiting for %d." % (min_players - players.size())
	if not has_booking():
		return "No booking."
	var out_of := maxi(min_players, players.size())
	var holding := 0
	var seated := 0
	for occupant in players:
		if occupant.holds_a_role():
			holding += 1
		if occupant.is_seated():
			seated += 1
	if holding < players.size():
		return "Roles: %d of %d." % [holding, out_of]
	if seated < players.size():
		return "Seated: %d of %d." % [seated, out_of]
	return "%s. %d." % [VEHICLE_NAMES.get(booking(), String(booking())), countdown_count()]


## The whole record as plain data for the host to replicate over a reliable RPC.
func snapshot() -> Dictionary:
	var occupants: Array[Dictionary] = []
	for occupant in players:
		occupants.append(occupant.to_data())
	return {
		"min_players": min_players,
		"players": occupants,
		"countdown_remaining": _countdown_remaining,
		"launched_roles": _launched_roles.duplicate(),
	}


## Replace this record with a replicated `snapshot()`. Silent: a guest's copy renders the
## facts and raises no events of its own.
func restore(data: Dictionary) -> void:
	min_players = data["min_players"]
	players.clear()
	for occupant in data["players"]:
		players.append(Player.from_data(occupant))
	_countdown_remaining = data["countdown_remaining"]
	_launched_roles = data["launched_roles"].duplicate()


## Every command ends here: the booking events for a change from `booking_before`, then the
## count. `breaks_the_count` names the commands the spec lists as cancels (a stand, a pick
## change, a hold drop, a departure): they stop a running count even when every condition
## still holds, and the ready-up then arms it again from the top.
func _after_command(booking_before: StringName, breaks_the_count: bool) -> void:
	_raise_booking_events(booking_before)
	if breaks_the_count and is_counting_down():
		_cancel_countdown()
	_arm_or_cancel_countdown()


## Raises the booking events for a change from `before` to the booking as it now stands,
## releasing every hold when it dissolves.
func _raise_booking_events(before: StringName) -> void:
	var after := booking()
	if before == after:
		return
	if before != &"":
		for occupant in players:
			occupant.hold = &""
		booking_dissolved.emit()
	if after != &"":
		booking_formed.emit(after)


## The ready-up, evaluated on every change: N players, a booking, every player holding a named
## role or Random, every player seated starts the count; any of them failing cancels it.
func _arm_or_cancel_countdown() -> void:
	var ready := _is_ready()
	if ready and not is_counting_down() and _launched_roles.is_empty():
		_countdown_remaining = COUNTDOWN_SECONDS
		countdown_started.emit()
	elif not ready and is_counting_down():
		_cancel_countdown()


func _cancel_countdown() -> void:
	_countdown_remaining = -1.0
	countdown_cancelled.emit()


func _is_ready() -> bool:
	if players.size() < min_players or not has_booking():
		return false
	for occupant in players:
		if not occupant.holds_a_role() or not occupant.is_seated():
			return false
	return true


## Every player's named role at launch: named holders keep theirs; Random holders are dealt
## the remaining named roles, shuffled, one each, in arrival order.
func _deal() -> Dictionary:
	var remaining := NAMED_ROLES.duplicate()
	var roles := {}
	for occupant in players:
		if occupant.hold != RANDOM:
			roles[occupant.steam_id] = occupant.hold
			remaining.erase(occupant.hold)
	remaining.shuffle()
	for holder in random_holders():
		roles[holder.steam_id] = remaining.pop_front()
	return roles


func _free_palette() -> int:
	var taken: Array[int] = []
	for occupant in players:
		taken.append(occupant.palette)
	for palette in range(1, CAPACITY + 1):
		if not taken.has(palette):
			return palette
	return 0


## One player in the room, in arrival order. Palette 1/2/3 is the arrival slot's fixed colour.
class Player extends RefCounted:
	var steam_id: int
	var display_name: String
	var palette: int
	## The vehicle this player has picked on the booking board, or empty.
	var pick: StringName = &""
	## The role this player holds at the role pickup (a named role or RANDOM), or empty.
	var hold: StringName = &""
	## The chair (1 to 3) this player sits in, which is the ready-up, or 0 when standing.
	var chair: int = 0

	func _init(id: int, name: String, palette_number: int) -> void:
		steam_id = id
		display_name = name
		palette = palette_number

	static func from_data(data: Dictionary) -> Player:
		var restored := Player.new(data["steam_id"], data["display_name"], data["palette"])
		restored.pick = data["pick"]
		restored.hold = data["hold"]
		restored.chair = data["chair"]
		return restored

	func to_data() -> Dictionary:
		return {
			"steam_id": steam_id,
			"display_name": display_name,
			"palette": palette,
			"pick": pick,
			"hold": hold,
			"chair": chair,
		}

	func has_a_pick() -> bool:
		return pick != &""

	func holds_a_role() -> bool:
		return hold != &""

	func is_seated() -> bool:
		return chair != 0

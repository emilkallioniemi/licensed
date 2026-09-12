class_name RoomState
extends RefCounted
## The host-owned record of the waiting room and every rule of it (spec section 0). The host
## is the only writer: it applies commands in receive order and replicates the whole record;
## every view renders from it and never mutates it. No scene, node, Steam, or transport here;
## this is the slice's one testing seam (`tests/verify_room_state.gd`).

## A room holds exactly three players, whatever the room waits for (ADR-0001).
const CAPACITY := 3
## The count the room waits for by default; `--min-players=N` lowers it (spec section 11).
const DEFAULT_MIN_PLAYERS := 3

const MONSTER_TRUCK := &"monster_truck"
## The vehicles the booking board offers this slice; the other rows are locked and a pick of
## them is refused, so a click on a locked row does nothing wherever it is sent from.
const BOOKABLE_VEHICLES: Array[StringName] = [MONSTER_TRUCK]

## A booking formed: `vehicle` is now booked and the role column wakes.
signal booking_formed(vehicle: StringName)
## The booking dissolved (a drop, a switch, or a departure); every hold was released.
signal booking_dissolved


## One player in the room, in arrival order. Palette 1/2/3 is the arrival slot's fixed colour.
class Player extends RefCounted:
	var steam_id: int
	var display_name: String
	var palette: int
	## The vehicle this player has picked on the booking board, or empty.
	var pick: StringName = &""

	func _init(id: int, name: String, palette_number: int) -> void:
		steam_id = id
		display_name = name
		palette = palette_number


## The count the room waits for: booking, roles, seated, and the notice board's "of N".
var min_players: int
## The rows a pick may land on.
var bookable_vehicles: Array[StringName]
## Every player in the room, in arrival order.
var players: Array[Player] = []


func _init(waits_for: int = DEFAULT_MIN_PLAYERS, bookable: Array[StringName] = BOOKABLE_VEHICLES) -> void:
	min_players = waits_for
	bookable_vehicles = bookable


func player_count() -> int:
	return players.size()


## The player with this Steam id, or null when nobody in the room has it.
func player(steam_id: int) -> Player:
	for candidate in players:
		if candidate.steam_id == steam_id:
			return candidate
	return null


## A player walks in. Takes the lowest free palette, so survivors of a departure keep theirs.
func arrive(steam_id: int, display_name: String) -> bool:
	if players.size() >= CAPACITY or player(steam_id) != null:
		return false
	players.append(Player.new(steam_id, display_name, _free_palette()))
	return true


## A player walks out. Their pick goes with them.
func leave(steam_id: int) -> bool:
	var leaver := player(steam_id)
	if leaver == null:
		return false
	var before := booking()
	players.erase(leaver)
	_settle_booking(before)
	return true


## Pick a vehicle, or switch to it from the current pick. Same pick again changes nothing.
func pick(steam_id: int, vehicle: StringName) -> bool:
	var picker := player(steam_id)
	if picker == null or not bookable_vehicles.has(vehicle) or picker.pick == vehicle:
		return false
	var before := booking()
	picker.pick = vehicle
	_settle_booking(before)
	return true


## Drop the current pick.
func drop_pick(steam_id: int) -> bool:
	var picker := player(steam_id)
	if picker == null or picker.pick == &"":
		return false
	var before := booking()
	picker.pick = &""
	_settle_booking(before)
	return true


func has_booking() -> bool:
	return booking() != &""


## The vehicle at least N players have picked, or empty. Nobody can arrive at a room of
## three, so under the default N an arrival cannot touch it; under a lower N it must not.
func booking() -> StringName:
	var picks := {}
	for occupant in players:
		if occupant.pick == &"":
			continue
		picks[occupant.pick] = picks.get(occupant.pick, 0) + 1
		if picks[occupant.pick] >= min_players:
			return occupant.pick
	return &""


## Raises the booking events for a change from `before` to the booking as it now stands.
func _settle_booking(before: StringName) -> void:
	var after := booking()
	if before == after:
		return
	if before != &"":
		booking_dissolved.emit()
	if after != &"":
		booking_formed.emit(after)


func _free_palette() -> int:
	var taken: Array[int] = []
	for occupant in players:
		taken.append(occupant.palette)
	for palette in range(1, CAPACITY + 1):
		if not taken.has(palette):
			return palette
	return 0

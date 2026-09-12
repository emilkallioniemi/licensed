class_name Palettes
extends RefCounted
## The three fixed learner palettes, one per arrival slot 01/02/03 (host is 01). Chosen from
## the kit's colours to match the numbered chairs' decor; the shirt is the flood colour
## every later mark (chips, strips, lamps, pips, occupied chairs) will use. Not a
## customisation system: the player never chooses.

## Shirt / trousers / skin / hair / shoes / accent, the six exports on the kit visual.
const SLOTS := {
	1: {
		"shirt": Color("477c79"),
		"trousers": Color("29494c"),
		"skin": Color("d3a78c"),
		"hair": Color("493429"),
		"shoes": Color("3c4248"),
		"accent": Color("f4ecd7"),
	},
	2: {
		"shirt": Color("dbaa51"),
		"trousers": Color("555f73"),
		"skin": Color("d3a78c"),
		"hair": Color("493429"),
		"shoes": Color("3c4248"),
		"accent": Color("477c79"),
	},
	3: {
		"shirt": Color("b96550"),
		"trousers": Color("29494c"),
		"skin": Color("d3a78c"),
		"hair": Color("493429"),
		"shoes": Color("3c4248"),
		"accent": Color("facf76"),
	},
}


## The kit visual's six colour exports for this arrival slot.
static func of(slot: int) -> Dictionary:
	return SLOTS.get(slot, SLOTS[1])


## The shirt colour: the flood used everywhere a player is marked.
static func flood_color(slot: int) -> Color:
	return of(slot)["shirt"]


## Paints a kit learner visual (`assets/slice_0/player/learner.tscn`) as this slot.
static func apply(visual: Node, slot: int) -> void:
	var colors := of(slot)
	visual.set("shirt_color", colors["shirt"])
	visual.set("trousers_color", colors["trousers"])
	visual.set("skin_color", colors["skin"])
	visual.set("hair_color", colors["hair"])
	visual.set("shoes_color", colors["shoes"])
	visual.set("accent_color", colors["accent"])


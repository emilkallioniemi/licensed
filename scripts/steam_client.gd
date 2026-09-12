extends Node
## Autoload `SteamClient`: initialises Steamworks against app 480 before any scene runs and
## holds the local player's identity. Steam is usable only when `is_running()` is true;
## every other `Steam.*` call in the game is gated on it (spec section 1, ADR-0002).

## Valve's SpaceWar test app. Passing it to `steamInitEx` sets the app id environment,
## so no `steam_appid.txt` is shipped or committed anywhere.
const APP_ID := 480
## The rich-presence key that tells a friend's reception desk this process is our game and
## not any other "Spacewar".
const RICH_PRESENCE_KEY := "licensed"
const RICH_PRESENCE_VALUE := "1"

## One of `Steam.SteamAPIInitResult`; `STEAM_API_INIT_RESULT_OK` means Steam is usable.
var init_status: int = Steam.STEAM_API_INIT_RESULT_FAILED_GENERIC
## Valve's own description of the init result, shown beneath the signage when Steam is not running.
var init_message: String = ""
## The local player's 64-bit Steam id; 0 until init succeeds.
var steam_id: int = 0
## The local player's Steam display name; empty until init succeeds.
var persona_name: String = ""
## The local player's medium (64 px) avatar; null until `avatar_loaded` has delivered it.
var avatar: ImageTexture


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _ready() -> void:
	var result: Dictionary = Steam.steamInitEx(APP_ID, true)
	init_status = result.get("status", Steam.STEAM_API_INIT_RESULT_FAILED_GENERIC)
	init_message = result.get("verbal", "")
	if not is_running():
		print("SteamClient: Steam is not running (status %d: %s)" % [init_status, init_message])
		return
	steam_id = Steam.getSteamID()
	persona_name = Steam.getPersonaName()
	Steam.setRichPresence(RICH_PRESENCE_KEY, RICH_PRESENCE_VALUE)
	Steam.avatar_loaded.connect(_on_avatar_loaded)
	Steam.getPlayerAvatar(Steam.AVATAR_MEDIUM)
	print("SteamClient: %s (%d) is at the test centre; rich presence %s=%s" % [
		persona_name, steam_id, RICH_PRESENCE_KEY, RICH_PRESENCE_VALUE,
	])


func is_running() -> bool:
	return init_status == Steam.STEAM_API_INIT_RESULT_OK


## Turns the RGBA byte buffer `avatar_loaded` delivers into a texture. Avatars are square.
static func avatar_texture_from(width: int, rgba: PackedByteArray) -> ImageTexture:
	var image := Image.create_from_data(width, width, false, Image.FORMAT_RGBA8, rgba)
	return ImageTexture.create_from_image(image)


func _on_avatar_loaded(avatar_id: int, width: int, rgba: PackedByteArray) -> void:
	if avatar_id != steam_id:
		return
	avatar = avatar_texture_from(width, rgba)
	print("SteamClient: avatar loaded, %d x %d" % [width, width])

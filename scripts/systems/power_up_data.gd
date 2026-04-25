extends Resource
class_name PowerUpData

enum PowerUpType { WEAPON_UPGRADE, HEALTH, SHIELD, SCORE_BONUS, SPEED_BOOST }

@export var display_name: String = "Power Up"
@export var power_up_type: PowerUpType = PowerUpType.WEAPON_UPGRADE
@export var weapon_type: String = ""
@export var spread: int = 1
@export var damage_boost: int = 0
@export var fire_rate_boost: float = 0.0
@export var duration: float = 0.0
@export var restore_health: int = 0

@export var color: Color = Color(1, 1, 0, 1)
@export var icon_texture: Texture2D

func _get_icon() -> Texture2D:
	return icon_texture

func get_description() -> String:
	var desc = display_name
	
	if weapon_type != "":
		desc += "\n" + weapon_type
	if restore_health > 0:
		desc += "\n+HP"
	if duration > 0:
		desc += " (" + str(duration) + "s)"
	
	return desc
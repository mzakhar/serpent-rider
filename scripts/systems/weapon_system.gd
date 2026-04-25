extends Node2D
class_name WeaponSystem

signal weapon_fired(projectile: Projectile)
signal weapon_changed(new_weapon: String)
signal power_up_applied(power_up)
signal fire_rate_changed(new_rate: float)

@export var fire_rate: float = 0.25
@export var projectile_scene: PackedScene
@export var projectile_damage: int = 10
@export var projectile_speed: float = 350.0
@export var spread_count: int = 1
@export var spread_angle: float = 0.0

var current_weapon: String = "fireball"
var fire_cooldown: float = 0.0
var is_firing: bool = false

var available_weapons: Dictionary = {
	"fireball": {
		"scene": null,
		"damage": 10,
		"speed": 350.0,
		"fire_rate": 0.25,
		"spread": 0.0,
		"pierce": 0
	},
	"double": {
		"scene": null,
		"damage": 15,
		"speed": 350.0,
		"fire_rate": 0.2,
		"spread": 2,
		"pierce": 0
	},
	"spread": {
		"scene": null,
		"damage": 8,
		"speed": 350.0,
		"fire_rate": 0.3,
		"spread": 3,
		"spread_angle": 15.0,
		"pierce": 1
	},
	"wave": {
		"scene": null,
		"damage": 12,
		"speed": 300.0,
		"fire_rate": 0.35,
		"spread": 1,
		"pierce": 2
	},
	"pierce": {
		"scene": null,
		"damage": 25,
		"speed": 400.0,
		"fire_rate": 0.5,
		"spread": 1,
		"pierce": 5
	}
}

func _ready() -> void:
	set_weapon("fireball")

func _process(delta: float) -> void:
	if is_firing and fire_cooldown <= 0:
		fire()
		fire_cooldown = fire_rate
	elif fire_cooldown > 0:
		fire_cooldown -= delta

func start_firing() -> void:
	is_firing = true

func stop_firing() -> void:
	is_firing = false

func fire() -> void:
	if not projectile_scene:
		return
	
	var fire_direction = Vector2.RIGHT
	
	for i in range(spread_count):
		var angle_offset = 0.0
		if spread_count > 1:
			angle_offset = spread_angle * (float(i) - (spread_count - 1) / 2.0)
		
		var rotated_direction = fire_direction.rotated(deg_to_rad(angle_offset))
		spawn_projectile(rotated_direction)

func spawn_projectile(direction: Vector2) -> void:
	var projectile = projectile_scene.instantiate()
	projectile.global_position = global_position
	projectile.set_direction(direction)
	projectile.damage = projectile_damage
	projectile.speed = projectile_speed
	projectile.source_team = "player"
	projectile.pierce_count = available_weapons[current_weapon].get("pierce", 0)
	
	get_tree().current_scene.add_child(projectile)
	weapon_fired.emit(projectile)

func set_weapon(weapon_name: String) -> void:
	if available_weapons.has(weapon_name):
		current_weapon = weapon_name
		var weapon_data = available_weapons[weapon_name]
		
		projectile_damage = weapon_data["damage"]
		projectile_speed = weapon_data["speed"]
		fire_rate = weapon_data["fire_rate"]
		spread_count = weapon_data["spread"]
		spread_angle = weapon_data.get("spread_angle", 0.0)
		
		weapon_changed.emit(weapon_name)
		fire_rate_changed.emit(fire_rate)
	else:
		push_warning("Weapon not found: ", weapon_name)

func apply_power_up(power_up: PowerUpData) -> void:
	if power_up.weapon_type != "":
		set_weapon(power_up.weapon_type)
	
	if power_up.duration > 0:
		await get_tree().create_timer(power_up.duration).timeout
		if is_instance_valid(self):
			set_weapon("fireball")
	
	power_up_applied.emit(power_up)
	EventBus.power_up_collected.emit(power_up)

func get_current_weapon() -> String:
	return current_weapon
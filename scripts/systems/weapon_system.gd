extends Node2D
class_name WeaponSystem

signal weapon_fired(projectile: Projectile)
signal weapon_changed(new_weapon: String)
signal power_up_applied(power_up: PowerUpData)
signal fire_rate_changed(new_rate: float)
signal charge_level_changed(level: int, max_level: int)

@export var fire_rate: float = 0.25
@export var projectile_scene: PackedScene
@export var projectile_damage: int = 10
@export var projectile_speed: float = 350.0
@export var spread_count: int = 1
@export var spread_angle: float = 0.0

@export var charge_enabled: bool = true
@export var max_charge_level: int = 4
@export var charge_time: float = 1.5

var current_weapon: String = "fireball"
var fire_cooldown: float = 0.0
var is_firing: bool = false
var is_charging: bool = false
var charge_level: int = 0
var charge_timer: float = 0.0
var charge_accumulator: int = 0

var dragon_breed_weapons: Dictionary = {
	"fireball": {
		"damage": 10,
		"speed": 350.0,
		"fire_rate": 0.25,
		"spread": 1,
		"pierce": 0,
		"is_chargeable": true,
		"charge_damage": [10, 15, 25, 40, 60],
		"charge_speed": [350, 350, 400, 450, 500],
		"charge_size": [1.0, 1.2, 1.5, 2.0, 2.5]
	},
	"flame": {
		"damage": 8,
		"speed": 200.0,
		"fire_rate": 0.1,
		"spread": 1,
		"pierce": 3,
		"is_chargeable": false,
		"projectile_scene": "res://scenes/projectiles/flame_breath.tscn"
	},
	"crescent": {
		"damage": 12,
		"speed": 280.0,
		"fire_rate": 0.35,
		"spread": 8,
		"pierce": 1,
		"is_chargeable": false,
		"projectile_scene": "res://scenes/projectiles/crescent.tscn"
	},
	"homing": {
		"damage": 20,
		"speed": 250.0,
		"fire_rate": 0.5,
		"spread": 4,
		"pierce": 0,
		"is_chargeable": false,
		"projectile_scene": "res://scenes/projectiles/homing_dragon.tscn",
		"homing_strength": 3.0,
		"homing_duration": 3.0
	},
	"lightning": {
		"damage": 15,
		"speed": 400.0,
		"fire_rate": 0.4,
		"spread": 1,
		"pierce": 2,
		"is_chargeable": false,
		"projectile_scene": "res://scenes/projectiles/lightning.tscn",
		"targeting": "downward"
	},
	"double": {
		"damage": 15,
		"speed": 350.0,
		"fire_rate": 0.2,
		"spread": 2,
		"pierce": 0,
		"is_chargeable": false
	},
	"spread": {
		"damage": 8,
		"speed": 350.0,
		"fire_rate": 0.3,
		"spread": 3,
		"spread_angle": 15.0,
		"pierce": 1,
		"is_chargeable": false
	},
	"pierce": {
		"damage": 25,
		"speed": 400.0,
		"fire_rate": 0.5,
		"spread": 1,
		"pierce": 5,
		"is_chargeable": false
	}
}

var base_damage: int = 10
var base_speed: float = 350.0
var base_fire_rate: float = 0.25

func _ready() -> void:
	base_damage = projectile_damage
	base_speed = projectile_speed
	base_fire_rate = fire_rate
	set_weapon("fireball")

func _process(delta: float) -> void:
	update_charge(delta)
	
	if is_firing and fire_cooldown <= 0:
		fire()
		fire_cooldown = fire_rate
	elif fire_cooldown > 0:
		fire_cooldown -= delta

func update_charge(delta: float) -> void:
	if not charge_enabled:
		return
	
	if is_charging and charge_level < max_charge_level:
		charge_timer += delta
		
		var new_level = min(int(charge_timer / charge_time), max_charge_level)
		if new_level != charge_level:
			charge_level = new_level
			charge_level_changed.emit(charge_level, max_charge_level)
	
	if not is_charging and charge_level > 0:
		fire_charged_shot()
		charge_level = 0
		charge_timer = 0.0
		charge_level_changed.emit(charge_level, max_charge_level)

func start_charging() -> void:
	if charge_enabled and dragon_breed_weapons[current_weapon].get("is_chargeable", true):
		is_charging = true
		charge_timer = 0.0
		charge_level = 0

func fire_charged_shot() -> void:
	if current_weapon != "fireball":
		return
	
	var base_proj = _get_base_projectile()
	if not base_proj:
		return
	
	var cd = dragon_breed_weapon_data()
	var damages = cd.get("charge_damage", [10, 15, 25, 40, 60])
	var speeds = cd.get("charge_speed", [350, 350, 400, 450, 500])
	var sizes = cd.get("charge_size", [1.0, 1.2, 1.5, 2.0, 2.5])
	
	var idx = min(charge_level, damages.size() - 1)
	spawn_charged_projectile(damages[idx], speeds[idx], sizes[idx])

func spawn_charged_projectile(dmg: float, spd: float, sz: float) -> void:
	var base_proj = _get_base_projectile()
	if not base_proj:
		return
	
	var projectile = base_proj.instantiate()
	projectile.global_position = global_position
	projectile.set_direction(Vector2.RIGHT)
	projectile.damage = int(dmg)
	projectile.speed = spd
	projectile.source_team = "player"
	
	get_tree().current_scene.add_child(projectile)
	weapon_fired.emit(projectile)

func _get_base_projectile() -> PackedScene:
	if projectile_scene:
		return projectile_scene
	return load("res://scenes/projectiles/fireball.tscn")

func start_firing() -> void:
	is_firing = true
	start_charging()

func stop_firing() -> void:
	start_charging()
	is_firing = false

func fire() -> void:
	var weapon_data = dragon_breed_weapons.get(current_weapon, dragon_breed_weapons["fireball"])
	var is_homing = current_weapon == "homing"
	var is_crescent = current_weapon == "crescent"
	var is_lightning = current_weapon == "lightning"
	var is_flame = current_weapon == "flame"
	
	var proj_scene_path = weapon_data.get("projectile_scene", "")
	var proj_scene: PackedScene
	if proj_scene_path and ResourceLoader.exists(proj_scene_path):
		proj_scene = load(proj_scene_path)
	else:
		proj_scene = _get_base_projectile()
	
	if is_crescent:
		fire_crescent_pattern(weapon_data)
	elif is_lightning:
		fire_lightning(weapon_data)
	elif is_flame:
		fire_flame(weapon_data)
	elif is_homing:
		fire_homing(weapon_data)
	else:
		var count = weapon_data.get("spread", 1)
		var angle = weapon_data.get("spread_angle", 0.0)
		fire_spread_pattern(count, angle, weapon_data)

func fire_crescent_pattern(data: Dictionary) -> void:
	var proj_scene = _get_projectile_scene(data)
	if not proj_scene:
		return
	
	var directions = [
		Vector2.RIGHT,
		Vector2.RIGHT.rotated(deg_to_rad(45)),
		Vector2.RIGHT.rotated(deg_to_rad(-45)),
		Vector2.RIGHT.rotated(deg_to_rad(90)),
		Vector2.RIGHT.rotated(deg_to_rad(-90)),
		Vector2.RIGHT.rotated(deg_to_rad(135)),
		Vector2.RIGHT.rotated(deg_to_rad(-135)),
		Vector2.RIGHT.rotated(deg_to_rad(180))
	]
	
	for dir in directions:
		spawn_dragon_breed_projectile(dir, data)

func fire_lightning(data: Dictionary) -> void:
	var dir = Vector2.DOWN
	spawn_dragon_breed_projectile(dir, data)

func fire_flame(data: Dictionary) -> void:
	var dir = Vector2.RIGHT
	spawn_dragon_breed_projectile(dir, data)

func fire_homing(data: Dictionary) -> void:
	for i in range(data.get("spread", 4)):
		var spread_dir = Vector2.RIGHT.rotated(deg_to_rad((i - 1.5) * 30))
		spawn_dragon_breed_projectile(spread_dir, data)

func fire_spread_pattern(count: int, angle: float, data: Dictionary) -> void:
	for i in range(count):
		var angle_offset = 0.0
		if count > 1:
			angle_offset = angle * (float(i) - (count - 1) / 2.0)
		var rotated_direction = Vector2.RIGHT.rotated(deg_to_rad(angle_offset))
		spawn_dragon_breed_projectile(rotated_direction, data)

func _get_projectile_scene(data: Dictionary) -> PackedScene:
	var path = data.get("projectile_scene", "")
	if path and ResourceLoader.exists(path):
		return load(path)
	return _get_base_projectile()

func spawn_dragon_breed_projectile(direction: Vector2, data: Dictionary) -> void:
	var proj_scene = _get_projectile_scene(data)
	if not proj_scene:
		return
	
	var projectile = proj_scene.instantiate()
	projectile.global_position = global_position
	projectile.set_direction(direction)
	projectile.damage = data.get("damage", projectile_damage)
	projectile.speed = data.get("speed", projectile_speed)
	projectile.source_team = "player"
	projectile.pierce_count = data.get("pierce", 0)
	
	get_tree().current_scene.add_child(projectile)
	weapon_fired.emit(projectile)

func spawn_projectile(direction: Vector2) -> void:
	var projectile = _get_base_projectile().instantiate()
	projectile.global_position = global_position
	projectile.set_direction(direction)
	projectile.damage = projectile_damage
	projectile.speed = projectile_speed
	projectile.source_team = "player"
	projectile.pierce_count = dragon_breed_weapons[current_weapon].get("pierce", 0)
	
	get_tree().current_scene.add_child(projectile)
	weapon_fired.emit(projectile)

func set_weapon(weapon_name: String) -> void:
	if dragon_breed_weapons.has(weapon_name):
		current_weapon = weapon_name
		var weapon_data = dragon_breed_weapons[weapon_name]
		
		base_damage = weapon_data["damage"]
		base_speed = weapon_data["speed"]
		base_fire_rate = weapon_data["fire_rate"]
		
		projectile_damage = base_damage
		projectile_speed = base_speed
		fire_rate = base_fire_rate
		spread_count = weapon_data.get("spread", 1)
		spread_angle = weapon_data.get("spread_angle", 0.0)
		
		charge_enabled = weapon_data.get("is_chargeable", true)
		
		weapon_changed.emit(weapon_name)
		fire_rate_changed.emit(fire_rate)
		charge_level_changed.emit(0, max_charge_level if charge_enabled else 0)
	else:
		push_warning("Weapon not found: ", weapon_name)

func dragon_breed_weapon_data() -> Dictionary:
	return dragon_breed_weapons.get(current_weapon, {})

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

func get_charge_level() -> int:
	return charge_level

func is_current_weapon_chargeable() -> bool:
	return dragon_breed_weapons[current_weapon].get("is_chargeable", true)

func get_max_charge_level() -> int:
	return max_charge_level
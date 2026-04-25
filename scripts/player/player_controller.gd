extends Node2D
class_name PlayerController

signal shield_state_changed(active: bool)
signal weapon_fired(direction: Vector2)
signal health_changed(current: int, max: int)

@export var dragon_scene: PackedScene

@onready var dragon_body: DragonBody = $DragonBody if has_node("DragonBody") else null
@onready var weapon_system: WeaponSystem = $WeaponSystem if has_node("WeaponSystem") else null
@onready var camera: Camera2D = $Camera2D if has_node("Camera2D") else null

var player_layer: int = 1

func _ready() -> void:
	setup_weapon_system()
	set_process_input(true)

func _process(delta: float) -> void:
	handle_firing_input()

func _input(event: InputEvent) -> void:
	pass

func handle_firing_input() -> void:
	if Input.is_action_pressed("fire_weapon"):
		if weapon_system:
			weapon_system.start_firing()
	elif Input.is_action_just_released("fire_weapon"):
		if weapon_system:
			weapon_system.stop_firing()

func setup_weapon_system() -> void:
	if not weapon_system:
		weapon_system = WeaponSystem.new()
		weapon_system.name = "WeaponSystem"
		add_child(weapon_system)
	
	var fireball_scene = load("res://scenes/projectiles/fireball.tscn")
	if fireball_scene:
		weapon_system.projectile_scene = fireball_scene
		weapon_system.set_weapon("fireball")

func get_dragon_position() -> Vector2:
	if dragon_body:
		return dragon_body.get_head_position()
	return global_position

func get_rider_position() -> Vector2:
	if dragon_body:
		return dragon_body.get_rider_position()
	return global_position

func get_tail_position() -> Vector2:
	if dragon_body:
		return dragon_body.get_tail_tip_position()
	return global_position

func is_shield_active() -> bool:
	if dragon_body:
		return dragon_body.shield_active
	return false

func take_damage(amount: int) -> void:
	if is_shield_active():
		return
	
	GameManager.take_damage(amount)
	health_changed.emit(GameManager.player_health, GameManager.player_max_health)

func heal(amount: int) -> void:
	GameManager.heal(amount)
	health_changed.emit(GameManager.player_health, GameManager.player_max_health)

func apply_power_up(power_up: PowerUpData) -> void:
	if weapon_system:
		weapon_system.apply_power_up(power_up)
	
	if power_up.restore_health > 0:
		heal(power_up.restore_health)
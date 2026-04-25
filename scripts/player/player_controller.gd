extends Node2D
class_name PlayerController

signal shield_state_changed(active: bool)
signal weapon_fired(direction: Vector2)
signal health_changed(current: int, max: int)
signal mounted_changed(is_mounted: bool)
signal platform_entered(platform)
signal platform_exited(platform)

@export var dragon_scene: PackedScene

enum PlayerMode { MOUNTED, ON_FOOT }
var mode: PlayerMode = PlayerMode.MOUNTED

@onready var dragon_body: DragonBody = $DragonBody if has_node("DragonBody") else null
@onready var weapon_system: WeaponSystem = $WeaponSystem if has_node("WeaponSystem") else null
@onready var rider_body: Area2D = $RiderBody if has_node("RiderBody") else null

var player_layer: int = 1
var current_platform: StaticBody2D = null
var can_dismount: bool = true

var on_foot_position: Vector2 = Vector2.ZERO

@onready var hitbox: Area2D = $Hitbox if has_node("Hitbox") else null

func _ready() -> void:
	setup_weapon_system()
	setup_rider_body()
	set_process_input(true)
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	if mode == PlayerMode.MOUNTED:
		handle_mounted_input(delta)
	elif mode == PlayerMode.ON_FOOT:
		handle_on_foot_input(delta)

func _process(delta: float) -> void:
	handle_firing_input()
	handle_dismount_input()
	handle_pause_input()

func handle_dismount_input() -> void:
	if Input.is_action_just_pressed("dismount"):
		handle_dismount()

func handle_pause_input() -> void:
	if Input.is_action_just_pressed("pause_game"):
		if GameManager.state == GameManager.GameState.PLAYING:
			GameManager.pause_game()
		elif GameManager.state == GameManager.GameState.PAUSED:
			GameManager.resume_game()

func handle_mounted_input(delta: float) -> void:
	if dragon_body:
		dragon_body.set_physics_process(true)

func handle_on_foot_input(delta: float) -> void:
	var input_dir = Vector2.ZERO
	
	if Input.is_action_pressed("move_up"):
		input_dir.y -= 1.0
	if Input.is_action_pressed("move_down"):
		input_dir.y += 1.0
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1.0
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1.0
	
	input_dir = input_dir.normalized()
	
	var speed = 120.0
	global_position += input_dir * speed * delta
	
	var bounds = get_viewport_rect()
	bounds.position.y = 250
	global_position.y = clamp(global_position.y, bounds.position.y, 320)

func handle_firing_input() -> void:
	if Input.is_action_pressed("fire_weapon"):
		if weapon_system:
			if mode == PlayerMode.MOUNTED:
				weapon_system.start_firing()
			elif mode == PlayerMode.ON_FOOT and current_platform:
				weapon_system.start_firing()
	elif Input.is_action_just_released("fire_weapon"):
		if weapon_system:
			weapon_system.stop_firing()

func handle_dismount() -> void:
	if mode == PlayerMode.MOUNTED and can_dismount and _can_dismount():
		dismount()
	elif mode == PlayerMode.ON_FOOT:
		mount()

func _can_dismount() -> bool:
	if not dragon_body:
		return false
	return dragon_body.current_velocity.length() < 20.0

func dismount() -> void:
	if not dragon_body:
		return
	
	mode = PlayerMode.ON_FOOT
	on_foot_position = global_position + Vector2(0, 24)
	
	dragon_body.visible = false
	dragon_body.set_physics_process(false)
	
	setup_rider_body()
	if rider_body:
		rider_body.visible = true
		rider_body.global_position = on_foot_position
	
	mounted_changed.emit(false)
	EventBus.player_shield_deactivated.emit()

func mount() -> void:
	mode = PlayerMode.MOUNTED
	
	if dragon_body:
		dragon_body.visible = true
		dragon_body.set_physics_process(true)
	
	if rider_body:
		rider_body.visible = false
	
	mounted_changed.emit(true)
	EventBus.player_shield_activated.emit()

func setup_rider_body() -> void:
	if not rider_body:
		rider_body = Area2D.new()
		rider_body.name = "RiderBody"
		rider_body.visible = false
		
		var collision = CollisionShape2D.new()
		collision.name = "CollisionShape2D"
		var shape = CircleShape2D.new()
		shape.radius = 8.0
		collision.shape = shape
		rider_body.add_child(collision)
		
		add_child(rider_body)

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
	if mode == PlayerMode.ON_FOOT and rider_body:
		return rider_body.global_position
	return get_dragon_position()

func get_tail_position() -> Vector2:
	if dragon_body:
		return dragon_body.get_tail_tip_position()
	return global_position

func is_shield_active() -> bool:
	if dragon_body:
		return dragon_body.shield_active
	return false

func is_mounted() -> bool:
	return mode == PlayerMode.MOUNTED

func take_damage(amount: int) -> void:
	if mode == PlayerMode.MOUNTED and is_shield_active():
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

func get_team() -> String:
	return "player"

func _on_platform_entered(platform: StaticBody2D) -> void:
	current_platform = platform
	platform_entered.emit(platform)

func _on_platform_exited(platform: StaticBody2D) -> void:
	if current_platform == platform:
		current_platform = null
		platform_exited.emit(platform)
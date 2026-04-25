extends Area2D
class_name Enemy
class_name EnemyBase

signal damaged(amount: int)
signal died(enemy_type: String, position: Vector2)
signal health_changed(current: int, max: int)

@export var health: int = 10
@export var max_health: int = 10
@export var damage_on_contact: int = 10
@export var score_value: int = 100

@export_enum("BASIC", "SHOOTER", "CHASER", "BOSS", "MINE") var enemy_type: int = 0
@export var movement_pattern: String = "straight"
@export var move_speed: float = 80.0
@export var shoot_interval: float = 2.0

var current_velocity: Vector2 = Vector2.LEFT
var can_take_damage: bool = true
var player_team: String = "enemy"

var screen_bounds: Rect2

func _ready() -> void:
	max_health = health
	add_to_group("enemies")
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	screen_bounds = get_viewport_rect()
	initialize()

func initialize() -> void:
	pass

func _physics_process(delta: float) -> void:
	update_movement(delta)
	
	if enemy_type == EnemyType.SHOOTER or enemy_type == EnemyType.MINE:
		handle_shooting(delta)

func update_movement(delta: float) -> void:
	match movement_pattern:
		"straight":
			current_velocity = Vector2.LEFT * move_speed
		"wave":
			var wave = sin(time_alive() * 3.0) * 50.0
			current_velocity = Vector2(-move_speed, wave)
		"chase":
			var player = _find_player()
			if player:
				var to_player = player.global_position - global_position
				current_velocity = to_player.normalized() * move_speed * 0.5
			else:
				current_velocity = Vector2.LEFT * move_speed
		"circle":
			var center_offset = Vector2(0, sin(time_alive() * 2.0) * 80.0)
			current_velocity = Vector2.LEFT * move_speed + center_offset
	
	global_position += current_velocity * delta
	
	if not screen_bounds.has_point(global_position):
		queue_free()

var _time_accum: float = 0.0
func time_alive() -> float:
	return _time_accum

func _process(delta: float) -> void:
	_time_accum += delta

func handle_shooting(delta: float) -> void:
	pass

func _find_player() -> Node2D:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		return players[0]
	return null

func _on_area_entered(area: Area2D) -> void:
	if area.has_method("get_team") and area.get_team() == "player":
		if area.has_method("is_shield_active") and area.is_shield_active():
			return
		damage_player(area, damage_on_contact)

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("get_team") and body.get_team() == "player":
		damage_player(body, damage_on_contact)

func damage_player(target: Node, amount: int) -> void:
	if target.has_method("take_damage"):
		target.take_damage(amount)

func take_damage(amount: int) -> void:
	if not can_take_damage:
		return
	
	health -= amount
	health_changed.emit(health, max_health)
	damaged.emit(amount)
	
	if health <= 0:
		die()

func get_team() -> String:
	return player_team

func die() -> void:
	died.emit(EnemyType.keys()[enemy_type], global_position)
	ScoreManager.add_score(score_value, global_position)
	queue_free()
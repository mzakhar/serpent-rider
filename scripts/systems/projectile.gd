extends Area2D
class_name Projectile

@export var speed: float = 300.0
@export var damage: int = 10
@export_enum("FIREBALL", "LIGHTNING", "TAIL_STRIKE", "SPREAD_SHOT", "WAVE_SHOT", "FLAME", "CRESCENT", "HOMING") var projectile_type: int = 0
@export var lifetime: float = 3.0
@export var pierce_count: int = 0

@export var homing_strength: float = 0.0
@export var homing_duration: float = 0.0

var velocity: Vector2 = Vector2.RIGHT
var time_alive: float = 0.0
var pierce_hits: Array[Node] = []
var source_team: String = "player"
var initial_velocity: Vector2 = Vector2.ZERO

signal hit_enemy(enemy, damage_dealt: int)
signal expired

func _ready() -> void:
	initial_velocity = velocity
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	
	if homing_strength > 0 and homing_duration > 0:
		set_meta("start_homing", true)

func _physics_process(delta: float) -> void:
	global_position += velocity * delta
	
	time_alive += delta
	
	if homing_strength > 0 and time_alive < homing_duration:
		apply_homing(delta)
	
	if time_alive >= lifetime:
		expire()

func apply_homing(delta: float) -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return
	
	var closest_enemy: Node2D = null
	var closest_dist: float = INF
	
	for enemy in enemies:
		if enemy == self or enemy in pierce_hits:
			continue
		var dist = global_position.distance_to(enemy.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest_enemy = enemy
	
	if closest_enemy:
		var target_dir = (closest_enemy.global_position - global_position).normalized()
		velocity = velocity.lerp(target_dir * speed, homing_strength * delta)
		rotation = velocity.angle()

func set_direction(dir: Vector2) -> void:
	velocity = dir.normalized() * speed
	rotation = velocity.angle()

func set_team(team: String) -> void:
	source_team = team

func _on_area_entered(area: Area2D) -> void:
	if should_ignore(area):
		return
	handle_hit(area)

func _on_body_entered(body: Node2D) -> void:
	if should_ignore(body):
		return
	handle_hit(body)

func should_ignore(target: Node) -> bool:
	if target == self:
		return true
	if target.has_method("get_team") and target.get_team() == source_team:
		return true
	if target in pierce_hits:
		return true
	return false

func handle_hit(target: Node) -> void:
	var damage_dealt = damage
	hit_enemy.emit(target, damage_dealt)
	
	if target.has_method("take_damage"):
		target.take_damage(damage_dealt)
	
	pierce_hits.append(target)
	if pierce_count > 0 and pierce_hits.size() >= pierce_count:
		expire()

func expire() -> void:
	expired.emit()
	queue_free()

func get_team() -> String:
	return source_team
extends Area2D
class_name Projectile
class_name ProjectileData

enum ProjectileType { FIREBALL, LIGHTNING, TAIL_STRIKE, SPREAD_SHOT, WAVE_SHOT }

@export var speed: float = 300.0
@export var damage: int = 10
@export var projectile_type: ProjectileType = ProjectileType.FIREBALL
@export var lifetime: float = 3.0
@export var pierce_count: int = 0

var velocity: Vector2 = Vector2.RIGHT
var time_alive: float = 0.0
var pierce_hits: Array[Node] = []
var source_team: String = "player"

signal hit_enemy(enemy, damage_dealt: int)
signal expired

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	global_position += velocity * delta
	
	time_alive += delta
	if time_alive >= lifetime:
		expire()

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
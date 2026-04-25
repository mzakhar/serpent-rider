extends Enemy

@export var projectile_scene: PackedScene
@export var aim_at_player: bool = true
@export var spread_count: int = 1

var shoot_cooldown: float = 0.0
var player: Node2D = null

func initialize() -> void:
	super.initialize()
	player = _find_player()
	if not projectile_scene:
		projectile_scene = load("res://scenes/projectiles/enemy_projectile.tscn")
	shoot_cooldown = randf_range(0.5, shoot_interval)

func handle_shooting(delta: float) -> void:
	shoot_cooldown -= delta
	if shoot_cooldown <= 0:
		fire_at_player()
		shoot_cooldown = shoot_interval

func fire_at_player() -> void:
	if not projectile_scene:
		return
	
	var target_dir = Vector2.LEFT
	if aim_at_player and player:
		target_dir = (player.global_position - global_position).normalized()
	
	for i in range(spread_count):
		var dir = target_dir
		if spread_count > 1:
			dir = target_dir.rotated(deg_to_rad((i - 0.5) * 20))
		spawn_projectile(dir)

func spawn_projectile(direction: Vector2) -> void:
	var proj = projectile_scene.instantiate()
	proj.global_position = global_position
	proj.set_direction(direction)
	proj.source_team = "enemy"
	
	get_tree().current_scene.add_child(proj)
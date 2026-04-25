extends Node2D
class_name EnemySpawner

signal enemy_spawned(enemy: Enemy)
signal wave_started(wave_num: int)
signal wave_completed(wave_num: int)

@export var spawn_interval: float = 2.0
@export var enemy_scene: PackedScene
@export var spawn_count: int = 5
@export var spawn_pattern: String = "random"
@export var spawn_area: Rect2

var spawn_timer: float = 0.0
var spawned_count: int = 0
var active_enemies: Array[Enemy] = []
var wave_number: int = 0
var is_active: bool = false
var paused: bool = false

@onready var default_area: Rect2 = Rect2(600, 0, 200, 364)

func _ready() -> void:
	if spawn_area == Rect2():
		spawn_area = default_area
	spawn_timer = spawn_interval

func _process(delta: float) -> void:
	if not is_active or paused:
		return
	
	spawn_timer -= delta
	if spawn_timer <= 0:
		spawn_enemy()
		spawn_timer = spawn_interval

func spawn_enemy() -> void:
	if spawned_count >= spawn_count and spawn_count > 0:
		wave_completed.emit(wave_number)
		return
	
	var pos = _get_spawn_position()
	var enemy = enemy_scene.instantiate()
	enemy.global_position = pos
	get_tree().current_scene.add_child(enemy)
	active_enemies.append(enemy)
	enemy.died.connect(_on_enemy_died)
	spawned_count += 1
	enemy_spawned.emit(enemy)

func _get_spawn_position() -> Vector2:
	match spawn_pattern:
		"random":
			return Vector2(
				spawn_area.position.x + randf() * spawn_area.size.x,
				spawn_area.position.y + randf() * spawn_area.size.y
			)
		"line":
			var y_step = spawn_area.size.y / max(spawn_count, 1)
			return Vector2(
				spawn_area.position.x + spawn_area.size.x,
				spawn_area.position.y + (spawned_count % spawn_count) * y_step
			)
		_"formation":
			var cols = 3
			var row = spawned_count / cols
			var col = spawned_count % cols
			return Vector2(
				spawn_area.position.x + spawn_area.size.x,
				spawn_area.position.y + col * 80 + 80
			)
	
	return spawn_area.position + spawn_area.size * 0.5

func _on_enemy_died(_type: String, _pos: Vector2) -> void:
	active_enemies.erase(null)

func start_spawning() -> void:
	is_active = true
	wave_started.emit(wave_number)

func stop_spawning() -> void:
	is_active = false

func pause_spawning() -> void:
	paused = true

func resume_spawning() -> void:
	paused = false

func reset_spawner() -> void:
	spawned_count = 0
	spawn_timer = spawn_interval
	active_enemies.clear()

func get_active_count() -> int:
	return active_enemies.size()

func get_spawned_count() -> int:
	return spawned_count
extends Enemy

signal phase_changed(new_phase: int)
signal attacks()

@export var max_phase: int = 3
@export var phase_health: Array[int] = [100, 75, 50]
@export var attack_patterns: Array[String] = ["spread", " barrage", " barrage", "barrage"]

@export var float_amplitude: float = 40.0
@export var float_speed: float = 2.0
@export var horizontal_move: float = 60.0

var current_phase: int = 0
var attack_cooldown: float = 0.0
var attack_timer: float = 0.0
var is_vulnerable: bool = true

var initial_position: Vector2
var time_alive_counter: float = 0.0

func _ready() -> void:
	super._ready()
	initial_position = global_position
	enemy_type = EnemyType.BOSS
	max_health = phase_health[0]
	health = max_health

func initialize() -> void:
	super.initialize()
	current_phase = 0

func _process(delta: float) -> void:
	time_alive_counter += delta
	update_boss_movement(delta)
	handle_boss_attacks(delta)
	update_phase()

func update_boss_movement(delta: float) -> void:
	var float_offset = Vector2(0, sin(time_alive_counter * float_speed * PI) * float_amplitude)
	var horizontal_offset = Vector2(sin(time_alive_counter * 0.5) * horizontal_float, 0)
	global_position = initial_position + float_offset + horizontal_offset

var horizontal_float: float = 80.0

func handle_boss_attacks(delta: float) -> void:
	attack_timer += delta
	attack_cooldown -= delta
	
	if attack_timer >= 2.0 and attack_cooldown <= 0:
		execute_attack()
		attack_timer = 0.0

func execute_attack() -> void:
	if current_phase >= attack_patterns.size():
		current_phase = attack_patterns.size() - 1
	
	match attack_patterns[current_phase]:
		"spread":
			fire_spread_attack()
		"barrage":
			fire_barrage_attack()
		"rapid":
			fire_rapid_attack()
		"spiral":
			fire_spiral_attack()
	
	attacks.emit()

func fire_spread_attack() -> void:
	for i in range(5):
		var dir = Vector2.LEFT.rotated(deg_to_rad((i - 2) * 30))
		spawn_attack_projectile(dir)

func fire_barrage_attack() -> void:
	attack_cooldown = 0.3
	for i in range(8):
		await get_tree().create_timer(0.15).timeout
		spawn_attack_projectile(Vector2.LEFT.rotated(deg_to_rad(randf_range(-60, 60))))

func fire_rapid_attack() -> void:
	attack_cooldown = 0.15
	for i in range(12):
		await get_tree().create_timer(0.08).timeout
		var dir = Vector2.LEFT.rotated(deg_to_rad(sin(i * 0.5) * 45))
		spawn_attack_projectile(dir)

func fire_spiral_attack() -> void:
	attack_cooldown = 0.1
	for i in range(24):
		await get_tree().create_timer(0.1).timeout
		var dir = Vector2.LEFT.rotated(deg_to_rad(i * 15))
		spawn_attack_projectile(dir)

func spawn_attack_projectile(direction: Vector2) -> void:
	var proj_scene = load("res://scenes/projectiles/enemy_projectile.tscn")
	if proj_scene:
		var proj = proj_scene.instantiate()
		proj.global_position = global_position
		proj.set_direction(direction)
		proj.damage = 15
		proj.source_team = "enemy"
		get_tree().current_scene.add_child(proj)

func update_phase() -> void:
	var new_phase = 0
	for i in range(phase_health.size()):
		if health <= phase_health[i]:
			new_phase = i
	
	if new_phase != current_phase:
		current_phase = new_phase
		max_health = phase_health[current_phase] if current_phase < phase_health.size() else health
		phase_changed.emit(current_phase)
		_on_phase_changed(new_phase)

func _on_phase_changed(phase: int) -> void:
	match phase:
		1:
			float_amplitude *= 1.5
			horizontal_move *= 1.2
		2:
			attack_timer = 0.0

func take_damage(amount: int) -> void:
	if not is_vulnerable:
		return
	
	if current_phase >= 2:
		var flash_color = Color.WHITE
		modulate = flash_color
		await get_tree().create_timer(0.05).timeout
		modulate = Color(1, 1, 1, 1)
	
	super.take_damage(amount)

func die() -> void:
	EventBus.level_completed.emit()
	ScoreManager.add_score(score_value * 5, global_position)
	queue_free()
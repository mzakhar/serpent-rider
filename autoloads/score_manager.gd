extends Node

var score: int = 0
var high_score: int = 0

var multipliers: Dictionary = {}

const MULTIPLIER_TIMEOUT: float = 10.0
var multiplier_timers: Dictionary = {}

func _ready() -> void:
	load_high_score()

func _process(delta: float) -> void:
	for key in multiplier_timers.keys():
		multiplier_timers[key] -= delta
		if multiplier_timers[key] <= 0:
			remove_multiplier(key)

func add_score(points: int, position: Vector2 = Vector2.ZERO) -> void:
	var final_points = points
	
	for key in multipliers.keys():
		final_points *= multipliers[key]
	
	score += final_points
	EventBus.score_updated.emit(score)

func set_multiplier(key: String, value: float, duration: float = MULTIPLIER_TIMEOUT) -> void:
	multipliers[key] = value
	multiplier_timers[key] = duration

func remove_multiplier(key: String) -> void:
	multipliers.erase(key)
	multiplier_timers.erase(key)

func reset_score() -> void:
	score = 0
	multipliers.clear()
	multiplier_timers.clear()
	EventBus.score_updated.emit(score)

func save_high_score() -> void:
	if score > high_score:
		high_score = score
		var save_game = FileAccess.open_encrypted_with_pass("user://highscore.dat", FileAccess.WRITE, "serpent_rider")
		if save_game:
			save_game.store_var(high_score)
			save_game.close()

func load_high_score() -> void:
	if FileAccess.file_exists("user://highscore.dat"):
		var save_game = FileAccess.open_encrypted_with_pass("user://highscore.dat", FileAccess.READ, "serpent_rider")
		if save_game:
			high_score = save_game.get_var()
			save_game.close()

func get_formatted_score() -> String:
	return str(score).pad_zeros(8)

func get_formatted_high_score() -> String:
	return str(high_score).pad_zeros(8)
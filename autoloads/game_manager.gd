extends Node

var current_level: int = 1
var is_paused: bool = false
var player_health: int = 100
var player_max_health: int = 100

var difficulty: float = 1.0

enum GameState { MENU, PLAYING, PAUSED, GAME_OVER }
var state: GameState = GameState.MENU

func _ready() -> void:
	reset_game()

func reset_game() -> void:
	current_level = 1
	player_health = player_max_health
	difficulty = 1.0
	state = GameState.MENU
	is_paused = false

func start_game() -> void:
	state = GameState.PLAYING
	is_paused = false
	player_health = player_max_health

func pause_game() -> void:
	if state == GameState.PLAYING:
		state = GameState.PAUSED
		is_paused = true
		EventBus.game_paused.emit()

func resume_game() -> void:
	if state == GameState.PAUSED:
		state = GameState.PLAYING
		is_paused = false
		EventBus.game_resumed.emit()

func game_over() -> void:
	state = GameState.GAME_OVER
	EventBus.player_died.emit()

func take_damage(amount: int) -> void:
	player_health = max(0, player_health - amount)
	EventBus.player_damaged.emit(amount)
	if player_health <= 0:
		game_over()

func heal(amount: int) -> void:
	player_health = min(player_max_health, player_health + amount)

func set_time_scale(scale: float) -> void:
	Engine.time_scale = scale
	debug_time_scale = scale
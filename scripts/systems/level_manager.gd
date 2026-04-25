extends Node2D
class_name LevelManager

signal level_started(level_num: int)
signal level_completed(level_num: int)
signal time_warning(low_time: bool)
signal level_failed
signal stage_cleared

@export var level_number: int = 1
@export var time_limit: float = 120.0
@export var kill_target: int = 0

var time_remaining: float = 0.0
var enemies_killed: int = 0
var active: bool = false
var paused: bool = false

@onready var camera: Camera2D = $Camera2D if has_node("Camera2D") else null

func _ready() -> void:
	EventBus.level_completed.connect(_on_level_completed)

func _process(delta: float) -> void:
	if not active or paused:
		return
	
	time_remaining -= delta
	
	if time_remaining <= 10.0 and time_remaining > 9.5:
		time_warning.emit(true)
	elif time_remaining <= 0:
		time_out()

func start_level() -> void:
	time_remaining = time_limit
	enemies_killed = 0
	active = true
	level_started.emit(level_number)
	GameManager.start_game()

func pause_level() -> void:
	paused = true
	GameManager.pause_game()

func resume_level() -> void:
	paused = false
	GameManager.resume_game()

func time_out() -> void:
	active = false
	level_failed.emit()
	EventBus.game_over.emit()
	GameManager.game_over()

func _on_level_completed() -> void:
	if active:
		enemies_killed += 1
		if enemies_killed >= kill_target and kill_target > 0:
			complete_level()

func complete_level() -> void:
	active = false
	level_completed.emit(level_number)
	EventBus.level_completed.emit()
	stage_cleared.emit()

func get_progress() -> float:
	return time_remaining / time_limit

func get_time_remaining() -> float:
	return time_remaining

func is_active() -> bool:
	return active
extends Camera2D
class_name ScrollCamera

signal camera_scrolled(distance: float)

@export var scroll_speed: float = 80.0
@export var auto_scroll: bool = true
@export var scroll_bounds: Rect2

var total_distance: float = 0.0

@onready var world_bounds : Rect2 = get_viewport_rect() if scroll_bounds == Rect2() else scroll_bounds

func _ready() -> void:
	position = Vector2.ZERO

func _physics_process(delta: float) -> void:
	if auto_scroll:
		var movement = Vector2.RIGHT * scroll_speed * delta
		global_position += movement
		total_distance += movement.x
		camera_scrolled.emit(total_distance)

func set_scroll_speed(speed: float) -> void:
	scroll_speed = speed

func stop_scroll() -> void:
	auto_scroll = false

func resume_scroll() -> void:
	auto_scroll = true

func get_total_distance() -> float:
	return total_distance

func is_auto_scrolling() -> bool:
	return auto_scroll
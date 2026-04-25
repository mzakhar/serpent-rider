extends Node2D
class_name DragonSegment

@export var segment_radius: float = 8.0
@export var lag_speed: float = 8.0
@export var is_head: bool = false

var target_position: Vector2
var velocity: Vector2

@onready var collision_shape: CollisionShape2D = $CollisionShape2D if has_node("CollisionShape2D") else null

func _ready() -> void:
	if collision_shape:
		var circle = CircleShape2D.new()
		circle.radius = segment_radius
		collision_shape.shape = circle

func _physics_process(delta: float) -> void:
	if is_head:
		global_position = global_position.lerp(target_position, lag_speed * delta)
	else:
		global_position = global_position.lerp(target_position, lag_speed * delta)

func set_target(new_target: Vector2) -> void:
	target_position = new_target

func get_world_position() -> Vector2:
	return global_position
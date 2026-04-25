extends StaticBody2D

class_name GamePlatform

@export var platform_id: String = ""
@export var has_power_up: bool = false
@export var power_up_scene: PackedScene
@export var width: float = 128.0
@export var height: float = 24.0

func _ready() -> void:
	setup_collision()

func setup_collision() -> void:
	var collision = get_node_or_null("CollisionShape2D")
	if not collision:
		collision = CollisionShape2D.new()
		collision.name = "CollisionShape2D"
		add_child(collision)
	
	var shape = RectangleShape2D.new()
	shape.size = Vector2(width, height)
	collision.shape = shape

func spawn_power_up() -> void:
	if has_power_up and power_up_scene:
		var power_up = power_up_scene.instantiate()
		power_up.global_position = global_position + Vector2(0, -24)
		get_tree().current_scene.add_child(power_up)
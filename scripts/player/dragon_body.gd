extends Node2D
class_name DragonBody

signal shield_activated
signal shield_deactivated

@export var segment_count: int = 12
@export var segment_spacing: float = 12.0
@export var lag_factor: float = 0.5
@export var max_speed: float = 180.0
@export var acceleration: float = 600.0
@export var friction: float = 0.92

@export var shield_active: bool = false
@export var shield_segments: int = 3

var segments: Array[DragonSegment] = []
var head_position: Vector2 = Vector2.ZERO
var input_direction: Vector2 = Vector2.ZERO
var current_velocity: Vector2 = Vector2.ZERO

var screen_bounds: Rect2

@onready var rider_position_anchor: Node2D = $RiderPosition if has_node("RiderPosition") else null

func _ready() -> void:
	screen_bounds = get_viewport_rect()
	screen_bounds.position = get_global_mouse_position() - screen_bounds.size / 2
	
	create_segments()
	
	EventBus.player_died.connect(_on_player_died)

func _physics_process(delta: float) -> void:
	handle_input()
	apply_movement(delta)
	update_segment_targets()
	update_shield_state()

func handle_input() -> void:
	input_direction = Vector2.ZERO
	
	if Input.is_action_pressed("move_up"):
		input_direction.y -= 1.0
	if Input.is_action_pressed("move_down"):
		input_direction.y += 1.0
	if Input.is_action_pressed("move_left"):
		input_direction.x -= 1.0
	if Input.is_action_pressed("move_right"):
		input_direction.x += 1.0
	
	input_direction = input_direction.normalized()

func apply_movement(delta: float) -> void:
	if input_direction.length() > 0:
		current_velocity += input_direction * acceleration * delta
		current_velocity = current_velocity.limit_length(max_speed)
	else:
		current_velocity *= friction
	
	current_velocity = current_velocity.limit_length(max_speed)
	
	head_position += current_velocity * delta
	head_position = clamp_to_bounds(head_position)

func clamp_to_bounds(pos: Vector2) -> Vector2:
	var margin = segment_spacing * 2
	return Vector2(
		clamp(pos.x, screen_bounds.position.x + margin, screen_bounds.end.x - margin),
		clamp(pos.y, screen_bounds.position.y + margin, screen_bounds.end.y - margin)
	)

func update_segment_targets() -> void:
	if segments.is_empty():
		return
	
	segments[0].set_target(head_position)
	
	for i in range(1, segments.size()):
		var target = segments[i - 1].get_world_position()
		var offset = target.direction_to(segments[i].get_world_position()) * segment_spacing
		var new_target = target - offset
		segments[i].set_target(new_target)

func update_shield_state() -> void:
	var shield_key = Input.is_action_pressed("activate_shield")
	
	if shield_key and not shield_active:
		enable_shield()
	elif not shield_key and shield_active:
		disable_shield()

func enable_shield() -> void:
	shield_active = true
	
	for i in range(min(shield_segments, segments.size())):
		if segments[i].collision_shape:
			segments[i].collision_shape.set_deferred("disabled", false)
	
	EventBus.player_shield_activated.emit()
	shield_activated.emit()

func disable_shield() -> void:
	shield_active = false
	
	for segment in segments:
		if segment.collision_shape:
			segment.collision_shape.set_deferred("disabled", true)
	
	EventBus.player_shield_deactivated.emit()
	shield_deactivated.emit()

func create_segments() -> void:
	head_position = global_position
	
	for i in range(segment_count):
		var segment = DragonSegment.new()
		segment.segment_radius = max(4.0, segment_spacing - i * 0.5)
		segment.lag_speed = lag_factor * (segment_count - i)
		segment.is_head = (i == 0)
		
		var offset_pos = Vector2(-segment_spacing * i, 0)
		segment.global_position = global_position + offset_pos
		
		var collision = CollisionShape2D.new()
		collision.name = "CollisionShape2D"
		collision.set_deferred("disabled", true)
		collision.position = Vector2.ZERO
		segment.add_child(collision)
		
		segments.append(segment)
		add_child(segment)
	
	segments[0].is_head = true

func get_head_position() -> Vector2:
	if segments.is_empty():
		return global_position
	return segments[0].global_position

func get_rider_position() -> Vector2:
	if rider_position_anchor:
		return rider_position_anchor.global_position
	return get_head_position()

func get_tail_tip_position() -> Vector2:
	if segments.is_empty():
		return global_position
	return segments.back().global_position

func _on_player_died() -> void:
	set_physics_process(false)
	if shield_active:
		disable_shield()

func get_segment_count() -> int:
	return segments.size()

func get_segment(index: int) -> DragonSegment:
	if index >= 0 and index < segments.size():
		return segments[index]
	return null
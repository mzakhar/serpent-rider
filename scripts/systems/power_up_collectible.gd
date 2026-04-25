extends Area2D
class_name PowerUp
class_name PowerUpCollectible

@export var power_up_data: PowerUpData
@export var bob_amplitude: float = 8.0
@export var bob_speed: float = 2.0

var initial_position: Vector2
var time_alive: float = 0.0
var collected: bool = false

func _ready() -> void:
	if not power_up_data:
		power_up_data = PowerUpData.new()
		power_up_data.display_name = "Unknown"
	
	initial_position = global_position
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	if collected:
		return
	
	time_alive += delta
	
	var bob_offset = Vector2(0, sin(time_alive * bob_speed * PI * 2) * bob_amplitude)
	global_position = initial_position + bob_offset

func _on_area_entered(area: Area2D) -> void:
	collect(area)

func _on_body_entered(body: Node2D) -> void:
	collect(body)

func collect(collector: Node) -> void:
	if collected:
		return
	
	if collector.has_method("apply_power_up"):
		collector.apply_power_up(power_up_data)
		collected = true
		queue_free()
elif collector.has_method("get_player") and collector.get_player() != null:
	var player = collector.get_player()
	if player.has_method("apply_power_up"):
		player.apply_power_up(power_up_data)
		collected = true
		queue_free()

func get_power_up_data() -> PowerUpData:
	return power_up_data
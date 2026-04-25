extends Node2D
class_name ParallaxLayer

@export var scroll_speed: float = 0.5
@export var layer_offset: float = 0.0
@export var tiles_horizontally: int = 2
@export var tiles_vertically: int = 1

var textures: Array[Texture2D] = []
var sprites: Array[Sprite2D] = []
var viewport_size: Vector2

func _ready() -> void:
	viewport_size = get_viewport_rect().size
	initialize_layer()

func initialize_layer() -> void:
	var texture = StandardMaterial2D.new()
	texture.albedo_color = Color(layer_offset * 0.1, layer_offset * 0.1, layer_offset * 0.15, 1)
	texture.shading_mode = BaseMaterial2D.SHADING_MODE_UNSHADED
	
	for y in range(tiles_vertically):
		for x in range(tiles_horizontally + 1):
			var sprite = Sprite2D.new()
			sprite.material = texture
			sprite.position = Vector2(x * viewport_size.x, y * viewport_size.y)
			
			if x == tiles_horizontally:
				sprite.modulate.a = 0.3
			
			add_child(sprite)
			sprites.append(sprite)

func _physics_process(delta: float) -> void:
	var scroll_offset = Vector2.RIGHT * scroll_speed * delta * Engine.time_scale
	
	for sprite in sprites:
		sprite.position -= scroll_offset
		
		if sprite.position.x < -viewport_size.x:
			sprite.position.x += viewport_size.x * (tiles_horizontally + 1)

func set_scroll_speed(speed: float) -> void:
	scroll_speed = speed

func get_parallax_factor() -> float:
	return scroll_speed
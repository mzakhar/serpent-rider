extends CanvasItem

class_name GameHUD

@onready var score_label: Label = $ScoreLabel if has_node("ScoreLabel") else null
@onready var health_bar: ProgressBar = $HealthBar if has_node("HealthBar") else null
@onready var power_up_label: Label = $PowerUpLabel if has_node("PowerUpLabel") else null
@onready var time_label: Label = $TimeLabel if has_node("TimeLabel") else null
@onready var charge_indicator: TextureProgressBar = $ChargeIndicator if has_node("ChargeIndicator") else null
@onready var shield_indicator: TextureRect = $ShieldIndicator if has_node("ShieldIndicator") else null

@export var font_size: int = 16

var current_score: int = 0
var current_health: int = 100
var max_health: int = 100
var current_weapon: String = "fireball"
var time_remaining: float = 120.0
var is_charging: bool = false
var charge_level: int = 0

var screen_size: Vector2

func _ready() -> void:
	setup_hud()
	connect_signals()
	screen_size = get_viewport_rect().size

func _process(_delta: float) -> void:
	queue_redraw()

func setup_hud() -> void:
	if not score_label:
		score_label = Label.new()
		score_label.name = "ScoreLabel"
		score_label.position = Vector2(8, 8)
		add_child(score_label)
	
	if not health_bar:
		health_bar = ProgressBar.new()
		health_bar.name = "HealthBar"
		health_bar.position = Vector2(8, 32)
		health_bar.size = Vector2(100, 12)
		health_bar.value = 100
		add_child(health_bar)
	
	if not power_up_label:
		power_up_label = Label.new()
		power_up_label.name = "PowerUpLabel"
		power_up_label.position = Vector2(8, 50)
		add_child(power_up_label)
	
	if not time_label:
		time_label = Label.new()
		time_label.name = "TimeLabel"
		time_label.position = Vector2(440, 8)
		add_child(time_label)
	
	if not shield_indicator:
		shield_indicator = TextureRect.new()
		shield_indicator.name = "ShieldIndicator"
		shield_indicator.position = Vector2(440, 32)
		shield_indicator.size = Vector2(24, 24)
		shield_indicator.visible = false
		add_child(shield_indicator)

func connect_signals() -> void:
	EventBus.score_updated.connect(_on_score_updated)
	EventBus.player_damaged.connect(_on_player_damaged)
	EventBus.power_up_collected.connect(_on_power_up_collected)
	
	var game_mgr = get_tree().root.get_node("GameManager")
	if game_mgr:
		game_mgr.player_health = GameManager.player_health
		game_mgr.player_max_healthy = GameManager.player_max_health

func _on_score_updated(new_score: int) -> void:
	current_score = new_score
	update_score_display()

func _on_player_damaged(_amount: int) -> void:
	current_health = GameManager.player_health
	update_health_display()

func _on_power_up_collected(_power_up: PowerUpData) -> void:
	current_weapon = _power_up.weapon_type if _power_up.weapon_type else current_weapon
	update_weapon_display()

func update_score_display() -> void:
	if score_label:
		score_label.text = "SCORE: " + str(current_score).pad_zeros(8)

func update_health_display() -> void:
	if health_bar:
		health_bar.value = (float(current_health) / max_health) * 100

func update_weapon_display() -> void:
	if power_up_label:
		power_up_label.text = "WEAPON: " + current_weapon.to_upper()

func update_time_display(time_left: float) -> void:
	time_remaining = time_left
	if time_label:
		var mins = int(time_left) / 60
		var secs = int(time_left) % 60
		time_label.text = "TIME: %d:%02d" % [mins, secs]
		if time_left < 10:
			time_label.modulate = Color(1, 0.3, 0.3, 1)
		else:
			time_label.modulate = Color(1, 1, 1, 1)

func show_shield_indicator(show: bool) -> void:
	if shield_indicator:
		shield_indicator.visible = show

func update_charge(level: int, max_level: int) -> void:
	charge_level = level
	if charge_indicator:
		charge_indicator.max_value = max_level
		charge_indicator.value = level

func clear() -> void:
	current_score = 0
	current_health = max_health
	current_weapon = "fireball"
	time_remaining = 0.0
	update_score_display()
	update_health_display()
	update_weapon_display()

func set_max_health(value: int) -> void:
	max_health = value

func set_health(value: int) -> void:
	current_health = value
	update_health_display()
extends Node

signal player_damaged(amount: int)
signal player_died
signal player_shield_activated
signal player_shield_deactivated
signal enemy_died(enemy_type: String, position: Vector2)
signal power_up_collected(power_up: Resource)
signal score_updated(new_score: int)
signal level_completed
signal game_paused
signal game_resumed

var debug_time_scale: float = 1.0
extends Node


var main_player : Player


func reset_level() -> void:
	LevelController.reset_level()


func get_respawn_transform() -> Transform:
	return LevelController.get_reset_transform()

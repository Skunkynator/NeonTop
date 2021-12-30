extends Node


var main_player : Player setget set_main_player


func set_main_player(player: Player):
	if not player:
		return
	if main_player == player:
		return
	if main_player:
		main_player.queue_free()
	main_player = player
	add_child(main_player)


func reset_level() -> void:
	LevelController.reset_level()


func get_respawn_transform() -> Transform:
	return LevelController.get_reset_transform()

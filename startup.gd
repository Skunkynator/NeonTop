extends Node

# Can handle more things on startup later such as for example
# loading screen, loading settings and applying these
# for now just loads the "Main Menu" Level
func _ready() -> void:
	GameController.main_player = get_player()
	LevelController.load_level("res://menus/main_menu.tscn")
	queue_free()


func get_player() -> Player:
	var player := preload("res://gameplay/player/player.tscn").instance() as Player
	return player

extends Node


var timer : float
var object_timer : float = 0
var reset_timer : float = 0
var start_transform : Transform
var reset_transform : Transform


func load_level(path: String) -> void:
	var new_level := load(path) as PackedScene
	if not new_level:
		return
	var instance := new_level.instance()
	var level := instance as Level
	if not level:
		if instance:
			instance.free()
		return
	_ExtendedFunctions.delete_children(self)
	add_child(level)
	start_transform = level.get_start_transform()
	restart_level()
	GameController.main_player.set_default_parameters()


func reset_level() -> void:
	object_timer = reset_timer


func restart_level() -> void:
	object_timer = 0
	reset_timer = 0
	reset_transform = start_transform


func get_reset_transform() -> Transform:
	return reset_transform


func _process(delta: float) -> void:
	object_timer += delta
	timer += delta

extends Node


var timer : float
var object_timer : float = 0
var reset_timer : float = 0
var start_transform : Transform
var reset_transform : Transform


func load_level(path: String) -> void:
	var new_level : PackedScene = load(path)
	if new_level == null:
		return
	var root_type := new_level.get_state().get_node_type(0)
	if root_type != "Level":
		return
	_ExtendedFunctions.delete_children(self)
	var level : Level = new_level.instance() 
	add_child(level)
	start_transform = level.get_start_transform()


func reset_level() -> void:
	object_timer = reset_timer


func restart_level() -> void:
	object_timer = 0
	reset_timer = object_timer
	reset_transform = start_transform


func get_reset_transform() -> Transform:
	return reset_transform


func _process(delta: float) -> void:
	object_timer += delta
	timer += delta

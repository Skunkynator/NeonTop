extends Node


var timer : float
var object_timer : float = 0
var reset_timer : float = 0
var start_transform : Transform
var reset_transform : Transform


func reset_level() -> void:
	object_timer = reset_timer


func restart_level() -> void:
	object_timer = 0
	reset_timer = object_timer


func get_reset_transform() -> Transform:
	return reset_transform


func _process(delta: float) -> void:
	object_timer += delta
	timer += delta

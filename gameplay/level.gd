extends Node
class_name Level


export var start_point_path : NodePath


func get_start_transform() -> Transform:
	var start_node : Spatial = get_node(start_point_path)
	if start_node == null:
		return Transform()
	return start_node.transform

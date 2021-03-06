extends Node
class_name Level


export var start_point_path : NodePath


func get_start_transform() -> Transform:
	var start_node : Spatial = get_node_or_null(start_point_path) as Spatial
	if not start_node:
		return Transform()
	return start_node.global_transform

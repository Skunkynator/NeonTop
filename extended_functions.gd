extends Object
class_name _ExtendedFunctions


static func delete_children(node : Node):
	for child in node.get_children(): # assuming that get_children only returns Nodes
		node.remove_child(child)
		child.queue_free()

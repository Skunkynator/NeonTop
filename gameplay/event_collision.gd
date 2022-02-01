extends CollisionObject
class_name EventCollision


func _ready() -> void:
	if has_signal("body_entered"):
		connect("body_entered",self,"_on_collision_body_entered")
	if has_signal("body_exited"):
		connect("body_exited",self,"_on_collision_body_exited")


func _on_player_entered(_player: Player) -> void:
	pass


func _on_player_exited(_player: Player) -> void:
	pass


func _on_player_inside(_player: Player) -> void:
	pass


func _on_collision_body_entered(body : Player):
	if not body:
		return
	_on_player_entered(body)
	get_tree().connect("idle_frame",self,"_on_player_inside",[body])


func _on_collision_body_exited(body : Player):
	if not body:
		return
	_on_player_exited(body)
	get_tree().disconnect("idle_frame",self,"_on_player_inside")

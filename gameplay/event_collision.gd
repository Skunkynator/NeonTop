extends CollisionObject
class_name EventCollision


func _ready() -> void:
	if has_signal("body_entered"):
		connect("body_entered",self,"_on_collision_body_entered")


func _on_player_entered(player: Player) -> void:
	pass


func _on_collision_body_entered(body : Player):
	if not body:
		return
	_on_player_entered(body)

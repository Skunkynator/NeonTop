extends EventCollision
class_name BounceCollision


export var strength : float = 1


func _on_player_entered(player: Player) -> void:
	player.bounce(transform.basis.y, strength*20)

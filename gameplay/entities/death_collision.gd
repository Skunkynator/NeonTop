extends EventCollision
class_name DeathCollision


func _on_player_entered(player: Player) -> void:
	player.die()

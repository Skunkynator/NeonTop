extends Control


func _ready() -> void:
	var continue_btn := get_node_or_null("./Buttons/Continue") as BaseButton
	var quit_btn := get_node_or_null("./Buttons/Quit") as BaseButton
	continue_btn.connect("pressed",self,"unpause")
	quit_btn.connect("pressed",self,"go_back")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and visible:
		unpause()
		get_tree().set_input_as_handled()


func unpause() -> void:
	GameController.continue_game()
	self.hide()


func go_back() -> void:
	self.hide()
	GameController.go_back()

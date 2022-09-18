extends Control

const GAME_SCENE = "res://Game/Game.tscn"

# deferred
func _on_ServerButton_pressed():
	lobby.create_server()
	get_tree().change_scene(GAME_SCENE)


# deferred
func _on_ClientButton_pressed():
	lobby.create_client($LineEdit.text)
	get_tree().change_scene(GAME_SCENE)

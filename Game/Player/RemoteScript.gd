extends Node

func _ready():
	if lobby.get_network_mode(self) == lobby.NetworkMode.REMOTE:
		print(get_parent().get_name(), ':remote_script')

func _process(delta):
	pass

remote func sync_data(transform, moving_, camera_holder_transform):
	get_parent().transform = transform
	get_node('../Graphics').moving = moving_
	get_node('../CameraHolder').transform = camera_holder_transform
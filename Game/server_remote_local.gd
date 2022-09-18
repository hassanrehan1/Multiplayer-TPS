extends Spatial

func _ready():
	var network_mode = lobby.get_network_mode(self)
	if network_mode == lobby.NetworkMode.SERVER:
		helpers.set_enabled($RemoteScript, false)
		helpers.set_enabled($LocalScript, false)
	elif network_mode == lobby.NetworkMode.LOCAL:
		helpers.set_enabled($ServerScript, false)
		helpers.set_enabled($RemoteScript, false)
	elif network_mode == lobby.NetworkMode.REMOTE:
		helpers.set_enabled($ServerScript, false)
		helpers.set_enabled($LocalScript, false)

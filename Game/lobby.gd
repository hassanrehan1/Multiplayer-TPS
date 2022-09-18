extends Node

const SERVER_PORT = 7777
const MAX_PLAYERS = 10



func _ready():
	get_tree().connect("network_peer_connected", self, "network_peer_connected")
	get_tree().connect("network_peer_disconnected", self, "network_peer_disconnected")
	get_tree().connect("connected_to_server", self, "connected_to_server")
	get_tree().connect("connection_failed", self, "connection_failed")
	get_tree().connect("server_disconnected", self, "server_disconnected")

func create_server():
	var peer = NetworkedMultiplayerENet.new()
	var error_code = peer.create_server(SERVER_PORT, MAX_PLAYERS)
	get_tree().set_network_peer(peer)
	if error_code != OK:
		print("create_server failed")

func create_client(ip):
	var peer = NetworkedMultiplayerENet.new()
	var error_code = peer.create_client(ip, SERVER_PORT)
	get_tree().set_network_peer(peer)
	if error_code != OK:
		print("create_server failed")

func network_peer_connected(id):
	pass # Will go unused, not useful here

func network_peer_disconnected(id):
	if get_tree().is_network_server():
		rpc("remove_player", id)
	pass

func connected_to_server():
	# Only called on clients, not server. Send my ID and info to all the other peers
	rpc("register_player", get_tree().get_network_unique_id())

func server_disconnected():
	pass # Server kicked us, show error and abort

func connection_failed():
	pass # Could not even connect to server, abort

const PLAYERS_PATH = '/root/Game/Players'
const SPAWN_POINTS = '/root/Game/SpawnPoints'
remote func register_player(id):#, info):
	assert(get_tree().is_network_server())
	
	var players_node = get_node(PLAYERS_PATH)
	for player in players_node.get_children():
		rpc_id(id, 'add_player', int(player.get_name()))
	rpc('add_player', id)

var spawn_index = 0
sync func add_player(id):
	var players_node = get_node(PLAYERS_PATH)
	var player = preload('res://Game/Player/Player.tscn').instance()
	player.set_name(str(id))
	player.set_network_master(id)
	
	var spawn_points = get_node(SPAWN_POINTS) 
	var spawn_point = spawn_points.get_child(spawn_index)
	spawn_index += 1
	if spawn_index >= spawn_points.get_child_count():
		spawn_index = 0
	player.global_transform = spawn_point.global_transform
	
	players_node.add_child(player)
	

sync func remove_player(id):
	print('remove_player ', id)
	var players_node = get_node(PLAYERS_PATH)
	if players_node.has_node(NodePath(str(id))):
		var player = players_node.get_node(str(id))
		player.queue_free()



enum NetworkMode { SERVER=0, LOCAL=1, REMOTE=2}

func get_network_mode(node):
	if get_tree().is_network_server():
		return NetworkMode.SERVER
	elif node.is_network_master():
		return NetworkMode.LOCAL
	elif !node.is_network_master():
		return NetworkMode.REMOTE








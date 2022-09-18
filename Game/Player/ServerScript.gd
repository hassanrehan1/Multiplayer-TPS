extends Node


var max_health = 100
sync var health = 100


func _ready():
	if lobby.get_network_mode(self) == lobby.NetworkMode.SERVER:
		print(get_parent().get_name(), ':server_script')

func _process(delta):
	#deal_damage(1)
	pass

func deal_damage(damage):
	assert(lobby.get_network_mode(self) == lobby.NetworkMode.SERVER)
	health -= damage
	rset('health', health)
	if health <= 0:
		rpc('die')
	get_node('../LocalScript').rpc_id(int(get_parent().get_name()), 'on_hit')


onready var explosion = preload('res://Game/Player/Graphics/Explosion.tscn').instance()
sync func die():
	explosion.global_transform = get_parent().global_transform
	get_node('/root/Game').add_child(explosion)
	get_parent().queue_free()

onready var timer = get_node('../Timer')
remote func automatic_shoot(damage, period):
	timer.wait_time = period
	if timer.get_time_left() <= 0:
		shoot(damage)
		timer.start()
	

onready var raycast = get_node('../CameraHolder/RayCast')
func shoot(damage):
	assert(lobby.get_network_mode(self) == lobby.NetworkMode.SERVER)
	if raycast.is_colliding():
		var target = raycast.get_collider()
		if target.has_node(NodePath('ServerScript')):
			target.get_node('ServerScript').deal_damage(damage)
		rpc('on_target_hit', raycast.get_collision_point())
	rpc('on_shot')

sync func on_shot():
	get_node('../MuzzleFlash').flash()
	get_node('../Graphics').fire_animation()
	pass

sync func on_target_hit(point):
	var sparks = get_node('../Graphics/Sparks')
	sparks.global_transform.origin = point
	sparks.restart()

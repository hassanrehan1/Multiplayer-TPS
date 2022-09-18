extends Node

onready var body = get_parent()
const SPEED = 500
const GRAVITY = 200

func _ready():
	if lobby.get_network_mode(self) == lobby.NetworkMode.LOCAL:
		print(get_parent().get_name(), ':local_script')
		get_node('../CameraHolder/Camera').make_current()
		get_node('../CameraHolder/Crosshair').visible = true


func _process(delta):
	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		get_node('../ServerScript').rpc_id(1, 'automatic_shoot', 2, 0.1)
	
	var camerapos_raycast = get_node('../CameraHolder/CameraPosRayCast')
	var camera = get_node('../CameraHolder/Camera')
	var raycast = get_node('../CameraHolder/RayCast')
#	if camerapos_raycast.is_colliding():
#		camera.global_transform.origin = helpers.vlerp(camerapos_raycast.global_transform.origin, camerapos_raycast.get_collision_point(), 0.7)
#	else:
#		camera.transform.origin = camerapos_raycast.transform.origin + camerapos_raycast.transform.xform(camerapos_raycast.cast_to)
#	raycast.global_transform.origin = camera.global_transform.origin
	
	
	var crosshair = get_node('../CameraHolder/Crosshair')
	crosshair.modulate = Color(1,1,1)
	if raycast.is_colliding():
		if raycast.get_collider().has_node(NodePath('ServerScript')):
			crosshair.modulate = Color(1,0,0)

var velocity_y = 0
func _physics_process(delta):
	rotation(delta)
	
	var forward = helpers.get_forward(body.transform)
	var right = helpers.get_right(body.transform)
	var up = helpers.get_up(body.transform)
	
	var direction = Vector3()
	if Input.is_key_pressed(KEY_W):
		direction += forward
	if Input.is_key_pressed(KEY_S):
		direction -= forward
	if Input.is_key_pressed(KEY_A):
		direction -= right
	if Input.is_key_pressed(KEY_D):
		direction += right
	
	velocity_y -= GRAVITY * delta
	if body.is_on_floor():
		velocity_y = 0
	
	var movement = direction.normalized() * SPEED * delta + Vector3(0,velocity_y,0) * delta
	body.move_and_slide(movement)
	
	
	var moving = direction.length() > 0.2
	
	get_node('../Graphics').moving = moving
	
	get_node('../RemoteScript').rpc_unreliable('sync_data', body.transform, moving, get_node('../CameraHolder').transform)


var mouse_relative = Vector2()

func _input(event):
	if event is InputEventMouseMotion:
		mouse_relative = event.relative

const SENSITIVITY = 0.2
func rotation(delta):
	var camera_holder = get_node('../CameraHolder')
	camera_holder.rotate_x(-mouse_relative.y*delta*SENSITIVITY)
	
	body.rotate_y(-mouse_relative.x*delta*SENSITIVITY)
	
	mouse_relative = Vector2()


remote func on_hit():
	assert(lobby.get_network_mode(self) == lobby.NetworkMode.LOCAL)
	var server_script = get_node('../ServerScript')
	get_node('../DamageFlash').flash(server_script.health, server_script.max_health)
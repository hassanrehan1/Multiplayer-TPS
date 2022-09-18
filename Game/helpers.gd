extends Node

func get_forward(transform):
	return -transform.basis.z

func get_right(transform):
	return transform.basis.x

func get_up(transform):
	return transform.basis.y

func set_enabled(node, enabled):
	node.set_process(enabled)
	node.set_process_input(enabled)
	node.set_physics_process(enabled)

func vlerp(from, to, weight):
	return from + (to-from) * max(min(weight,1),0)

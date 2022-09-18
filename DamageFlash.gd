extends Sprite

func flash(health, max_health):
	print(123)
	modulate.a = (max_health - health)/float(max_health)



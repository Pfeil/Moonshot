extends Area2D

export var number_emitters: int = 100

const PARTICLES = preload("res://effects/border_emitter.tscn")

func set_play_area_size(size: float):
	$CollisionShape2D.shape.radius = size
	for i in range(0, self.number_emitters):
		var p = PARTICLES.instance()
		var angle = i * 2*PI / number_emitters
		p.position = Vector2(size, 0).rotated(angle)
		p.rotate(angle + PI/2)
		self.add_child(p)

func _on_play_area_body_shape_exited(body_id: int, body: Node, body_shape: int, area_shape: int):
	if body == null:
		# this may happen because of things that delete themselves and therefore exit the area.
		return
	
	if body.is_in_group("bullets"):
		body.explode(self)

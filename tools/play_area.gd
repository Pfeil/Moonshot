extends Area2D

export var number_emitters: int = 100

const PARTICLES = preload("res://effects/border_emitter.tscn")
const PLANETS = preload("res://planet/Planet.tscn")

onready var camera = self.get_parent()
onready var shape = self.get_node("CollisionShape2D")

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
	
	if body.is_in_group("planet"):
		camera.remove_planet(body)
		body.queue_free()
		# spawn a new one
		var p: RigidBody2D = PLANETS.instance()  # TODO spawn a random planet (other mass, other kind to make game less boring)
		p.mass = 100 # TODO hack. we should have a constructor to generate a random planet with random properties like mass.
		var spawn_at = camera.global_position + Vector2.RIGHT.rotated(rand_range(0, 2*PI)) * get_area_radius()
		p.global_position = spawn_at
		self.get_tree().root.add_child(p)
		p.apply_central_impulse(-spawn_at.rotated(rand_range(-PI/3, PI/3)) * rand_range(0.1, 0.8) / p.mass)
		
	if body.is_in_group("players"):
		body.linear_velocity = Vector2.ZERO		#TODO velocity should be relative to the mass center
		body.global_position = camera.global_position + (Vector2.RIGHT * get_area_radius() / 2)
		body.reset_scale()

func get_area_radius() -> float:
	return shape.shape.radius


func _on_play_area_body_shape_entered(body_id: int, body: Node, body_shape: int, area_shape: int):
	if body == null:
		# not sure if this can happen.
		print("body entered was null")
		return
		
	if body.is_in_group("bullets"):
		# TODO do we want to register them somewhere?
		pass
		
	if body.is_in_group("planet"):
		camera.add_planet(body)
		
	if body.is_in_group("players"):
		camera.add_player(body)

extends RigidBody2D

const PARTICLES = preload("res://effects/TimedParticles.tscn")

export var EXPLOSION_IMPULSE_MODIFIER: float = 800
export var BULLET_IMPULSE_MODIFIER: float = 350
export var my_scale: float = 1

onready var TIMER = self.get_node("Lifetimer")
onready var PARENT = self.get_parent()
onready var collisionShape: CollisionShape2D = $CollisionShape2D
onready var sprite: Sprite = $Sprite
onready var max_sprite_scale = sprite.scale
onready var max_collision_shape_scale = collisionShape.scale
onready var max_mass = mass

func _ready():
	set_scale(my_scale * Vector2.ONE)

func rescale_by_factor(scale_factor: float):
	my_scale	*= scale_factor
	set_scale(Vector2.ONE * my_scale)


# overwriting set_scale
func set_scale(new_scale: Vector2):
	collisionShape.scale 	= max_collision_shape_scale * new_scale
	sprite.scale 			= max_sprite_scale 			* new_scale
	mass					= max_mass 					* new_scale.length_squared()


func _on_Bullet_body_entered(body: Node):
	if (body != null) and (body.get_class() == "RigidBody2D"):
		body.apply_central_impulse((body.position - self.position).normalized() * EXPLOSION_IMPULSE_MODIFIER * my_scale * my_scale)
	self.explode(body)

func _on_Lifetimer_timeout():
	self.queue_free()

func explode(body: Node):
	if body != null:
		var effect = PARTICLES.instance()
		effect.position = body.global_transform.inverse() * self.global_position
		body.add_child(effect)
		self.queue_free()
	else:
		print("body in explode was null")

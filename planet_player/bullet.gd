extends RigidBody2D

const PARTICLES = preload("res://effects/TimedParticles.tscn")

export var EXPLOSION_IMPULSE: float = 500

var bullet_scale: float = 1

onready var TIMER = self.get_node("Lifetimer")
onready var PARENT = self.get_parent()
onready var collisionShape: CollisionShape2D = $CollisionShape2D
onready var sprite: Sprite = $Sprite
onready var maxScale = sprite.scale
onready var maxMass = mass

func _ready():
	_set_scale(bullet_scale)

func _set_scale(new_scale):
	collisionShape.scale 	= maxScale * new_scale
	sprite.scale 			= maxScale * new_scale
	mass					= maxMass * new_scale

func _on_Bullet_body_entered(body: Node):
	if (body != null) and (body.get_class() == "RigidBody2D"):
		body.apply_central_impulse((body.position - self.position).normalized() * EXPLOSION_IMPULSE)
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

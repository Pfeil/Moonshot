extends RigidBody2D

const PARTICLES = preload("res://effects/TimedParticles.tscn")

onready var TIMER = self.get_node("Lifetimer")
onready var PARENT = self.get_parent()

func _on_Bullet_body_entered(body: Node):
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

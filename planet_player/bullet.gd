extends RigidBody2D

const PARTICLES = preload("res://effects/TimedParticles.tscn")

onready var TIMER = self.get_node("Lifetimer")
onready var PARENT = self.get_parent()

func _on_Bullet_body_entered(body: Node):
	var effect = PARTICLES.instance()
	effect.position = body.global_transform.inverse() * self.global_position
	body.add_child(effect)
	self.queue_free()


func _on_Lifetimer_timeout():
	self.queue_free()

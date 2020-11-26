extends Particles2D



func _on_Emitttimer_timeout():
	self.emitting = false

func _on_Lifetimer_timeout():
	self.queue_free()

extends AudioStreamPlayer2D

export var pitch_variance_range: Vector2 = Vector2(0.7, 1.2)
export var silence_between_range: Vector2 = Vector2(3.0, 15.0)

var allow_play = true
onready var timer: Timer = self.get_node("Timer")

func scream(body: Node):
	if self.playing == false and self.allow_play:
		self.allow_play = false
		self.pitch_scale = rand_range(pitch_variance_range.x, pitch_variance_range.y)
		self.play()
		timer.wait_time = rand_range(silence_between_range.x, silence_between_range.y)
		timer.start()


func _on_Timer_timeout():
	self.allow_play = true

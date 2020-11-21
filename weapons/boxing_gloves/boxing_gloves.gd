extends Node2D


onready var HandLeft: Node2D = self.get_node("HandLeft")
onready var HandRight: Node2D = self.get_node("HandRight")

var left_hand_next = false


func _input(event):
	if event.is_action_pressed("Player_ATTACK"):
		if self.left_hand_next:
			self.HandLeft.trigger()
		else:
			self.HandRight.trigger()
		self.left_hand_next = !self.left_hand_next

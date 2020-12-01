extends Control

onready var score_label_p1 = self.get_node("MarginContainer/HBoxContainer/p1")
onready var score_label_p2 = self.get_node("MarginContainer/HBoxContainer/p2")

var score_p1: int = 0
var score_p2: int = 0

func player_event(player_number: int):
	if player_number == 0:
		self.increment_p1()
	elif player_number == 1:
		self.increment_p2()

func increment_p1():
	score_p1 += 1
	score_label_p1.text = str(self.score_p1)
	
func increment_p2():
	score_p2 += 1
	score_label_p2.text = str(self.score_p2)

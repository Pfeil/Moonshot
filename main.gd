extends Node2D


onready var planet_a = self.get_node("Planet")
onready var planet_b = self.get_node("Planet2")
onready var planet_c = self.get_node("Planet3")


# Called when the node enters the scene tree for the first time.
func _ready():
	var factor = 20
	self.planet_a.apply_central_impulse(Vector2.UP   * factor)
	self.planet_b.apply_central_impulse(Vector2.DOWN * factor)
	self.planet_c.apply_central_impulse(Vector2.DOWN * factor)

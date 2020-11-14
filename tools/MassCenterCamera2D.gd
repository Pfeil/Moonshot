extends Camera2D

const step: float = 0.9;  # 0.1 = 10%
onready var planets: Array = get_tree().get_nodes_in_group("planet")


func _process(delta):
	var mass_center: Vector2 = Vector2.ZERO
	var mass_sum: float = 0
	for planet in planets:
		mass_center += planet.get_position() * planet.get_mass()
		mass_sum += planet.get_mass()
	mass_center /= mass_sum
	self.position = mass_center
	print(mass_center)


func _input(event):
	if event.is_action_pressed("Zoom_IN"):
		self.zoom *= self.step
		self.drag_margin_bottom *= self.step
		self.drag_margin_top    *= self.step
		self.drag_margin_left   *= self.step
		self.drag_margin_right  *= self.step
	elif event.is_action_pressed("Zoom_OUT"):
		self.zoom /= self.step
		self.drag_margin_bottom /= self.step
		self.drag_margin_top    /= self.step
		self.drag_margin_left   /= self.step
		self.drag_margin_right  /= self.step

extends Camera2D

const step: float = 0.9;  # 0.1 = 10%

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

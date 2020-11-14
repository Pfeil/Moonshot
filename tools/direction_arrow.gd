extends Line2D

onready var end: Vector2 = self.points[1]

func set_direction(direction: Vector2):
	self.points[1] = direction
	
func set_percent(percent: float):
	var begin: Vector2 = self.points[0]
	self.points[1] = begin.linear_interpolate(self.end, percent)

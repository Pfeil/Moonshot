extends Camera2D

# larger allows to zoom further away.
export var maximum_distance: float = 4000
# minimal margin between players and end of the screen (multiplyer)
export var bounary_to_players: float = 2

const step: float = 0.9;  # 0.1 = 10%
onready var planets: Array = self.get_tree().get_nodes_in_group("planet")
onready var players: Array = self.get_tree().get_nodes_in_group("players")


func _process(_delta):
	var mass_center: Vector2 = Vector2.ZERO
	var mass_sum: float = 0
	for planet in planets:
		mass_center += planet.get_position() * planet.get_mass()
		mass_sum += planet.get_mass()
	mass_center /= mass_sum
	self.position = mass_center
	
	self.adjust_zoom_level()


func _input(event):
	# currently not used (zoom is automatic!)
	var zoom_out_allow: bool = self.zoom.x < self.maximum_distance
	if event.is_action_pressed("Zoom_IN"):
		self.zoom *= self.step
		self.drag_margin_bottom *= self.step
		self.drag_margin_top    *= self.step
		self.drag_margin_left   *= self.step
		self.drag_margin_right  *= self.step
	elif zoom_out_allow and event.is_action_pressed("Zoom_OUT"):
		self.zoom /= self.step
		self.drag_margin_bottom /= self.step
		self.drag_margin_top    /= self.step
		self.drag_margin_left   /= self.step
		self.drag_margin_right  /= self.step

func adjust_zoom_level():
	var self_x = self.global_position.x
	var self_y = self.global_position.y
	var x: float = abs(self.players[0].global_position.x - self_x)
	var y: float = abs(self.players[0].global_position.y - self_y)
	var b = self.bounary_to_players
	
	for thing in self.players:
		x = max(x, abs(thing.global_position.x - self_x)) * b
		y = max(y, abs(thing.global_position.y - self_y)) * b
	
	var target_size: Vector2 = Vector2(x, y)
	$max_distance.set_direction(target_size) # debug
	$boundary_indicator.position = target_size # debug
	var distance = min(target_size.length(), self.maximum_distance) # This determines the maximum zoom level!
	var window_size: Vector2 = OS.window_size
	var screen_radius: float = (min(window_size.y, window_size.x) * self.zoom.x) / 2.0
	$screen_end_indicator.position = Vector2(screen_radius, screen_radius) # debug
	var factor: float = distance / screen_radius
	self.zoom *= Vector2(factor, factor)

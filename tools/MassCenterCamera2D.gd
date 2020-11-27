extends Camera2D

# larger allows to zoom further away.
export var minimal_zoom_level: float = 5
# minimal margin between players and end of the screen (multiplyer)
export var bounary_to_players: float = 2
export var camera_zoom_speed: float = 0.01

const step: float = 0.9;  # 0.1 = 10%
onready var planets: Array = self.get_tree().get_nodes_in_group("planet")
onready var players: Array = self.get_tree().get_nodes_in_group("players")

onready var camera_start_size: Rect2 = self.get_viewport_rect()

onready var arrow_distance = self.get_node("max_distance")


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
	var zoom_out_allow: bool = self.zoom.x < self.minimal_zoom_level
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
	self.arrow_distance.set_direction(target_size)
	var distance = target_size.length()
	var max_size: Vector2 = self.camera_start_size.size
	var factor_difference: float = distance / max_size.y
	var max_factor: float = min(factor_difference, self.minimal_zoom_level)
	self.zoom = self.zoom.linear_interpolate(Vector2(max_factor, max_factor), self.camera_zoom_speed)

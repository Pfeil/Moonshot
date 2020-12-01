extends Camera2D

# larger allows to zoom further away.
export var maximum_distance: float = 4000
# minimal margin between players and end of the screen (multiplyer)
export var bounary_to_players: float = 2
# in case of a changed mass center, use this factor for interpolation
export var camera_move_interpolation_factor: float = 0.005
# in case of changed player positions (especially "beaming") this is used to interpolate.
export var camera_zoom_interpolation_factor: float = 0.1

const step: float = 0.9;  # 0.1 = 10%
onready var planets: Array = self.get_tree().get_nodes_in_group("planet")
onready var players: Array = self.get_tree().get_nodes_in_group("players")


func _ready():
	for planet in planets:
		planet.connect("planet_deleted", self, "_on_planet_deleted")
		planet.connect("planet_created", self, "_on_planet_created")	#emited by planet if it fuses with other planet and new fused planet is created
	$play_area.set_play_area_size(self.maximum_distance)

func _on_planet_deleted(planet):
	remove_planet(planet)

func _on_planet_created(planet):
	add_planet(planet)

func _process(_delta):
	var mass_center: Vector2 = Vector2.ZERO
	var mass_sum: float = 0
	for planet in planets:
		if planet != null:	#TODO dirty fix
			mass_center += planet.get_position() * planet.get_mass()
			mass_sum += planet.get_mass()
	mass_center /= mass_sum
	self.position = self.position.linear_interpolate(mass_center, self.camera_move_interpolation_factor)
	
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
	#$max_distance.set_direction(target_size) # debug
	#$boundary_indicator.position = target_size # debug
	var distance = min(target_size.length(), self.maximum_distance) # This determines the maximum zoom level!
	var window_size: Vector2 = OS.window_size
	var screen_radius: float = (min(window_size.y, window_size.x) * self.zoom.x) / 2.0
	#$screen_end_indicator.position = Vector2(screen_radius, screen_radius) # debug
	var factor: float = distance / screen_radius
	self.zoom *= Vector2(1,1).linear_interpolate(Vector2(factor, factor), self.camera_zoom_interpolation_factor)

func remove_planet(body: Node):
	var index = self.planets.find(body)
	if index != -1:
		self.planets.remove(index)
	
func add_planet(body: Node):
	if self.planets.find(body) == -1 and body.is_in_group("planet"):
		self.planets.push_back(body)

func add_player(body: Node):
	if self.players.find(body) == -1 and body.is_in_group("players"):
		self.players.push_back(body)

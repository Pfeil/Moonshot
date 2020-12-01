tool
extends RigidBody2D

const G = 1000		#TODO adjust this constant
const MAX_SCALE = 10		#Scale at which planet explodes
const EXPLOSION_IMPULSE_FACTOR = 1000	# strength of impulse at which smaller planets from explosion 

var editor_variables_setup:bool = false
var is_in_physics_ready = true

export var density: float = 10	setget set_density
export var my_scale: float = 1	setget set_my_scale

export var start_impulse: Vector2 = Vector2.ZERO
export var path_to_central_planet: NodePath
export var around_planet_circulating_objects = []

var rigidBodiesInRange = []

onready var current_force = start_impulse
onready var impulse_arrow = $ImpulseArrow
onready var sprite: Sprite = $Sprite
onready var shape: CollisionShape2D = $Shape
onready var planet = load("res://planet/Planet.tscn")
var is_not_allowed_to_fuse = false
var original_sprite_scale
var original_shape_scale

signal planet_deleted(planet)
signal planet_created(planet)

func _ready():
	setup_editor_variables()
	set_my_scale(my_scale)
	set_density(density)

func set_density(new_density):
	density = new_density
	set_mass(my_scale * my_scale * density)

func set_mass(new_mass):
	mass = new_mass
	density = (mass / (my_scale * my_scale))

func set_my_scale(new_my_scale: float):
	my_scale = new_my_scale
	if sprite:
		sprite.scale 	= new_my_scale * original_sprite_scale
	if shape:
		shape.scale 	= new_my_scale * original_shape_scale
	mass = my_scale * my_scale * density


#TODO
func explode():
	self.is_not_allowed_to_fuse = true
	print("explode!")
	var radius_old = shape.shape.radius * my_scale	#TODO think abour better variable to set distance between new planets
	print(radius_old)
	var new_scale = my_scale / 4
	var distance_to_center = new_scale
	print("explosion_position: "+str(self.position))
	create_new_planet(self.position + Vector2.UP * 1*radius_old, 	new_scale, self.linear_velocity, Vector2.UP * EXPLOSION_IMPULSE_FACTOR)
	create_new_planet(self.position + Vector2.DOWN * 1*radius_old, 	new_scale, self.linear_velocity, Vector2.DOWN * EXPLOSION_IMPULSE_FACTOR)
	create_new_planet(self.position + Vector2.LEFT * 1*radius_old, 	new_scale, self.linear_velocity, Vector2.LEFT * EXPLOSION_IMPULSE_FACTOR)
	create_new_planet(self.position + Vector2.RIGHT * 1*radius_old,	new_scale, self.linear_velocity, Vector2.RIGHT * EXPLOSION_IMPULSE_FACTOR)
	emit_signal("planet_deleted", self)
	self.call_deferred("queue_free")


func create_new_planet(planet_position, planet_scale, planet_velocity: Vector2 = Vector2.ZERO, planet_start_impulse: Vector2 = Vector2.ZERO):
	var planet_instance: RigidBody2D = planet.instance()
	planet_instance.is_not_allowed_to_fuse = true
	planet_instance.position = planet_position
	planet_instance.my_scale = planet_scale
	planet_instance.linear_velocity = planet_velocity
	#get_tree().get_root().call_deferred("add_child", planet_instance)
	get_tree().get_root().add_child(planet_instance)
	planet_instance.apply_central_impulse( planet_start_impulse)
	print(planet_instance.position)
	#planet_instance.is_not_allowed_to_fuse = false
	emit_signal("planet_created", planet_instance)


func setup_editor_variables():
	sprite = $Sprite
	shape = $Shape
	original_sprite_scale = sprite.scale
	original_shape_scale = shape.scale
	editor_variables_setup = true

func _physics_process(_delta: float):
	if Engine.editor_hint:	# Code to execute in editor:
		if not editor_variables_setup:
			setup_editor_variables()
	if not Engine.editor_hint:	# Code to execute in game:
		
		if is_in_physics_ready:
			if path_to_central_planet:
				var central_planet = get_node(path_to_central_planet)
				var vec_to_central_planet: Vector2 = (central_planet.position - position)
				var distance: float = vec_to_central_planet.length()
				var orbit_direction = Vector2(vec_to_central_planet.y, -vec_to_central_planet.x).normalized()
				self.apply_central_impulse( orbit_direction * sqrt( (G * (central_planet.mass + mass) ) / (distance) ) )
				impulse_arrow.set_direction(orbit_direction * 100)
			else:
				apply_central_impulse(start_impulse)
			is_in_physics_ready = false

		if my_scale >= MAX_SCALE:
			explode()

		for body in rigidBodiesInRange:
			if body != null:	#check if body still exists
				var distance_vector: Vector2 = body.get_position() - self.get_position()
				var distance_squared: float = distance_vector.length_squared()
				var dir_vector: Vector2 = distance_vector.normalized()
				if distance_squared > 0.1:
					var impulse = G * (body.get_mass() * mass) / distance_squared
					var impulse_vector = impulse * dir_vector
					body.apply_central_impulse(-impulse_vector)
				
	# Code to execute both in editor and in game:


func rescale_by_factor(scale_factor: float):
	sprite.scale 	*= scale_factor
	shape.scale 	*= scale_factor
	mass 			*= scale_factor * scale_factor


func _on_GravityArea_body_entered(body):
	if body.get_class() == "RigidBody2D":
		if body == self:
			return
		if body in rigidBodiesInRange:
			return
		rigidBodiesInRange.append(body)


func _on_GravityArea_body_exited(body):
	if body in rigidBodiesInRange:
		rigidBodiesInRange.erase(body)


func _on_Planet_body_entered(body):
	if body.is_in_group("planet"):
		# fuse with other planet
		if not (self.is_not_allowed_to_fuse or body.is_not_allowed_to_fuse):
			self.is_not_allowed_to_fuse = true
			body.is_not_allowed_to_fuse = true
			emit_signal("planet_deleted", self)
			body.emit_signal("planet_deleted", self)
			
			var planet_instance = planet.instance()
			planet_instance.position = (body.get_global_position() + self.get_global_position())/2
			planet_instance.my_scale = body.my_scale + self.my_scale
			planet_instance.linear_velocity = (body.linear_velocity + self.linear_velocity)/2

			get_tree().get_root().call_deferred("add_child", planet_instance)
			emit_signal("planet_created", planet_instance)
		self.call_deferred("queue_free")

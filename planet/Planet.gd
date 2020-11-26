extends RigidBody2D

const G = 1000		#TODO adjust this constant

export var start_implulse: Vector2 = Vector2.ZERO
export var path_to_central_planet: NodePath
export var around_planet_circulating_objects = []

var rigidBodiesInRange = []

onready var current_force = start_implulse
onready var impulse_arrow = $ImpulseArrow
var is_in_physics_ready = true


func _physics_process(delta: float):
	if is_in_physics_ready:
		if path_to_central_planet:
			var central_planet = get_node(path_to_central_planet)
			var vec_to_central_planet: Vector2 = (central_planet.position - position)
			var distance: float = vec_to_central_planet.length()
			var orbit_direction = Vector2(vec_to_central_planet.y, -vec_to_central_planet.x).normalized()
			self.apply_central_impulse( orbit_direction * sqrt( (G * (central_planet.mass + mass) ) / (distance) ) )
			impulse_arrow.set_direction(orbit_direction * 100)
		else:
			apply_central_impulse(start_implulse)
		is_in_physics_ready = false
	
	for body in rigidBodiesInRange:
		var distance_vector: Vector2 = body.get_position() - self.get_position()
		var distance_squared: float = distance_vector.length_squared()
		var dir_vector: Vector2 = distance_vector.normalized()
		var impulse = G * (body.get_mass() * mass) / distance_squared
		var impulse_vector = impulse * dir_vector
		body.apply_central_impulse(-impulse_vector)



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

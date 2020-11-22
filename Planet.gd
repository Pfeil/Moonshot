extends RigidBody2D

const G = 1		#TODO adjust this constant

export var start_implulse = Vector2.ZERO
export var around_planet_circulating_objects = []

var rigidBodiesInRange = []

onready var current_force = start_implulse
onready var impulse_arrow = $ImpulseArrow

func _ready():
	apply_impulse(Vector2.ZERO, start_implulse)


func _physics_process(delta: float):
	for body in rigidBodiesInRange:
		var distance_vector: Vector2 = body.get_position() - self.get_position()
		var distance_squared: float = distance_vector.length_squared()
		var dir_vector: Vector2 = distance_vector.normalized()
		var impulse = G * (self.get_mass() * body.get_mass()) / distance_squared
		var impulse_vector = impulse * dir_vector
		body.apply_central_impulse(-impulse_vector)

#overrides apply_central_impulse() to get current force
func apply_central_impulse(impulse):
	.apply_central_impulse(impulse)
	current_force += impulse
	

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

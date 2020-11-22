extends RigidBody2D

### Multiplayer Stuff ###
export var player_num = 0


### Jumping section ###
enum PLAYER_STATE {
	ON_FLOOR,
	GETTING_OFF,
	MID_AIR,
}
var state: int = PLAYER_STATE.MID_AIR
onready var jump_charger_bar = self.get_node("jump_charger")
var jump_charge_time: float = 0
export var jump_charge_max_seconds: float = 3
export var jump_factor = 25

### kinematic control ###
export var moving_speed = 20
var control_direction: Vector2 = Vector2.ZERO
onready var control_arrow: Line2D = self.get_node("control_vector")
var sticky_to = null
export var kinematic_gravity: float = 25.0

### Velocity vector ###
onready var velocity_arrow = self.get_node("velocity_vector")


func _ready():
	self.mode = MODE_RIGID

func _process(delta):
	self.update_direction_vectors()
	self.updateVectors()
	if self.state == PLAYER_STATE.ON_FLOOR:
		self.flip()
		if Input.is_action_pressed("Player_"+str(player_num)+"_JUMP") and self.jump_charge_max_seconds > self.jump_charge_time:
			self.jump_charge_time += delta
			self.jump_charger_bar.set_percent(self.jump_charge_time / self.jump_charge_max_seconds)
		elif Input.is_action_just_released("Player_"+str(player_num)+"_JUMP"):
			# resetting the bar and time will be done later, when in mid air
			self.state = PLAYER_STATE.GETTING_OFF
	
	if self.state == PLAYER_STATE.MID_AIR:
		self.jump_charge_time = 0
		self.jump_charger_bar.set_percent(0)


func _physics_process(delta):
	if self.state == PLAYER_STATE.ON_FLOOR:
		var in_air = not (self.sticky_to in self.get_colliding_bodies())
		var sticky_vector: Vector2 = (self.sticky_to.position - self.position).normalized()
		var next_step: Vector2 = self.control_direction.rotated(self.rotation) * delta
		var gravity_step: Vector2 = sticky_vector * self.kinematic_gravity * delta
		if in_air:
			self.position += gravity_step
		self.position += next_step
		self.rotation = sticky_vector.angle() - PI/2
	elif self.state == PLAYER_STATE.GETTING_OFF:
		self.mode = MODE_RIGID
		self.sticky_to = null
		self.linear_velocity = Vector2.ZERO
		self.state = PLAYER_STATE.MID_AIR
		self.apply_central_impulse(self.calculate_jump_impulse())



func update_direction_vectors():
	if self.state == PLAYER_STATE.ON_FLOOR:
		self.control_direction = Vector2.ZERO
		if Input.is_action_pressed("Player_"+str(player_num)+"_LEFT"):
			self.control_direction.x = -self.moving_speed
		if Input.is_action_pressed("Player_"+str(player_num)+"_RIGHT"):
			self.control_direction.x =  self.moving_speed

func updateVectors():
	self.control_arrow.set_direction(self.control_direction)
	self.velocity_arrow.set_direction(self.linear_velocity.rotated(-self.rotation))
	# TODO visualize applied force?
	
func calculate_jump_impulse():
	var percent: float = self.jump_charge_time / self.jump_charge_max_seconds
	var jump_force = self.control_direction
	jump_force.y = self.moving_speed
	if jump_force.y > 0:
		jump_force.y *= -1
	return jump_force.rotated(self.rotation).normalized() * percent * self.jump_factor

func flip():
	if self.control_direction.x > 0.0:
		self.scale.x = 1
	elif self.control_direction.x < 0.0:
		self.scale.x = -1

func _on_RigidPlayer_body_shape_entered(_body_id: int, body: Node, _body_shape: int, _local_shape: int):
	if self.state != PLAYER_STATE.GETTING_OFF and body.is_in_group("walkables"):
		print("contact!")
		body.add_child(Polygon2D.new())
		self.state = PLAYER_STATE.ON_FLOOR
		self.mode = MODE_KINEMATIC
		self.sticky_to = body
		#var sticky_vector: Vector2 = self.sticky_to.position - self.position
		#self.rotation = sticky_vector.angle() - PI/2

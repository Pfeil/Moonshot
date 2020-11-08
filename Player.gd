extends RigidBody2D

export var speed: int = 1
export var jump_multiplier: float = 4.0
export var velocity_max: Vector2 = Vector2(5, 5)

onready var steering_arrow: Line2D = self.get_node("steering_arrow")
onready var velocity_arrow: Line2D = self.get_node("velocity_arrow")

var direction: Vector2 = Vector2.ZERO

var on_ground = null
var ground_normal: Vector2 = Vector2.ZERO

var on_back = null
var on_front = null

var on_head = null
var head_direction: Vector2 = Vector2.ZERO

func _ready():
	pass # Replace with function body.

func _process(delta):
	self.get_control_input()
	self.steering_arrow.points[1] = Vector2.ZERO
	self.velocity_arrow.points[1] = self.linear_velocity.rotated(-self.rotation)
	if self.on_ground != null:
		self.steering_arrow.points[1] = self.direction
		self.limit_velocity(self.linear_velocity, self.velocity_max)
		#self.apply_central_impulse(direction.rotated(self.rotation) * delta) # TODO this is in kinematic mode, use another method to move!
		if self.direction.y < 0.001:
			self.direction.y = speed
		self.linear_velocity = direction.rotated(self.rotation) * delta
		#self.translate(direction.rotated(self.rotation) * delta)

func limit_velocity(current: Vector2, limit: Vector2):
	self.linear_velocity.x = min(self.linear_velocity.x, limit.x)
	self.linear_velocity.y = min(self.linear_velocity.y, limit.y)
	
func get_control_input():
	self.direction = Vector2(0.0, 0.0)
	if Input.is_action_just_pressed("Player_JUMP"):
		self.direction.y = self.speed * -self.jump_multiplier
	if Input.is_action_pressed("Player_RIGHT"):
		self.direction.x = self.speed
	if Input.is_action_pressed("Player_LEFT"):
		self.direction.x = -self.speed

func _on_Player_body_shape_entered(body_id: int, body: Node, body_shape: int, local_shape: int):
	if body.is_in_group("walkables") and body is RigidBody2D:
		var rigid: RigidBody2D = body
		var radius: Vector2 = self.get_global_transform().get_origin() - rigid.get_global_transform().get_origin()
		var up: Vector2 = self.get_global_transform().y
		self.on_ground = rigid
		self.ground_normal = radius
		self.head_direction = up
		#self.mode = MODE_KINEMATIC
		self.rotate(radius.angle_to(-up))

func _on_Player_body_shape_exited(body_id, body: Node, body_shape, local_shape):
	if self.on_ground != null && self.on_ground.get_instance_id() == body.get_instance_id():
		self.mode = MODE_RIGID
		self.on_ground = null

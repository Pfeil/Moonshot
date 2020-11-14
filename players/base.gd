extends KinematicBody2D


export var speed: float = 5.0;
export var kinematic_gravity: float = 2.0
export var sticky_vector_length: float = 35.0

var direction: Vector2 = Vector2.ZERO
var sticky_vector: Vector2 = Vector2.DOWN * sticky_vector_length

onready var control_arrow = self.get_node("control_vector")
onready var down_arrow = self.get_node("sticky_vector")
onready var velocity_arrow = self.get_node("linear_velocity_vector")

func _ready():
	pass # Replace with function body.


func _physics_process(delta: float):
	#var down_vector: Vector2 = (Vector2.DOWN * self.sticky_vector_length).rotated(-self.rotation)
	var up_vector: Vector2 = -self.sticky_vector
	var direction: Vector2 = self.direction.rotated(self.rotation)
	
	var velocity: Vector2 = self.move_and_slide_with_snap(direction, self.sticky_vector, up_vector, true, 4, 0.785, false)
		
	for i in self.get_slide_count():
		var collision: KinematicCollision2D = self.get_slide_collision(i)
		if collision.collider.has_method("is_in_group") and collision.collider.is_in_group("walkables"):
			#print("I collided with ", collision.collider.name)
			var collider: Node2D = collision.collider
			self.sticky_vector = collider.position - self.position
			self.rotation = self.sticky_vector.angle() - PI/2
	
	self.control_arrow.set_direction(self.direction)
	self.down_arrow.set_direction(self.sticky_vector.rotated(-self.rotation))
	self.velocity_arrow.set_direction(velocity.rotated(-self.rotation))


func _input(event):
	self.direction.y = self.kinematic_gravity
	
	if event.is_action_pressed("Player_LEFT"):
		self.direction.x -= self.speed
	elif event.is_action_released("Player_LEFT"):
		self.direction.x += self.speed
		
	if event.is_action_pressed("Player_RIGHT"):
		self.direction.x += self.speed
	elif event.is_action_released("Player_RIGHT"):
		self.direction.x -= self.speed

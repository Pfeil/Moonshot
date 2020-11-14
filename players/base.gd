extends KinematicBody2D


export var speed: float = 5.0;
export var kinematic_gravity: float = 2.0
export var sticky_vector_length: float = 10.0

var direction: Vector2 = Vector2.ZERO

onready var control_arrow = self.get_node("control_vector")
onready var down_arrow = self.get_node("sticky_vector")
onready var up_arrow = self.get_node("up_vector")

func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	var down_vector: Vector2 = (Vector2.DOWN * self.kinematic_gravity).rotated(self.rotation)
	var up_vector: Vector2 = -down_vector
	
	self.control_arrow.set_direction(self.direction)
	self.down_arrow.set_direction(down_vector)
	self.up_arrow.set_direction(up_vector)
	
	self.move_and_slide_with_snap(self.direction, down_vector, up_vector)

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

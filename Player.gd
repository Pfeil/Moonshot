extends RigidBody2D


var direction: Vector2 = Vector2.ZERO
var speed = 5;


func _ready():
	pass # Replace with function body.



func _process(delta):
	self.apply_central_impulse(direction)

func _input(event):
	if event.is_action_pressed("Player_RIGHT"):
		self.direction.x += self.speed
	elif event.is_action_pressed("Player_LEFT"):
		self.direction.x -= self.speed
	elif event.is_action_released("Player_RIGHT"):
		self.direction.x -= speed
	elif event.is_action_released("Player_LEFT"):
		self.direction.x += speed


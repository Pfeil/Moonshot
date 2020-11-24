extends "../planet/Planet.gd"

export var PLAYER_NUMBER: int = 0
export var bullet_impulse: float = 100
export var hasRecoil: bool = true

export var JOYPAD_NUMBER = 0
export var JOYPAD_DEADZONE = 0.25


var aiming_direction: Vector2
onready var OS_NAME = OS.get_name()
onready var rotation_point = $RotationPoint
onready var cannon = $RotationPoint/Cannon
onready var bullet_spawn_position = $RotationPoint/Cannon/BulletSpawnPosition
onready var bullet = preload("res://planet_player/bullet.tscn")



func _process(_delta):
	var analogStick_vectors = get_joystick_input()
	if analogStick_vectors[0]:	#Joystick controlls
		aiming_direction = analogStick_vectors[0].normalized()
	elif analogStick_vectors[1]:
		aiming_direction = analogStick_vectors[1].normalized()
	else:	# Mouse controlls
		aiming_direction = (get_global_mouse_position() - transform.get_origin())
	rotation_point.look_at(transform.get_origin() + aiming_direction)

func _physics_process(delta):
	rotation = 0

func _input(event):
	if event.is_action_pressed("Player_"+str(PLAYER_NUMBER)+"_SHOOT"):
		shoot()


func shoot():
	print("peng!")
	var bullet_instance = bullet.instance()
	var bullet_spawn_position_global = bullet_spawn_position.get_global_position()
	get_tree().get_root().add_child(bullet_instance)
	bullet_instance.position = bullet_spawn_position_global
	bullet_instance.rotation = rotation_point.rotation
	bullet_instance.linear_velocity = self.linear_velocity	#TODO
	bullet_instance.apply_central_impulse(Vector2(bullet_impulse, 0).rotated(rotation_point.rotation))
	self.apply_central_impulse(-Vector2(bullet_impulse, 0).rotated(rotation_point.rotation))

func get_joystick_input():
	var leftAnalogStick_vector =Vector2.ZERO
	var rightAnalogStick_vector =Vector2.ZERO
	# TODO: not yet tested on WINDOWS and OSX
	# TODO: not efficient to ask for OS every time.
	# get input from left stick dependent of OS system
	if OS_NAME == "Windows":
		leftAnalogStick_vector = Vector2(Input.get_joy_axis(0, 0), -Input.get_joy_axis(0, 1))
		rightAnalogStick_vector = Vector2(Input.get_joy_axis(0, 2), Input.get_joy_axis(0, 3))
	elif OS_NAME == "X11":
		leftAnalogStick_vector = Vector2(Input.get_joy_axis(0, 0), Input.get_joy_axis(0, 1))
		rightAnalogStick_vector = Vector2(Input.get_joy_axis(0, 2), Input.get_joy_axis(0, 3))
	elif OS_NAME == "OSX":
		leftAnalogStick_vector = Vector2(Input.get_joy_axis(0, 1), Input.get_joy_axis(0, 2))
		rightAnalogStick_vector = Vector2(Input.get_joy_axis(0, 3), Input.get_joy_axis(0, 4))
	else:
		leftAnalogStick_vector = Vector2(Input.get_joy_axis(0, 0), Input.get_joy_axis(0, 1))
		rightAnalogStick_vector = Vector2(Input.get_joy_axis(0, 2), Input.get_joy_axis(0, 3))
	# take Deadzone of the sticks in account
	if leftAnalogStick_vector.length() < JOYPAD_DEADZONE:
		leftAnalogStick_vector = Vector2(0, 0)
	if rightAnalogStick_vector.length() < JOYPAD_DEADZONE:
		rightAnalogStick_vector = Vector2(0, 0)
	return [leftAnalogStick_vector, rightAnalogStick_vector]

extends "../planet/Planet.gd"

export var PLAYER_NUMBER: int = 0
export var bullet_impulse: float = 100
export var hasRecoil: bool = true

var aiming_direction: Vector2
onready var rotation_point = $RotationPoint
onready var cannon = $RotationPoint/Cannon
onready var bullet_spawn_position = $RotationPoint/Cannon/BulletSpawnPosition
onready var bullet = preload("res://planet_player/bullet.tscn")



func _process(_delta):
	rotation_point.look_at(transform.get_origin() + aiming_direction)
	aiming_direction = (get_global_mouse_position() - transform.get_origin())

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

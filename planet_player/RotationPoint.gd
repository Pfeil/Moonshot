extends Node2D

export var PLAYER_NUMBER: int = 0

export var bullet_impulse: float = 100
export var hasRecoil: bool = true

var aiming_direction: Vector2
onready var cannon = $Cannon
onready var bullet_spawn_position = $Cannon/BulletSpawnPosition
onready var bullet = preload("res://planet_player/bullet.tscn")

func _ready():
	pass


func _process(delta):
	look_at(transform.get_origin() + aiming_direction)

func _input(event):
	if event.is_action_pressed("Player_"+str(PLAYER_NUMBER)+"_SHOOT"):
		shoot()
	aiming_direction = (get_global_mouse_position() - transform.get_origin())


func shoot():
	var bullet_instance = bullet.instance()
	var bullet_spawn_position_global = bullet_spawn_position.get_global_position()
	get_tree().get_root().add_child(bullet_instance)
	bullet_instance.position = bullet_spawn_position_global
	bullet_instance.apply_central_impulse(Vector2(bullet_impulse, 0).rotated(self.rotation))
	get_parent().apply_central_impulse(-Vector2(bullet_impulse, 0).rotated(self.rotation))

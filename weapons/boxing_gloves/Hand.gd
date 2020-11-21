extends Node2D


onready var target_position: Vector2 = self.get_node("TargetPosition").position
onready var start_position: Vector2 = self.get_node("StartPosition").position
onready var glove: KinematicBody2D = self.get_node("Glove")

export var speed: float = 5.0
var spline_position: float = 0.0

var pushing: bool = false
var pulling: bool = false

const boundary: float = 0.01

func _physics_process(delta):
	if self.pushing:
		self.spline_position += speed * delta
		glove.position = start_position.linear_interpolate(target_position, self.spline_position)
		
		if self.spline_position >= 1.0:
			self.pushing = false
			self.pulling = true
	
	elif self.pulling:
		self.spline_position -= speed * delta
		glove.position = start_position.linear_interpolate(target_position, self.spline_position)
		
		if self.spline_position <= 0.0:
			self.pulling = false

func trigger():
	if !self.pushing:
		self.pulling = false
		self.pushing = true

func on_collision():
	self.pushing = false
	self.pulling = true

extends MarginContainer

func _input(event):
	if not event is InputEventMouseMotion:
		get_tree().change_scene("res://main.tscn")

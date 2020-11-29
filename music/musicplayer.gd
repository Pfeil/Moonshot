extends AudioStreamPlayer


var tracks: Array = [
	preload("res://music/Checking Manifest.ogg"),
	preload("res://music/Parabola.ogg"),
	preload("res://music/Race to Mars.ogg")
]

var current_track: int = -1


# Called when the node enters the scene tree for the first time.
func _ready():
	self._on_AudioPlayer_finished()

func _on_AudioPlayer_finished():
	current_track += 1
	current_track %= self.tracks.size()
	self.stream = tracks[current_track]
	self.play()

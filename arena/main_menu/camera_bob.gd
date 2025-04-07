extends Node3D

var elapsed: float = 0.0

func _process(delta: float) -> void:
	position.x = sin(delta * 0.0134)
	position.y = cos(delta * 0.133)

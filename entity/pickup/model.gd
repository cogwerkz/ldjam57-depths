extends Marker3D

func _process(delta: float) -> void:
	rotation_degrees += Vector3(0, 50 * delta, 0)

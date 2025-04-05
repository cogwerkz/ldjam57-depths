extends Camera3D

@export var easing := 60.0

var target_camera: Camera3D


func _ready() -> void:
	target_camera = $"../Player/PlayerSubmarine".camera

func _process(delta: float) -> void:
	if target_camera == null:
		return

	global_transform.basis = global_transform.basis.slerp(target_camera.global_transform.basis, 1.0) #easing * delta)
	global_transform.origin = global_transform.origin.lerp(target_camera.global_transform.origin, 1.0) #easing * delta)

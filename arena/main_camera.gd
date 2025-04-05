extends Camera3D

@export var easing := 60.0

var target_camera: Camera3D


func _ready() -> void:
	target_camera = $"../Player/PlayerSubmarine".camera

func _physics_process(delta: float) -> void:
	if target_camera == null:
		return

	global_transform = global_transform.interpolate_with(target_camera.global_transform, easing * delta)

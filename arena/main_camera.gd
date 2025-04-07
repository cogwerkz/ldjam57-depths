extends Camera3D

@export var easing := 60.0
@export var player: PlayerSubmarine

var target_camera: Camera3D


func _ready() -> void:
	if player != null:
		target_camera = player.camera

func _physics_process(delta: float) -> void:
	if target_camera == null:
		return

	global_transform = global_transform.interpolate_with(target_camera.global_transform, easing * delta)

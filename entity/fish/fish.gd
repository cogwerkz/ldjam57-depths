extends Node3D

@onready var path_follow: PathFollow3D = $Path3D/PathFollow3D

@onready var fishes: Array[Node3D] = [
	$Path3D/PathFollow3D/BlueFish, $Path3D/PathFollow3D/Clownfish
]

func _ready() -> void:
	path_follow.progress += randf_range(0.0, 0.1)
	fishes[randi() % fishes.size()].visible = true

func _process(delta: float) -> void:
	path_follow.progress += delta

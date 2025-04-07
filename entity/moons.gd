extends Node3D

@onready var moon_parent = $Node3D
@onready var moon1 = $Node3D/Moon1
@onready var moon2 = $Node3D/Moon2

func _process(delta: float) -> void:
	moon_parent.rotate_y(0.8 * delta)
	moon1.rotate_x(0.7 * delta)
	moon2.rotate_x(0.6 * delta)

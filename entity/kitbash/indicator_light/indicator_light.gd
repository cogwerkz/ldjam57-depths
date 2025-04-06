extends Node3D
class_name IndicatorLight

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var animator: AnimationPlayer = $AnimationPlayer

@export var color: Color = Color(1.0, 1.0, 1.0, 1.0):
	set(val):
		color = val
	get():
		return color

@export_range(0.0, 10.0, 0.1) var intensity: float = 1.0:
	set(val):
		intensity = val
	get():
		return intensity

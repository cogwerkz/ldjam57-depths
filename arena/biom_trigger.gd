extends Area3D
class_name BiomTrigger

@export var biom: String = ""

func _ready() -> void:
	set_collision_layer_value(6, true)

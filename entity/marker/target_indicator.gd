extends Node3D
class_name TargetIndicator

@export var follow_target: Node3D

func _process(delta: float) -> void:
	if follow_target != null and is_instance_valid(follow_target):
		global_position = follow_target.global_position
	else:
		follow_target = null
		visible = false

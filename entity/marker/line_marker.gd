@tool
extends Node3D
class_name LineMarker

@export var from: Node3D
@export var to: Node3D

@export var color: Color = Color(1, 1, 1, 1):
	set(val):
		color = val
		if !is_node_ready():
			await ready
		material_override.albedo_color = color
	get():
		return color

@onready var line_renderer := $LineRenderer3D
@onready var material_override: StandardMaterial3D = line_renderer.material_override

var is_dead := false

var start: Vector3
var end: Vector3

func _ready() -> void:
	line_renderer.points = [Vector3.ZERO, Vector3.ZERO] as Array[Vector3]
	top_level = true
	
func _process(_delta: float) -> void:
	if from != null and is_instance_valid(from):
		start = from.global_position
	
	if to != null and is_instance_valid(to):
		end = to.global_position
		
	line_renderer.points = [start, end] as Array[Vector3]

func destroy(colapse_at_end: bool = false) -> void:
	is_dead = true
	var tween := get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	
	if colapse_at_end:
		tween.tween_property(self, "start", end, 0.4)
	else:
		tween.tween_property(self, "end", start, 0.4)
	
	await tween.finished
	
	queue_free()

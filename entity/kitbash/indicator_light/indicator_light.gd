@tool
extends Node3D
class_name IndicatorLight

@onready var light: MeshInstance3D = $Light
@onready var light_material: StandardMaterial3D = light.mesh.surface_get_material(0)
@onready var blip: MeshInstance3D = $Blip
@onready var blip_material: StandardMaterial3D = blip.mesh.surface_get_material(0)
@onready var animator: AnimationPlayer = $AnimationPlayer

@export_range(-1.0, 1.0, 0.1) var light_phase_offset: float = 0.0:
	set(val):
		light_phase_offset = val
		if not is_node_ready():
			await ready
		animator.seek(light_phase_offset * animator.get_animation(animator.current_animation).length)
	get():
		return light_phase_offset

@export var color: Color = Color(1.0, 1.0, 1.0, 1.0):
	set(val):
		color = val
		if not is_node_ready():
			await ready
		light_material.albedo_color = color * intensity
		light_material.albedo_color.a = 1.0
		blip_material.albedo_color = color * intensity
		blip_material.albedo_color.a = 1.0
	get():
		return color

@export_range(0.0, 10.0, 0.1) var intensity: float = 1.0:
	set(val):
		intensity = val
		if not is_node_ready():
			await ready
		light_material.albedo_color = color * intensity
		light_material.albedo_color.a = 1.0
		blip_material.albedo_color = color * intensity
		blip_material.albedo_color.a = 1.0
	get():
		return intensity

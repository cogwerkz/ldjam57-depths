extends Node3D

@onready var label: Label3D = $Label3D
@export var life: float
@export var anchor: Node3D
@export var text: String

func _ready() -> void:
	var material = $Marker3D/MeshInstance3D.mesh.surface_get_material(0)
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_property(material, "albedo_color", Color(1.0, 1.0, 1.0, 0.0), life)
	tween.parallel().tween_property(label, "modulate", Color(1.0, 1.0, 1.0, 0.0), life)
	await tween.finished
	queue_free()
	
func _process(_delta: float) -> void:
	var distance = anchor.global_position.distance_to(global_position)
	label.text = "%s\n%.2fm" % [text, distance]

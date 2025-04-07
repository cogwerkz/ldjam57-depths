extends Node3D

@export var player: PlayerSubmarine

@onready var bounds: Area3D = $DangerAreas/Area3D
@onready var danger_overlay: ColorRect = $ColorRect


func _ready() -> void:
	bounds.body_exited.connect(body_exited)
	bounds.body_entered.connect(body_entered)
	danger_overlay.color.a = 0.0
	danger_overlay.visible = false

func body_exited(body: Node3D) -> void:
	if not body is PlayerSubmarine or not(body as PlayerSubmarine).current_state.is_alive():
		return
	danger_overlay.visible = true
	var tween = get_tree().create_tween()
	tween.tween_property(danger_overlay, "color", Color(1, 1, 1, 0.5), 0.3)
	
func body_entered(body: Node3D) -> void:
	if not body is PlayerSubmarine or not(body as PlayerSubmarine).current_state.is_alive():
		return
	var tween = get_tree().create_tween()
	tween.tween_property(danger_overlay, "color", Color(1, 1, 1, 0.0), 0.3)
	await tween.finished
	danger_overlay.visible = false

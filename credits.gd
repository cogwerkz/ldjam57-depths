extends Control

func _ready() -> void:
	await get_tree().create_timer(1).timeout
	get_tree().create_tween().tween_property($ColorRect/MarginContainer/RichTextLabel, "visible_ratio", 1, 3)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_end"):
		get_tree().change_scene_to_file("main")

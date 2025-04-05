extends Node3D

@onready var skill_tree_panel = %SkillTreePanel

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

	if event.is_action_pressed("upgrades"):
		skill_tree_panel.visible = !skill_tree_panel.visible

func _on_skill_tree_panel_visibility_changed() -> void:
	if skill_tree_panel.visible:
		get_tree().paused = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		get_tree().paused = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

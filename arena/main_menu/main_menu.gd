extends Node3D

func _ready() -> void:
	$Node3D/MainCamera.make_current()
	if OS.has_feature("web"):
		$CanvasLayer/MarginContainer/VBoxContainer/Quit.visible = false
	
	$CanvasLayer/MarginContainer/VBoxContainer/NewGame.button_up.connect(start_new_game)
	$CanvasLayer/MarginContainer/VBoxContainer/Quit.button_up.connect(quit)

func start_new_game() -> void:
	get_tree().change_scene_to_file("res://arena/Game.tscn")
	
func quit() -> void:
	get_tree().quit()

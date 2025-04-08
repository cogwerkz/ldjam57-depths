extends Node3D

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$Node3D/MainCamera.make_current()
	if OS.has_feature("web"):
		$CanvasLayer/MarginContainer/VBoxContainer/Quit.visible = false
	
	$CanvasLayer/MarginContainer/VBoxContainer/NewGame.button_up.connect(start_new_game)
	$CanvasLayer/MarginContainer/VBoxContainer/Quit.button_up.connect(quit)
	$CanvasLayer/MarginContainer/VBoxContainer/Credits.button_up.connect(credits)

func start_new_game() -> void:
	get_tree().change_scene_to_file("res://arena/Game.tscn")
	
func quit() -> void:
	get_tree().quit()

func credits()-> void:
	get_tree().change_scene_to_file("res://credits.tscn")

extends Node3D

func _ready() -> void:
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://arena/main_menu/MainMenu.tscn")

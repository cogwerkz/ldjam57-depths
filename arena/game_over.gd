extends ColorRect

@export var player: PlayerSubmarine

func _ready() -> void:
	$Panel/MarginContainer/VBoxContainer/Button.button_up.connect(go_to_menu)
	modulate.a = 0.0
	if player != null:
		player.game_over.connect(show_game_over)

func show_game_over() -> void:
	self.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.3)

func go_to_menu() -> void:
	get_tree().change_scene_to_file("res://arena/main_menu/MainMenu.tscn")

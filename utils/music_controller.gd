extends Node

@onready var player = $AudioStreamPlayer

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("mute"):
		if player.playing:
			player.stop()
		else:
			player.play()

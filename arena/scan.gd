extends Label

func _ready() -> void:
	visible = false
	await get_tree().create_timer(2).timeout
	modulate = Color.TRANSPARENT
	visible = true
	await get_tree().create_tween().tween_property(self, "modulate", Color.WHITE, 1).finished
	await get_tree().create_timer(5).timeout
	await get_tree().create_tween().tween_property(self, "modulate", Color.TRANSPARENT, 1).finished
	queue_free()

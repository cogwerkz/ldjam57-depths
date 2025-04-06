extends Label

@export var intructons_duration_s: float = 30

func _ready() -> void:
	await get_tree().create_timer(intructons_duration_s).timeout
	await get_tree().create_tween().tween_property(self, "modulate", Color.TRANSPARENT, 1).finished
	queue_free()

extends Node3D

@onready var particles: GPUParticles3D = $GPUParticles3D

func _ready() -> void:
	particles.emitting = true
	await particles.finished
	queue_free()

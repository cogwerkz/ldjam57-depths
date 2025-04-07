extends Node3D

@onready var particles: Array[GPUParticles3D] = [
	$GPUParticles3D2,
	$GPUParticles3D3
]

func _ready() -> void:
	for p in particles:
		p.emitting = true
	await particles[0].finished

	queue_free()

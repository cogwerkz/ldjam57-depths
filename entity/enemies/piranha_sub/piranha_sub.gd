extends RigidBody3D

@export var health: float = 50.0

func enemy_descriptor() -> Dictionary:
	return {
		"name": "Pirahna",
	}
	
func take_damage(amount: float) -> void:
	health -= amount
	if health <= 0.0:
		die()

func die() -> void:
	# TODO: FxManager emit boom effect
	$CollisionShape3D.set_deferred("disabled", true)
	$Area3D/CollisionShape3D.set_deferred("disabled", true)
	var rand_dir = Vector3(randf_range(-0.5, 0.5), randf_range(-0.5, 0.5), randf_range(-0.5, 0.5))
	var rand_force = Vector3(randf_range(-0.5, 0.5), randf_range(-0.5, 0.5), randf_range(-0.5, 0.5)) * 30.0
	var rand_torque = Vector3(randf_range(-0.5, 0.5), randf_range(-0.5, 0.5), randf_range(-0.5, 0.5)) * 60.0
	apply_force(rand_dir, rand_force)
	apply_torque(rand_torque)
	await get_tree().create_timer(2.0).timeout
	queue_free()

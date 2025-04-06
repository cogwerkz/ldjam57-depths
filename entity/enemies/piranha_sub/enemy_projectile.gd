extends Area3D
class_name EnemyProjectile

signal hit_player(projectile: EnemyProjectile, player: Node3D)

@export var life: float = 4.0
@export var projectile_velocity: Vector3

var destroyed := false

func _ready() -> void:
	body_entered.connect(on_hit)
	look_at_from_position(Vector3.ZERO, projectile_velocity.normalized(), Vector3.UP)
	top_level = true

func on_hit(body: Node3D) -> void:
	if body.has_method("player_descriptor"):
		hit_player.emit(self, body)

func _physics_process(delta: float) -> void:
	if destroyed:
		return

	global_position += projectile_velocity * delta
	life -= delta
	if life <= 0.0:
		# TODO: impl FxManager
		destroy()

func destroy() -> void:
	destroyed = true
	$shell.queue_free()
	$CollisionShape3D.set_deferred("disabled", true)
	projectile_velocity = Vector3.ZERO
	$GPUParticles3D.emitting = false
	await $GPUParticles3D.finished
	queue_free()

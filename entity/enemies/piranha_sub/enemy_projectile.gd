extends Area3D
class_name EnemyProjectile

const IMPACT_FX := preload("res://effects/fx/ImpactFx.tscn")

signal hit_player(projectile: EnemyProjectile, player: Node3D)

@export var life: float = 4.0
@export var projectile_velocity: Vector3

@onready var fx_spawn_point: Marker3D = $FxSpawnPoint

var destroyed := false

func _ready() -> void:
	body_entered.connect(on_hit)
	if projectile_velocity.length() > 0.01:
		look_at_from_position(Vector3.ZERO, projectile_velocity.normalized(), Vector3.UP)
	top_level = true
	$Shoot.play()

func on_hit(body: Node3D) -> void:
	if body.has_method("player_descriptor"):
		hit_player.emit(self, body)
		var fx := IMPACT_FX.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
		FxManager.add_fx(fx)
		fx.global_position = fx_spawn_point.global_position

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
	$Hit.play()
	await $GPUParticles3D.finished
	queue_free()

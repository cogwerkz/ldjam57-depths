extends Area3D

const ENEMY_PROJECTILE := preload("res://entity/enemies/piranha_sub/EnemyProjectile.tscn")
const EXPLOSION_FX := preload("res://effects/fx/ExplosionFx.tscn")

const MAX_SPEED := 50.0
const MAX_HEALTH := 30.0
const DAMAGE := 50.0
const PURSUE_THRESHOLD := 20.0

@export var health: float = MAX_HEALTH
@export var pursue_range: float = PURSUE_THRESHOLD

enum ActivityState {
	Idle,
	Pursue,
}

var current_state: ActivityState = ActivityState.Idle
@onready var player: PlayerSubmarine = State.get_player()

var linear_velocity: Vector3 = Vector3.ZERO
var anchor_position: Vector3

var is_dead := false

func _ready() -> void:
	anchor_position = global_position

func _physics_process(delta: float) -> void:
	if is_dead:
		linear_velocity = linear_velocity.move_toward(Vector3.ZERO, 0.2 * delta)
		global_position += linear_velocity
		return
		
	match current_state:
		ActivityState.Idle:
			if player != null and player.global_position.distance_to(global_position) < pursue_range and player.current_state.is_alive():
				current_state = ActivityState.Pursue
				return
			
			var target_dir := anchor_position - global_position
			var distance := target_dir.length()
			var current_dir := -global_basis.z
			var diff := target_dir - current_dir
			var new_dir := current_dir + diff.normalized() * 0.75 * delta
			look_at_from_position(global_position, global_position + new_dir)
			
			if distance > 2.0:
				linear_velocity = new_dir.normalized() * 5.0 * delta
		
			linear_velocity = linear_velocity.move_toward(Vector3.ZERO, 0.2 * delta)
			
			if linear_velocity.length() > MAX_SPEED * 0.5:
				linear_velocity = linear_velocity.normalized() * MAX_SPEED
				
		ActivityState.Pursue:
			var target_dir := player.global_position - global_position
			var distance := target_dir.length()
			var current_dir := -global_basis.z
			var diff := target_dir - current_dir
			var new_dir := current_dir + diff.normalized() * 1.75 * delta
			look_at_from_position(global_position, global_position + new_dir)
			linear_velocity = new_dir.normalized() * 5.0 * delta
			linear_velocity = linear_velocity.move_toward(Vector3.ZERO, 0.2 * delta)
				
			if linear_velocity.length() > MAX_SPEED:
				linear_velocity = linear_velocity.normalized() * MAX_SPEED
			if player.global_position.distance_to(global_position) > pursue_range:
				current_state = ActivityState.Idle
				return
			if !player.current_state.is_alive():
				current_state = ActivityState.Idle
				return
				
			if distance < 3.0:
				explode()
	
	global_position += linear_velocity

func enemy_descriptor() -> Dictionary:
	return {
		"name": "Pufferfish",
	}

func explode() -> void:
	if player.has_method("take_damage"):
		player.take_damage(DAMAGE)
	die()
	
func take_damage(amount: float) -> void:
	health -= amount
	if health <= 0.0:
		die()

func die() -> void:
	is_dead = true
	var fx := EXPLOSION_FX.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
	FxManager.add_fx(fx)
	fx.global_position = global_position
	$CollisionShape3D.set_deferred("disabled", true)
	$Area3D/CollisionShape3D.set_deferred("disabled", true)
	$Explosion.play()
	await get_tree().create_timer(2.0).timeout
	queue_free()

extends RigidBody3D

const ENEMY_PROJECTILE := preload("res://entity/enemies/piranha_sub/EnemyProjectile.tscn")
const EXPLOSION_FX := preload("res://effects/fx/ExplosionFx.tscn")

const MAX_SPEED := 50.0
const MAX_HEALTH := 50.0
const PATROL_THRESHOLD := 5.0
const WEAPON_COOLDOWN := 3.0
const DAMAGE := 20.0
const PURSUE_THRESHOLD := 20.0
const KEEP_DISTANCE_RANGE := 6.0

@export var health: float = MAX_HEALTH
@export var pursue_range: float = PURSUE_THRESHOLD

@export var patrol_markers: Array[Marker3D]

enum ActivityState {
	Patrol,
	Pursue,
	Flee,
}

@onready var action_point: Marker3D = $ActionPoint

@onready var target_marker_index: int = 0 
var current_state: ActivityState = ActivityState.Patrol
@onready var player: PlayerSubmarine = State.get_player()

var cooldown:= WEAPON_COOLDOWN

func _physics_process(delta: float) -> void:
	match current_state:
		ActivityState.Patrol:
			if player != null and player.global_position.distance_to(global_position) < pursue_range and player.current_state.is_alive():
				current_state = ActivityState.Pursue
				return
				
			var next_marker: Marker3D = patrol_markers[target_marker_index] if patrol_markers.size() > target_marker_index else null
			if !next_marker:
				return
			
			var target_dir := next_marker.global_position - global_position
			var distance := target_dir.length()
			if distance < PATROL_THRESHOLD:
				target_marker_index = (target_marker_index + 1) % patrol_markers.size()
				next_marker = patrol_markers[target_marker_index] if patrol_markers.size() > target_marker_index else null
			
			target_dir = next_marker.global_position - global_position
			var current_dir := -global_basis.z
			var diff := target_dir - current_dir
			var new_dir := current_dir + diff.normalized() * 0.75 * delta
			look_at_from_position(global_position, global_position + new_dir)
			apply_force(new_dir.normalized() * 5.0 * delta, Vector3.ZERO)
			
			if linear_velocity.length() > MAX_SPEED * 0.5:
				linear_velocity = linear_velocity.normalized() * MAX_SPEED
				
		ActivityState.Pursue:
			if cooldown > 0.0:
				cooldown -= delta
			if cooldown <= 0.0:
				if try_shoot():
					cooldown = WEAPON_COOLDOWN
			
			var target_dir := player.global_position - global_position
			var distance := target_dir.length()
			var current_dir := -global_basis.z
			var diff := target_dir - current_dir
			var new_dir := current_dir + diff.normalized() * 0.75 * delta
			look_at_from_position(global_position, global_position + new_dir)
			if distance > KEEP_DISTANCE_RANGE:
				apply_force(new_dir.normalized() * 10.0 * delta, Vector3.ZERO)
			else:
				apply_force(new_dir.normalized() * -5.0 * delta, Vector3.ZERO)
				
			if linear_velocity.length() > MAX_SPEED:
				linear_velocity = linear_velocity.normalized() * MAX_SPEED
			if health < 0.25 * MAX_HEALTH:
				current_state = ActivityState.Flee
				return
			if player.global_position.distance_to(global_position) > pursue_range:
				current_state = ActivityState.Patrol
				return
			if !player.current_state.is_alive():
				current_state = ActivityState.Patrol
				return
			
		ActivityState.Flee:
			var target_dir := global_position - player.global_position
			var current_dir := -global_basis.z
			var diff := target_dir - current_dir
			var new_dir := current_dir + diff.normalized() * 0.95 * delta
			look_at_from_position(global_position, global_position + new_dir)
			apply_force(new_dir.normalized() * 40.0 * delta, Vector3.ZERO)
			if linear_velocity.length() > MAX_SPEED:
				linear_velocity = linear_velocity.normalized() * MAX_SPEED
			if player.global_position.distance_to(global_position) > pursue_range * 2.0:
				current_state = ActivityState.Patrol
				return

func enemy_descriptor() -> Dictionary:
	return {
		"name": "Pirahna",
	}
	
func try_shoot() -> bool:
	var target_dir := player.global_position - global_position
	var current_dir := -global_basis.z
	
	var angle = target_dir.normalized().angle_to(current_dir.normalized())
	
	if angle < 0.5:
		var proj: EnemyProjectile = ENEMY_PROJECTILE.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
		proj.projectile_velocity = target_dir.normalized() * 15.0
		add_child(proj)
		proj.global_position = action_point.global_position
		proj.hit_player.connect(on_hit_player)
		return true

	return false

func on_hit_player(projectile: EnemyProjectile, player: Node3D) -> void:
	projectile.destroy()
	if player.has_method("take_damage"):
		player.take_damage(DAMAGE)

	
func take_damage(amount: float) -> void:
	health -= amount
	if health <= 0.0:
		die()

func die() -> void:
	var fx := EXPLOSION_FX.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
	FxManager.add_fx(fx)
	fx.global_position = global_position
	
	$CollisionShape3D.set_deferred("disabled", true)
	$Area3D/CollisionShape3D.set_deferred("disabled", true)
	var rand_dir = Vector3(randf_range(-0.5, 0.5), randf_range(-0.5, 0.5), randf_range(-0.5, 0.5))
	var rand_force = Vector3(randf_range(-0.5, 0.5), randf_range(-0.5, 0.5), randf_range(-0.5, 0.5)) * 2.0
	var rand_torque = Vector3(randf_range(-0.5, 0.5), randf_range(-0.5, 0.5), randf_range(-0.5, 0.5)) * 60.0
	apply_force(rand_dir, rand_force)
	apply_torque(rand_torque)
	$Explosion.play()
	await get_tree().create_timer(2.0).timeout
	queue_free()

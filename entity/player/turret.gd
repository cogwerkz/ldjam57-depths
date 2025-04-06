extends Marker3D

const TARGET_INDICATOR = preload("res://entity/marker/TargetIndicator.tscn")
const PROJECTILE = preload("res://entity/player/Projectile.tscn")


@onready var target_finder: Area3D = $Area3D
@onready var target_finder_collision_shape: CollisionShape3D = $Area3D/CollisionShape3D
@onready var yaw: Node3D = $Yaw
@onready var pitch: Node3D = $Yaw/Pitch
@onready var action_point: Marker3D = $Yaw/Pitch/ActionPoint
@onready var rest_point: Marker3D = $TurretRestTarget
@onready var player: PlayerSubmarine = $".."


@export var limit_yaw_angle = false
@export var turret_max_yaw_speed = 180.0
@export var turret_max_yaw_angle = +90.0
@export var turret_min_yaw_angle = -90.0

@export var turret_max_pitch_speed = 180.0
@export var turret_max_pitch_angle = +70.0
@export var turret_min_pitch_angle = -20.0


@onready var indicator: TargetIndicator = TARGET_INDICATOR.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
var locked_target: Node3D

# Update turret priorities every TURRET_TICK seconds
const TURRET_TICK = 1.0
var tick = TURRET_TICK

var cooldown := 0.0

var yaw_angle := 0.0
var pitch_angle := 0.0

func _ready() -> void:
	if player.has_method("current_state") and player.current_state != null:
		player.current_state.changed.connect(update_turret_state)
		
	indicator.visible = false
	add_child(indicator)
	indicator.top_level = true

func _process(delta: float) -> void:
	tick -= delta
	if tick <= 0.0:
		tick = TURRET_TICK
		tick_turret()
	
	if player != null and player.current_state != null:
		if cooldown < player.current_state.turret_cooldown:
			cooldown += delta
		if cooldown >= player.current_state.turret_cooldown:
			if Input.is_action_pressed("primary_action") and locked_target != null:
				cooldown -= player.current_state.turret_cooldown
				shoot()
				
	track_target(delta)

func update_turret_state() -> void:
	(target_finder_collision_shape.shape as SphereShape3D).radius = player.current_state.turret_range
	# TODO: reflect other state vars as well

func tick_turret() -> void:
	if Engine.is_editor_hint():
		return

	var possible_target: Node3D = locked_target if is_instance_valid(locked_target) else null
	var distance_to_possible_target = global_position.distance_to(locked_target.global_position) if locked_target != null else -1.0
	for target in target_finder.get_overlapping_bodies():
		if target.has_method("enemy_descriptor"):
			var distance = global_position.distance_to(target.global_position)
			if distance_to_possible_target < 0.0 or distance < distance_to_possible_target:
				distance_to_possible_target = distance
				possible_target = target

	# Loose lock if target too far away
	if locked_target != null:
		if global_position.distance_to(locked_target.global_position) > player.current_state.turret_range:
			lock(null)
	else:
		# Finally, pick the new clossest target, if any
		lock(possible_target)
		
func lock(target: Node3D) -> void:
	locked_target = target
	if locked_target == null:
		indicator.visible = false
		indicator.follow_target = null
	else:
		indicator.follow_target = locked_target
		indicator.visible = true

func shoot() -> void:
	var proj: Projectile = PROJECTILE.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
	proj.projectile_velocity = -action_point.global_basis.z * 10.0
	add_child(proj)
	proj.global_position = action_point.global_position
	proj.hit_enemy.connect(on_hit_enemy)

func on_hit_enemy(projectile: Projectile, enemy: Node3D) -> void:
	projectile.destroy()
	if enemy.has_method("take_damage"):
		enemy.take_damage(player.current_state.turret_damage)

func update_yaw(delta: float, target_position: Vector3) -> void:
	var yaw_dir = (yaw.global_transform.inverse() * target_position - yaw.position).normalized()
	var tmp_yaw_axis = Plane(Vector3.UP, 0).project(yaw_dir).normalized()
	var new_yaw_angle = MathUtils.signed_angle_to(
		tmp_yaw_axis,
		Vector3.FORWARD,
		Vector3.DOWN
	)
	# x2 comes from [-360, +360] degree arc of relative movement
	new_yaw_angle =  new_yaw_angle / PI * deg_to_rad(turret_max_yaw_speed * 2.0)
	new_yaw_angle = clamp(new_yaw_angle, -turret_max_yaw_speed, turret_max_yaw_speed) * delta
	if limit_yaw_angle:
		yaw_angle = clamp(yaw_angle + new_yaw_angle, deg_to_rad(turret_min_yaw_angle), deg_to_rad(turret_max_yaw_angle))
	else:
		yaw_angle += new_yaw_angle
	yaw.transform.basis = Basis(Vector3.UP, yaw_angle)

func update_pitch(delta: float, target_position: Vector3) -> void:
	var pitch_dir = (pitch.global_transform.inverse() * target_position).normalized()
	var tmp_pitch_axis = Plane(Vector3.RIGHT, 0.0).project(pitch_dir).normalized()
	var new_pitch_angle = MathUtils.signed_angle_to(
		tmp_pitch_axis,
		Vector3.FORWARD,
		Vector3.LEFT
	)
	# x2 comes from [-360, +360] degree arc of relative movement
	new_pitch_angle = new_pitch_angle / PI * deg_to_rad(turret_max_pitch_speed * 2.0)
	new_pitch_angle = clamp(new_pitch_angle, -turret_max_pitch_speed, turret_max_pitch_speed) * delta
	pitch_angle = clamp(pitch_angle + new_pitch_angle, deg_to_rad(turret_min_pitch_angle), deg_to_rad(turret_max_pitch_angle))
	pitch.transform.basis = Basis(Vector3.RIGHT, pitch_angle)
	
func track_target(delta) -> void:
	if locked_target != null and is_instance_valid(locked_target):
		update_yaw(delta, locked_target.global_position)
		update_pitch(delta, locked_target.global_position)
	else:
		update_yaw(delta, rest_point.global_position)
		update_pitch(delta, rest_point.global_position)

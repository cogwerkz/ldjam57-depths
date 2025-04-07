extends RigidBody3D
class_name PlayerSubmarine


const MARKER := preload("res://entity/marker/PoiMarker.tscn")
const LINE := preload("res://entity/marker/LineMarker.tscn")
const EXPLOSION_FX := preload("res://effects/fx/ExplosionFx.tscn")

@onready var camera: Camera3D = $Camera3D
@onready var crosshair: TextureRect = $Gui/Crosshair
@onready var direction: TextureRect = $Gui/Direction

@onready var pickup_detector: Area3D = $PickupDetector
@onready var scanner: Area3D = $Scanner
@onready var scanner_collider: CollisionShape3D = $Scanner/CollisionShape3D
@onready var scanner_sphere: MeshInstance3D = $Scanner/MeshInstance3D
@onready var scanner_line_container: Node3D = $Scanner/Lines

@onready var propellor_animator: AnimationPlayer = $Thrust/AnimationPlayer

@onready var engine1 = $Thrust/Source/GPUParticles3D
@onready var engine2 = $Thrust/Source/GPUParticles3D2

@onready var scanner_sfx = $Scanner/ScanSFX

# Add reference to the compass node (assign in editor)
@export var compass: Compass

signal game_over()

var current_state: PlayerState
var skill_tree: SkillTree

var mouse_captured = true
var mouse_deltas := Vector2.ZERO

func player_descriptor() -> Dictionary:
	return {
		"name": "player"
	}
	
func take_damage(amount: float) -> void:
	current_state.current_health -= amount
	if current_state.current_health <= 0.0:
		die()

func die() -> void:
	var fx := EXPLOSION_FX.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
	FxManager.add_fx(fx)
	fx.global_position = global_position

	$CollisionShape3D.set_deferred("disabled", true)
	$Turret/Area3D/CollisionShape3D.set_deferred("disabled", true)
	var rand_dir = Vector3(randf_range(-0.5, 0.5), randf_range(-0.5, 0.5), randf_range(-0.5, 0.5))
	var rand_force = Vector3(randf_range(-0.5, 0.5), randf_range(-0.5, 0.5), randf_range(-0.5, 0.5)) * 2.0
	var rand_torque = Vector3(randf_range(-0.5, 0.5), randf_range(-0.5, 0.5), randf_range(-0.5, 0.5)) * 60.0
	apply_force(rand_dir, rand_force)
	apply_torque(rand_torque)
	await get_tree().create_timer(2.0).timeout
	# TODO: show game over scren
	game_over.emit()
	print("ded")

func _ready() -> void:
	skill_tree = State.get_skill_tree()
	current_state = State.get_player_state()
	
	skill_tree.apply_skill_effects(current_state)
	skill_tree.changed.connect(func(): skill_tree.apply_skill_effects(current_state))
	current_state.changed.connect(current_state_updated)
	
	contact_monitor = true
	linear_damp = 2.5
	angular_damp = 3.0
	direction.position = crosshair.position # this makes arrow position independent of viewport size calculation
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	pickup_detector.area_entered.connect(on_pickup)
	
func current_state_updated() -> void:
	pass	

func update_gui() -> void:
	var center = crosshair.position # this makes arrow position independent of viewport size calculation
	direction.position = direction.position.lerp(center + mouse_deltas * 32.0, 0.02)

	var distance = direction.position.distance_to(center)
	var away_from_center = direction.position - center

	direction.rotation = away_from_center.angle() + deg_to_rad(90.0)

	if distance < 64:
		direction.modulate.a = smoothstep(0.0, 1.0, distance / 64.0)
	else:
		direction.modulate.a = 1.0

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if mouse_captured:
			mouse_deltas += event.screen_relative * 0.1

func _physics_process(delta: float) -> void:
	if not current_state.is_alive():
		return

	process_scanner(delta)
	if Input.is_action_just_pressed('debug_toggle_mouse_capture'):
		mouse_captured = !mouse_captured
		if mouse_captured:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	var acceleration := current_state.linear_acceleration * 60.0 * delta
	var overdrive = 2.0
	# if Input.is_action_pressed('throttle_overdrive'):
	#dwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww                                                                                                                                                                         	overdrive = 4.0
	if current_state.current_fuel <= 0.01:
		overdrive = 0.0
	if Input.is_action_pressed('throttle_forward'):
		apply_force(transform.basis.z * -acceleration * overdrive, Vector3.ZERO)
	if Input.is_action_pressed('throttle_backward'):
		apply_force(transform.basis.z * acceleration * overdrive, Vector3.ZERO)
	if Input.is_action_pressed('throttle_up'):
		apply_force(transform.basis.y * acceleration * overdrive, Vector3.ZERO)
	if Input.is_action_pressed('throttle_down'):
		apply_force(transform.basis.y * -acceleration * overdrive, Vector3.ZERO)
	if Input.is_action_pressed('throttle_left'):
		apply_force(transform.basis.x * -acceleration * overdrive, Vector3.ZERO)
	if Input.is_action_pressed('throttle_right'):
		apply_force(transform.basis.x * acceleration * overdrive, Vector3.ZERO)
	if Input.is_action_pressed('roll_left'):
		apply_torque(transform.basis.z * acceleration * overdrive * 0.2)
	if Input.is_action_pressed('roll_right'):
		apply_torque(transform.basis.z * -acceleration * overdrive * 0.2)

	var yaw = mouse_deltas.x / crosshair.position.x * 100000.0 * delta
	var pitch = mouse_deltas.y / crosshair.position.y * 100000.0 * delta
	
	if linear_velocity.length() > current_state.max_speed:
		linear_velocity = linear_velocity.normalized() * current_state.max_speed
	
	# Adjust propellor speed
	var velocity := linear_velocity.length()
	if velocity > 0.0:
		var going_backwards = -global_basis.z.normalized().dot(linear_velocity.normalized()) > 0
		var speed_scale = max(0.1, 8.0 * linear_velocity.length() / current_state.max_speed)
		propellor_animator.speed_scale = speed_scale if not going_backwards else -speed_scale	
			
	apply_torque(transform.basis.y * (-yaw))
	apply_torque(transform.basis.x * (-pitch))
	
	update_gui()

	mouse_deltas *= 0.5
	
	# Always point Y axis up - "auto-leveling"
	var new_x = -global_transform.basis.z.cross(Vector3.UP).normalized()
	var new_z = new_x.cross(Vector3.UP).normalized()
	var new_basis = Basis(new_x, Vector3.UP, new_z)
	global_transform.basis = global_transform.basis.slerp(new_basis, 0.8 * delta)
	
	var speed = linear_velocity.length()
	var fuel_efficiency = current_state.fuel_efficiency
	if speed > 0.0:
		var fuel_consumption = fuel_efficiency * speed * delta / 1000
		current_state.current_fuel -= fuel_consumption
		if current_state.current_fuel <= 0.01:
			current_state.current_fuel = 0.0
			linear_velocity = linear_velocity.lerp(Vector3.ZERO, 0.1)
			angular_velocity = angular_velocity.lerp(Vector3.ZERO, 0.1)
			engine1.emitting = false
			engine2.emitting = false
		current_state.changed.emit()

func on_pickup(area: Area3D):
	if area is Pickup:
		var pickup: Pickup = area
		var descriptor = pickup.pickup_descriptor()
	
		match descriptor.type:
			Pickup.PickupType.Science:
				skill_tree.add_science_points(descriptor.get("amount", 1))
			Pickup.PickupType.Fuel:
				pass
			Pickup.PickupType.Ammo:
				pass
			Pickup.PickupType.LogBook:
				pass
		
		var tween = get_tree().create_tween().parallel()
		tween.tween_property(pickup, "global_position", global_position, 0.2)
		tween.tween_property(pickup, "scale", Vector3(0.1, 0.1, 0.1), 0.2)
		tween.set_ease(Tween.EASE_OUT)
		tween.play()
		await tween.finished
		pickup.queue_free()

# ============= #
# == Scanner == #
# ============= #
signal scanner_ready()
signal scanner_charge_updated(charge_percentage: float)
var scanner_charge_level: float = 0
var is_scanning: bool = false
var is_charged: bool = true
	
func process_scanner(delta: float) -> void:
	if Input.is_action_just_released("tertiary_action") and is_charged:
		scan()

	if !is_scanning and scanner_charge_level > 0.0:
		scanner_charge_level -= delta
		var charge_percentage = 1.0 - (scanner_charge_level/current_state.scanner_cooldown)
		scanner_charge_updated.emit(charge_percentage)
		if scanner_charge_level <= 0.0:
			scanner_charge_updated.emit(1.0)
			scanner_ready.emit()
			is_charged = true
	
func scan() -> void:
	scanner_sfx.play()
	scanner_charge_updated.emit(0.0)
	is_scanning = true
	is_charged = false
	scanner_charge_level = current_state.scanner_cooldown
	(scanner_collider.shape as SphereShape3D).radius = current_state.scanner_range
	
	# Perform scan pulse animation
	var material = scanner_sphere.get_active_material(0)
	scanner_sphere.scale = Vector3(0.1, 0.1, 0.1)
	material.set("shader_parameter/color2", Color(0,8,0,1))
	var tween = get_tree().create_tween()
	var sr = current_state.scanner_range
	tween.tween_property(scanner_sphere, "scale", Vector3(sr, sr, sr), 3.0)
	tween.tween_property(material, "shader_parameter/color2", Color.TRANSPARENT, 0.2)
	await tween.finished
	
	for area in scanner.get_overlapping_areas():
		if area is Pickup:
			var pickup: Pickup = area
			var descriptor: Dictionary = pickup.pickup_descriptor()
			# --- Create screen marker ---
			var marker = MARKER.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
			marker.text = descriptor.name # Use name from descriptor
			marker.life = current_state.scanner_decay
			marker.anchor = self
			# Parent marker to the pickup itself initially, so it moves with it if needed
			# But set top_level so it renders correctly relative to camera
			pickup.add_child(marker)
			marker.global_position = pickup.global_position + Vector3(0.0, 1.5, 0.0)
			marker.top_level = true # Make sure it renders above everything
			
			# --- Add compass marker ---
			if is_instance_valid(compass):
				# Check if descriptor has a type, default if not
				var pickup_type = descriptor.get("type", Pickup.PickupType.Science) # Provide a default if type might be missing
				compass.add_poi(pickup.global_position, pickup_type, current_state.scanner_decay)
			else:
				printerr("PlayerSubmarine: Compass node not assigned!")
	
	is_scanning = false


func _on_pickup_detector_area_entered(area: Area3D) -> void:
	print("AAAAAAAAAAAA")
	if area is BiomTrigger:
		print("BBBBBBBBBBBBBB")
		BiomUtils.set_biom(area.biom)


func _on_pickup_detector_area_exited(area: Area3D) -> void:
	print("CCCCCCCCCCCCCccc")
	if area is BiomTrigger:
		print("DDDDDDDDDDDDDDDdd")
		BiomUtils.set_biom("")

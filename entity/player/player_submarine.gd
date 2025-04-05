extends RigidBody3D
class_name PlayerSubmarine

const MARKER := preload("res://entity/marker/PoiMarker.tscn")

@onready var camera: Camera3D = $Camera3D
@onready var crosshair: TextureRect = $Gui/Crosshair
@onready var direction: TextureRect = $Gui/Direction

@onready var pickup_detector: Area3D = $PickupDetector
@onready var scanner: Area3D = $Scanner

# TODO: use cd and range for scanner from state
const SCANNER_COOLDOWN := 10.0
var scanner_charge := SCANNER_COOLDOWN
var scanner_decay := SCANNER_COOLDOWN * 0.6

@export var current_state: PlayerState = PlayerState.new()
@export var skill_tree: SkillTree

var mouse_captured = true
var mouse_deltas := Vector2.ZERO

func _ready() -> void:
	skill_tree.apply_skill_effects(current_state)
	contact_monitor = true
	linear_damp = 2.5
	angular_damp = 3.0
	direction.position = crosshair.position # this makes arrow position independent of viewport size calculation
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	skill_tree.changed.connect(func(): skill_tree.apply_skill_effects(current_state))
	current_state.changed.connect(current_state_updated)
	
	pickup_detector.area_entered.connect(on_pickup)

func current_state_updated() -> void:
	pass
	
func scan() -> void:
	for area in scanner.get_overlapping_areas():
		if area is Pickup:
			var pickup: Pickup = area
			var marker = MARKER.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
			marker.text = pickup.pickup_descriptor().name
			marker.life = scanner_decay
			marker.anchor = self
			area.add_child(marker)
			marker.global_position = pickup.global_position + Vector3(0.0, 1.5, 0.0)
			marker.top_level = true

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
			mouse_deltas += event.relative * 150.0 * 1.0 / Vector2(get_viewport().size)

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed('debug_toggle_mouse_capture'):
		mouse_captured = !mouse_captured
		if mouse_captured:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	var acceleration := current_state.linear_acceleration * 60.0 * delta
	var overdrive = 1.0
	var should_auto_level = true
	if Input.is_action_pressed('throttle_overdrive'):
		overdrive = 4.0
	if Input.is_action_pressed('throttle_forward'):
		apply_force(transform.basis.z * -acceleration * overdrive, Vector3.ZERO)
		should_auto_level = false
	if Input.is_action_pressed('throttle_backward'):
		apply_force(transform.basis.z * acceleration * overdrive, Vector3.ZERO)
		should_auto_level = false
	if Input.is_action_pressed('throttle_up'):
		apply_force(transform.basis.y * acceleration * overdrive, Vector3.ZERO)
		should_auto_level = false
	if Input.is_action_pressed('throttle_down'):
		apply_force(transform.basis.y * -acceleration * overdrive, Vector3.ZERO)
		should_auto_level = false
	if Input.is_action_pressed('throttle_left'):
		apply_force(transform.basis.x * -acceleration * overdrive, Vector3.ZERO)
		should_auto_level = false
	if Input.is_action_pressed('throttle_right'):
		apply_force(transform.basis.x * acceleration * overdrive, Vector3.ZERO)
		should_auto_level = false
	if Input.is_action_pressed('roll_left'):
		apply_torque(transform.basis.z * acceleration * overdrive * 0.2)
		should_auto_level = false
	if Input.is_action_pressed('roll_right'):
		apply_torque(transform.basis.z * -acceleration * overdrive * 0.2)
		should_auto_level = false
		
	if Input.is_action_just_released("tertiary_action"):
		scan()

	var yaw = mouse_deltas.x / crosshair.position.x * 100000.0 * overdrive * delta
	var pitch = mouse_deltas.y / crosshair.position.y * 100000.0 * overdrive * delta
	
	apply_torque(transform.basis.y * (-yaw))
	apply_torque(transform.basis.x * (-pitch))
	
	if absf(yaw) > 0.5 || absf(pitch) > 0.5:
		should_auto_level = false 
	
	
	update_gui()

	mouse_deltas *= 0.5
	
	if should_auto_level:
		# Always point Y axis up - "auto-leveling"
		var new_x = -global_transform.basis.z.cross(Vector3.UP).normalized()
		var new_z = new_x.cross(Vector3.UP).normalized()
		var new_basis = Basis(new_x, Vector3.UP, new_z)
		global_transform.basis = global_transform.basis.slerp(new_basis, 0.8 * delta)

func on_pickup(area: Area3D):
	if area is Pickup:
		var pickup: Pickup = area
		var descriptor = pickup.pickup_descriptor()
	
		match descriptor.type:
			Pickup.PickupType.Science:
				skill_tree.add_science_points(descriptor.get("amount", 1))
				print("Skill tree science points: ", skill_tree.science_points)
			Pickup.PickupType.Fuel:
				pass
			Pickup.PickupType.Ammo:
				pass
			Pickup.PickupType.LogBook:
				pass

		pickup.destroy()

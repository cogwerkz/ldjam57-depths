extends RigidBody3D
class_name PlayerSubmarine

@onready var camera: Camera3D = $Camera3D
@onready var crosshair: TextureRect = $Gui/Crosshair
@onready var direction: TextureRect = $Gui/Direction

@export var saved_state: PlayerState

var _current_state: PlayerState

## Take these from current state instead
@export var acceleration := 10.0
@export var max_health := 100.0
@export var current_health := 100.0
@export var health_regen := 0.0
@export var max_ammo := 100.0
@export var current_ammo := 100.0
@export var ammo_regen := 20.0
@export var core_meltdown_timer := 30.0
@onready var health := current_health
@onready var ammo := current_ammo

var mouse_captured = true

var mouse_deltas := Vector2.ZERO

func update_state(delta: float) -> void:
	health = min(health + health_regen * delta, max_health)
	ammo = min(ammo + ammo_regen * delta, max_ammo)

func update_gui() -> void:
	var center_offset = Vector2(16, 16)
	var center = get_viewport().size * 0.5 - center_offset
	direction.position = direction.position.lerp(center + mouse_deltas * 32.0, 0.025)

	var distance = direction.position.distance_to(center)
	var away_from_center = direction.position - center

	direction.rotation = away_from_center.angle() + deg_to_rad(90.0)

	if distance < 64:
		direction.modulate.a = smoothstep(0.0, 1.0, distance / 64.0)
	else:
		direction.modulate.a = 1.0

func _ready() -> void:
	_current_state = PlayerState.new()
	contact_monitor = true
	linear_damp = 1.5
	angular_damp = 3.0
	var target = direction
	var center = get_viewport().size * 0.5
	target.position = center
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if mouse_captured:
			mouse_deltas += event.relative * 150.0 * 1.0 / Vector2(get_viewport().size)

func _physics_process(delta: float) -> void:
	if Input.is_action_just_released('ui_cancel'):
		get_tree().quit()

	if Input.is_action_just_pressed('debug_toggle_mouse_capture'):
		mouse_captured = !mouse_captured
		if mouse_captured:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	var overdrive = 1.0
	if Input.is_action_pressed('throttle_overdrive'):
		overdrive = 4.0
	if Input.is_action_pressed('throttle_forward'):
		apply_force(transform.basis.z * -acceleration * overdrive, Vector3.ZERO)
	if Input.is_action_pressed('throttle_backward'):
		apply_force(transform.basis.z * acceleration * overdrive, Vector3.ZERO)
	if Input.is_action_pressed('throttle_up'):
		apply_force(transform.basis.y * acceleration, Vector3.ZERO)
	if Input.is_action_pressed('throttle_down'):
		apply_force(transform.basis.y * -acceleration, Vector3.ZERO)
	if Input.is_action_pressed('throttle_left'):
		apply_force(transform.basis.x * -acceleration, Vector3.ZERO)
	if Input.is_action_pressed('throttle_right'):
		apply_force(transform.basis.x * acceleration, Vector3.ZERO)

	var yaw = mouse_deltas.x
	var pitch = mouse_deltas.y

	apply_torque(transform.basis.y * (-yaw))
	apply_torque(transform.basis.x * (-pitch))

	update_state(delta)
	update_gui()

	mouse_deltas *= 0.5
	
	# Always point Y axis up - "auto-leveling"
	var new_x = -global_transform.basis.z.cross(Vector3.UP).normalized()
	var new_z = new_x.cross(Vector3.UP).normalized()
	var new_basis = Basis(new_x, Vector3.UP, new_z)
	global_transform.basis = global_transform.basis.slerp(new_basis, 0.95 * delta)

func heal(amount: float) -> void:
	health = min(max_health, health + amount)

func damage(amount: float) -> void:
	health = max(0.0, health - amount)
	if health <= 0.0:
		await get_tree().create_timer(0.5).timeout
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

extends Node3D

@onready var player_submarine = $Player/PlayerSubmarine
@onready var skill_tree_panel = %SkillTreePanel
@onready var depth_label = %DepthLabel

@export var sky_map: GradientTexture1D
@export var depth_map: GradientTexture1D
@export var environment: WorldEnvironment
@export var sun: DirectionalLight3D

func _ready() -> void:
	$MainCamera.make_current()
	State.get_player_state().reset_defaults()
	State.get_player_state().emit_changed()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

	if event.is_action_pressed("upgrades"):
		skill_tree_panel.visible = !skill_tree_panel.visible

func _on_skill_tree_panel_visibility_changed() -> void:
	if skill_tree_panel.visible:
		get_tree().paused = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		get_tree().paused = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(_delta: float) -> void:
	var depth = player_submarine.global_position.y
	depth_label.text = "%d m" % int(round(depth))
	
	var t = absf(clampf(depth, -100.0, 0.0)) / 100.0
	var depth_color = depth_map.gradient.sample(t)
	var sky_color = sky_map.gradient.sample(t)
	
	var sky_material = (environment.environment.sky.sky_material as ProceduralSkyMaterial)
	sky_material.ground_bottom_color = depth_color
	sky_material.ground_horizon_color = depth_color
	sky_material.sky_top_color = sky_color
	sky_material.sky_horizon_color = depth_color
	sun.light_energy = 1.0 - t
	

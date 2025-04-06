extends Panel

const INIT_SKILL_SELECTED = "fuel_efficiency"

@onready var skills_box = %SkillsBoxContainer

@onready var science_points_label: Label = %SciencePointsLabel
@onready var skill_name: Label = %SkillNameLabel
@onready var skill_description: Label = %SkillDescriptionLabel
@onready var skill_level: Label = %SkillLevelLabel
@onready var skill_level_description: Label = %SkillLevelDescriptionLabel
@onready var skill_upgrade: Button= %SkillUpgradeButton

@export var skill_tree: SkillTree
@export var player_state: PlayerState
var selected_skill_key: String = INIT_SKILL_SELECTED

func _ready() -> void:
	skill_tree.changed.connect(func(): 
		_update_gui()
	)
	
	var skills_button_group = ButtonGroup.new()
	skills_button_group.allow_unpress = false
	skills_button_group.connect("pressed", _on_selected_skill_changed)
	
	for skill_key in skill_tree.skills.keys():
		var skill_value = skill_tree.skills[skill_key]
		var skill_button = Button.new()
		skill_button.set_meta("skill_key", skill_key)
		skill_button.toggle_mode = true
		skill_button.text = skill_value["name"]
		skill_button.button_group = skills_button_group
		skill_button.set_pressed(INIT_SKILL_SELECTED == skill_key)
		skills_box.add_child(skill_button)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("upgrades"):
		await get_tree().process_frame
		visible = false

func _on_selected_skill_changed(button: Button):
	var skill_key = button.get_meta("skill_key")
	selected_skill_key = skill_key

func _update_gui() -> void:
	science_points_label.set_text("%d Science Points" % skill_tree.science_points)

	var skill = skill_tree.skills[selected_skill_key]
	
	skill_name.text = skill["name"]
	skill_description.text = skill["description"]
	skill_level.text = "Level: %d" % skill["current_level"]
	skill_upgrade.pressed.connect(func():
		if skill_tree.upgrade_skill(selected_skill_key, player_state):
			_update_gui()
	)
	var current_level = skill["current_level"]
	if current_level < skill["levels"].size():
		var next_level = skill["levels"][current_level]
		skill_level_description.text = next_level["description"]
		skill_upgrade.text = "Upgrade (%d SP)" % next_level["cost"]
		skill_upgrade.disabled = not skill_tree.can_upgrade_skill(selected_skill_key)
	else:
		skill_level_description.text = "Max Level Reached"
		skill_upgrade.disabled = true
		skill_upgrade.text = "Max Level"

func _on_close_button_pressed() -> void:
	visible = false
	
func _on_visibility_changed() -> void:
	if self.is_node_ready() and visible:
		_update_gui()

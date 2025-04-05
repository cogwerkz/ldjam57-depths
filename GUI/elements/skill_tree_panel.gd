extends Panel

const INIT_SKILL_SELECTED = "fuel_efficiency"

@onready var skills_box = %SkillsBoxContainer

@onready var skill_name: Label = %SkillNameLabel
@onready var skill_description: Label = %SkillDescriptionLabel
@onready var skill_level: Label = %SkillLevelLabel
@onready var skill_level_description: Label = %SkillLevelDescriptionLabel
@onready var skill_upgrade: Button= %SkillUpgradeButton

@export var skill_tree: SkillTree

func _ready() -> void:
	if !skill_tree:
		skill_tree = SkillTree.new()
	
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

func _on_selected_skill_changed(button: Button):
	var skill_key = button.get_meta("skill_key")
	var skill = skill_tree.skills[skill_key]
	
	skill_name.text = skill["name"]
	skill_description.text = skill["description"]
	skill_level.text = "Level: %d" % skill["current_level"]
	
	var current_level = skill["current_level"]
	if current_level < skill["levels"].size():
		var next_level = skill["levels"][current_level]
		skill_level_description.text = next_level["description"]
		skill_upgrade.disabled = false
		skill_upgrade.text = "Upgrade (%d SP)" % next_level["cost"]
	else:
		skill_level_description.text = "Max Level Reached"
		skill_upgrade.disabled = true
		skill_upgrade.text = "Max Level"

func _on_close_button_pressed() -> void:
	visible = false

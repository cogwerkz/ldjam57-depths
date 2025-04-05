extends Resource
class_name SkillTree

var science_points: int = 0

var skills = {
	"fuel_efficiency": {
		"name": "Fuel efficiency",
		"current_level": 0,
		"levels": [
			{
				"cost": 1,
				"effects": {
					"fuel_efficiency": 5.0
				}
			}
		]
	},
	"max_speed": {
		"name": "Submarine speed",
		"current_level": 0,
		"levels": [
			{
				"cost": 1,
				"effects": {
					"max_speed" : 5.0
				}
			}
		]
	},
	"hull_strenght": {
		"name": "Hull Strenght",
		"current_level": 0,
		"levels": [
			{
				"cost": 1,
				"effects": {
					"max_health" : 5.0
				}
			}
		]
	},
	"pressure_resistance": {
		"name": "Pressure Resistance",
		"current_level": 0,
		"levels": [
			{
				"cost": 1,
				"effects": {
					"pressure_resistance" : 5.0
				}
			}
		]
	},
	"targeting_system": {
		"name": "Turret Targeting System",
		"current_level": 0,
		"levels": [
			{
				"cost": 1,
				"effects": {
					"turret_hit_chance" : 5.0
				}
			}
		]
	},
	"turret_range": {
		"name": "Turret Range",
		"current_level": 0,
		"levels": [
			{
				"cost": 1,
				"effects": {
					"turret_range" : 5.0
				}
			}
		]
	},
	"ammo_capacity": {
		"name": "Turret Ammo Storage",
		"current_level": 0,
		"levels": [
			{
				"cost": 1,
				"effects": {
					"turret_max_ammo" : 5.0
				}
			}
		]
	},
	"scanner_boost": {
		"name": "Scanner range",
		"current_level": 0,
		"levels": [
			{
				"cost": 1,
				"effects": {
					"scanner_range" : 5.0
				}
			}
		]
	},
	"scanner_efficiency": {
		"name": "Scanner Cooldown",
		"current_level": 0,
		"levels": [
			{
				"cost": 1,
				"effects": {
					"scanner_cooldown" : 5.0
				}
			}
		]
	}
}

func add_science_points(amount: int) -> void:
	science_points += amount

func can_upgrade_skill(skill_id: String) -> bool:
	if not skills.has(skill_id):
		return false
		
	var skill = skills[skill_id]
	
	if skill["current_level"] >= skill["levels"].size():
		return false
		
	var cost = skill["levels"][skill["current_level"]]["cost"]
	return science_points >= cost

func upgrade_skill(skill_id: String, player_state: PlayerState) -> bool:
	if not can_upgrade_skill(skill_id):
		return false
		
	var skill = skills[skill_id]
	var level_data = skill["levels"][skill["current_level"]]
	
	science_points -= level_data["cost"]
	skill["current_level"] += 1
	
	apply_skill_effects(player_state)
	return true

func apply_skill_effects(player_state: PlayerState) -> void:
	player_state.reset_defaults()
	
	for skill_id in skills:
		var skill = skills[skill_id]
		var current_level = skill["current_level"]
		
		if current_level <= 0:
			continue
			
		for level_idx in range(current_level):
			var level_data = skill["levels"][level_idx]
			
			for stat in level_data["effects"]:
				if player_state.get(stat) != null:
					var current_value = player_state.get(stat)
					var effect_value = level_data["effects"][stat]
					player_state.set(stat, current_value + effect_value)
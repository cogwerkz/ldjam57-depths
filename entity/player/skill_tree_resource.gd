extends Resource
class_name SkillTree

var science_points: int = 0

var skills = {
	"fuel_efficiency": {
		"name": "Fuel Efficiency",
		"description": "Reduces the amount of fuel consumed while moving, allowing for longer explorations.",
		"current_level": 0,
		"levels": [
			{
				"cost": 1,
				"effects": {
					"fuel_efficiency": 0.9
				},
				"description": "Reduces fuel consumption by 10%."
			},
			{
				"cost": 2,
				"effects": {
					"fuel_efficiency": 0.8
				},
				"description": "Reduces fuel consumption by 20%."
			},
			{
				"cost": 3,
				"effects": {
					"fuel_efficiency": 0.7
				},
				"description": "Reduces fuel consumption by 30%."
			},
			{
				"cost": 4,
				"effects": {
					"fuel_efficiency": 0.6
				},
				"description": "Reduces fuel consumption by 40%."
			},
			{
				"cost": 5,
				"effects": {
					"fuel_efficiency": 0.5
				},
				"description": "Reduces fuel consumption by 50%."
			}

		]
	},
	"max_speed": {
		"name": "Submarine Speed",
		"description": "Increases the maximum speed of your submarine, allowing you to travel faster across the ocean.",
		"current_level": 0,
		"levels": [
			{
				"cost": 1,
				"effects": {
					"max_speed" : 5.0
				},
				"description": "Increases maximum speed by 5 units."
			}
		]
	},
	"hull_strenght": {
		"name": "Hull Strength",
		"description": "Improves the structural integrity of your submarine, increasing its maximum health and resistance to damage.",
		"current_level": 0,
		"levels": [
			{
				"cost": 1,
				"effects": {
					"max_health" : 5.0
				},
				"description": "Increases maximum hull health by 5 points."
			}
		]
	},
	"pressure_resistance": {
		"name": "Pressure Resistance",
		"description": "Enhances the submarine's ability to withstand the crushing pressure of the deep ocean, allowing you to dive to greater depths without taking damage.",
		"current_level": 0,
		"levels": [
			{
				"cost": 1,
				"effects": {
					"pressure_resistance" : 5.0
				},
				"description": "Increases maximum safe diving depth by 5 units."
			}
		]
	},
	"targeting_system": {
		"name": "Turret Targeting System",
		"description": "Improves the accuracy of your submarine's turrets, increasing the chance of hitting hostile targets.",
		"current_level": 0,
		"levels": [
			{
				"cost": 1,
				"effects": {
					"turret_hit_chance" : 5.0 
				},
				"description": "Increases turret hit chance by 5%."
			}
		]
	},
	"turret_range": {
		"name": "Turret Range",
		"description": "Extends the effective firing range of your submarine's turrets, allowing you to engage threats from a safer distance.",
		"current_level": 0,
		"levels": [
			{
				"cost": 1,
				"effects": {
					"turret_range" : 5.0
				},
				"description": "Increases turret firing range by 5 units."
			}
		]
	},
	"ammo_capacity": {
		"name": "Turret Ammo Storage",
		"description": "Increases the maximum amount of ammunition your submarine can carry for its turrets, allowing for sustained combat.",
		"current_level": 0,
		"levels": [
			{
				"cost": 1,
				"effects": {
					"turret_max_ammo" : 5.0
				},
				"description": "Increases maximum turret ammo capacity by 5 rounds."
			}
		]
	},
	"scanner_boost": {
		"name": "Scanner Range",
		"description": "Increases the detection range of your submarine's scanner, allowing you to identify points of interest and threats from further away.",
		"current_level": 0,
		"levels": [
			{
				"cost": 1,
				"effects": {
					"scanner_range" : 5.0
				},
				"description": "Increases scanner detection range by 5 units."
			}
		]
	},
	"scanner_efficiency": {
		"name": "Scanner Cooldown",
		"description": "Reduces the cooldown time between scanner uses, allowing you to scan your surroundings more frequently.",
		"current_level": 0,
		"levels": [
			{
				"cost": 1,
				"effects": {
					"scanner_cooldown" : 5.0 
				},
				"description": "Reduces scanner cooldown time by 5%."
			}
		]
	}
};

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

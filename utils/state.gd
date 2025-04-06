extends Node

func get_player_state() -> PlayerState:
	var state_node: GlobalState = get_tree().get_nodes_in_group("state")[0]
	return state_node.player_state

func get_skill_tree() -> SkillTree:
	var state_node: GlobalState = get_tree().get_nodes_in_group("state")[0]
	return state_node.skill_tree

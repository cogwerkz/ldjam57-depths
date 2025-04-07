extends Node

func _get_container() -> Node3D:
	return get_tree().get_nodes_in_group("fx_manager")[0]

func add_fx(fx_node: Node3D) -> void:
	_get_container().add_child(fx_node)

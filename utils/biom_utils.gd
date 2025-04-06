extends Node

var current_biom: String = ""

signal biom_changed(biom: String)

func set_biom(biom: String):
	current_biom = biom
	biom_changed.emit(current_biom)

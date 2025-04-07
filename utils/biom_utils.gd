extends Node

var current_biom: String = ""

signal biom_changed(biom: String)
signal logbook_discovered(logbook_id: int)

func set_biom(biom: String):
	current_biom = biom
	biom_changed.emit(current_biom)

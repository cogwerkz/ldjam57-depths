extends Area3D
class_name Pickup

enum PickupType {
	Science,
	Fuel,
	Ammo,
	LogBook,
}

const NAMES = {
	PickupType.Science: "Science",
	PickupType.Fuel: "Fuel",
	PickupType.Ammo: "Ammo",
	PickupType.LogBook: "Lost Log Book",
}

@export var type: PickupType = PickupType.Science
@export var amount: int = 1
# This should only exist for log books
@export var log_book_entry: String = ""

func pickup_descriptor() -> Dictionary:
	var ret = { "type": type, "name": NAMES[type] }
	
	match type:
		PickupType.LogBook:
			ret["entry"] = log_book_entry
		_:
			ret["amount"] = amount

	return ret

func destroy() -> void:
	queue_free()

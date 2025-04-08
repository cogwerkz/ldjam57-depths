extends Area3D
class_name Pickup

@onready var bullet = $Model/Bullets
@onready var health = $Model/Health
@onready var log_book = $Model/LogBook
@onready var science = $Model/Science
@onready var fuel = $Model/GasCan

enum PickupType {
	Science,
	Fuel,
	Ammo,
	LogBook,
	Health
}

const NAMES = {
	PickupType.Science: "Science",
	PickupType.Fuel: "Fuel",
	PickupType.Ammo: "Ammo",
	PickupType.LogBook: "Lost Log Book",
	PickupType.Health: "Health",
}

@export var type: PickupType = PickupType.Science
@export var amount: int = 1
# This should only exist for log books
@export var log_book_entry: String = ""

func _ready() -> void:
	bullet.visible = false
	health.visible = false
	log_book.visible = false
	science.visible = false
	fuel.visible = false
	match type:
		PickupType.Science:
			science.visible = true
		PickupType.Fuel:
			fuel.visible = true
		PickupType.Ammo:
			bullet.visible = true
		PickupType.LogBook:
			log_book.visible = true
		PickupType.Health:
			health.visible = true

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

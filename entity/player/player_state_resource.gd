extends Resource
class_name PlayerState

# Speed
@export var max_speed: float = 50.0

# Acceleration/Deceleration
@export var linear_acceleration: float = 5.0
@export var angular_acceleration: float = 15.0

# Structure
@export var max_health: float = 100.0
@export var current_health: float = 100.0
@export_range(0, 10000) var pressure_resistance: float = 1000.0

# Fuel
@export var fuel_max: float = 100.0
@export var current_fuel: float = 100.0
@export_range(0, 100) var fuel_efficiency: float = 75.0

# Turret
@export var turret_max_ammo: int = 10
@export var turret_current_ammo: int = 10
@export var turret_damage: float = 10.0
@export var turret_range: float = 30.0
@export var turret_cooldown: float = 0.5
@export_range(0, 100) var turret_hit_chance: float = 60.0

# Scanner
@export var scanner_range: float = 300.0
@export var scanner_decay: float = 10.0
@export var scanner_cooldown: float = 5.0

# Tractor Beam
@export var tractor_beam_range: float = 100.0
@export var tractor_beam_collection_speed: float = 15.0

func reset_defaults() -> void:
	max_speed = 50.0
	linear_acceleration = 5.0
	angular_acceleration = 10.0
	max_health = 100.0
	pressure_resistance = 1000.0
	fuel_max = 100.0
	fuel_efficiency = 75.0
	turret_max_ammo = 10
	turret_damage = 10.0
	turret_range = 30.0
	turret_cooldown = 0.5
	turret_hit_chance = 60.0
	scanner_range = 300.0
	scanner_decay = 10.0
	scanner_cooldown = 5.0
	tractor_beam_range = 100.0
	tractor_beam_collection_speed = 15.0

func damage(amount: float) -> void:
	current_health = max(0, current_health - amount)

func heal(amount: float) -> void:
	current_health = min(max_health, current_health + amount)

func consume_fuel(amount: float) -> bool:
	if current_fuel >= amount:
		current_fuel -= amount
		return true
	return false

func refuel(amount: float) -> void:
	current_fuel = min(fuel_max, current_fuel + amount)

func use_ammo(amount: int = 1) -> bool:
	if turret_current_ammo >= amount:
		turret_current_ammo -= amount
		return true
	return false

func reload_ammo(amount: int) -> void:
	turret_current_ammo = min(turret_max_ammo, turret_current_ammo + amount)

func is_alive() -> bool:
	return current_health > 0

func get_health_percentage() -> float:
	return (current_health / max_health) * 100.0

func get_fuel_percentage() -> float:
	return (current_fuel / fuel_max) * 100.0

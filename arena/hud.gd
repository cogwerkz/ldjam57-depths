extends Control

@onready var health = $HealthProgressBar
@onready var fuel = $HealthProgressBar/FuelProgressBar
@onready var scanner = $HealthProgressBar/ScannerProgressBar

@export var player: PlayerSubmarine
@export var TWEEN_DURATION: float = 0.2

# Health Colors
const HEALTH_FULL = Color("#00FF00")
const HEALTH_MEDIUM = Color("#FFFF00")
const HEALTH_LOW = Color("#FF8C00")
const HEALTH_CRITICAL = Color("#FF0000")

# Fuel Colors
const FUEL_FULL = Color("#FFFF00")
const FUEL_MEDIUM = Color("#FFA500")
const FUEL_LOW = Color("#FF4500")
const FUEL_CRITICAL = Color("#FF0000")

# Scanner Ready Colors
const SCANNER_NORMAL = Color("#FFFFFF")
const SCANNER_READY = Color("#00FF00")

var player_state: PlayerState

func _ready() -> void:
	player_state = State.get_player_state()
	
	player_state.changed.connect(_update_hud)
	player.scanner_charge_updated.connect(_on_scanner_charge_level)
	player.scanner_ready.connect(_on_scanner_ready)
	_update_hud()
	_on_scanner_ready()
	print(player_state)

func _update_hud():
	# Update Health with Tween
	var health_tween = create_tween()
	health_tween.tween_property(health, "value", player_state.get_health_percentage(), TWEEN_DURATION)
	if player_state.get_health_percentage() > 75:
		health.tint_progress = HEALTH_FULL
	elif player_state.get_health_percentage() > 50:
		health.tint_progress = HEALTH_MEDIUM
	elif player_state.get_health_percentage() > 25:
		health.tint_progress = HEALTH_LOW
	else:
		health.tint_progress = HEALTH_CRITICAL

	# Update Fuel with Tween
	var fuel_tween = create_tween()
	fuel_tween.tween_property(fuel, "value", player_state.get_fuel_percentage(), TWEEN_DURATION)
	if player_state.get_fuel_percentage() > 75:
		fuel.tint_progress = FUEL_FULL
	elif player_state.get_fuel_percentage() > 50:
		fuel.tint_progress = FUEL_MEDIUM
	elif player_state.get_fuel_percentage() > 25:
		fuel.tint_progress = FUEL_LOW
	else:
		fuel.tint_progress = FUEL_CRITICAL

func _on_scanner_charge_level(value_percent: float):
	scanner.tint_progress = SCANNER_NORMAL
	var scanner_tween = create_tween()
	scanner_tween.tween_property(scanner, "value", value_percent, TWEEN_DURATION)

func _on_scanner_ready():
	var scanner_tween = create_tween().parallel()
	scanner_tween.tween_property(scanner, "tint_progress", SCANNER_READY, TWEEN_DURATION)
	scanner_tween.tween_property(scanner, "value", 100, TWEEN_DURATION)

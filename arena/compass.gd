extends TextureRect
class_name Compass

@export var player: PlayerSubmarine

# Called when the node enters the scene tree for the first time.
func _ready():
	if not is_instance_valid(player):
		printerr("Compass: Player instance is not valid!")
		set_process(false)
		return

	texture_repeat = TextureRepeat.TEXTURE_REPEAT_ENABLED


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not is_instance_valid(player):
		return # Don't process if player or material is invalid

	# Get player's yaw rotation in degrees (assuming Y is up)
	# Normalize angle to be between 0 and 360
	var player_angle_deg = fposmod(rad_to_deg(-player.rotation.y), 360.0)

	var texture_width = texture.get_width()
	var viewport_width_normalized = size.x / texture_width
	var desired_left_edge_angle_normalized = (player_angle_deg / 360.0) - (viewport_width_normalized / 2.0)

	# Set the shader uniform
	var shader_material = material as ShaderMaterial
	shader_material.set_shader_parameter("scroll_offset", desired_left_edge_angle_normalized)

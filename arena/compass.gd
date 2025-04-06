extends TextureRect
class_name Compass

@export var player: PlayerSubmarine
# Width of the fade effect at each edge (should match shader's default or be set)
@export var fade_width_normalized : float = 0.1

# Container to hold the POI dots
@onready var poi_container: Node2D = Node2D.new()

# Store active POIs: {'node': TextureRect, 'target_position': Vector3, 'type': Pickup.PickupType, 'life': float}
var pois: Array[Dictionary] = []

# Texture for the POI dots
var circle_texture: ImageTexture

# Define colors for different pickup types (adjust as needed)
const POI_COLORS = {
	Pickup.PickupType.Science: Color.BLUE,
	Pickup.PickupType.Fuel: Color.GREEN,
	Pickup.PickupType.Ammo: Color.RED,
	Pickup.PickupType.LogBook: Color.YELLOW,
	# Add default or other types if necessary
}

# Called when the node enters the scene tree for the first time.
func _ready():
	if not is_instance_valid(player):
		printerr("Compass: Player instance is not valid!")
		set_process(false)
		return

	texture_repeat = TextureRepeat.TEXTURE_REPEAT_ENABLED
	# Generate the circle texture
	circle_texture = _create_circle_texture(8, Color.WHITE) # Create a 8x8 white circle
	# Add the container for dots
	add_child(poi_container)


# Generates a simple circle texture
func _create_circle_texture(diameter: int, color: Color) -> ImageTexture:
	var radius = diameter / 2.0
	var center = Vector2(radius, radius)
	var image = Image.create(diameter, diameter, false, Image.FORMAT_RGBA8)
	image.fill(Color(0,0,0,0)) # Fill with transparent

	for y in range(diameter):
		for x in range(diameter):
			var point = Vector2(x, y)
			if point.distance_to(center) <= radius:
				image.set_pixel(x, y, color)

	var img_texture = ImageTexture.create_from_image(image) # Renamed variable
	return img_texture


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not is_instance_valid(player) or not material is ShaderMaterial:
		return # Don't process if player or material is invalid

	# --- Compass Scrolling Logic ---
	var player_angle_deg = fposmod(rad_to_deg(-player.rotation.y), 360.0)
	var texture_width = texture.get_width() # Use actual texture width for scroll calculation base
	var viewport_width_normalized = size.x / texture_width # How much of texture width is visible
	# Calculate the normalized position (0-1) of the texture that should align with the left edge of the viewport
	var desired_left_edge_angle_normalized = (player_angle_deg / 360.0) - (viewport_width_normalized / 2.0)

	# Set the shader uniform for scrolling
	var shader_material = material as ShaderMaterial
	shader_material.set_shader_parameter("scroll_offset", desired_left_edge_angle_normalized)

	# --- POI Dot Update Logic ---
	var compass_width = size.x
	var compass_center_y = size.y / 2.0
	var fade_width_pixels = fade_width_normalized * compass_width

	# Use index loop for safe removal while iterating
	for i in range(pois.size() - 1, -1, -1):
		var poi = pois[i]
		poi.life -= delta

		if poi.life <= 0:
			poi.node.queue_free()
			pois.remove_at(i)
			continue

		# Calculate relative angle
		var player_pos = player.global_position
		var poi_pos = poi.target_position
		# Project vectors onto the horizontal plane (XZ)
		var player_forward_xz = Vector2(player.global_transform.basis.z.x, player.global_transform.basis.z.z)
		var poi_direction_xz = Vector2(poi_pos.x - player_pos.x, poi_pos.z - player_pos.z)

		if poi_direction_xz.length_squared() < 0.001: # Avoid issues if POI is directly above/below
			poi.node.visible = false # Hide dot if too close horizontally
			continue

		# Angle from player's forward (-Z) to the POI direction in the horizontal plane
		# Note: angle_to gives signed angle. We need 0-360 relative to North (or some fixed axis)
		# Easier: Get global angle of player and POI, then find difference.
		var player_global_angle_rad = Vector2.UP.angle_to(player_forward_xz) # Angle relative to +Y (which is -Z in 2D projection)
		var poi_global_angle_rad = Vector2.UP.angle_to(poi_direction_xz)

		# Convert to degrees and normalize 0-360
		var _player_global_angle_deg = fposmod(rad_to_deg(player_global_angle_rad), 360.0) # Prefixed unused variable
		var poi_global_angle_deg = fposmod(rad_to_deg(poi_global_angle_rad), 360.0)

		# Calculate the POI's position relative to the player's current view center angle
		var _relative_angle_deg = fposmod(poi_global_angle_deg - player_angle_deg + 180.0, 360.0) - 180.0 # Prefixed unused variable

		# Convert relative angle to normalized position (0.0 = left edge, 0.5 = center, 1.0 = right edge)
		# The compass shows roughly 180 degrees? Let's assume the shader scroll logic handles the view window correctly.
		# We need the POI's absolute normalized position (0-1) on the full 360 texture
		var poi_absolute_normalized = poi_global_angle_deg / 360.0

		# Calculate where this absolute normalized position appears within the scrolled viewport
		# scroll_offset is the normalized position of the texture at the left edge
		# Use fposmod(..., 1.0) as the GDScript equivalent of fract()
		var display_x_normalized = fposmod(poi_absolute_normalized - desired_left_edge_angle_normalized, 1.0)

		# Denormalize to pixel coordinates
		var display_x = display_x_normalized * compass_width

		# Update dot position
		poi.node.position = Vector2(display_x, compass_center_y)

		# Update visibility based on fade areas
		var dot_is_visible = (display_x > fade_width_pixels) and (display_x < compass_width - fade_width_pixels) # Renamed variable
		poi.node.visible = dot_is_visible


# Function called by PlayerSubmarine to add a POI marker to the compass
func add_poi(poi_world_position: Vector3, type: Pickup.PickupType, lifetime: float) -> void: # Renamed parameter
	var dot = TextureRect.new()
	dot.texture = circle_texture
	dot.size = circle_texture.get_size() # Use texture size
	dot.pivot_offset = dot.size / 2.0 # Center pivot for positioning
	dot.modulate = POI_COLORS.get(type, Color.WHITE) # Use modulate for color

	poi_container.add_child(dot)

	pois.append({
		'node': dot,
		'target_position': poi_world_position, # Use renamed parameter
		'type': type,
		'life': lifetime
	})

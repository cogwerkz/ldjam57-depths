shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float scroll_offset = 0.0; // Normalized offset (0.0 to 1.0)
uniform float fade_width_normalized : hint_range(0.0, 0.5) = 0.1; // Width of the fade effect at each edge

void fragment() {
	// Calculate the scrolled UV coordinates
	vec2 scrolled_uv = UV;
	scrolled_uv.x = fract(UV.x + scroll_offset); // Use fract() for seamless wrapping

	// Sample the texture using the scrolled UVs
	vec4 tex_color = texture(TEXTURE, scrolled_uv);

	// Calculate fade factor based on horizontal position (UV.x)
	// smoothstep(edge0, edge1, x) transitions from 0 to 1 as x goes from edge0 to edge1
	float fade_left = smoothstep(0.0, fade_width_normalized, UV.x); // Fade in from left
	float fade_right = smoothstep(1.0, 1.0 - fade_width_normalized, UV.x); // Fade out to right
	float fade_factor = min(fade_left, fade_right); // Combine fades

	// Apply the fade factor to the alpha channel
	COLOR = tex_color;
	COLOR.a *= fade_factor;
}

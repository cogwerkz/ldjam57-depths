shader_type spatial;
render_mode unshaded, cull_disabled;

uniform vec4 color: source_color = vec4(1,1,1,.1);
uniform float fresnel_sharpness = 1.0;

void fragment() {
	float fresnel = pow(1.0 - dot(VIEW, NORMAL), fresnel_sharpness);

	ALBEDO = COLOR.rgb * color.rgb;
	ALPHA = COLOR.a * (color.a + fresnel);
}

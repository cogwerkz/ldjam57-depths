shader_type canvas_item;

uniform float amount = 40.0;
uniform float vignette_intensity = 0.4;

float vignette(vec2 uv){
	uv *= 1.0 - uv.xy;
	float vignette = uv.x * uv.y * 15.0;
	return pow(vignette, vignette_intensity);
}

float random(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	float a = fract(sin(dot(UV * 0.5, vec2(12.9898, 78.233) * TIME)) * 438.5453) * 1.9;
	vec4 col = texture(TEXTURE, UV);
	col.a *= pow(a, amount);
	float v = 1.0 - vignette(UV);

	float alpha = COLOR.a;
	COLOR.a *= clamp(pow(a, amount) * v, 0, 1);
	COLOR = mix(COLOR, vec4(0.0, 0.0, 0.0, alpha), v);
}

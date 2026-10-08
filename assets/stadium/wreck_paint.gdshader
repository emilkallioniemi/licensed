shader_type spatial;
render_mode cull_disabled;
uniform vec4 paint : source_color = vec4(0.45, 0.08, 0.04, 1.0);
varying vec3 panel_position;
float noise(vec3 p) {
	vec3 i = floor(p), f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float n = dot(i, vec3(1.0, 57.0, 113.0));
	return mix(mix(mix(fract(sin(n) * 43758.5453), fract(sin(n+1.0) * 43758.5453), f.x),
		mix(fract(sin(n+57.0) * 43758.5453), fract(sin(n+58.0) * 43758.5453), f.x), f.y),
		mix(mix(fract(sin(n+113.0) * 43758.5453), fract(sin(n+114.0) * 43758.5453), f.x),
		mix(fract(sin(n+170.0) * 43758.5453), fract(sin(n+171.0) * 43758.5453), f.x), f.y), f.z);
}
void vertex() { panel_position = VERTEX; }
void fragment() {
	float weather = noise(panel_position * 4.0);
	float chips = smoothstep(.64, .82, noise(panel_position * 55.0)) * smoothstep(.45, .70, weather);
	vec3 faded = paint.rgb * (.78 + .28 * weather);
	ALBEDO = mix(faded, vec3(.13, .065, .026), chips * .8);
	ROUGHNESS = .62 + weather * .28;
	METALLIC = .18 * (1.0 - chips);
}

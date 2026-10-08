shader_type spatial;
uniform vec4 clothing : source_color = vec4(1.0);
// Exported UVs hold individual phase and height above the fan's feet.
void vertex(){
	float sway = sin(TIME * 2.2 + UV.x) * UV.y * UV.y;
	VERTEX.x += sway * .035;
	VERTEX.z += sway * .025;
}
void fragment(){ALBEDO=clothing.rgb;ROUGHNESS=.9;}

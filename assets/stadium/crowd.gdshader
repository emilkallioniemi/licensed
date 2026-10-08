shader_type spatial;
uniform vec4 clothing : source_color = vec4(1.0);
void vertex(){VERTEX.z+=sin(TIME*2.6+VERTEX.x*.73+VERTEX.z*.4)*.055;}
void fragment(){ALBEDO=clothing.rgb;ROUGHNESS=.9;}

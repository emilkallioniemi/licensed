shader_type spatial;
render_mode unshaded, blend_add, cull_disabled, depth_draw_never;
varying float height;
void vertex(){height=UV.y;VERTEX.x+=sin(TIME*8.0+VERTEX.y*4.0)*.12*VERTEX.y;VERTEX.z+=cos(TIME*11.0+VERTEX.y*3.0)*.1*VERTEX.y;}
void fragment(){float flicker=.65+.35*sin(TIME*16.0+UV.x*35.0+UV.y*23.0);vec3 fire=mix(vec3(1.0,.09,.004),vec3(1.0,.75,.12),height);ALBEDO=fire;EMISSION=fire*(2.0+flicker*2.0);ALPHA=(.4+.45*flicker)*smoothstep(0.0,.2,height);}

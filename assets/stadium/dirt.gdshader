shader_type spatial;
render_mode diffuse_burley;
varying vec3 p;
float hash(vec2 v){return fract(sin(dot(v,vec2(127.1,311.7)))*43758.5453);}
float noise(vec2 v){vec2 i=floor(v),f=fract(v);f=f*f*(3.0-2.0*f);return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)),f.x),f.y);}
void vertex(){p=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;}
void fragment(){
 float macro=noise(p.xz*.13)*.6+noise(p.xz*.51)*.4;
 float grain=noise(p.xz*13.0);
 float rut=pow(abs(sin(p.x*.92+sin(p.z*.065)*2.2)),22.0);
 float tracks=smoothstep(.4,.9,noise(p.xz*.065));
 ALBEDO=mix(vec3(.14,.061,.027),vec3(.34,.19,.085),macro)*(.88+grain*.19)*(1.0-rut*tracks*.25);
 ROUGHNESS=mix(.76,.98,macro);
 NORMAL=normalize(NORMAL+vec3((grain-.5)*.16,(noise(p.xz*12.0+3.0)-.5)*.16,0));
}

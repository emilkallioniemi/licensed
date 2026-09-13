shader_type spatial;
render_mode diffuse_burley;
varying vec3 world;
float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float noise(vec2 p) {
 vec2 i=floor(p); vec2 f=fract(p); f=f*f*(3.0-2.0*f);
 return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)),f.x),f.y);
}
void vertex() { world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz; }
void fragment() {
 vec2 p=world.xz;
 float dust=noise(p*.23)*.6+noise(p*.74)*.4;
 vec3 asphalt=mix(vec3(.025,.031,.029),vec3(.040,.042,.034),smoothstep(.28,.8,dust));
 float grain=mix(.5,noise(p*7.0),1.0-smoothstep(.025,.12,length(fwidth(p))));
 // Old broad tyre sweeps and tarred slab seams, no directional route markings.
 float sweep=1.0-smoothstep(.09,.22,abs(length((p-vec2(-4,0))*vec2(1,.8))-13.0));
 float seam=1.0-smoothstep(.015,.055,abs(mod(p.x+noise(p*.5)*.10,7.0)-3.5));
 ALBEDO=asphalt*(.96+grain*.08)*(1.0-sweep*.12-seam*.17);
 ROUGHNESS=.96;
}

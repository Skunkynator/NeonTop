shader_type spatial;
render_mode unshaded;

uniform sampler2D dist_map : hint_black;
uniform vec4 colour : hint_color;
uniform float inv_glow_strength : hint_range(1,16) = 1;
uniform bool vertex_displacement = false;
uniform float strength = 0.3;
const float displace_modx = 3.1415926538;
const float displace_mody = 1.6180339887;
const float displace_modz = 1.4142135623;


void vertex() {
	if(vertex_displacement){
		vec3 offset = vec3(0);
		offset.x = sin(TIME + displace_mody * VERTEX.y + displace_modz * VERTEX.z);
		offset.z = sin(TIME + displace_modx * VERTEX.x + displace_mody * VERTEX.y);
		offset.y = sin(TIME + displace_modx * VERTEX.x + displace_modz * VERTEX.z);
		VERTEX = VERTEX + offset * strength;
	}
}

void fragment() {
	float glow = 1. - texture(dist_map,UV).r;
	glow = pow(glow,inv_glow_strength);
	ALBEDO.rgb = glow * colour.rgb;
}

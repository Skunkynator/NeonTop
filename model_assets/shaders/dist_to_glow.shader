shader_type spatial;
render_mode unshaded;

uniform sampler2D dist_map : hint_black;
uniform vec4 colour : hint_color;
uniform float inv_glow_strength : hint_range(1,16) = 1;

void fragment() {
	float glow = 1. - texture(dist_map,UV).r;
	glow = pow(glow,inv_glow_strength);
	ALBEDO.rgb = glow * colour.rgb;
}

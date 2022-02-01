shader_type spatial;
render_mode unshaded;
uniform vec4 colour : hint_color;
uniform float animation_speed = 4.;
uniform float ring_density = 17.;
uniform float thickness_change = 3.;
uniform float thickness_change_speed = 5.;
uniform float squareness : hint_range(0,20) = 2;
uniform vec2 size = vec2(1);

void vertex() {
	COLOR = vec4(VERTEX,1);
}

void fragment() {
	vec4 position = COLOR;
	position.x = max(abs(position.x) - max(size.x-size.y, 0) * 0.5, 0);
	position.z = max(abs(position.z) - max(size.y-size.x, 0) * 0.5, 0);
	position.x = pow(position.x,squareness);
	position.z = pow(position.z,squareness);
	float ring = pow(position.x+position.z, 1./squareness);
	float len = ring*ring_density+TIME*animation_speed;
	float thickness = 1.+thickness_change+sin(TIME*thickness_change_speed)*thickness_change;
	ALBEDO.rgb = pow(max(sin(len),0),thickness)*colour.rgb;
}

shader_type spatial;

uniform float strength;
render_mode unshaded;

float rand(vec4 v) {
	float a = v.x*v.y*9.+v.w*2.;
	float b = v.z*v.x*12.+v.y*921.;
	float c = v.w*v.y*99.-v.x*123.;
	c += mod(a*1237.,11)+b*7.;
	b += mod(c*19.,23)+a*23.;
	a += mod(c*2341.,a)+b*21.;
	a = mod(a+b+c,1);
	return abs(a);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	
	float gx = rand(vec4(round(uv.x*30.)/30.,TIME,0,0));
	float gy = rand(vec4(round(uv.y*21.)/21.,TIME,0,0));
	uv += vec2(0,rand(vec4(uv,TIME,0)))*strength*0.03 * float(gx > (1.-strength));
	uv += vec2(rand(vec4(uv,TIME,0)),0)*strength*0.03 * float(gy > (1.-strength));
	
	ALBEDO.rgb = texture(SCREEN_TEXTURE,uv).rgb;
}

void vertex() {
	POSITION = vec4(VERTEX,1);
}
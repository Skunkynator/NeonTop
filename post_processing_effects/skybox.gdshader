shader_type spatial;

render_mode unshaded;

void fragment() {
	vec3 col = normalize(COLOR.rgb);
	//make normal vector work nicely with later code
	vec3 normal = abs(col);
	normal.x = -normal.x;
	
	col = fract(col * 10.) * 2. - vec3(1.);
	col = col * col;
	col = col * col;
	col = col * col;
	col = col * col;
	//get vector length, and make sure it isnt too streched
	float veclength = length(col);
	float dotLength = abs(dot(normal, col));
	veclength = veclength * veclength;
	veclength = sqrt(veclength - min(dotLength * dotLength * 1.25, veclength));
	//return colour
	ALBEDO.rgb = veclength * vec3(0,0,1);
}

void vertex() {
	vec4 vert = vec4(VERTEX,1);
	vert.z = 0.9999994932;
	POSITION = vert;
	VERTEX = vert.xyz;
	vert.z = -1.0;
	//i have no idea why i have to multiply by 10. here
	vert.xy = vert.xy * 10.;
	//convert to world space
	vert = vert * INV_PROJECTION_MATRIX * INV_CAMERA_MATRIX;
	COLOR = vert;
}
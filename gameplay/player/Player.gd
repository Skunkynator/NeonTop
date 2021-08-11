extends KinematicBody
class_name Player


export(NodePath) var player_view_path
export var player_speed := 15
export var max_jumps := 2
export var wall_tollerance := 0.2 # for wall running
export var min_wall_speed := 7 # min speed needed for wall run
export var max_coyote_timer := 0.15
export var max_jump_timer := 0.1
export var max_wall_timer := 0.2
var player_view : Spatial
var mouse_sensitivity := 0.2
var forward := Vector3.FORWARD
var up := Vector3.UP
var left := Vector3.LEFT
var velocity := Vector3.ZERO
var dvel := Vector3.ZERO # desired velocity
var gravity_dir := -up
var gravity_strength := 20
var cur_gravity := Vector3.ZERO
var jump_strength := 0.5
var jumps_left := 0
var cam_tilt := 0 # when wall running
var wall_normal := Vector3.ZERO
var coyote_timer := 0.0 # for delayed jumps
var jump_timer := 1.0 # for early jumps
var wall_timer := 1.0 # for late wall jumps


func _ready():
	var test := Vector3.UP.cross(Vector3.FORWARD)
	var test2 := Vector3.FORWARD.cross(Vector3.UP)
	var node : Node = get_node(player_view_path)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if node is Spatial:
		player_view = node


func _physics_process(delta):
	# Compute desired direction
	dvel = forward * int(Input.is_action_pressed("gp_forward"))
	dvel -= forward * int(Input.is_action_pressed("gp_back"))
	dvel += left * int(Input.is_action_pressed("gp_left"))
	dvel -= left * int(Input.is_action_pressed("gp_right"))
	if Input.is_action_just_pressed("gp_jump"):
		jump_timer = 0
	if dvel.length() != 0:
		dvel = dvel.normalized()
	dvel *= player_speed
	# How much control the player has over movement
	var control = 0.003 if is_on_floor() or is_on_wall() else 0.4
	cur_gravity += gravity_dir * gravity_strength * delta
	cur_gravity *= int(not (is_on_floor() or is_on_ceiling()))
	
	coyote_timer += delta
	wall_timer += delta
	jump_timer += delta
	if coyote_timer > 0.15 and jumps_left == max_jumps:
		jumps_left = max_jumps - 1
	 
	var snap := -up
	cam_tilt = 0
	if is_on_floor():
		coyote_timer = 0
		jumps_left = max_jumps
		snap = -get_floor_normal()
	elif is_on_wall():
		coyote_timer = 0
		jumps_left = max_jumps
		_wall_controls()
	if jump_timer < max_jump_timer:
		if !is_on_floor() and wall_timer < max_wall_timer:
			wall_timer = 1
			velocity += player_speed*wall_normal
			jumps_left += int(jumps_left == 0)
		if jumps_left > 0:
			jump_timer = 1
			jumps_left -= 1
			snap = Vector3.ZERO
			cur_gravity = -gravity_dir * gravity_strength * jump_strength
			if !is_on_wall() and dvel and velocity.normalized().dot(dvel.normalized()) < 0.5:
				velocity = 1.1*dvel
	else:
		velocity = velocity.linear_interpolate(dvel, 1-pow(control, delta))
	
	player_view.rotation_degrees.z = lerp(player_view.rotation_degrees.z, cam_tilt, 1-pow(0.1,delta))
	velocity = move_and_slide_with_snap(velocity + cur_gravity,snap,up)
	cur_gravity = velocity.project(gravity_dir)
	velocity -= cur_gravity


func _wall_controls():
	for i in get_slide_count():
		var collision := get_slide_collision(i)
		if abs(collision.normal.dot(-gravity_dir)) < wall_tollerance:
			wall_normal = collision.normal
			wall_timer = 0
			if velocity.length() > min_wall_speed: # start wall run
				dvel *= 1.4
				cur_gravity = Vector3.ZERO
				velocity -= wall_normal
				cam_tilt = 20 * wall_normal.dot(left)
			break


func _input(event):
	if event is InputEventMouseMotion:
		process_mouse(event.relative)

# x mouse change -> Y camera rotation
# y mouse change -> X camera rotation
func process_mouse(change: Vector2):
	change = change * mouse_sensitivity
	if player_view:
		var view := player_view.rotation_degrees
		view.x = clamp(view.x - change.y,-85,85)
		view.y = view.y - change.x
		player_view.rotation_degrees = view
		player_view.orthonormalize()
		forward = -player_view.transform.basis.z
		forward = Plane(up,0).project(forward).normalized()
		left = up.cross(forward).normalized()
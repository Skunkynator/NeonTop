extends KinematicBody
class_name Player


export(int, LAYERS_3D_PHYSICS) var ui_layer : int
export var player_view_path : NodePath
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
var cam_tilt := .0 # when wall running
var wall_normal := Vector3.ZERO
var coyote_time := .0 # for delayed jumps
var coyote_active := true # if we're still checking
var jump_timer := 1.0 # for early jumps | when jump was last pressed
var wall_timer := 1.0 # for late wall jumps | when wall was last touched
var wallrun_timer := 1.0 # when we last ran on a wall
var frozen := false
var mouse_freeze := false


func _ready() -> void:
	GameController.main_player = self
	var node := get_node(player_view_path) as Spatial
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	player_view = node


func _physics_process(delta : float) -> void:
	if frozen:
		return
	# Compute desired direction
	dvel = forward * int(Input.is_action_pressed("gp_forward"))
	dvel -= forward * int(Input.is_action_pressed("gp_back"))
	dvel += left * int(Input.is_action_pressed("gp_left"))
	dvel -= left * int(Input.is_action_pressed("gp_right"))
	if Input.is_action_just_pressed("gp_jump"):
		jump_timer = 0
	if dvel.length() != 0:
		dvel = dvel.normalized()
	if velocity.normalized().dot(dvel) < 0:
		dvel *= 2.5
	dvel *= player_speed
	# How much control the player has over movement
	var control := 0.003 if is_on_floor() or is_on_wall() else 0.4
	
	coyote_time += delta
	wall_timer += delta
	wallrun_timer += delta
	jump_timer += delta
	if coyote_active and coyote_time > 0.15:
		if jumps_left == max_jumps:
			jumps_left = max_jumps - 1
		coyote_active = false
	
	var snap := -up
	cam_tilt = 0
	if is_on_floor():
		coyote_time = 0
		coyote_active = true
		jumps_left = max_jumps
		snap = -get_floor_normal()
	elif is_on_wall():
		_wall_behaviour()
	
	cur_gravity += gravity_dir * gravity_strength * delta
	if (is_on_floor() and cur_gravity.dot(up) < 0 or is_on_ceiling() and cur_gravity.dot(up) > 0):
		cur_gravity *= 0
	else:
		snap = Vector3.ZERO
	
	# for jumping. This is if player pressed jump a little too early
	if jump_timer < max_jump_timer:
		if !is_on_floor() and wall_timer < max_wall_timer:
			wall_timer = max_wall_timer
			velocity += player_speed*wall_normal
			jumps_left += int(jumps_left == 0)
		if jumps_left > 0:
			jump_timer = max_jump_timer
			jumps_left -= 1
			snap = Vector3.ZERO
			cur_gravity = -gravity_dir * gravity_strength * jump_strength
			if !is_on_wall() and dvel and velocity.normalized().dot(dvel.normalized()) < 0.5:
				velocity = 0.5 * dvel
	else:
		velocity = velocity.linear_interpolate(dvel, 1-pow(control, delta))
	
	player_view.rotation_degrees.z = lerp(player_view.rotation_degrees.z, cam_tilt, 1-pow(0.1,delta))
	velocity = move_and_slide_with_snap(velocity + cur_gravity,snap,up)
	cur_gravity = velocity.project(gravity_dir)
	velocity -= cur_gravity
	check_event_collisions()


func _wall_behaviour():
	for i in get_slide_count():
		var collision := get_slide_collision(i)
		if abs(collision.normal.dot(-gravity_dir)) < wall_tollerance:
			wall_normal = collision.normal
			if velocity.length() > min_wall_speed: # start wall run
				dvel *= 1.3
				cur_gravity = Vector3.ZERO
				velocity -= wall_normal
				cam_tilt = 20 * wall_normal.dot(left)
				if wallrun_timer > 0.7:
					jumps_left += 1
				wallrun_timer = 0
			wall_timer = 0
			break


func _input(event : InputEvent) -> void:
	if event is InputEventMouseMotion:
		process_mouse((event as InputEventMouseMotion).relative)
	if event is InputEventMouse:
		process_3d_ui(event as InputEventMouse)

# x mouse change -> Y camera rotation
# y mouse change -> X camera rotation
func process_mouse(change : Vector2) -> void:
	if mouse_freeze:
		return
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


func process_3d_ui(mouse_event : InputEventMouse) -> void:
	var camera := get_viewport().get_camera()
	var global_position := mouse_event.global_position
	var from := camera.project_ray_origin(global_position)
	var to := from + camera.project_ray_normal(global_position) * 10
	var intersect := get_world().direct_space_state.intersect_ray(from, to, [], ui_layer,false,true)
	if intersect.size() > 0:
		var ui_area := intersect.collider as Gui3dController
		ui_area.handle_input(mouse_event,intersect.position as Vector3)


func release_mouse():
	mouse_freeze = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func capture_mouse():
	mouse_freeze = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func check_event_collisions() -> void:
	for collision_num in get_slide_count():
		var collision := get_slide_collision(collision_num)
		if collision.collider.has_method("_on_player_entered"):
			collision.collider._on_player_entered(self)


func die() -> void:
	var animationPlayer: AnimationPlayer = $AnimationPlayer as AnimationPlayer
	if animationPlayer:
		animationPlayer.play("death")
		var animation_len := animationPlayer.get_current_animation_length()
		frozen = true
		yield(get_tree().create_timer(animation_len / 2), "timeout")
		frozen = false
	GameController.reset_level()
	set_default_parameters()


func set_default_parameters() -> void:
	cur_gravity = Vector3.ZERO
	dvel = Vector3.ZERO
	velocity = Vector3.ZERO
	var respawn_trans: Transform = GameController.get_respawn_transform()
	self.up = respawn_trans.basis.y
	if player_view:
		player_view.rotation_degrees = Vector3.ZERO
		process_mouse(Vector2.ZERO)
	transform.origin = respawn_trans.origin

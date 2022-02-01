tool
extends Area
class_name Gui3dController


export var viewport_path : NodePath
var quad_mesh_size : Vector2
var last_mouse_pos2D : Vector2
var node_viewport : Viewport


func _ready() -> void:
	var node_quad : MeshInstance
	for child in get_children():
		if child is MeshInstance:
			node_quad = child as MeshInstance
			break
	node_viewport = get_node_or_null(viewport_path) as Viewport
	if not node_quad or not node_viewport:
		queue_free()
		return
	if not node_quad.mesh is QuadMesh:
		queue_free()
		return
	var material := node_quad.get_surface_material(0) as SpatialMaterial
	quad_mesh_size = node_quad.mesh.size
	material.albedo_texture = node_viewport.get_texture()
	if OS.get_current_video_driver() == OS.VIDEO_DRIVER_GLES2:
		material.flags_albedo_tex_force_srgb = false
	set_collision_layer_bit(15,true)


func handle_input(event : InputEventMouse, global_position : Vector3) -> void:
	var mouse_pos3D : Vector3
	mouse_pos3D = global_transform.affine_inverse() * global_position
	var mouse_pos2D := Vector2(mouse_pos3D.x, -mouse_pos3D.y)
	mouse_pos2D.x += quad_mesh_size.x / 2
	mouse_pos2D.y += quad_mesh_size.y / 2 
	mouse_pos2D.x = (mouse_pos2D.x / quad_mesh_size.x) * node_viewport.size.x
	mouse_pos2D.y = (mouse_pos2D.y / quad_mesh_size.y) * node_viewport.size.y
	event.position = mouse_pos2D
	event.global_position = mouse_pos2D
	if event is InputEventMouseMotion:
		(event as InputEventMouseMotion).relative = mouse_pos2D - last_mouse_pos2D
	last_mouse_pos2D = mouse_pos2D
	node_viewport.input(event)
	pass


func _get_configuration_warning():
	var warning : String = ''
	var has_mesh_instance := false
	var has_collision_shape := false
	var mesh_instance : MeshInstance
	for child in get_children():
		if child is MeshInstance:
			mesh_instance = child as MeshInstance
			has_mesh_instance = true
		has_collision_shape = child is CollisionShape or has_collision_shape
	if not has_collision_shape:
		warning += 'No CollisionShape given as a child!\n'
	if not has_mesh_instance:
		warning += 'No MeshInstance given as a child!\n'
	else:
		if not mesh_instance.mesh is QuadMesh:
			warning += 'Only QuadMesh is supported!\n'
		if not mesh_instance.get_surface_material(0) is SpatialMaterial:
			warning += 'SpatialMaterial is required on mesh!\n'
	if not viewport_path:
		warning += 'Viewport path not given!\n'
	return warning

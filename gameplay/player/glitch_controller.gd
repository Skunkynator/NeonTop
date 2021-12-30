extends MeshInstance


export var strength : float = 0 setget set_strength
var material : ShaderMaterial


func set_strength(new_strength : float):
	if material:
		material.set_shader_param("strength",new_strength)


func _ready() -> void:
	material = mesh.surface_get_material(0) as ShaderMaterial
	if not material:
		free()
	var cur_shader : Shader
	cur_shader = material.shader
	if not cur_shader.has_param("strength"):
		free()
	set_strength(0)

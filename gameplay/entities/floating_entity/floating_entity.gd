extends Spatial
class_name FloatingEntity


export var float_strength : float = 0.5
export var float_dir : Vector3 = Vector3(0,1,0)
export var float_speed : float = 1
var float_modifier : float = 1
var timer : float = 0
var prev_offset : float


func _ready() -> void:
	randomize()
	timer += rand_range(0 , 2 * PI / float_speed)
	prev_offset = get_offset_at(timer)


func _process(delta: float) -> void:
	timer = fmod((timer + delta), (2 * PI / float_speed))
	var offset := get_offset_at(timer)
	global_translate((prev_offset - offset) * float_dir)
	prev_offset = offset


func get_offset_at(time: float) -> float:
	return sin(time * float_speed) * float_strength

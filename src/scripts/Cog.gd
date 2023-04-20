extends Hazard


export var speed : float = -30
var base_rot

func _ready() -> void:
	base_rot = rotation
	
func reset():
	rotation = base_rot


	
func _physics_process(delta: float) -> void:
	rotate(deg2rad(speed) * delta)

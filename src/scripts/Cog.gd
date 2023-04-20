extends KinematicBody2D


export var speed : float = -30



	
func _physics_process(delta: float) -> void:
	rotate(deg2rad(speed) * delta)

extends KinematicBody2D

onready var animator :=  $AnimationPlayer
export var speed : float = 1
export var start_time : float = 0


func _ready() -> void:
	if(start_time == 0):
		animator.play("anim_StepOut",-1,speed)
	else:
		$StartTimer.start(start_time)


func _on_StartTimer_timeout() -> void:
	animator.play("anim_StepOut",-1,speed)

func _randomize_sound():
	var randomfloat : float = rand_range(0.9,1.1)
	$StepIn.pitch_scale = randomfloat

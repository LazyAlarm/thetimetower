extends KinematicBody2D

export var start_time : float = 0
export var speed : float = 100

func _ready() -> void:
	if start_time == 0:
		$AnimationPlayer.play("anim_Crusher",-1,speed/100)
	else:
		$StartTimer.start(start_time)


func _on_StartTimer_timeout() -> void:
	$AnimationPlayer.play("anim_Crusher",-1,speed/100)

func _randomize_sound():
	var randomfloat : float = rand_range(0.9,1.1)
	$AudioStreamPlayer2D.pitch_scale = randomfloat

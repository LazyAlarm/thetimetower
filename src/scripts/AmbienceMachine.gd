extends AudioStreamPlayer2D


export var pitch_rangemn := 0.9
export var pitch_rangmx := 1.1

func _ready() -> void:
	attenuation = 2.5
	pitch_scale = rand_range(pitch_rangemn,pitch_rangmx)

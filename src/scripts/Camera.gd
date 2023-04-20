extends Camera2D

var max_x_distance : float = 15
var max_y_distance : float = 30
var catch_x : bool = false
var catch_y : bool = false

onready var player := get_parent().get_node("Player")

func _process(delta: float) -> void:
	#global_position = lerp(global_position, get_parent().get_node("Player").global_position,delta * 3)
	
	if(abs(global_position.x-player.global_position.x) > max_x_distance):
		catch_x = true
	if(abs(global_position.y-player.global_position.y) > max_y_distance):
		catch_y = true
	
	if(catch_x):
		global_position.x = lerp(global_position.x, player.global_position.x,delta * 2)
		if(abs(global_position.x-player.global_position.x) < 1):
			catch_x = false

	if(catch_y):
		global_position.y = lerp(global_position.y, player.global_position.y,delta * 2)
		if(abs(global_position.y-player.global_position.y) < 1):
			catch_y = false

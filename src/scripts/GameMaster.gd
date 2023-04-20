extends Node


onready var player = $Player
onready var music_ending := preload("res://src/sound/Juhani Junkala [Chiptune Adventures] 1. Stage 1.wav")
onready var menu = $CanvasLayer/Menu
onready var timer = $Timer
onready var timer_text = $CanvasLayer/UI/TimerText
onready var gameover_text = $CanvasLayer/UI/OutOfTime
onready var totaltime_text = get_parent().get_node("Ending/Total Time")

var hazards : Array
var spawnpoints : Array
var index : int = 0
var waiting : bool = true

var won : bool = false
var quiet_music : bool = false
var moved_before : bool = false
var total_time : float = 0

func _ready() -> void:
	$CanvasLayer.show()
	get_tree().paused = true
	spawnpoints.append(player.global_position)
	player.connect("respawn",self,"_respawn")
	timer.connect("timeout",self,"_timeout")
	
	#Setup Spawnpoints
	for node in get_parent().get_children():
		print_debug(node.name)
		if node is Checkpoint:
			node.body_to_check = player
			node.connect("checkpoint_reached",self,"_set_spawn")
	#Get Obstacles
	for child in get_parent().get_children():
		if (child.get_child_count() > 0):
			for grandchild in child.get_children():
				if grandchild is Hazard:
					hazards.append(grandchild)

func _process(delta: float) -> void:
	if(Input.is_action_pressed("reset")):
		reset_timer += delta
		if(reset_timer > 1):
			get_tree().reload_current_scene()
	
	if(quiet_music):
		$"BG Music".volume_db = clamp($"BG Music".volume_db- (delta*4),-100,100)
	if(moved_before):
		total_time += delta
	if(won):
		return
	if(player.animator.current_animation == "anim_Die"):
		timer.stop()
		return
	if(!player.has_moved):
		timer_text.text = "Time: 10"
		timer.stop()
		return
	timer_text.text = "Time: " + str(int(timer.time_left+1))
	if(waiting and player.has_moved):
		waiting = false
		timer.start()
		moved_before = true
	
func _timeout():
	if(won):
		return
	timer_text.text = "Time: 0"
	player.player_died()
	gameover_text.show()


func _respawn():
	gameover_text.hide()
	timer.stop()
	waiting = true
	player.has_moved = false
	if(index < 0): index = 0
	player.global_transform.origin = spawnpoints[index]
	player.velocity = Vector2.ZERO
	#_reset_cycles()

func _set_spawn(spawnpoint):
	timer.stop()
	waiting = true
	player.has_moved = false
	for i in spawnpoints:
		if i == spawnpoint:
			return
	spawnpoints.append(spawnpoint)
	index += 1
	#_reset_cycles()
	
#TODO: Get list on ready then only loop through that list
func _reset_cycles():
	for hazard in hazards:
		hazard.reset()
	

var reset_timer : float

func _on_Play_button_down() -> void:
	get_tree().paused = false
	menu.hide()
	$"BG Music".play()
	
func _on_Final_Checkpoint(body: Node) -> void:
	won = true
	timer_text.text = "Time: Infinite"

func _on_Shhhh_body_entered(body: Node) -> void:
	if(body.collision_layer == 9): #Player
		quiet_music = true

func _input(event: InputEvent) -> void:
	if(Input.is_action_pressed("start")):
		if(menu.visible):
			_on_Play_button_down()

	if(Input.is_action_just_released("reset")):
		reset_timer = 0
		_respawn()

func _on_Win_body_entered(body: Node) -> void:
	if(body.collision_layer == 9): #Player
		if($"Win Music".is_playing()):
			return
		$"Win Music".play()
		timer_text.hide()
		
		var time = int(total_time * 100)
	
		var milliseconds = time % 100
		time /= 100
		var seconds = time % 60
		time /= 60
		var minutes = time % 60
		time /= 60
		var hours = time % 60
		time /= 60
		#var milliseconds = round((total_time-seconds) * 100)
		totaltime_text.text = "Total Time \n" + str("%02d:%02d:%02d:%2d" % [hours,minutes,seconds,milliseconds])
		

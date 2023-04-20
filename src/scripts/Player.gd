extends KinematicBody2D

#Animation
onready var graphics = $Graphics
onready var animator = $AnimationPlayer

#Movement
var velocity : Vector2 = Vector2.ZERO
var max_speed : float = 90
var max_fall_speed : float = 320
var jump_velocity : float = 250 
var wall_distance : float = 5
var wall_jump_margin : float = 2
var wall_jump_height : float = 250
var wall_jump_velocity : float = 250
var wall_slide : bool = false
var acceleration : float = 20
var gravity : float = 9.81

var is_stuck = false
export var is_dead = false
var has_moved : bool = false

func _physics_process(delta: float) -> void:
	#Test for death
	if is_dead:
		return

	var space_state = get_world_2d().direct_space_state
	is_stuck = space_state.intersect_ray(global_position, global_position+ Vector2.UP, [self])
	if(is_stuck):
		player_died()
		return
	
	#Normal Jump
	if(Input.is_action_just_pressed("jump")):
		$jump_queue.start()
	if(($jump_queue.time_left > 0 or Input.is_action_pressed("jump")) and (is_on_floor() or $coyote_queue.time_left > 0)):
		velocity.y = -jump_velocity
		has_moved = true
		speaker.stream = sound_jump
		speaker.play()
		$coyote_queue.stop()
		$jump_queue.stop()

	#Wall Jump
	if((Input.is_action_just_pressed("jump")) and is_on_wall() and !is_on_floor() and abs(velocity.x) > 0):
		velocity.y = -wall_jump_height
		has_moved = true
		speaker.stream = sound_kick
		speaker.play()
		$coyote_queue.stop()
		$jump_queue.stop()
		var result_right = space_state.intersect_ray(global_position, global_position + Vector2.RIGHT * (wall_distance + wall_jump_margin), [self],1)
		if(result_right):
			velocity.x = -wall_jump_velocity #* Input.get_action_strength("move_right")
			$wall_jump_timer.start()
		var result_left = space_state.intersect_ray(global_position, global_position + Vector2.LEFT * (wall_distance + wall_jump_margin), [self],1)
		if(result_left):
			velocity.x = wall_jump_velocity #* Input.get_action_strength("move_left")
			$wall_jump_timer.start()
	
	
	#Wall Slide
	if(is_on_wall() and !is_on_floor() and $jump_queue.time_left == 0 and !Input.is_action_just_pressed("jump") and velocity.y > 0 and Input.get_axis("move_left","move_right") != 0 ):
		
		var result_right = space_state.intersect_ray(global_position, global_position + Vector2.RIGHT * wall_distance, [self])
		var result_left = space_state.intersect_ray(global_position, global_position + Vector2.LEFT * wall_distance, [self])
		if(result_right):
			if(Input.get_axis("move_left","move_right") > 0):
				wall_slide = true
		elif(result_left):
			if(Input.get_axis("move_left","move_right") < 0):
				wall_slide = true
	else:
		wall_slide = false
	
	
	#Smack Head on ceiling
	if(is_on_ceiling() and velocity.y < 0):
		velocity.y = 0
	
	#Just standing
	if(is_on_floor() and velocity.y > 1):
		$coyote_queue.start()
		$wall_jump_timer.stop()
		velocity.y = 1

	#Slow Jump
	if(wall_slide):
		velocity.y = clamp(velocity.y + (gravity * 0.2), -max_fall_speed * 0.2, max_fall_speed * 0.2)
	elif(velocity.y < 0 and Input.is_action_pressed("jump")):
		velocity.y = clamp(velocity.y + (gravity), -max_fall_speed, max_fall_speed)
	else: #Standard fall
		velocity.y = clamp(velocity.y + (gravity * 1.75), -max_fall_speed, max_fall_speed)
	
	
	#Input X
	var inputx : float
	if(velocity.x < max_speed and $wall_jump_timer.time_left == 0):
		inputx += Input.get_action_strength("move_right")
	if(velocity.x > -max_speed and $wall_jump_timer.time_left == 0):
		inputx -= Input.get_action_strength("move_left")
	velocity.x += (inputx * acceleration)
	if($wall_jump_timer.time_left == 0 and velocity.x != 0 and abs(velocity.x) > max_speed):
		#velocity.x = clamp(velocity.x, -max_speed, max_speed)
		velocity.x = lerp(velocity.x,clamp(velocity.x, -max_speed, max_speed), delta * 4)
	if(!Input.is_action_pressed("move_left") and !Input.is_action_pressed("move_right")):
		if(is_on_floor()):
			velocity.x *= 0.85
		else:
			velocity.x *= 0.95
	else:
		has_moved = true

	move_and_slide(velocity, Vector2.UP)
	
	

onready var speaker := $Sounds
var sound_jump := preload("res://src/sound/Jump.wav")
var sound_kick := preload("res://src/sound/WallKick.wav")

func _process(delta: float) -> void:
	
	#Animation
	
	if is_dead:
		return
		
	graphics.flip_h = velocity.x < 0
	if(wall_slide):
		animator.play("anim_Slide")
	elif !is_on_floor():
		animator.play("anim_Jump")
	elif velocity.x != 0 and abs(velocity.x) > 10:
		if(animator.current_animation != "anim_Run"):
			animator.play("anim_Run")
		#animator.playback_speed = velocity.x/(max_speed*0.75)
	else:
		animator.play("anim_Idle")
		animator.playback_speed = 1



signal respawn
signal player_won(spawnpoint)

func player_died():
	animator.play("anim_Die",-1,1)


func _respawn():
	emit_signal("respawn")
	
	
	
	

func _on_hitbox_collision(area: Area2D) -> void:
	if(area.collision_layer == 4): #Enemy
		emit_signal("player_died")
	if(area.collision_layer == 16): #Goal
		emit_signal("player_won",area.global_position)

extends Area2D
class_name Checkpoint

signal checkpoint_reached(spawnpoint)
var body_to_check


func _on_Checkpoint_body_entered(body: Node) -> void:
	$Sprite.frame = 1
	$AudioStreamPlayer2D.play()
	
func _physics_process(delta: float) -> void:
	if(body_to_check and overlaps_body(body_to_check)):
		emit_signal("checkpoint_reached",global_position)
		


func _on_Checkpoint_body_exited(body: Node) -> void:
	$Sprite.frame = 0

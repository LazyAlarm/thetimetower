extends Area2D




func _on_Checkpoint_body_entered(body: Node) -> void:
	$Sprite.frame = 1
	$AudioStreamPlayer2D.play()

func _on_Checkpoint_body_exited(body: Node) -> void:
	$Sprite.frame = 0

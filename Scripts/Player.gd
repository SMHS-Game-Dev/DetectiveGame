extends CharacterBody2D

const SPEED: float = 300.0

var input: Vector2 = Vector2.ZERO
var timer: float = 0.0

func _physics_process(delta: float) -> void:
	input = Input.get_vector("left", "right", "up", "down") if not GameDialogueManager.in_dialogue else Vector2.ZERO
	
	velocity.x = input.x * SPEED
	velocity.y = input.y * SPEED
	
	move_and_slide()
	
func _on_area_2d_area_entered(area: Area2D) -> void:
	pass

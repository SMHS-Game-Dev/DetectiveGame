extends CharacterBody2D


const SPEED: float = 300.0
var input: Vector2 = Vector2.ZERO # (0, 0)

func _physics_process(delta: float) -> void:
	input.x = Input.get_axis("left", "right")
	input.y = Input.get_axis("up", "down")
	
	velocity.x = input.x * SPEED if input.x else 0
	velocity.y = input.y * SPEED if input.y else 0
	

	move_and_slide()


func _on_area_2d_area_entered(area: Area2D) -> void:
	pass

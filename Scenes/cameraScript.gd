extends CharacterBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var space_state = get_world_2d().direct_space_state
	var cam = self.get_child(0)
	var player = get_parent().get_node("Player")
	var playPos = player.global_position
	var camPos  = cam.get_target_position()
	var camRayX = PhysicsRayQueryParameters2D.create(camPos, Vector2 (playPos.x + 150, playPos.y), 16) #creates right facing ray
	var camRayNegX = PhysicsRayQueryParameters2D.create(camPos, Vector2 (playPos.x - 150, playPos.y), 16)
	var camRayY = PhysicsRayQueryParameters2D.create(camPos, Vector2 (playPos.x, playPos.y - 150), 16)
	var camRayNegY = PhysicsRayQueryParameters2D.create(camPos, Vector2 (playPos.x, playPos.y + 150), 16)
	var resX = space_state.intersect_ray(camRayX) 
	var resNegX = space_state.intersect_ray(camRayNegX)
	var resY = space_state.intersect_ray(camRayY)
	var resNegY = space_state.intersect_ray(camRayNegY)
	var moveCamX = true
	var moveCamY = true
	velocity = player.velocity
	
	if resX and player.velocity.x > 0:
		velocity.x = 0 
		moveCamX = false
	if resNegX and player.velocity.x < 0:
		velocity.x = 0
		moveCamX = false

	if resY and player.velocity.y < 0:
		velocity.y = 0
		moveCamY = false
	if resNegY and player.velocity.y > 0:
		velocity.y = 0
		moveCamY = false

	if moveCamX and (camPos.x - playPos.x > 10.0 or camPos.x - playPos.x < -10.0):

			velocity.x = player.velocity.x * 0.2
	
	elif moveCamX:
		self.global_position.x = playPos.x
	if moveCamY and (camPos.y - playPos.y > 10.0 or camPos.y - playPos.y < -10.0):

			velocity.y = player.velocity.y * 0.2
	
	elif moveCamY:
		self.global_position.y = playPos.y
	move_and_slide()

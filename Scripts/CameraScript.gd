extends CharacterBody2D

@onready var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
@onready var cam: Camera2D = self.get_child(0)
@onready var player: CharacterBody2D = get_parent().get_node("Player")

var deadzone_x: float = 250.0
var deadzone_y: float = 140.0

func _ready() -> void:
	self.global_position = player.global_position

func _physics_process(delta: float) -> void:
	var play_pos = player.global_position

	var viewport_size = get_viewport().get_visible_rect().size
	var half_w = (viewport_size.x / 2.0) / cam.zoom.x
	var half_h = (viewport_size.y / 2.0) / cam.zoom.y

	var offset_x = play_pos.x - self.global_position.x
	var offset_y = play_pos.y - self.global_position.y

	if abs(offset_x) > deadzone_x: self.global_position.x = play_pos.x - (sign(offset_x) * deadzone_x)
	if abs(offset_y) > deadzone_y: self.global_position.y = play_pos.y - (sign(offset_y) * deadzone_y)

	velocity = Vector2.ZERO

	var origin = self.global_position

	var cam_ray_x = PhysicsRayQueryParameters2D.create(origin, Vector2(origin.x + half_w, origin.y), 16)
	var cam_ray_neg_x = PhysicsRayQueryParameters2D.create(origin, Vector2(origin.x - half_w, origin.y), 16)
	var cam_ray_y = PhysicsRayQueryParameters2D.create(origin, Vector2(origin.x, origin.y - half_h), 16)
	var cam_ray_neg_y = PhysicsRayQueryParameters2D.create(origin, Vector2(origin.x, origin.y + half_h), 16)

	var res_x = space_state.intersect_ray(cam_ray_x)
	var res_neg_x = space_state.intersect_ray(cam_ray_neg_x)
	var res_y = space_state.intersect_ray(cam_ray_y)
	var res_neg_y = space_state.intersect_ray(cam_ray_neg_y)

	if res_x and self.global_position.x > res_x.position.x     - half_w: self.global_position.x = res_x.position.x     - half_w
	if res_neg_x and self.global_position.x < res_neg_x.position.x + half_w: self.global_position.x = res_neg_x.position.x + half_w
	if res_y and self.global_position.y < res_y.position.y     + half_h: self.global_position.y = res_y.position.y     + half_h
	if res_neg_y and self.global_position.y > res_neg_y.position.y - half_h: self.global_position.y = res_neg_y.position.y - half_h

	move_and_slide()

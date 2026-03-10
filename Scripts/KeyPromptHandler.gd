@tool
extends Panel

var location: Vector2
var can_interact: bool = false
var key_code: int = 0
var assigned_key_index: int = -1

func _ready() -> void:
	_on_resized()
	location = position
	position.y = location.y + 20

func _on_resized() -> void:
	$Letter.add_theme_font_size_override("font_size", int(size.x * 0.5))

func _on_interactable_player_near(state: bool) -> void:
	can_interact = state
	if state:
		assigned_key_index = KeyManager.claim_key()
		key_code = OS.find_keycode_from_string(KeyManager.keys[assigned_key_index])
		$Letter.text = KeyManager.keys[assigned_key_index]
		show_key()
	else:
		if assigned_key_index != -1:
			KeyManager.release_key(assigned_key_index)
			assigned_key_index = -1
		hide_key()

func show_key() -> void:
	modulate.a = 0
	visible = true
	
	var moveTween: Tween = create_tween()
	moveTween.tween_property(self, "position:y", location.y, 0.3) \
	.set_ease(Tween.EASE_OUT) \
	.set_trans(Tween.TRANS_QUART)
	
	var opacityTween: Tween = create_tween()
	opacityTween.tween_property(self, "modulate:a", 1, 0.3) \
	.set_ease(Tween.EASE_OUT) \
	.set_trans(Tween.TRANS_QUART)
	
func hide_key() -> void:
	var moveTween: Tween = create_tween()
	moveTween.tween_property(self, "position:y", location.y + 20, 0.3) \
	.set_ease(Tween.EASE_OUT) \
	.set_trans(Tween.TRANS_QUART)
	
	var opacityTween: Tween = create_tween()
	opacityTween.tween_property(self, "modulate:a", 0, 0.3) \
	.set_ease(Tween.EASE_OUT) \
	.set_trans(Tween.TRANS_QUART)

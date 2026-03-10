@tool
extends Panel

var location: Vector2
var can_interact: bool = false
var key_code: int = 0

func _ready() -> void:
	_on_resized()
	location = position
	position.y = location.y + 20

func _on_resized() -> void:
	$Letter.add_theme_font_size_override("font_size", int(size.x * 0.5))

func _on_interactable_player_near(state: bool) -> void:
	can_interact = state
	if state:
		key_code = OS.find_keycode_from_string(KeyManager.keys[KeyManager.key_prompts])
		$Letter.text = KeyManager.keys[KeyManager.key_prompts]
		KeyManager.key_prompts += 1
		
		show_key()
	else:
		KeyManager.key_prompts -= 1
	
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

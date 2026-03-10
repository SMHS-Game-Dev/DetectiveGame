extends Panel

signal animation_finished

@onready var label: RichTextLabel = $Dialogue

var dropin_effect: RichTextEffect
var is_typing: bool = false
var full_text: String = ""
var delay: float
var tween: Tween

func _ready() -> void:
	for effect in label.custom_effects:
		if effect.bbcode == "dropin":
			dropin_effect = effect
			break

func display_line(text: String) -> void:
	full_text = text
	dropin_effect.reveal_times.clear()
	label.text = "[dropin]" + full_text + "[/dropin]"
	label.visible_characters = 0
	is_typing = true
	
	var total_duration: float = min(0.05 * text.length(), 5.0)
	delay = total_duration / text.length()
	
	for i in range(text.length()):
		var reveal_time: float = Time.get_ticks_msec() / 1000.0 + (i * delay)
		dropin_effect.reveal_times.append(reveal_time)
	
	tween = create_tween()
	tween.tween_method(
		func(val: int): label.visible_characters = val,
		0, text.length(),
		total_duration
	).set_trans(Tween.TRANS_LINEAR)
	tween.tween_callback(func():
		is_typing = false
		label.text = label.get_parsed_text()
		animation_finished.emit()
	)

func skip_animation() -> void:
	if tween:
		tween.kill()
	dropin_effect.reveal_times.clear()
	label.visible_characters = -1
	label.text = full_text
	is_typing = false
	animation_finished.emit()

func _type_next_character(index: int) -> void:
	if index >= full_text.length():
		is_typing = false
		label.text = label.get_parsed_text()
		return
	dropin_effect.reveal_times.append(Time.get_ticks_msec() / 1000.0)
	label.visible_characters = index + 1
	await get_tree().create_timer(delay).timeout
	_type_next_character(index + 1)

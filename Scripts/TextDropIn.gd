extends RichTextEffect
var bbcode = "dropin"

var reveal_times: PackedFloat32Array = []

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var char_index = char_fx.range.x
	if reveal_times.is_empty() or char_index >= reveal_times.size():
		return true

	var now = Time.get_ticks_msec() / 1000.0
	var reveal_time = reveal_times[char_index]

	if now > reveal_time + 0.1:
		return true

	var elapsed = now - reveal_time
	char_fx.offset.y = -8.0 * (1.0 - ease(clamp(elapsed / 0.1, 0.0, 1.0), -2.0))
	return true

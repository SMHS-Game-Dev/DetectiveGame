extends Control

@onready var rich_label: RichTextLabel = $RichTextLabel
@onready var text_edit: TextEdit = $TextEdit

var format_ranges: Dictionary = {
	"bold": [],
	"italic": [],
	"underline": [],
	"strike": []
}

const FORMAT_TAGS: Dictionary = {
	"bold": ["[b]", "[/b]"],
	"italic": ["[i]", "[/i]"],
	"underline": ["[u]", "[/u]"],
	"strike": ["[s]", "[/s]"]
}

var _prev_text: String = ""

var pages: Array = []
var current_page: int = 0

func _make_blank_page() -> Dictionary:
	return {
		"text": "",
		"format_ranges": { "bold": [], "italic": [], "underline": [], "strike": [] }
	}

func _save_current_page() -> void:
	if pages.size() <= current_page:
		pages.resize(current_page + 1)
	pages[current_page] = {
		"text": text_edit.text,
		"format_ranges": _deep_copy_format_ranges(format_ranges)
	}

func _load_page(index: int) -> void:
	var page: Dictionary = pages[index]
	_prev_text = page["text"]
	text_edit.text = page["text"]
	format_ranges = _deep_copy_format_ranges(page["format_ranges"])
	_rebuild_rich_text()

func _deep_copy_format_ranges(src: Dictionary) -> Dictionary:
	var copy: Dictionary = {}
	for fmt in src:
		copy[fmt] = []
		for r in src[fmt]:
			copy[fmt].append([r[0], r[1]])
	return copy

func _ready() -> void:
	pages.append(_make_blank_page())

	text_edit.add_theme_color_override("font_color", Color(0, 0, 0, 0))
	text_edit.add_theme_color_override("font_selected_color", Color(0, 0, 0, 0))
	text_edit.add_theme_color_override("background_color", Color(0, 0, 0, 0))
	text_edit.add_theme_color_override("selection_color", Color(0.3, 0.6, 1.0, 0.35))
	text_edit.add_theme_constant_override("line_spacing", 0)
	text_edit.get_v_scroll_bar().modulate.a = 0
	rich_label.get_v_scroll_bar().modulate.a = 0
	rich_label.add_theme_constant_override("line_separation", 0)
	text_edit.text_changed.connect(_on_text_changed)

	$Background/HBoxContainer/Bold.connect("button_down", _toggle_format.bind("bold"))
	$Background/HBoxContainer/Italicize.connect("button_down", _toggle_format.bind("italic"))
	$Background/HBoxContainer/Underline.connect("button_down", _toggle_format.bind("underline"))
	$Background/HBoxContainer/Strikethrough.connect("button_down", _toggle_format.bind("strike"))
	
	$"Background/HBoxContainer2/Left Button".connect("button_down", _page_left)
	$"Background/HBoxContainer2/Right Button".connect("button_down", _page_right)

func _input(event: InputEvent) -> void:
	if not text_edit.has_focus():
		return
	if not (event is InputEventKey and event.pressed and not event.echo):
		return

	if event.alt_pressed and not event.ctrl_pressed and not event.shift_pressed:
		match event.keycode:
			KEY_LEFT:
				_page_left()
				get_viewport().set_input_as_handled()
				return
			KEY_RIGHT:
				_page_right()
				get_viewport().set_input_as_handled()
				return

	var handled: bool = true
	if event.ctrl_pressed and not event.shift_pressed:
		match event.keycode:
			KEY_B: _toggle_format("bold")
			KEY_I: _toggle_format("italic")
			KEY_U: _toggle_format("underline")
			_: handled = false
	elif event.ctrl_pressed and event.shift_pressed:
		match event.keycode:
			KEY_S: _toggle_format("strike")
			_: handled = false
	else:
		handled = false

	if handled:
		get_viewport().set_input_as_handled()

func _get_char_pos(line: int, col: int) -> int:
	var pos: int = 0
	for i in range(line):
		pos += text_edit.get_line(i).length() + 1
	return pos + col

func _toggle_format(fmt: String) -> void:
	if not text_edit.has_selection():
		return

	var start: int = _get_char_pos(
		text_edit.get_selection_from_line(),
		text_edit.get_selection_from_column()
	)
	var end: int = _get_char_pos(
		text_edit.get_selection_to_line(),
		text_edit.get_selection_to_column()
	)
	if start >= end:
		return

	if _is_fully_formatted(fmt, start, end):
		_remove_format_range(fmt, start, end)
	else:
		_add_format_range(fmt, start, end)

	_rebuild_rich_text()
	
func _page_left() -> void:
	if current_page > 0:
		_save_current_page()
		current_page -= 1
		_load_page(current_page)
	$"Background/HBoxContainer2/Page Number".text = str(current_page + 1) + "/" + str(pages.size())

func _page_right() -> void:
	_save_current_page()
	if current_page < pages.size() - 1:
		current_page += 1
	else:
		pages.append(_make_blank_page())
		current_page += 1
	_load_page(current_page)
	$"Background/HBoxContainer2/Page Number".text = str(current_page + 1) + "/" + str(pages.size())

func _is_fully_formatted(fmt: String, start: int, end: int) -> bool:
	var pos: int = start
	var sorted: Array = format_ranges[fmt].duplicate(true)
	sorted.sort_custom(func(a: Array, b: Array): return a[0] < b[0])
	for r in sorted:
		if r[1] <= pos:
			continue
		if r[0] > pos:
			return false
		pos = max(pos, r[1])
		if pos >= end:
			return true
	return pos >= end

func _add_format_range(fmt: String, start: int, end: int) -> void:
	format_ranges[fmt].append([start, end])
	_merge_format_ranges(fmt)

func _remove_format_range(fmt: String, start: int, end: int) -> void:
	var new_ranges: Array = []
	for r in format_ranges[fmt]:
		if r[1] <= start or r[0] >= end:
			new_ranges.append(r)
		else:
			if r[0] < start:
				new_ranges.append([r[0], start])
			if r[1] > end:
				new_ranges.append([end, r[1]])
	format_ranges[fmt] = new_ranges

func _merge_format_ranges(fmt: String) -> void:
	var ranges: Array = format_ranges[fmt]
	if ranges.size() <= 1:
		return
	ranges.sort_custom(func(a: Array, b: Array) -> bool: return a[0] < b[0])
	var merged: Array = [ranges[0].duplicate()]
	for i in range(1, ranges.size()):
		var last: Array = merged[-1]
		var curr: Array = ranges[i]
		if curr[0] <= last[1]:
			last[1] = max(last[1], curr[1])
		else:
			merged.append(curr.duplicate())
	format_ranges[fmt] = merged

func _shift_all_ranges(from_pos: int, delta: int) -> void:
	for fmt in format_ranges:
		for r in format_ranges[fmt]:
			if r[0] > from_pos:
				r[0] = max(0, r[0] + delta)
			if r[1] > from_pos:
				r[1] = max(0, r[1] + delta)
		format_ranges[fmt] = format_ranges[fmt].filter(
			func(r: Array) -> bool: return r[1] > r[0]
		)

func _delete_all_ranges(del_start: int, del_end: int) -> void:
	for fmt in format_ranges:
		_remove_format_range(fmt, del_start, del_end)

func _on_text_changed() -> void:
	var new_text: String = text_edit.text
	var delta: int = new_text.length() - _prev_text.length()

	if delta > 0:
		var line_height: float = text_edit.get_line_height()
		var total_lines: int = 0
		for i in range(text_edit.get_line_count()):
			total_lines += text_edit.get_line_wrap_count(i) + 1
		var content_h: float = total_lines * line_height
		var visible_h: float = text_edit.size.y
		if content_h > visible_h:
			var caret_line: int = text_edit.get_caret_line()
			var caret_col: int = text_edit.get_caret_column()
			text_edit.text = _prev_text
			var safe_line: int = mini(caret_line, text_edit.get_line_count() - 1)
			var safe_col: int = mini(caret_col, text_edit.get_line(safe_line).length())
			text_edit.set_caret_line(safe_line)
			text_edit.set_caret_column(safe_col)
			return

	if delta != 0:
		var caret_pos: int = _get_char_pos(
			text_edit.get_caret_line(),
			text_edit.get_caret_column()
		)
		if delta > 0:
			_shift_all_ranges(caret_pos - delta, delta)
		else:
			var del_start: int = caret_pos
			var del_end: int = caret_pos + (-delta)
			_delete_all_ranges(del_start, del_end)
			_shift_all_ranges(del_end, delta)

	_prev_text = new_text
	_rebuild_rich_text()

func _escape_bbcode(s: String) -> String:
	return s.replace("[", "[lb]")

func _rebuild_rich_text() -> void:
	var plain: String = text_edit.text
	if plain.is_empty():
		rich_label.text = ""
		return

	var boundaries: Array = [0, plain.length()]
	for fmt in format_ranges:
		for r in format_ranges[fmt]:
			boundaries.append(r[0])
			boundaries.append(mini(r[1], plain.length()))
	boundaries = boundaries.filter(func(v: int) -> bool: return v >= 0 and v <= plain.length())
	boundaries.sort()

	var deduped: Array = []
	for b in boundaries:
		if deduped.is_empty() or deduped[-1] != b:
			deduped.append(b)
	boundaries = deduped

	var result: String = ""
	for si in range(boundaries.size() - 1):
		var seg_start: int = boundaries[si]
		var seg_end: int = boundaries[si + 1]
		if seg_start >= seg_end:
			continue

		var mid: int = seg_start
		var open_tags: String = ""
		var close_tags: String = ""
		for fmt in ["bold", "italic", "underline", "strike"]:
			if _pos_in_format(fmt, mid):
				open_tags += FORMAT_TAGS[fmt][0]
				close_tags = FORMAT_TAGS[fmt][1] + close_tags

		result += open_tags + _escape_bbcode(plain.substr(seg_start, seg_end - seg_start)) + close_tags

	rich_label.text = result

func _pos_in_format(fmt: String, pos: int) -> bool:
	for r in format_ranges[fmt]:
		if pos >= r[0] and pos < r[1]:
			return true
	return false

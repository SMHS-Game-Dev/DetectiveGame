extends Node

const DIALOGUE_BOX_SCENE = preload("res://Scenes/DialogueBox.tscn")

var dialogue_box: Panel
var canvas_layer: CanvasLayer
var current_line: int = 0
var dialogue_data: Dictionary = {}
var character_data: Dictionary = {}
var is_animating: bool = false
var in_dialogue: bool = false

func _ready():	
	canvas_layer = CanvasLayer.new()
	get_tree().root.add_child.call_deferred(canvas_layer)
	await get_tree().process_frame
	dialogue_box = DIALOGUE_BOX_SCENE.instantiate()
	canvas_layer.add_child(dialogue_box)
	await get_tree().process_frame
	dialogue_box.visible = false
	dialogue_box.connect("resized", _on_dialogue_resized)
	dialogue_box.connect("animation_finished", _on_animation_finished)
	
	character_data = load_json("res://JSON/Characters.json")
	
func load_json(path: String) -> Dictionary:
	if (path.is_empty()):
		push_error("No Path URL")
		return {}
		
	var file = FileAccess.open(path, FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()
	var json = JSON.new()
	var error = json.parse(json_string)
	if error == OK:
		return json.data
	else:
		push_error("JSON parse error: ", json.get_error_message())
		return {}
		
func start_dialogue(path: String) -> void:
	dialogue_data = load_json(path)
	if dialogue_data.is_empty():
		push_error("Invalid dialogue data")
		return
		
	current_line = 0
	dialogue_box.visible = true
	in_dialogue = true
	show_line()
	
func show_line() -> void:
	if current_line >= dialogue_data["lines"].size():
		end_dialogue()
		return
		
	if dialogue_box.get_child(0) != null && dialogue_box.get_child(1) != null:
		var line = dialogue_data["lines"][current_line]
		is_animating = true
		dialogue_box.display_line(line["text"])
		dialogue_box.get_child(0).texture = load(character_data[line["speaker"]]["icon"])
		_on_dialogue_resized()
	else:
		push_error("Dialogue box not fully loaded")
		return
		
func advance_dialogue() -> void:
	if is_animating:
		dialogue_box.skip_animation()
		return
	current_line += 1
	show_line()

func _on_animation_finished():
	is_animating = false
	
func end_dialogue() -> void:
	in_dialogue = false
	is_animating = false
	dialogue_box.visible = false

func _on_dialogue_resized() -> void:
	if dialogue_box.get_child(1) != null:
		fit_text(dialogue_box.get_child(1))
		
func fit_text(label: RichTextLabel) -> void:
	var ideal_size = int(label.size.y / 6.0)
	label.add_theme_font_size_override("normal_font_size", ideal_size)
	await get_tree().process_frame
	if not label.get_v_scroll_bar().visible:
		return
	var low = 1
	var high = ideal_size
	var best = low
	while low <= high:
		var mid = (low + high) / 2
		label.add_theme_font_size_override("normal_font_size", mid)
		await get_tree().process_frame
		if not label.get_v_scroll_bar().visible:
			best = mid
			low = mid + 1
		else:
			high = mid - 1
	label.add_theme_font_size_override("normal_font_size", best)

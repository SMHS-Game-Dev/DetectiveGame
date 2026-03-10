extends Node

const DIALOGUE_BOX_SCENE: Resource = preload("res://Scenes/DialogueBox.tscn")
const DIALOGUE_OPTION_SCENE: Resource = preload("res://Scenes/DialogueOption.tscn")

var dialogue_box: Panel
var canvas_layer: CanvasLayer
var current_line: int = 0
var dialogue: Resource
var dialogue_line: DialogueLine
var dialogue_options: bool = false
var character_data: Dictionary = {}
var is_animating: bool = false
var in_dialogue: bool = false

func _ready() -> void:	
	canvas_layer = CanvasLayer.new()
	get_tree().root.add_child.call_deferred(canvas_layer)
	await get_tree().process_frame
	dialogue_box = DIALOGUE_BOX_SCENE.instantiate() as Panel
	canvas_layer.add_child(dialogue_box)
	await get_tree().process_frame
	dialogue_box.visible = false
	dialogue_box.connect("resized", _on_dialogue_resized)
	dialogue_box.connect("animation_finished", _on_animation_finished)
	
	character_data = load_json("res://Data/Characters.json")
	
func load_json(path: String) -> Dictionary:
	if (path.is_empty()):
		push_error("No Path URL")
		return {}
		
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	var json_string: String = file.get_as_text()
	file.close()
	var json: JSON = JSON.new()
	var error: Error = json.parse(json_string)
	if error == OK:
		return json.data
	else:
		push_error("JSON parse error: ", json.get_error_message())
		return {}
		
func start_dialogue(path: String) -> void:
	if not ResourceLoader.exists(path):
		push_error("Invalid dialogue data")
		return
		
	dialogue = load(path)
	dialogue_line = await dialogue.get_next_dialogue_line("start")
	
	dialogue_box.visible = true
	in_dialogue = true
	show_line("")
	
func show_line(response_id: String) -> void:
	if dialogue_line != null:
		if dialogue_box.get_children().size() == 3:
			if not response_id.is_empty(): print(response_id)
			print(dialogue_line)
			for child in (dialogue_box.get_child(2) as VBoxContainer).get_children():
				child.queue_free()
			dialogue_options = false
			is_animating = true
			dialogue_box.display_line(dialogue_line.text)
			if dialogue_line.character:
				(dialogue_box.get_child(0) as TextureRect).texture = load(character_data[dialogue_line.character]["icon"])
			_on_dialogue_resized()
			if not dialogue_line.responses.is_empty():
				dialogue_options = true
				for option: DialogueResponse in dialogue_line.responses:
					var option_button: Button = DIALOGUE_OPTION_SCENE.instantiate() as Button
					option_button.text = option.text
					option_button.pressed.connect(show_line.bind(option.next_id))
					(dialogue_box.get_child(2) as VBoxContainer).add_child(option_button)
			dialogue_line = await dialogue.get_next_dialogue_line(dialogue_line.next_id if response_id.is_empty() else response_id)
			if not response_id.is_empty(): show_line("")
	else:
		end_dialogue()
		
func advance_dialogue() -> void:
	if is_animating:
		dialogue_box.skip_animation()
		return
	show_line("")

func _on_animation_finished() -> void:
	is_animating = false
	
func end_dialogue() -> void:
	in_dialogue = false
	is_animating = false
	dialogue_box.visible = false

func _on_dialogue_resized() -> void:
	if (dialogue_box.get_child(1) as RichTextLabel) != null:
		fit_text(dialogue_box.get_child(1) as RichTextLabel)
		
func fit_text(label: RichTextLabel) -> void:
	var ideal_size: int = int(label.size.y / 6.0)
	label.add_theme_font_size_override("normal_font_size", ideal_size)
	await get_tree().process_frame
	if not label.get_v_scroll_bar().visible:
		return
	var low: int = 1
	var high: int = ideal_size
	var best: int = low
	while low <= high:
		var mid: int = (low + high) / 2
		label.add_theme_font_size_override("normal_font_size", mid)
		await get_tree().process_frame
		if not label.get_v_scroll_bar().visible:
			best = mid
			low = mid + 1
		else:
			high = mid - 1
	label.add_theme_font_size_override("normal_font_size", best)

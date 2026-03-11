extends CharacterBody2D

const SPEED: float = 300.0
const NOTEPAD: Resource = preload("res://Scenes/Notepad.tscn")

var input: Vector2 = Vector2.ZERO
var timer: float = 0.0
var notepad_open: bool = false
var notepad: Control
var notepad_top: float
var notepad_bottom: float
var notepad_anim_done: bool = true
var notepad_edit: TextEdit

func _ready() -> void:
	notepad = NOTEPAD.instantiate()
	notepad_edit = notepad.find_child("TextEdit")
	notepad.visible = false
	notepad_top = notepad.anchor_top
	notepad.anchor_top = 1
	GameDialogueManager.canvas_layer.add_child(notepad)
	
func _show_notepad() -> void:
	notepad_edit.grab_focus()
	notepad_anim_done = false
	notepad_open = true
	notepad.visible = true
	var notepadTween: Tween = create_tween()
	notepadTween.tween_property(notepad, "anchor_top", notepad_top, 0.3) \
	.set_ease(Tween.EASE_OUT) \
	.set_trans(Tween.TRANS_QUART)
	await notepadTween.finished
	notepad_anim_done = true
	
func _hide_notepad() -> void:
	notepad_anim_done = false
	notepad_open = false
	var notepadTween: Tween = create_tween()
	notepadTween.tween_property(notepad, "anchor_top", 1, 0.3) \
	.set_ease(Tween.EASE_OUT) \
	.set_trans(Tween.TRANS_QUART)
	await notepadTween.finished
	notepad_anim_done = true
	notepad.visible = false

func _physics_process(delta: float) -> void:
	input = Input.get_vector("left", "right", "up", "down") if not (GameDialogueManager.in_dialogue or notepad_open) else Vector2.ZERO
	
	velocity.x = input.x * SPEED
	velocity.y = input.y * SPEED
	
	move_and_slide()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_notepad") and notepad_anim_done:
		if notepad_open: _hide_notepad() 
		else: _show_notepad()

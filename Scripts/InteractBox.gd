extends StaticBody2D

signal player_near(state: bool)
@export var dialogue_file: String = ""
@onready var player: Player = get_tree().get_nodes_in_group("player")[0]

func _on_interact_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		emit_signal("player_near", true)

func _on_interact_box_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		emit_signal("player_near", false)

func _input(event: InputEvent) -> void:
	if not $KeyPopup.can_interact or player.notepad_open:
		return
		
	var is_own_key = (event is InputEventKey and event.pressed and not event.echo and event.keycode == $KeyPopup.key_code)
	var is_advance_action = event.is_action_pressed("advance_dialogue")
	var valid_dialogue_state = ((not GameDialogueManager.dialogue_options) or GameDialogueManager.is_animating)
	
	if valid_dialogue_state:
		if GameDialogueManager.in_dialogue:
			if $KeyPopup.key_code == KeyManager.key_code:
				if is_own_key or is_advance_action:
					GameDialogueManager.advance_dialogue()
					get_viewport().set_input_as_handled()
					
					if not GameDialogueManager.in_dialogue:
						$KeyPopup.show_key()
		else:
			if is_own_key:
				KeyManager.key_code = $KeyPopup.key_code
				GameDialogueManager.start_dialogue(dialogue_file)
				get_viewport().set_input_as_handled()
				$KeyPopup.hide_key()

extends StaticBody2D

signal player_near(state: bool)
@export var dialogue_file: String = ""

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _on_interact_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		emit_signal("player_near", true)

func _on_interact_box_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		emit_signal("player_near", false)

func _input(event: InputEvent) -> void:
	if $KeyPopup.can_interact:
		if event.is_action_pressed("interact") and ((not GameDialogueManager.dialogue_options) or GameDialogueManager.is_animating):
			if (GameDialogueManager.in_dialogue):
				GameDialogueManager.advance_dialogue()
				if not GameDialogueManager.in_dialogue:
					$KeyPopup.show_key()
			else:
				GameDialogueManager.start_dialogue(dialogue_file)
				$KeyPopup.hide_key()
		elif event.is_action_pressed("advance_dialogue") and GameDialogueManager.in_dialogue and ((not GameDialogueManager.dialogue_options) or GameDialogueManager.is_animating):
			GameDialogueManager.advance_dialogue()
			if not GameDialogueManager.in_dialogue:
					$KeyPopup.show_key()

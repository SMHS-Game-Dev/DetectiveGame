extends Node

var characters: Dictionary = {}

func _ready():
	var file = FileAccess.open("res://JSON/Characters.json", FileAccess.READ)
	characters = JSON.parse_string(file.get_as_text())

func get_character(id: String) -> Dictionary:
	return characters.get(id, {})

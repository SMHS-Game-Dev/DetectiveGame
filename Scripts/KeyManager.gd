extends Node

var keys: Array[String] = ["E", "F", "R", "G", "T", "H", "J"]
var available_keys: Array = range(keys.size())
var key_code: int

func claim_key() -> int:
	return available_keys.pop_front()

func release_key(index: int) -> void:
	available_keys.append(index)
	available_keys.sort()

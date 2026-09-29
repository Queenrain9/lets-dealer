extends RefCounted
class_name DealerTask

var id: String = ""
var phase: String = ""
var headline: String = ""
var prompt: String = ""
var choices: Array[String] = []
var correct_index: int = 0
var time_limit: float = 10.0
var base_tip: int = 100
var action_kind: String = ""
var success_text: String = ""
var state: Dictionary = {}


func _init(data: Dictionary = {}) -> void:
	id = String(data.get("id", "task"))
	phase = String(data.get("phase", "TABLE"))
	headline = String(data.get("headline", ""))
	prompt = String(data.get("prompt", ""))
	correct_index = int(data.get("correct_index", 0))
	time_limit = float(data.get("time_limit", 10.0))
	base_tip = int(data.get("base_tip", 100))
	action_kind = String(data.get("action_kind", ""))
	success_text = String(data.get("success_text", "정확한 처리"))
	var raw_choices: Variant = data.get("choices", [])
	if raw_choices is Array:
		for item: Variant in raw_choices:
			choices.append(String(item))
	var raw_state: Variant = data.get("state", {})
	if raw_state is Dictionary:
		state = (raw_state as Dictionary).duplicate(true)

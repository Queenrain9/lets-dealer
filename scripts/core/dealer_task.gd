extends RefCounted
class_name DealerTask

var id: String = ""
var phase: String = ""
var headline: String = ""
var event_text: String = ""
var time_limit: float = 10.0
var base_tip: int = 100
var expected_action: String = ""
var success_text: String = ""
var target_seat: int = -1
var state: Dictionary = {}


func _init(data: Dictionary = {}) -> void:
	id = String(data.get("id", "task"))
	phase = String(data.get("phase", "TABLE"))
	headline = String(data.get("headline", ""))
	event_text = String(data.get("event_text", ""))
	time_limit = float(data.get("time_limit", 10.0))
	base_tip = int(data.get("base_tip", 100))
	expected_action = String(data.get("expected_action", ""))
	success_text = String(data.get("success_text", "정확한 처리"))
	target_seat = int(data.get("target_seat", -1))
	var raw_state: Variant = data.get("state", {})
	if raw_state is Dictionary:
		state = (raw_state as Dictionary).duplicate(true)

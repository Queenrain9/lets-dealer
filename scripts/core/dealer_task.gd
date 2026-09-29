extends RefCounted
class_name DealerTask

var id: String = ""
var phase: String = ""
var expected_action: String = ""
var success_text: String = ""
var base_tip: int = 100
var target_seat: int = -1
var source_seat: int = -1
var blocking: bool = true
var patience_limit: float = 7.0
var age: float = 0.0
var warned: bool = false
var state: Dictionary = {}


func _init(data: Dictionary = {}) -> void:
	id = String(data.get("id", "duty"))
	phase = String(data.get("phase", "TABLE"))
	expected_action = String(data.get("expected_action", ""))
	success_text = String(data.get("success_text", "처리 완료"))
	base_tip = int(data.get("base_tip", 100))
	target_seat = int(data.get("target_seat", -1))
	source_seat = int(data.get("source_seat", -1))
	blocking = bool(data.get("blocking", true))
	patience_limit = float(data.get("patience_limit", 7.0))
	age = 0.0
	warned = false
	var raw_state: Variant = data.get("state", {})
	if raw_state is Dictionary:
		state = (raw_state as Dictionary).duplicate(true)


func reset_clock() -> void:
	age = 0.0
	warned = false


func urgency() -> float:
	if patience_limit <= 0.0:
		return 0.0
	return clampf(age / patience_limit, 0.0, 2.0)

extends RefCounted
class_name NPCProfile

var id: String = ""
var display_name: String = ""
var trait_label: String = ""
var action_speed: float = 1.0
var patience: float = 1.0
var request_bias: float = 1.0
var tip_multiplier: float = 1.0
var warning_line: String = "딜러?"
var miss_line: String = "요청한 거 아직인데요."


func _init(data: Dictionary = {}) -> void:
	id = String(data.get("id", "npc"))
	display_name = String(data.get("display_name", "PLAYER"))
	trait_label = String(data.get("trait_label", "REGULAR"))
	action_speed = float(data.get("action_speed", 1.0))
	patience = float(data.get("patience", 1.0))
	request_bias = float(data.get("request_bias", 1.0))
	tip_multiplier = float(data.get("tip_multiplier", 1.0))
	warning_line = String(data.get("warning_line", "딜러?"))
	miss_line = String(data.get("miss_line", "요청한 거 아직인데요."))

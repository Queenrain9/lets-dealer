extends Button
class_name DraggableCard

@onready var card_label: Label = $Label

var _home_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	_home_position = position
	card_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	focus_mode = Control.FOCUS_NONE

func arm(card_id: String) -> void:
	card_label.text = card_id
	disabled = false
	visible = true
	reset_preview()

func disarm() -> void:
	disabled = true
	visible = false
	reset_preview()

func begin_preview() -> void:
	scale = Vector2(0.98, 0.98)

func update_preview(gesture_delta: Vector2) -> void:
	var preview_delta: Vector2 = gesture_delta.limit_length(72.0) * 0.18
	position = _home_position + preview_delta

func reset_preview() -> void:
	position = _home_position
	rotation = 0.0
	scale = Vector2.ONE

func get_input_rect() -> Rect2:
	return get_global_rect()

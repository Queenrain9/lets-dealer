extends Button
class_name SwipeChipStack

@export var seat_index: int = 0

@onready var amount_label: Label = $AmountLabel

var _home_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	_home_position = position
	amount_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	focus_mode = Control.FOCUS_NONE
	disabled = true
	visible = false

func arm(amount: int) -> void:
	amount_label.text = str(amount)
	visible = amount > 0
	disabled = not visible
	reset_preview()

func disarm() -> void:
	disabled = true
	visible = false
	reset_preview()

func begin_preview() -> void:
	scale = Vector2(1.04, 1.04)

func update_preview(gesture_delta: Vector2) -> void:
	var preview_delta: Vector2 = gesture_delta.limit_length(64.0) * 0.16
	position = _home_position + preview_delta

func reset_preview() -> void:
	position = _home_position
	scale = Vector2.ONE

func get_input_rect() -> Rect2:
	return get_global_rect()

extends PanelContainer
class_name SwipeChipStack

const PREVIEW_PULL_RATIO: float = 0.16
const MAX_PREVIEW_PULL: float = 64.0

@export var seat_index: int = 0

@onready var amount_label: Label = $AmountLabel

var _home_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	_home_position = position
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func arm(amount: int) -> void:
	amount_label.text = str(amount)
	visible = amount > 0
	reset_preview()

func disarm() -> void:
	visible = false
	reset_preview()

func begin_preview() -> void:
	scale = Vector2(1.04, 1.04)

func update_preview(gesture_delta: Vector2) -> void:
	var preview_delta: Vector2 = (
		gesture_delta.limit_length(MAX_PREVIEW_PULL) * PREVIEW_PULL_RATIO
	)
	position = _home_position + preview_delta

func reset_preview() -> void:
	position = _home_position
	scale = Vector2.ONE

func get_input_rect() -> Rect2:
	return get_global_rect()

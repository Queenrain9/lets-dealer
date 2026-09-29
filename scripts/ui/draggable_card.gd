extends PanelContainer
class_name DraggableCard

const PREVIEW_PULL_RATIO: float = 0.18
const MAX_PREVIEW_PULL: float = 72.0

@onready var card_label: Label = $Label

var _home_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	_home_position = position
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func arm(card_id: String) -> void:
	card_label.text = card_id
	visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	reset_preview()

func disarm() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	reset_preview()

func begin_preview() -> void:
	scale = Vector2(0.98, 0.98)

func update_preview(gesture_delta: Vector2) -> void:
	var preview_delta: Vector2 = (
		gesture_delta.limit_length(MAX_PREVIEW_PULL) * PREVIEW_PULL_RATIO
	)
	position = _home_position + preview_delta
	rotation = clampf(gesture_delta.x / 1000.0, -0.08, 0.08)

func reset_preview() -> void:
	position = _home_position
	rotation = 0.0
	scale = Vector2.ONE

func get_input_rect() -> Rect2:
	return get_global_rect()

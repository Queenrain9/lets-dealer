extends PanelContainer
class_name SwipeChipStack

signal sweep_released(seat_index: int, start_position: Vector2, end_position: Vector2)

const MOUSE_POINTER_ID: int = -1
const PREVIEW_PULL_RATIO: float = 0.18
const MAX_PREVIEW_PULL: float = 70.0

@export var seat_index: int = 0

@onready var amount_label: Label = $AmountLabel

var _swiping: bool = false
var _input_enabled: bool = false
var _pointer_id: int = MOUSE_POINTER_ID
var _gesture_start: Vector2 = Vector2.ZERO
var _home_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	_home_position = position
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process_input(false)

func arm(amount: int) -> void:
	amount_label.text = str(amount)
	position = _home_position
	rotation = 0.0
	scale = Vector2.ONE
	visible = amount > 0
	_input_enabled = amount > 0
	mouse_filter = Control.MOUSE_FILTER_STOP if _input_enabled else Control.MOUSE_FILTER_IGNORE

func disarm() -> void:
	_swiping = false
	_input_enabled = false
	visible = false
	position = _home_position
	rotation = 0.0
	scale = Vector2.ONE
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process_input(false)

func snap_home() -> void:
	position = _home_position
	rotation = 0.0
	scale = Vector2.ONE
	_input_enabled = visible
	mouse_filter = Control.MOUSE_FILTER_STOP if _input_enabled else Control.MOUSE_FILTER_IGNORE

func _gui_input(event: InputEvent) -> void:
	if not _input_enabled or _swiping:
		return

	if event is InputEventScreenTouch:
		var touch_event: InputEventScreenTouch = event
		if touch_event.pressed:
			_begin_sweep(touch_event.index, touch_event.position)
			accept_event()
	elif event is InputEventMouseButton:
		var mouse_button: InputEventMouseButton = event
		if mouse_button.button_index == MOUSE_BUTTON_LEFT and mouse_button.pressed:
			# Keep press/move/release in the same viewport coordinate space.
			_begin_sweep(MOUSE_POINTER_ID, get_viewport().get_mouse_position())
			accept_event()

func _input(event: InputEvent) -> void:
	if not _swiping:
		return

	if _pointer_id == MOUSE_POINTER_ID:
		if event is InputEventMouseMotion:
			var mouse_motion: InputEventMouseMotion = event
			_update_sweep(mouse_motion.position)
		elif event is InputEventMouseButton:
			var mouse_button: InputEventMouseButton = event
			if mouse_button.button_index == MOUSE_BUTTON_LEFT and not mouse_button.pressed:
				_finish_sweep(mouse_button.position)
	else:
		if event is InputEventScreenDrag:
			var touch_drag: InputEventScreenDrag = event
			if touch_drag.index == _pointer_id:
				_update_sweep(touch_drag.position)
		elif event is InputEventScreenTouch:
			var touch_event: InputEventScreenTouch = event
			if touch_event.index == _pointer_id and not touch_event.pressed:
				_finish_sweep(touch_event.position)

func _begin_sweep(pointer_id: int, pointer_position: Vector2) -> void:
	_swiping = true
	_pointer_id = pointer_id
	_gesture_start = pointer_position
	move_to_front()
	set_process_input(true)
	scale = Vector2(1.04, 1.04)

func _update_sweep(pointer_position: Vector2) -> void:
	var sweep_delta: Vector2 = pointer_position - _gesture_start
	var preview_delta: Vector2 = sweep_delta.limit_length(MAX_PREVIEW_PULL) * PREVIEW_PULL_RATIO
	position = _home_position + preview_delta

func _finish_sweep(pointer_position: Vector2) -> void:
	_swiping = false
	set_process_input(false)
	position = _home_position
	scale = Vector2.ONE
	sweep_released.emit(seat_index, _gesture_start, pointer_position)

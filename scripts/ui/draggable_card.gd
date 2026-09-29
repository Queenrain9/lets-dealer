extends PanelContainer
class_name DraggableCard

signal swipe_started
signal swipe_updated(swipe_delta: Vector2)
signal swipe_released(start_position: Vector2, end_position: Vector2)

const MOUSE_POINTER_ID: int = -1
const PREVIEW_PULL_RATIO: float = 0.22
const MAX_PREVIEW_PULL: float = 90.0

@onready var card_label: Label = $Label

var _swiping: bool = false
var _input_enabled: bool = true
var _pointer_id: int = MOUSE_POINTER_ID
var _gesture_start: Vector2 = Vector2.ZERO
var _home_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	# Capture the authored scene position before the parent scene can call disarm().
	# Deferring this used to let disarm() reset the card to (0, 0), which then
	# became the accidental "home" position.
	_home_position = position
	set_process_input(false)

func arm(card_id: String) -> void:
	card_label.text = card_id
	visible = true
	_input_enabled = true
	mouse_filter = Control.MOUSE_FILTER_STOP

func disarm() -> void:
	_swiping = false
	_input_enabled = false
	visible = false
	set_process_input(false)
	_reset_preview()

func set_interaction_enabled(value: bool) -> void:
	_input_enabled = value
	mouse_filter = Control.MOUSE_FILTER_STOP if value else Control.MOUSE_FILTER_IGNORE

func snap_home() -> void:
	position = _home_position
	_reset_preview()
	_input_enabled = true
	mouse_filter = Control.MOUSE_FILTER_STOP

func fly_to(global_target: Vector2, duration: float = 0.16) -> void:
	_input_enabled = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", global_target, duration)
	await tween.finished


func _gui_input(event: InputEvent) -> void:
	if not _input_enabled or _swiping:
		return

	if event is InputEventScreenTouch:
		var touch_event: InputEventScreenTouch = event
		if touch_event.pressed:
			_begin_swipe(touch_event.index, touch_event.position)
			accept_event()
	elif event is InputEventMouseButton:
		var mouse_button: InputEventMouseButton = event
		if mouse_button.button_index == MOUSE_BUTTON_LEFT and mouse_button.pressed:
			# _gui_input mouse positions are Control-local, while _input motion/release
			# positions are viewport-space. Normalize the press to viewport-space so
			# the swipe vector is measured in one coordinate system.
			_begin_swipe(MOUSE_POINTER_ID, get_viewport().get_mouse_position())
			accept_event()

func _input(event: InputEvent) -> void:
	if not _swiping:
		return

	if _pointer_id == MOUSE_POINTER_ID:
		if event is InputEventMouseMotion:
			var mouse_motion: InputEventMouseMotion = event
			_update_swipe(mouse_motion.position)
		elif event is InputEventMouseButton:
			var mouse_button: InputEventMouseButton = event
			if mouse_button.button_index == MOUSE_BUTTON_LEFT and not mouse_button.pressed:
				_finish_swipe(mouse_button.position)
	else:
		if event is InputEventScreenDrag:
			var touch_drag: InputEventScreenDrag = event
			if touch_drag.index == _pointer_id:
				_update_swipe(touch_drag.position)
		elif event is InputEventScreenTouch:
			var touch_event: InputEventScreenTouch = event
			if touch_event.index == _pointer_id and not touch_event.pressed:
				_finish_swipe(touch_event.position)

func _begin_swipe(pointer_id: int, pointer_position: Vector2) -> void:
	_swiping = true
	_pointer_id = pointer_id
	_gesture_start = pointer_position
	move_to_front()
	set_process_input(true)
	scale = Vector2(0.98, 0.98)
	swipe_started.emit()

func _update_swipe(pointer_position: Vector2) -> void:
	var swipe_delta: Vector2 = pointer_position - _gesture_start
	var preview_delta: Vector2 = swipe_delta.limit_length(MAX_PREVIEW_PULL) * PREVIEW_PULL_RATIO

	position = _home_position + preview_delta
	rotation = clampf(swipe_delta.x / 900.0, -0.10, 0.10)
	swipe_updated.emit(swipe_delta)

func _finish_swipe(pointer_position: Vector2) -> void:
	_swiping = false
	set_process_input(false)
	_reset_preview()
	swipe_released.emit(_gesture_start, pointer_position)

func _reset_preview() -> void:
	if not _swiping:
		position = _home_position
	rotation = 0.0
	scale = Vector2.ONE

extends PanelContainer
class_name DraggableCard

signal drag_started
signal drag_moved(global_pointer_position: Vector2)
signal drag_released(global_pointer_position: Vector2)

const MOUSE_POINTER_ID := -1

@onready var card_label: Label = $Label

var _dragging: bool = false
var _pointer_id: int = MOUSE_POINTER_ID
var _drag_offset: Vector2 = Vector2.ZERO
var _home_global_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	call_deferred("_capture_home_position")
	set_process_input(false)

func arm(card_id: String) -> void:
	card_label.text = card_id
	visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP

func disarm() -> void:
	_dragging = false
	visible = false
	set_process_input(false)

func snap_home() -> void:
	global_position = _home_global_position

func _capture_home_position() -> void:
	_home_global_position = global_position

func _gui_input(event: InputEvent) -> void:
	if _dragging:
		return

	if event is InputEventScreenTouch and event.pressed:
		_begin_drag(event.index, event.position)
		accept_event()
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_begin_drag(MOUSE_POINTER_ID, event.position)
			accept_event()

func _input(event: InputEvent) -> void:
	if not _dragging:
		return

	if _pointer_id == MOUSE_POINTER_ID:
		if event is InputEventMouseMotion:
			_move_drag(event.position)
		elif event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
				_finish_drag(event.position)
	else:
		if event is InputEventScreenDrag and event.index == _pointer_id:
			_move_drag(event.position)
		elif event is InputEventScreenTouch:
			if event.index == _pointer_id and not event.pressed:
				_finish_drag(event.position)

func _begin_drag(pointer_id: int, pointer_position: Vector2) -> void:
	_dragging = true
	_pointer_id = pointer_id
	_drag_offset = pointer_position - global_position
	move_to_front()
	set_process_input(true)
	drag_started.emit()
	drag_moved.emit(pointer_position)

func _move_drag(pointer_position: Vector2) -> void:
	global_position = pointer_position - _drag_offset
	drag_moved.emit(pointer_position)

func _finish_drag(pointer_position: Vector2) -> void:
	_dragging = false
	set_process_input(false)
	drag_released.emit(pointer_position)

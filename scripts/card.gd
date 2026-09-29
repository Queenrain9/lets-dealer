extends Control
## Owns one pointer; rules and destination validation belong to Table.

signal drag_started
signal dropped(global_point: Vector2)

var dragging: bool = false
var enabled: bool = true
var _pointer: int = -2
var _grab_offset := Vector2.ZERO
var _home := Vector2.ZERO
var _home_offsets := Vector4.ZERO
var _return_tween: Tween
var _returning: bool = false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_home = global_position
	_home_offsets = Vector4(offset_left, offset_top, offset_right, offset_bottom)
	resized.connect(queue_redraw)
	var layout_parent := get_parent() as Control
	if layout_parent != null:
		layout_parent.resized.connect(cancel_drag)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.canceled and dragging and _pointer == -1:
			cancel_drag()
			get_viewport().set_input_as_handled()
		elif event.pressed:
			_try_pickup(event.position, -1)
		elif dragging and _pointer == -1:
			_finish_drag(event.position)
	elif event is InputEventMouseMotion and dragging and _pointer == -1:
		_move_drag(event.position)
	elif event is InputEventScreenTouch:
		if event.canceled and dragging and _pointer == event.index:
			cancel_drag()
			get_viewport().set_input_as_handled()
		elif event.pressed:
			_try_pickup(event.position, event.index)
		elif dragging and _pointer == event.index:
			_finish_drag(event.position)
	elif event is InputEventScreenDrag and dragging and _pointer == event.index:
		_move_drag(event.position)

func _try_pickup(point: Vector2, pointer: int) -> void:
	if not enabled or dragging or _returning or not get_global_rect().has_point(point):
		return
	_home = global_position
	_home_offsets = Vector4(offset_left, offset_top, offset_right, offset_bottom)
	_grab_offset = point - global_position
	_pointer = pointer
	dragging = true
	z_index = 10
	queue_redraw()
	drag_started.emit()
	get_viewport().set_input_as_handled()

func _move_drag(point: Vector2) -> void:
	global_position = point - _grab_offset
	get_viewport().set_input_as_handled()

func _finish_drag(point: Vector2) -> void:
	dragging = false
	_pointer = -2
	z_index = 0
	queue_redraw()
	dropped.emit(point)
	get_viewport().set_input_as_handled()

func return_home() -> void:
	_stop_return()
	_returning = true
	_return_tween = create_tween()
	_return_tween.tween_property(self, "global_position", _home, 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_return_tween.finished.connect(func() -> void: _returning = false)

func cancel_drag() -> void:
	_stop_return()
	_restore_home_offsets()
	dragging = false
	_pointer = -2
	z_index = 0
	queue_redraw()

func set_enabled(value: bool) -> void:
	enabled = value
	if not enabled:
		cancel_drag()
	queue_redraw()

func _stop_return() -> void:
	if _return_tween != null and _return_tween.is_running():
		_return_tween.kill()
		_restore_home_offsets()
	_returning = false

func _restore_home_offsets() -> void:
	offset_left = _home_offsets.x
	offset_top = _home_offsets.y
	offset_right = _home_offsets.z
	offset_bottom = _home_offsets.w

func _draw() -> void:
	var shadow := StyleBoxFlat.new()
	shadow.bg_color = Color(0.0, 0.0, 0.0, 0.3)
	shadow.set_corner_radius_all(13)
	draw_style_box(shadow, Rect2(Vector2(6, 10), size))
	var back := StyleBoxFlat.new()
	back.bg_color = Color("40232d")
	back.border_color = Color("f5d693") if dragging else Color("c5a36a")
	back.set_border_width_all(3 if dragging else 2)
	back.set_corner_radius_all(12)
	draw_style_box(back, Rect2(Vector2.ZERO, size))
	var inset := Rect2(Vector2(9, 9), size - Vector2(18, 18))
	draw_rect(inset, Color("a77557"), false, 1.0)
	for row in range(5):
		for column in range(3):
			var center := Vector2(23 + column * 38, 26 + row * 30)
			var points := PackedVector2Array([center + Vector2(0, -7), center + Vector2(6, 0), center + Vector2(0, 7), center + Vector2(-6, 0), center + Vector2(0, -7)])
			draw_polyline(points, Color(0.75, 0.52, 0.40, 0.42), 1.0)

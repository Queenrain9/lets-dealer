extends SceneTree

var failures: int = 0
var checks: int = 0
var table

func _init() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		printerr("FAIL: " + message)

func _mouse_button(point: Vector2, pressed: bool, canceled: bool = false) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	event.canceled = canceled
	event.position = point
	event.global_position = point
	Input.parse_input_event(event)
	Input.flush_buffered_events()

func _mouse_motion(point: Vector2) -> void:
	var event := InputEventMouseMotion.new()
	event.position = point
	event.global_position = point
	event.button_mask = MOUSE_BUTTON_MASK_LEFT
	Input.parse_input_event(event)
	Input.flush_buffered_events()

func _touch(point: Vector2, finger: int, pressed: bool, canceled: bool = false) -> void:
	var event := InputEventScreenTouch.new()
	event.position = point
	event.index = finger
	event.pressed = pressed
	event.canceled = canceled
	Input.parse_input_event(event)
	Input.flush_buffered_events()

func _touch_move(point: Vector2, finger: int) -> void:
	var event := InputEventScreenDrag.new()
	event.position = point
	event.index = finger
	Input.parse_input_event(event)
	Input.flush_buffered_events()

func _mouse_drop(seat_index: int) -> void:
	_mouse_button(table.card.get_global_rect().get_center(), true)
	await process_frame
	var target: Vector2 = table.seats[seat_index].get_drop_rect().get_center()
	_mouse_motion(target)
	_mouse_button(target, false)
	await create_timer(0.25).timeout

func _run() -> void:
	if not ResourceLoader.exists("res://scenes/table.tscn"):
		_check(false, "the playable Table scene has not been implemented")
		quit(1)
		return
	root.size = Vector2i(720, 1280)
	var scene: PackedScene = load("res://scenes/table.tscn")
	table = scene.instantiate()
	root.add_child(table)
	await process_frame
	await process_frame
	_check(table.round.phase == "ready", "training must wait for first pickup")
	await _mouse_drop(0)
	_check(table.round.dealt_count == 1 and table.seats[0].card_count == 1, "real mouse drag must deal to the left seat")
	await _mouse_drop(0)
	_check(table.round.dealt_count == 1 and table.round.mistakes == 1, "drop on wrong seat must not duplicate a card")
	var home: Vector2 = table.card.global_position
	_mouse_button(table.card.get_global_rect().get_center(), true)
	_mouse_motion(Vector2(20, 600))
	_mouse_button(Vector2(20, 600), false)
	await create_timer(0.25).timeout
	_check(table.round.mistakes == 1 and table.card.global_position.is_equal_approx(home), "outside drop must return home without penalty")
	table.restart_training()
	_mouse_button(table.card.get_global_rect().get_center(), true)
	_mouse_button(table.seats[0].get_drop_rect().get_center(), false, true)
	_check(table.round.dealt_count == 0 and not table.card.dragging, "OS canceled mouse release must not deal a card")
	_mouse_button(table.card.get_global_rect().get_center(), true)
	_mouse_button(table.seats[2].get_drop_rect().get_center(), false, true)
	_check(table.round.mistakes == 0, "OS canceled mouse release over wrong seat must not penalize")
	table.restart_training()
	var resize_home: Vector2 = table.card.global_position
	_mouse_button(table.card.get_global_rect().get_center(), true)
	root.size = Vector2i(720, 1600)
	await process_frame
	await process_frame
	_mouse_button(table.seats[0].get_drop_rect().get_center(), false)
	_check(table.card.global_position.is_equal_approx(resize_home + Vector2(0, 320)) and not table.card.dragging, "resize during drag must restore the current anchored deck location")
	_check(table.round.dealt_count == 0 and table.round.mistakes == 0, "resize-canceled drag must reject its stale release")
	root.size = Vector2i(720, 1280)
	table.restart_training()
	await process_frame
	await process_frame
	resize_home = table.card.global_position
	_mouse_button(table.card.get_global_rect().get_center(), true)
	_mouse_motion(table.seats[0].get_drop_rect().get_center())
	_mouse_button(table.seats[0].get_drop_rect().get_center(), false)
	root.size = Vector2i(720, 1600)
	await create_timer(0.25).timeout
	_check(table.card.global_position.is_equal_approx(resize_home + Vector2(0, 320)), "resize during return animation must not corrupt anchor offsets")
	root.size = Vector2i(720, 1280)
	await process_frame
	await process_frame
	table.restart_training()
	await process_frame
	_touch(table.card.get_global_rect().get_center(), 0, true)
	await process_frame
	var touch_target: Vector2 = table.seats[0].get_drop_rect().get_center()
	_touch(table.card.get_global_rect().get_center(), 1, true)
	_touch_move(table.seats[2].get_drop_rect().get_center(), 1)
	_touch(table.seats[2].get_drop_rect().get_center(), 1, false)
	_check(table.round.dealt_count == 0 and table.card.dragging, "second finger must not steal or release the active card")
	_touch_move(touch_target, 0)
	_touch(touch_target, 0, false)
	await create_timer(0.25).timeout
	_check(table.round.dealt_count == 1 and table.seats[0].card_count == 1, "first-finger touch must deal normally")
	_touch(table.card.get_global_rect().get_center(), 0, true)
	_touch(table.seats[1].get_drop_rect().get_center(), 0, false, true)
	await process_frame
	_check(table.round.dealt_count == 1 and table.round.mistakes == 0 and not table.card.dragging, "OS canceled touch must not become a drop")
	_mouse_button(table.card.get_global_rect().get_center(), true)
	table.toggle_pause()
	var frozen_time: float = table.round.remaining
	_mouse_button(table.seats[1].get_drop_rect().get_center(), false)
	await create_timer(0.1).timeout
	_check(table.round.paused and table.round.remaining == frozen_time and table.round.dealt_count == 1, "pause must cancel drag, freeze time and reject release")
	table.toggle_pause()
	_mouse_button(table.card.get_global_rect().get_center(), true)
	table.restart_training()
	_mouse_button(table.seats[0].get_drop_rect().get_center(), false)
	await process_frame
	_check(table.round.dealt_count == 0 and table.round.phase == "ready", "stale release after restart must not deal")
	for seat_index in [0, 1, 2, 0, 1, 2]:
		await _mouse_drop(seat_index)
	_check(table.round.phase == "completed" and table.result_panel.visible, "last card must show training completion")
	for seat in table.seats:
		_check(seat.card_count == 2, "each NPC must receive exactly two cards")
	_mouse_button(table.card.get_global_rect().get_center(), true)
	_mouse_button(table.seats[0].get_drop_rect().get_center(), false)
	_check(table.round.dealt_count == 6, "input after completion must not add a seventh card")
	table.restart_training()
	for error_index in range(3):
		await _mouse_drop(2)
	_check(table.round.phase == "failed" and table.result_panel.visible, "three wrong-seat drops must show failure")
	table.restart_training()
	_mouse_button(table.card.get_global_rect().get_center(), true)
	table.round.remaining = 0.01
	await create_timer(0.06).timeout
	_mouse_button(table.seats[0].get_drop_rect().get_center(), false)
	_check(table.round.phase == "failed" and table.round.dealt_count == 0, "timeout while dragging must reject the later release")
	table.restart_training()
	_mouse_button(table.card.get_global_rect().get_center(), true)
	table.notification(MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT)
	_check(table.round.paused and not table.card.dragging, "focus loss must pause and return the card")
	table.toggle_pause()
	for viewport_size in [Vector2i(720, 1600), Vector2i(960, 1280), Vector2i(720, 1280)]:
		root.size = viewport_size
		table.restart_training()
		await process_frame
		await process_frame
		await _mouse_drop(0)
		_check(table.round.dealt_count == 1, "drop coordinates must follow the actual viewport layout")
	table.queue_free()
	await process_frame
	print("Table input: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)

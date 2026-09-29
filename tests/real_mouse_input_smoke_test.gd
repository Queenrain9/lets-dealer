extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var packed_scene: PackedScene = load("res://scenes/table_test.tscn") as PackedScene
	if packed_scene == null:
		_fail("table_test.tscn failed to load.")
		return

	var scene: Control = packed_scene.instantiate() as Control
	root.add_child(scene)
	await process_frame

	# Start the hand through the button's actual GUI signal path.
	var start_button: Button = scene.get_node("StartHandButton") as Button
	await _mouse_click(start_button.get_global_rect().get_center())
	await process_frame

	var game: DealerGameState = scene.get("game") as DealerGameState
	var card: DraggableCard = scene.get_node("CardDrag") as DraggableCard

	if game == null or card == null:
		_fail("Scene did not initialize gameplay state.")
		return

	if game.table.hand.phase != HandState.Phase.DEALING:
		_fail("Actual mouse click did not start the hand.")
		return

	for expected_count in range(1, 3):
		await _mouse_click(card.get_input_rect().get_center())
		await process_frame

		if game.table.hand.cards_dealt != expected_count:
			_fail(
				"Actual mouse input failed on deal %d. cards_dealt=%d."
				% [expected_count, game.table.hand.cards_dealt]
			)
			return

		if not card.visible:
			_fail("Next source card disappeared after actual mouse deal %d." % expected_count)
			return

	print("LET'S DEALER real mouse input smoke test passed.")
	scene.queue_free()
	quit(0)

func _mouse_click(position: Vector2) -> void:
	var press: InputEventMouseButton = InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = position
	press.global_position = position
	press.button_mask = MOUSE_BUTTON_MASK_LEFT
	Input.parse_input_event(press)
	await process_frame

	var release: InputEventMouseButton = InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.pressed = false
	release.position = position
	release.global_position = position
	release.button_mask = 0
	Input.parse_input_event(release)
	await process_frame

func _fail(message: String) -> void:
	push_error("LET'S DEALER real mouse input smoke test failed: " + message)
	quit(1)

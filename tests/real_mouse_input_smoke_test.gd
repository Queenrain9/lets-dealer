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

	# Headless Godot does not reliably route synthetic mouse events through GUI
	# Button focus/press handling, so start the hand directly. From this point on,
	# all card/chip interactions go through Input.parse_input_event and the same
	# _input path used by a real PC mouse.
	scene.call("_on_start_hand_pressed")
	await process_frame

	var game: DealerGameState = scene.get("game") as DealerGameState
	var card: DraggableCard = scene.get_node("CardDrag") as DraggableCard

	if game == null or card == null:
		_fail("Scene did not initialize gameplay state.")
		return

	if game.table.hand.phase != HandState.Phase.DEALING:
		_fail("Hand did not enter DEALING before real-input test.")
		return

	for expected_count in range(1, 9):
		await _mouse_click(card.get_input_rect().get_center())
		await process_frame

		if game.table.hand.cards_dealt != expected_count:
			_fail(
				"Actual mouse input failed on deal %d. cards_dealt=%d."
				% [expected_count, game.table.hand.cards_dealt]
			)
			return

	if game.table.hand.phase != HandState.Phase.BETTING_PREFLOP:
		_fail("Eight real mouse card actions did not reach COLLECT BETS.")
		return

	var chip_indices: Array[int] = [0, 1, 3]
	for chip_index in chip_indices:
		var chip: SwipeChipStack = scene.get_node(
			"TableSurface/ChipStack%d" % chip_index
		) as SwipeChipStack

		if chip == null or not chip.visible:
			_fail("Expected betting stack %d was not available." % chip_index)
			return

		await _mouse_click(chip.get_input_rect().get_center())
		await process_frame

	if game.table.hand.pot.main_pot != 100:
		_fail(
			"Actual mouse chip input did not create POT 100. Got %d."
			% game.table.hand.pot.main_pot
		)
		return

	if not game.all_bets_collected():
		_fail("Actual mouse chip input left pending bets.")
		return

	print("LET'S DEALER real mouse card/chip input smoke test passed.")
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

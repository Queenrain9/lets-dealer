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

	scene.call("_on_start_hand_pressed")
	await process_frame

	var game: DealerGameState = scene.get("game") as DealerGameState
	var card: DraggableCard = scene.get_node("CardDrag") as DraggableCard

	if game == null or card == null:
		_fail("Scene did not initialize gameplay state.")
		return

	for expected_count in range(1, 9):
		card.button_down.emit()
		await process_frame

		if game.table.hand.cards_dealt != expected_count:
			_fail(
				"Card button_down signal failed on deal %d. cards_dealt=%d."
				% [expected_count, game.table.hand.cards_dealt]
			)
			return

	if game.table.hand.phase != HandState.Phase.BETTING_PREFLOP:
		_fail("Eight native card Button actions did not reach COLLECT BETS.")
		return

	var chip_indices: Array[int] = [0, 1, 3]
	for chip_index in chip_indices:
		var chip: SwipeChipStack = scene.get_node(
			"TableSurface/ChipStack%d" % chip_index
		) as SwipeChipStack

		if chip == null or not chip.visible or chip.disabled:
			_fail("Expected betting Button %d was not available." % chip_index)
			return

		chip.button_down.emit()
		await process_frame

	if game.table.hand.pot.main_pot != 100:
		_fail(
			"Chip button_down signals did not create POT 100. Got %d."
			% game.table.hand.pot.main_pot
		)
		return

	if not game.all_bets_collected():
		_fail("Chip button_down signals left pending bets.")
		return

	print("LET'S DEALER button-down card/chip signal test passed.")
	scene.queue_free()
	quit(0)

func _fail(message: String) -> void:
	push_error("LET'S DEALER button-down signal test failed: " + message)
	quit(1)

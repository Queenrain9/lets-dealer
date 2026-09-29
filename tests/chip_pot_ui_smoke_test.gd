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
	if game == null:
		_fail("DealerGameState was not initialized.")
		return

	while game.table.hand.phase == HandState.Phase.DEALING:
		var seat_index: int = game.expected_deal_seat()
		if not game.try_deal_card_to_seat(seat_index):
			_fail("Could not finish dealing before chip test.")
			return

	await process_frame

	var chip0: SwipeChipStack = scene.get_node(
		"TableSurface/ChipStack0"
	) as SwipeChipStack
	var chip1: SwipeChipStack = scene.get_node(
		"TableSurface/ChipStack1"
	) as SwipeChipStack
	var chip2: SwipeChipStack = scene.get_node(
		"TableSurface/ChipStack2"
	) as SwipeChipStack
	var chip3: SwipeChipStack = scene.get_node(
		"TableSurface/ChipStack3"
	) as SwipeChipStack
	var pot_label: Label = scene.get_node("TableSurface/PotLabel") as Label
	var advance_button: Button = scene.get_node("AdvanceButton") as Button

	if not chip0.visible or not chip1.visible or chip2.visible or not chip3.visible:
		_fail("Betting chip visibility did not match the prototype scenario.")
		return

	if not advance_button.disabled:
		_fail("OPEN FLOP was enabled before chip collection finished.")
		return

	var active_chips: Array[SwipeChipStack] = [chip0, chip1, chip3]
	for chip_stack in active_chips:
		var start_position: Vector2 = chip_stack.get_global_rect().get_center()
		var pot_center: Vector2 = pot_label.get_global_rect().get_center()
		var direction: Vector2 = (pot_center - start_position).normalized()
		var end_position: Vector2 = start_position + (direction * 100.0)

		scene.call(
			"_on_chip_sweep_released",
			chip_stack.seat_index,
			start_position,
			end_position
		)
		await process_frame

	if game.table.hand.pot.main_pot != 100:
		_fail("Expected UI collection to produce POT 100.")
		return

	if not game.all_bets_collected():
		_fail("UI collection left pending betting chips.")
		return

	if advance_button.disabled:
		_fail("OPEN FLOP did not enable after all chips were collected.")
		return

	if pot_label.text != "POT  100":
		_fail("Pot label did not reflect the collected amount.")
		return

	print("LET'S DEALER chip and pot UI smoke test passed.")
	scene.queue_free()
	quit(0)

func _fail(message: String) -> void:
	push_error("LET'S DEALER chip/pot UI smoke test failed: " + message)
	quit(1)

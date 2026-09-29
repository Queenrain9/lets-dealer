extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var packed: PackedScene = load(
		"res://scenes/dealer_vertical_slice.tscn"
	) as PackedScene
	if packed == null:
		_fail("dealer vertical slice scene failed to load.")
		return

	var scene: Control = packed.instantiate() as Control
	root.add_child(scene)
	await process_frame

	var game: DealerGameState = scene.get("game") as DealerGameState
	var build_label: Label = scene.get_node("TopBar/BuildLabel") as Label
	var start_button: Button = scene.get_node("DealerDock/StartButton") as Button
	var deal_button: Button = scene.get_node("DealerDock/DealButton") as Button
	var action_button: Button = scene.get_node("DealerDock/ActionButton") as Button
	var pot_label: Label = scene.get_node("Table/PotLabel") as Label
	var result_panel: PanelContainer = scene.get_node("ResultPanel") as PanelContainer

	if build_label.text != "BUILD · vertical-slice-003":
		_fail("Vertical slice build stamp mismatch.")
		return

	start_button.button_down.emit()
	await process_frame

	if game.table.hand.phase != HandState.Phase.DEALING:
		_fail("START HAND did not enter DEALING.")
		return

	for expected_count in range(1, 13):
		deal_button.button_down.emit()
		await process_frame
		if game.table.hand.cards_dealt != expected_count:
			_fail(
				"Deal button failed at card %d. cards_dealt=%d."
				% [expected_count, game.table.hand.cards_dealt]
			)
			return

	if game.table.hand.phase != HandState.Phase.BETTING_PREFLOP:
		_fail("12 cards did not enter COLLECT BETS.")
		return

	var chip_indices: Array[int] = [0, 1, 2, 4, 5]
	for chip_index in chip_indices:
		var chip: Button = scene.get_node("Table/Chip%d" % chip_index) as Button
		if chip == null or not chip.visible or chip.disabled:
			_fail("Expected betting chip %d was not active." % chip_index)
			return
		chip.button_down.emit()
		await process_frame

	if game.table.hand.pot.main_pot != 7400:
		_fail("Expected POT 7,400, got %d." % game.table.hand.pot.main_pot)
		return

	if pot_label.text != "POT 7,400":
		_fail("Visible pot label did not show 7,400.")
		return

	if action_button.disabled or not action_button.visible:
		_fail("OPEN FLOP was not ready after collecting all bets.")
		return

	for _index in range(6):
		action_button.button_down.emit()
		await process_frame

	if game.table.hand.phase != HandState.Phase.COMPLETE:
		_fail("Vertical slice did not reach COMPLETE.")
		return

	if game.table.hand.board.size() != 5:
		_fail("Expected five board cards.")
		return

	if not result_panel.visible:
		_fail("Result panel did not appear after payout.")
		return

	print("LET'S DEALER vertical slice smoke test passed.")
	scene.queue_free()
	quit(0)

func _fail(message: String) -> void:
	push_error("LET'S DEALER vertical slice smoke test failed: " + message)
	quit(1)

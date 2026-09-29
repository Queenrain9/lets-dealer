extends SceneTree

func _init() -> void:
	var exit_code := _run()
	quit(exit_code)

func _run() -> int:
	var table_config := load("res://data/table_configs/prototype_table.tres") as TableConfig
	if table_config == null:
		return _fail("Prototype TableConfig failed to load.")

	var game := DealerGameState.new()
	game.configure(table_config)
	game.start_hand()

	var dealt_count := 0
	var expected_total := table_config.seat_count * table_config.cards_per_player

	while game.table.hand.phase == HandState.Phase.DEALING:
		var seat_index := game.expected_deal_seat()
		if seat_index < 0:
			return _fail("DealerGameState returned an invalid expected seat.")
		if not game.try_deal_card_to_seat(seat_index):
			return _fail("A valid card deal was rejected.")

		dealt_count += 1
		if dealt_count > expected_total:
			return _fail("Dealing loop exceeded expected card count.")

	if dealt_count != expected_total:
		return _fail("Expected %d dealt cards, got %d." % [expected_total, dealt_count])

	if game.table.hand.phase != HandState.Phase.BETTING_PREFLOP:
		return _fail("Hand did not enter BETTING_PREFLOP after dealing.")

	for _step in range(6):
		game.advance_prototype_phase()

	if game.table.hand.board.size() != 5:
		return _fail("Expected 5 board cards, got %d." % game.table.hand.board.size())

	if game.table.hand.phase != HandState.Phase.COMPLETE:
		return _fail("Hand did not reach COMPLETE.")

	if game.result.mistakes != 0:
		return _fail("Smoke test unexpectedly recorded a mistake.")

	if game.result.perfect_actions != dealt_count:
		return _fail("Perfect action count does not match dealt card count.")

	print("LET'S DEALER core smoke test passed.")
	return 0

func _fail(message: String) -> int:
	push_error("LET'S DEALER smoke test failed: " + message)
	return 1

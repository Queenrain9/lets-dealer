extends SceneTree

func _init() -> void:
	var exit_code: int = _run()
	quit(exit_code)

func _run() -> int:
	var table_config: TableConfig = load(
		"res://data/table_configs/prototype_table.tres"
	) as TableConfig
	var hand_config: PrototypeHandConfig = load(
		"res://data/prototype_hands/core_hand_01.tres"
	) as PrototypeHandConfig

	if table_config == null or hand_config == null:
		return _fail("Prototype gameplay configuration failed to load.")

	var game: DealerGameState = DealerGameState.new()
	game.configure(table_config)
	game.configure_prototype_hand(hand_config)
	game.start_hand()

	var dealt_count: int = 0
	var expected_total: int = table_config.seat_count * table_config.cards_per_player

	while game.table.hand.phase == HandState.Phase.DEALING:
		var seat_index: int = game.expected_deal_seat()
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

	if game.pending_bet_total() != 100:
		return _fail("Expected 100 in pending bets.")

	if game.advance_prototype_phase():
		return _fail("Flop advanced before all betting chips were collected.")

	var collected_count: int = 0
	for seat_index in range(game.table.seats.size()):
		var seat: PlayerSeat = game.table.get_seat(seat_index)
		if seat.current_bet > 0:
			if not game.try_collect_bet_from_seat(seat_index):
				return _fail("A valid chip collection was rejected.")
			collected_count += 1

	if collected_count != 3:
		return _fail("Expected three betting stacks to collect.")

	if game.table.hand.pot.main_pot != 100:
		return _fail("Expected main pot 100, got %d." % game.table.hand.pot.main_pot)

	if not game.all_bets_collected():
		return _fail("Pending bets remained after collection.")

	for _step in range(6):
		if not game.advance_prototype_phase():
			return _fail("A valid prototype phase advance was rejected.")

	if game.table.hand.board.size() != 5:
		return _fail("Expected 5 board cards, got %d." % game.table.hand.board.size())

	if game.table.hand.phase != HandState.Phase.COMPLETE:
		return _fail("Hand did not reach COMPLETE.")

	if game.result.mistakes != 0:
		return _fail("Smoke test unexpectedly recorded a mistake.")

	if game.result.perfect_actions != dealt_count + collected_count:
		return _fail("Perfect action count does not match completed dealer actions.")

	print("LET'S DEALER core smoke test passed.")
	return 0

func _fail(message: String) -> int:
	push_error("LET'S DEALER smoke test failed: " + message)
	return 1

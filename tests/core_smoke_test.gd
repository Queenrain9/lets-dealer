extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var table_config := load("res://data/table_configs/prototype_table.tres") as TableConfig
	assert(table_config != null)

	var game := DealerGameState.new()
	game.configure(table_config)
	game.start_hand()

	var dealt_count := 0
	while game.table.hand.phase == HandState.Phase.DEALING:
		var seat_index := game.expected_deal_seat()
		assert(seat_index >= 0)
		assert(game.try_deal_card_to_seat(seat_index))
		dealt_count += 1
		assert(dealt_count <= table_config.seat_count * table_config.cards_per_player)

	assert(dealt_count == table_config.seat_count * table_config.cards_per_player)
	assert(game.table.hand.phase == HandState.Phase.BETTING_PREFLOP)

	for _step in range(6):
		game.advance_prototype_phase()

	assert(game.table.hand.board.size() == 5)
	assert(game.table.hand.phase == HandState.Phase.COMPLETE)
	assert(game.result.mistakes == 0)
	assert(game.result.perfect_actions == dealt_count)

	print("LET'S DEALER core smoke test passed.")
	quit(0)

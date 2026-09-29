extends Resource
class_name DealerGameState

signal phase_changed(phase: int)
signal expected_deal_seat_changed(seat_index: int)
signal card_dealt(seat_index: int, card_id: String)
signal betting_ready
signal bet_collected(seat_index: int, amount: int, pot_total: int)
signal mistake_recorded(reason: String)
signal hand_completed(result: SessionResult)

var table: PokerTableState = PokerTableState.new()
var result: SessionResult = SessionResult.new()
var prototype_hand_config: PrototypeHandConfig

var _deal_order: Array[int] = []
var _deal_cursor: int = 0

func configure(table_config: TableConfig) -> void:
	table.setup(table_config)

func configure_prototype_hand(hand_config: PrototypeHandConfig) -> void:
	prototype_hand_config = hand_config

func start_hand() -> void:
	if table.config == null:
		push_error("DealerGameState requires a TableConfig before starting a hand.")
		return

	var next_hand_number: int = table.hand.hand_number + 1
	table.reset_for_new_hand(next_hand_number, _build_shuffled_deck())
	result.begin_hand(next_hand_number)

	_deal_order.clear()
	for _round_index in range(table.config.cards_per_player):
		for seat_index in range(table.config.seat_count):
			_deal_order.append(seat_index)

	_deal_cursor = 0
	_set_phase(HandState.Phase.DEALING)
	_emit_expected_deal_seat()

func try_deal_card_to_seat(seat_index: int) -> bool:
	if table.hand.phase != HandState.Phase.DEALING:
		return false

	if _deal_cursor >= _deal_order.size():
		return false

	var expected_seat: int = _deal_order[_deal_cursor]
	if seat_index != expected_seat:
		_record_mistake("Wrong seat. Expected seat %d." % (expected_seat + 1))
		return false

	if table.hand.deck.is_empty():
		push_error("Prototype deck ran out of cards.")
		return false

	var card_id: String = String(table.hand.deck.pop_back())
	var seat: PlayerSeat = table.get_seat(seat_index)
	if seat == null:
		return false

	seat.receive_card(card_id)
	table.hand.cards_dealt += 1
	_record_success()
	card_dealt.emit(seat_index, card_id)

	_deal_cursor += 1
	if _deal_cursor >= _deal_order.size():
		expected_deal_seat_changed.emit(-1)
		_set_phase(HandState.Phase.BETTING_PREFLOP)
		_prepare_prototype_betting()
	else:
		_emit_expected_deal_seat()

	return true

func try_collect_bet_from_seat(seat_index: int) -> bool:
	if table.hand.phase != HandState.Phase.BETTING_PREFLOP:
		return false

	var seat: PlayerSeat = table.get_seat(seat_index)
	if seat == null or seat.current_bet <= 0:
		_record_mistake("There are no chips to collect from Player %d." % (seat_index + 1))
		return false

	var amount: int = seat.collect_current_bet()
	table.hand.pot.collect_main_pot(amount)
	_record_success()
	bet_collected.emit(seat_index, amount, table.hand.pot.total_amount())
	return true

func all_bets_collected() -> bool:
	for seat in table.seats:
		if seat.current_bet > 0:
			return false
	return true

func pending_bet_total() -> int:
	var total: int = 0
	for seat in table.seats:
		total += seat.current_bet
	return total

func advance_prototype_phase() -> bool:
	match table.hand.phase:
		HandState.Phase.BETTING_PREFLOP:
			if not all_bets_collected():
				return false
			_deal_board_cards(3)
			_set_phase(HandState.Phase.FLOP)
		HandState.Phase.FLOP:
			_deal_board_cards(1)
			_set_phase(HandState.Phase.TURN)
		HandState.Phase.TURN:
			_deal_board_cards(1)
			_set_phase(HandState.Phase.RIVER)
		HandState.Phase.RIVER:
			_set_phase(HandState.Phase.SHOWDOWN)
		HandState.Phase.SHOWDOWN:
			_set_phase(HandState.Phase.PAYOUT)
		HandState.Phase.PAYOUT:
			_set_phase(HandState.Phase.COMPLETE)
			result.finish()
			hand_completed.emit(result)
		_:
			return false

	return true

func peek_next_card() -> String:
	if table.hand.deck.is_empty():
		return ""
	return table.hand.deck.back()

func expected_deal_seat() -> int:
	if table.hand.phase != HandState.Phase.DEALING:
		return -1
	if _deal_cursor < 0 or _deal_cursor >= _deal_order.size():
		return -1
	return _deal_order[_deal_cursor]

func get_phase_label() -> String:
	match table.hand.phase:
		HandState.Phase.IDLE:
			return "IDLE"
		HandState.Phase.DEALING:
			return "DEALING"
		HandState.Phase.BETTING_PREFLOP:
			return "COLLECT BETS"
		HandState.Phase.FLOP:
			return "FLOP"
		HandState.Phase.TURN:
			return "TURN"
		HandState.Phase.RIVER:
			return "RIVER"
		HandState.Phase.SHOWDOWN:
			return "SHOWDOWN (placeholder)"
		HandState.Phase.PAYOUT:
			return "PAYOUT (placeholder)"
		HandState.Phase.COMPLETE:
			return "COMPLETE"
		_:
			return "UNKNOWN"

func _prepare_prototype_betting() -> void:
	if prototype_hand_config == null:
		push_error("PrototypeHandConfig is required for the betting prototype.")
		return

	for seat_index in range(table.seats.size()):
		var seat: PlayerSeat = table.seats[seat_index]
		seat.folded = prototype_hand_config.seat_is_folded(seat_index)

		var requested_bet: int = prototype_hand_config.bet_for_seat(seat_index)
		if not seat.folded and requested_bet > 0:
			seat.post_bet(requested_bet)

	betting_ready.emit()

func _record_success() -> void:
	result.register_success()
	table.hand.perfect_actions = result.perfect_actions
	table.hand.combo = result.combo

func _record_mistake(reason: String) -> void:
	result.register_mistake()
	table.hand.mistakes = result.mistakes
	table.hand.combo = result.combo
	mistake_recorded.emit(reason)

func _set_phase(new_phase: HandState.Phase) -> void:
	table.hand.phase = new_phase
	phase_changed.emit(int(new_phase))

func _emit_expected_deal_seat() -> void:
	expected_deal_seat_changed.emit(expected_deal_seat())

func _deal_board_cards(count: int) -> void:
	for _index in range(count):
		if table.hand.deck.is_empty():
			return
		table.hand.board.append(String(table.hand.deck.pop_back()))

func _build_shuffled_deck() -> Array[String]:
	var deck: Array[String] = []
	var ranks: Array[String] = ["2", "3", "4", "5", "6", "7", "8", "9", "T", "J", "Q", "K", "A"]
	var suits: Array[String] = ["C", "D", "H", "S"]

	for suit in suits:
		for rank in ranks:
			deck.append(rank + suit)

	deck.shuffle()
	return deck

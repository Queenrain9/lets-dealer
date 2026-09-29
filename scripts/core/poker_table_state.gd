extends Resource
class_name PokerTableState

var config: TableConfig
var seats: Array[PlayerSeat] = []
var hand: HandState = HandState.new()

func setup(table_config: TableConfig) -> void:
	config = table_config
	seats.clear()

	for seat_index in range(config.seat_count):
		var seat := PlayerSeat.new()
		seat.setup(
			seat_index,
			"Player %d" % (seat_index + 1),
			config.starting_stack
		)
		seats.append(seat)

func reset_for_new_hand(hand_number: int, shuffled_deck: Array[String]) -> void:
	for seat in seats:
		seat.reset_for_hand()
	hand.reset(hand_number, shuffled_deck)

func get_seat(seat_index: int) -> PlayerSeat:
	if seat_index < 0 or seat_index >= seats.size():
		return null
	return seats[seat_index]

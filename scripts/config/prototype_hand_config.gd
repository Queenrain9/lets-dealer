extends Resource
class_name PrototypeHandConfig

@export var preflop_bets: PackedInt32Array = PackedInt32Array([20, 40, 0, 40])
@export var folded_seats: PackedInt32Array = PackedInt32Array([2])

func bet_for_seat(seat_index: int) -> int:
	if seat_index < 0 or seat_index >= preflop_bets.size():
		return 0
	return int(preflop_bets[seat_index])

func seat_is_folded(seat_index: int) -> bool:
	return folded_seats.has(seat_index)

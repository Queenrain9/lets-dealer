extends RefCounted
class_name DealerTableState

var seat_count: int = 6
var street: String = "preflop"
var button_seat: int = 0
var small_blind_seat: int = 1
var big_blind_seat: int = 2
var small_blind: int = 300
var big_blind: int = 600

var stacks: Array[int] = []
var street_contributions: Array[int] = []
var total_contributions: Array[int] = []
var folded: Array[bool] = []
var all_in: Array[bool] = []


func _init(count: int = 6) -> void:
	seat_count = count
	_resize_state()


func begin_hand(
	starting_stacks: Array[int],
	dealer_button: int,
	sb_amount: int = 300,
	bb_amount: int = 600
) -> void:
	seat_count = starting_stacks.size()
	_resize_state()
	for i in range(seat_count):
		stacks[i] = maxi(starting_stacks[i], 0)

	button_seat = _wrap_seat(dealer_button)
	small_blind_seat = _wrap_seat(button_seat + 1)
	big_blind_seat = _wrap_seat(button_seat + 2)
	small_blind = maxi(sb_amount, 0)
	big_blind = maxi(bb_amount, 0)
	street = "preflop"

	if small_blind > 0:
		_commit_chips(small_blind_seat, small_blind)
	if big_blind > 0:
		_commit_chips(big_blind_seat, big_blind)


func begin_street(next_street: String) -> void:
	street = next_street
	for i in range(seat_count):
		street_contributions[i] = 0


func apply_action(seat: int, state_text: String, target_contribution: int) -> int:
	if not _valid_seat(seat):
		return 0

	var upper: String = state_text.to_upper()
	if upper.begins_with("FOLD"):
		folded[seat] = true
		return 0

	if folded[seat]:
		return 0

	var committed: int = 0
	if target_contribution > street_contributions[seat]:
		committed = _commit_chips(seat, target_contribution - street_contributions[seat])

	if upper.begins_with("ALL IN") or stacks[seat] <= 0:
		all_in[seat] = true

	return committed


func payout(seat: int, amount: int) -> void:
	if not _valid_seat(seat):
		return
	stacks[seat] += maxi(amount, 0)


func pot_total() -> int:
	var total: int = 0
	for value in total_contributions:
		total += value
	return total


func street_total() -> int:
	var total: int = 0
	for value in street_contributions:
		total += value
	return total


func has_street_chips() -> bool:
	return street_total() > 0


func contribution_for(seat: int) -> int:
	if not _valid_seat(seat):
		return 0
	return street_contributions[seat]


func stack_for(seat: int) -> int:
	if not _valid_seat(seat):
		return 0
	return stacks[seat]


func position_for(seat: int) -> String:
	if seat == button_seat:
		return "D"
	if seat == small_blind_seat:
		return "SB"
	if seat == big_blind_seat:
		return "BB"
	return ""


func pot_layers() -> Array[Dictionary]:
	var levels: Array[int] = []
	for value in total_contributions:
		if value > 0 and not levels.has(value):
			levels.append(value)
	levels.sort()

	var raw_layers: Array[Dictionary] = []
	var previous: int = 0
	for level in levels:
		var contributors: int = 0
		var eligible: Array[int] = []
		for seat in range(seat_count):
			if total_contributions[seat] >= level:
				contributors += 1
				if not folded[seat]:
					eligible.append(seat)

		var amount: int = (level - previous) * contributors
		previous = level
		if amount <= 0 or eligible.is_empty():
			continue

		raw_layers.append({
			"amount": amount,
			"eligible": eligible,
			"cap": level,
		})

	var merged: Array[Dictionary] = []
	for layer in raw_layers:
		if not merged.is_empty():
			var previous_layer: Dictionary = merged[merged.size() - 1]
			if _same_seats(
				previous_layer.get("eligible", []) as Array,
				layer.get("eligible", []) as Array
			):
				previous_layer["amount"] = int(previous_layer.get("amount", 0)) + int(layer.get("amount", 0))
				previous_layer["cap"] = int(layer.get("cap", 0))
				continue
		merged.append(layer.duplicate(true))

	return merged


func main_pot_amount() -> int:
	var layers: Array[Dictionary] = pot_layers()
	if layers.is_empty():
		return 0
	return int(layers[0].get("amount", 0))


func side_pot_amount() -> int:
	var layers: Array[Dictionary] = pot_layers()
	var amount: int = 0
	for i in range(1, layers.size()):
		amount += int(layers[i].get("amount", 0))
	return amount


func _commit_chips(seat: int, requested: int) -> int:
	if not _valid_seat(seat) or requested <= 0 or folded[seat]:
		return 0
	var amount: int = mini(requested, stacks[seat])
	stacks[seat] -= amount
	street_contributions[seat] += amount
	total_contributions[seat] += amount
	if stacks[seat] <= 0:
		all_in[seat] = true
	return amount


func _resize_state() -> void:
	stacks.clear()
	street_contributions.clear()
	total_contributions.clear()
	folded.clear()
	all_in.clear()
	for _i in range(seat_count):
		stacks.append(0)
		street_contributions.append(0)
		total_contributions.append(0)
		folded.append(false)
		all_in.append(false)


func _same_seats(a: Array, b: Array) -> bool:
	if a.size() != b.size():
		return false
	for i in range(a.size()):
		if int(a[i]) != int(b[i]):
			return false
	return true


func _valid_seat(seat: int) -> bool:
	return seat >= 0 and seat < seat_count


func _wrap_seat(seat: int) -> int:
	if seat_count <= 0:
		return 0
	return posmod(seat, seat_count)

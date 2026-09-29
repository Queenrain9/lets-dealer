extends Resource
class_name PotState

var main_pot: int = 0
var side_pots: Array[Dictionary] = []

func reset() -> void:
	main_pot = 0
	side_pots.clear()

func total_amount() -> int:
	var total := main_pot
	for side_pot in side_pots:
		total += int(side_pot.get("amount", 0))
	return total

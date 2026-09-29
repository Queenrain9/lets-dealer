extends Resource
class_name PlayerSeat

var seat_index: int = 0
var display_name: String = ""
var stack: int = 0
var current_bet: int = 0
var hole_cards: Array[String] = []
var folded: bool = false
var all_in: bool = false

func setup(index: int, name: String, starting_stack: int) -> void:
	seat_index = index
	display_name = name
	stack = starting_stack
	reset_for_hand()

func reset_for_hand() -> void:
	current_bet = 0
	hole_cards.clear()
	folded = false
	all_in = false

func receive_card(card_id: String) -> void:
	hole_cards.append(card_id)

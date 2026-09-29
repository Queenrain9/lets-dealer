extends Resource
class_name PlayerSeat

var seat_index: int = 0
var display_name: String = ""
var stack: int = 0
var current_bet: int = 0
var hand_contribution: int = 0
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
	hand_contribution = 0
	hole_cards.clear()
	folded = false
	all_in = false

func receive_card(card_id: String) -> void:
	hole_cards.append(card_id)

func post_bet(amount: int) -> int:
	var safe_amount: int = clampi(amount, 0, stack)
	current_bet += safe_amount
	hand_contribution += safe_amount
	stack -= safe_amount
	if stack == 0 and safe_amount > 0:
		all_in = true
	return safe_amount

func collect_current_bet() -> int:
	var amount: int = current_bet
	current_bet = 0
	return amount

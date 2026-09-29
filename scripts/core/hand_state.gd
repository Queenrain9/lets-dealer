extends Resource
class_name HandState

enum Phase {
	IDLE,
	DEALING,
	BETTING_PREFLOP,
	FLOP,
	TURN,
	RIVER,
	SHOWDOWN,
	PAYOUT,
	COMPLETE,
}

var hand_number: int = 0
var phase: Phase = Phase.IDLE
var deck: Array[String] = []
var board: Array[String] = []
var pot: PotState = PotState.new()

var cards_dealt: int = 0
var mistakes: int = 0
var combo: int = 0
var perfect_actions: int = 0

func reset(new_hand_number: int, shuffled_deck: Array[String]) -> void:
	hand_number = new_hand_number
	phase = Phase.IDLE
	deck = shuffled_deck.duplicate()
	board.clear()
	pot.reset()
	cards_dealt = 0
	mistakes = 0
	combo = 0
	perfect_actions = 0

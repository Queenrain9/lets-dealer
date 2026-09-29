extends Resource
class_name SessionResult

var hand_number: int = 0
var started_at_msec: int = 0
var finished_at_msec: int = 0
var perfect_actions: int = 0
var mistakes: int = 0
var combo: int = 0
var max_combo: int = 0

func begin_hand(new_hand_number: int) -> void:
	hand_number = new_hand_number
	started_at_msec = Time.get_ticks_msec()
	finished_at_msec = 0
	perfect_actions = 0
	mistakes = 0
	combo = 0
	max_combo = 0

func register_success() -> void:
	perfect_actions += 1
	combo += 1
	max_combo = max(max_combo, combo)

func register_mistake() -> void:
	mistakes += 1
	combo = 0

func finish() -> void:
	finished_at_msec = Time.get_ticks_msec()

func elapsed_seconds() -> float:
	if started_at_msec <= 0:
		return 0.0
	var end_time := finished_at_msec if finished_at_msec > 0 else Time.get_ticks_msec()
	return float(end_time - started_at_msec) / 1000.0

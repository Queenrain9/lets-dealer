extends RefCounted
## UI-independent rules for the first card-dealing exercise.

const SEAT_COUNT: int = 3
const TOTAL_CARDS: int = 6
const TIME_LIMIT: float = 60.0
const MAX_MISTAKES: int = 3

var phase: String = "ready"
var dealt_count: int = 0
var mistakes: int = 0
var remaining: float = TIME_LIMIT
var paused: bool = false

func start() -> void:
	if phase == "ready" and not paused:
		phase = "active"

func expected_seat() -> int:
	if phase == "completed" or phase == "failed":
		return -1
	return dealt_count % SEAT_COUNT

func attempt_drop(seat_index: int) -> String:
	if phase != "active" or paused:
		return "inactive"
	if seat_index < 0 or seat_index >= SEAT_COUNT:
		return "outside"
	if seat_index != expected_seat():
		mistakes += 1
		if mistakes >= MAX_MISTAKES:
			phase = "failed"
		return "wrong_seat"
	dealt_count += 1
	if dealt_count == TOTAL_CARDS:
		phase = "completed"
	return "accepted"

func tick(delta: float) -> void:
	if phase != "active" or paused:
		return
	remaining = maxf(0.0, remaining - maxf(0.0, delta))
	if remaining <= 0.0:
		phase = "failed"

func set_paused(value: bool) -> void:
	if phase == "ready" or phase == "active":
		paused = value

func accuracy() -> int:
	var attempts: int = dealt_count + mistakes
	if attempts == 0:
		return 100
	return roundi(100.0 * float(dealt_count) / float(attempts))

func reset() -> void:
	phase = "ready"
	dealt_count = 0
	mistakes = 0
	remaining = TIME_LIMIT
	paused = false
